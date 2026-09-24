#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the two tables in docs/updates/trainers/PARTIES.md.

  parties        data/trainers/parties.asm. One row per party, keyed by the
                 (trainer class, party number) pair a map script hands to
                 wTrainerClass/wTrainerNo. The pointer table at the top of the
                 asm is what maps a label to a class, so it's read rather than
                 assumed from the label's name. Rows are ordered by where the
                 battle happens, following data/maps/town_map_order.asm - see
                 town_map_rank() for how a location comment gets there.
  special-moves  data/trainers/special_moves.asm, joined against the parties so
                 each entry names the Pokemon it's overwriting a move on - the
                 asm only knows it by party slot, which is unreadable on its own.

Only the tables between the generated: markers are rewritten; the prose around
them stays.

Usage:
  gen_parties_doc.py            rewrite the tables in place
  gen_parties_doc.py --check    exit nonzero if a table is stale (no write)
  gen_parties_doc.py --stdout   print the generated tables only
"""

import os
import re
import sys

import docgen

TRAINER_CONSTANTS_ASM = docgen.path("constants", "trainer_constants.asm")
MAP_CONSTANTS_ASM = docgen.path("constants", "map_constants.asm")
PARTIES_ASM = docgen.path("data", "trainers", "parties.asm")
SPECIAL_MOVES_ASM = docgen.path("data", "trainers", "special_moves.asm")
TOWN_MAP_ENTRIES_ASM = docgen.path("data", "maps", "town_map_entries.asm")
TOWN_MAP_ORDER_ASM = docgen.path("data", "maps", "town_map_order.asm")
PARTIES_DOC = docgen.path("docs", "updates", "trainers", "PARTIES.md")

PARTY_COLUMNS = ("Class", "Location", "Lv", "Party", "Notes")
MOVE_COLUMNS = ("Class", "Party", "Slot", "Pokémon", "Move #", "Move")

PARTY_LENGTH = 6  # constants/pokemon_constants.asm
NUM_MOVES = 4

LABEL_RE = re.compile(r"^(\w+):")
POINTER_RE = re.compile(r"^\s*dw\s+(\w+)\s*(?:;.*)?$")
COMMENT_RE = re.compile(r"^\s*;\s*(.*?)\s*$")
# `db ...` with the trailing comment, if any, captured separately.
DB_RE = re.compile(r"^\s*db\s+([^;]*?)\s*(?:;\s*(.*?)\s*)?$")

# Parties whose first byte isn't one of these are read as "the whole team shares
# this level". $FE is a typo for $FE-shaped data the engine never checks for -
# see the Quirks section of the doc - but the bytes after it are level/species
# pairs, so it's parsed as one.
PAIRED_HEADERS = ("$FF", "$FE")

# Parties under this comment are left out of the doc - nothing on any map points
# at them. Every other party has to resolve to a map, or it would be dropped
# without anyone noticing.
UNPLACED = ("Unused",)

# The boss of a place sorts last there, however the class ids fall. Giovanni is
# in for Viridian Gym and stays the last Rocket at the Game Corner and in Silph
# Co.; Rival3 is in so the champion ends the table.
BOSS_CLASSES = ("BROCK", "MISTY", "LT_SURGE", "ERIKA", "KOGA", "BLAINE", "SABRINA",
                "GIOVANNI", "RIVAL3")

# The town map's order isn't the order the game is played in. Each entry pins
# every party at a location next to a map from town_map_order.asm: -0.5 puts it
# in just before that map's trainers, +0.5 just after.
PINNED_LOCATIONS = {
	# You're sent down Route 11 on the way out of Vermilion, long before the town
	# map's order gets to it - it sits between Saffron and Route 12 there.
	"Route 11": ("ROUTE_6", +0.5),
	# The gym is only open once you've cleared the S.S. Anne and cut the tree.
	"Vermilion Gym": ("SS_ANNE_1F", +0.5),
	# Giovanni's gym is an endgame stop, not the second town you walk into.
	"Viridian Gym": ("ROUTE_22", -0.5),
}

# Inside one place, locations run in map id order - which walks Silph Co. and the
# Pokemon Mansion floor by floor - and the gym is always the last stop in its
# city. These are the stops the map ids get wrong, in the order they should run.
# A listed location comes after the unlisted ones in its place.
LATE_LOCATIONS = (
	"SS Anne 2F",       # the rival is the last thing you do on the ship
	"Lorelei's Room",   # the Elite Four in the order you have to beat them,
	"Bruno's Room",
	"Agatha's Room",
	"Lance's Room",
	"Champion's Room",  # and the champion after them
)

# The same, for one party rather than everywhere a location is fought.
PINNED_PARTIES = {
	# Route 22 is otherwise endgame (Rival2), but the Rival1 battle there is the
	# second fight in the game, right after the one in Oak's lab.
	("RIVAL1", 2): ("PALLET_TOWN", +0.5),
}

# Location comments that aren't their map constant's name with the punctuation
# taken out. Only for the sort - the doc still prints the comment as written.
LOCATION_ALIASES = {
	"SS_ANNE_STERN": "SS_ANNE_B1F",
	"MANSION_2F": "POKEMON_MANSION_2F",
	"MANSION_3F": "POKEMON_MANSION_3F",
	"MANSION_B1F": "POKEMON_MANSION_B1F",
}


class Party:
	def __init__(self, header, mons, note, lineno):
		self.header = header   # "$FF"/"$FE", or None for a shared level
		self.mons = mons       # [(level, species constant)]
		self.note = note
		self.lineno = lineno
		self.location = None   # filled in by read_parties


def number(token, asm, lineno):
	"""A db field: decimal, $hex, or a sum of those (`75 + 128`)."""
	total = 0
	for term in token.split("+"):
		term = term.strip()
		try:
			total += int(term[1:], 16) if term.startswith("$") else int(term, 10)
		except ValueError:
			sys.exit("%s:%d: %r is not a number" % (asm, lineno, token))
	return total


def read_map_ids():
	"""({map constant: id}, the id the indoor maps start at)."""
	ids = {}
	value = 0
	first_indoor = None
	with open(MAP_CONSTANTS_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if line.startswith("DEF FIRST_INDOOR_MAP"):
				first_indoor = value
			elif line.startswith("map_const "):
				ids[line.split()[1].rstrip(",")] = value
				value += 1
	if first_indoor is None:
		sys.exit("%s: no FIRST_INDOOR_MAP" % MAP_CONSTANTS_ASM)
	return ids, first_indoor


def read_town_map_entries():
	"""(outdoor maps' town map coordinates by id, [(last map id, coordinates)]).

	Indoor maps aren't listed one by one: InternalMapEntries is a run of "every
	map up to this one sits here", which is why the second list is walked in
	order rather than indexed.
	"""
	external = []
	internal = []
	with open(TOWN_MAP_ENTRIES_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if line.startswith("external_map"):
				fields = [f.strip() for f in line[len("external_map"):].split(",")]
				external.append((int(fields[0]), int(fields[1])))
			elif line.startswith("internal_map"):
				fields = [f.strip() for f in line[len("internal_map"):].split(",")]
				internal.append((fields[0], (int(fields[1]), int(fields[2]))))
	if not external or not internal:
		sys.exit("%s: no town map entries" % TOWN_MAP_ENTRIES_ASM)
	return external, internal


def town_map_spot(map_name, maps):
	"""Where a map sits on the town map, as coordinates, or None if it's not a map.

	Two maps at the same spot are the same place as far as the town map is
	concerned - which is how Silph Co. ends up filed under Saffron City and the
	Elite Four's rooms under Indigo Plateau.
	"""
	ids, first_indoor, external, internal = maps
	if map_name not in ids:
		return None
	map_id = ids[map_name]
	if map_id < first_indoor:
		return external[map_id]
	for last_map, coordinates in internal:
		if last_map not in ids:
			sys.exit("%s: unknown map %s" % (TOWN_MAP_ENTRIES_ASM, last_map))
		if map_id <= ids[last_map]:
			return coordinates
	return None


def read_town_map_order(maps):
	"""{town map coordinates: how early the player gets there}."""
	rank = {}
	with open(TOWN_MAP_ORDER_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if not line.startswith("db "):
				continue
			map_name = line.split()[1]
			spot = town_map_spot(map_name, maps)
			if spot is None:
				sys.exit("%s: %s isn't on the town map" % (TOWN_MAP_ORDER_ASM, map_name))
			rank.setdefault(spot, len(rank))
	if not rank:
		sys.exit("%s: no maps listed" % TOWN_MAP_ORDER_ASM)
	return rank


def map_constant(location):
	"""The map a location comment names, as a constant.

	The comments are prose, so: a trailing parenthetical is commentary, a slash
	means the party is reused and the first map wins, and the rest is the
	constant with its punctuation stripped out.
	"""
	name = location.split("(")[0].split("/")[0].strip()
	name = name.replace("é", "E").replace("'", "")
	name = re.sub(r"[.\s-]+", "_", name.upper())
	return LOCATION_ALIASES.get(name, name)


def pinned_rank(pin, maps, rank):
	"""A (map, offset) pin, as a rank that sorts either side of that map's own."""
	map_name, offset = pin
	spot = town_map_spot(map_name, maps)
	if spot not in rank:
		sys.exit("%s isn't in %s - it can't be pinned to" %
		         (map_name, os.path.basename(TOWN_MAP_ORDER_ASM)))
	return rank[spot] + offset


def town_map_place(party, maps, rank):
	"""(how early in the game a party is fought, the map it's fought on).

	(None, None) if it's nowhere. A party is placed by the section comment above
	it, and failing that by its own trailing comment - which is what puts the
	four Jessie & James battles in their own places rather than together under
	that heading.
	"""
	for comment in (party.location, party.note):
		if comment is None or comment in UNPLACED:
			continue
		map_name = map_constant(comment)
		spot = town_map_spot(map_name, maps)
		if spot in rank:
			return rank[spot], map_name
	return None, None


def stop_order(location, map_name, maps):
	"""Where a location comes in its place's own sequence of stops.

	Map ids order the floors of a building the way you climb them; a gym is the
	last stop in its city; LATE_LOCATIONS covers the rest by hand.
	"""
	if location in LATE_LOCATIONS:
		return (1, LATE_LOCATIONS.index(location))
	map_id = maps[0][map_name]
	return (2 if map_name.endswith("_GYM") else 0, map_id)


def read_trainer_classes():
	"""The trainer class constants in id order, NOBODY ($00) included."""
	classes = []
	with open(TRAINER_CONSTANTS_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if line.startswith("trainer_const "):
				classes.append(line.split()[1])
	if not classes:
		sys.exit("no trainer classes found in %s" % TRAINER_CONSTANTS_ASM)
	return classes


def read_pointer_table():
	"""The labels in TrainerDataPointers, in order - index 0 is class $01."""
	labels = []
	in_table = False
	with open(PARTIES_ASM, encoding="utf-8") as f:
		for line in f:
			if line.startswith("TrainerDataPointers:"):
				in_table = True
			elif in_table:
				if line.lstrip().startswith("assert_table_length"):
					break
				match = POINTER_RE.match(line)
				if match:
					labels.append(match.group(1))
	if not labels:
		sys.exit("%s: no TrainerDataPointers table" % PARTIES_ASM)
	return labels


def parse_party(operand, note, asm, lineno):
	"""One `db` line, null terminator stripped, into a Party."""
	tokens = [token.strip() for token in operand.split(",")]
	if tokens[-1] != "0":
		sys.exit("%s:%d: party data isn't null-terminated" % (asm, lineno))
	tokens = tokens[:-1]

	header = None
	if tokens and tokens[0] in PAIRED_HEADERS:
		header = tokens[0]
		tokens = tokens[1:]

	if header:
		if not tokens or len(tokens) % 2:
			sys.exit("%s:%d: %s party wants level/species pairs, got %d fields" %
			         (asm, lineno, header, len(tokens)))
		mons = [(number(tokens[i], asm, lineno), tokens[i + 1])
		        for i in range(0, len(tokens), 2)]
	else:
		if len(tokens) < 2:
			sys.exit("%s:%d: party has a level but no species" % (asm, lineno))
		level = number(tokens[0], asm, lineno)
		mons = [(level, species) for species in tokens[1:]]

	if len(mons) > PARTY_LENGTH:
		sys.exit("%s:%d: %d Pokemon in one party (max %d)" %
		         (asm, lineno, len(mons), PARTY_LENGTH))
	return Party(header, mons, note, lineno)


def read_parties():
	"""{trainer class constant: [Party]}, in the pointer table's order.

	A comment on a line of its own is the location the parties below it are
	fought at, and holds until the next one; a comment trailing a `db` is a note
	about that party alone.
	"""
	classes = read_trainer_classes()
	labels = read_pointer_table()
	if len(labels) + 1 != len(classes):
		sys.exit("%d trainer classes but %d data pointers - the tables have drifted apart" %
		         (len(classes) - 1, len(labels)))
	class_for_label = dict(zip(labels, classes[1:]))

	parties = {name: [] for name in classes[1:]}
	defined = set()
	label = None
	location = None
	with open(PARTIES_ASM, encoding="utf-8") as f:
		for lineno, line in enumerate(f, 1):
			match = LABEL_RE.match(line)
			if match:
				defined.add(match.group(1))
				label = class_for_label.get(match.group(1))
				location = None
				continue
			if label is None:
				continue
			match = COMMENT_RE.match(line)
			if match:
				location = match.group(1)
				continue
			match = DB_RE.match(line)
			if match and match.group(1):
				party = parse_party(match.group(1), match.group(2), PARTIES_ASM, lineno)
				party.location = location
				parties[label].append(party)

	missing = [label for label in labels if label not in defined]
	if missing:
		sys.exit("%s: pointers to undefined %s" % (PARTIES_ASM, ", ".join(missing)))
	return parties


def build_parties(parties, maps, rank):
	"""Every reachable party, in the order the player walks into them.

	A place's trainers are grouped by the location they're fought at, so a gym's
	trainers stay together in front of their leader instead of interleaving with
	the rest of the city by class id. Ties keep the asm's own order, so a class's
	parties stay in party-number order within a location, except that the boss of
	a location is moved to the end of it.
	"""
	rows = []
	used = set()
	late = set()
	for name, class_parties in parties.items():
		for index, party in enumerate(class_parties, 1):
			if party.location in UNPLACED:
				continue
			where, map_name = town_map_place(party, maps, rank)
			if where is None:
				sys.exit("%s:%d: can't place %s party %d (%s) - the doc is ordered by "
				         "location, so add a comment naming the map, an entry to "
				         "LOCATION_ALIASES, or one to UNPLACED" %
				         (PARTIES_ASM, party.lineno, name, index,
				          party.location or "no location comment"))
			pin = PINNED_PARTIES.get((name, index)) or PINNED_LOCATIONS.get(party.location)
			if pin:
				used.add(pin)
				where = pinned_rank(pin, maps, rank)
			if party.location in LATE_LOCATIONS:
				late.add(party.location)
			levels = [level for level, _ in party.mons]
			if min(levels) == max(levels):
				level = "%d" % levels[0]
				members = ", ".join(species for _, species in party.mons)
			else:
				level = "%d-%d" % (min(levels), max(levels))
				members = ", ".join("%s %d" % (species, lvl) for lvl, species in party.mons)
			rows.append(((where, stop_order(party.location, map_name, maps),
			              name in BOSS_CLASSES),
			             [name, party.location, level, members, party.note or ""]))
	if not rows:
		sys.exit("no parties found in %s" % PARTIES_ASM)
	stale = [key for key, pin in list(PINNED_LOCATIONS.items()) + list(PINNED_PARTIES.items())
	         if pin not in used]
	stale += [location for location in LATE_LOCATIONS if location not in late]
	if stale:
		sys.exit("%s: nothing to order for %s - the location or party is gone" %
		         (PARTIES_ASM, ", ".join(str(key) for key in stale)))
	rows.sort(key=lambda row: row[0])
	return [row for _, row in rows]


def build_special_moves(parties):
	"""The SpecialTrainerMoves entries, each resolved to the Pokemon it edits."""
	rows = []
	trainer = None
	empty = True
	with open(SPECIAL_MOVES_ASM, encoding="utf-8") as f:
		for lineno, line in enumerate(f, 1):
			match = DB_RE.match(line)
			if not match or not match.group(1):
				continue
			fields = [field.strip() for field in match.group(1).split(",")]
			if trainer is None:
				if fields == ["-1"]:  # end of table
					break
				if len(fields) != 2:
					sys.exit("%s:%d: expected `db class, party`, got %r" %
					         (SPECIAL_MOVES_ASM, lineno, match.group(1)))
				name, party_number = fields[0], number(fields[1], SPECIAL_MOVES_ASM, lineno)
				if name not in parties:
					sys.exit("%s:%d: unknown trainer class %s" %
					         (SPECIAL_MOVES_ASM, lineno, name))
				if not 1 <= party_number <= len(parties[name]):
					sys.exit("%s:%d: %s has no party %d" %
					         (SPECIAL_MOVES_ASM, lineno, name, party_number))
				trainer = (name, party_number, parties[name][party_number - 1])
				empty = True
				continue
			if fields == ["0"]:  # end of this trainer's entry
				if empty:
					rows.append([trainer[0], str(trainer[1]), "-", "-", "-", "(none)"])
				trainer = None
				continue
			if len(fields) != 3:
				sys.exit("%s:%d: expected `db slot, move slot, move`, got %r" %
				         (SPECIAL_MOVES_ASM, lineno, match.group(1)))
			name, party_number, party = trainer
			slot = number(fields[0], SPECIAL_MOVES_ASM, lineno)
			move_slot = number(fields[1], SPECIAL_MOVES_ASM, lineno)
			if not 1 <= slot <= len(party.mons):
				sys.exit("%s:%d: %s party %d has no slot %d (%d Pokemon)" %
				         (SPECIAL_MOVES_ASM, lineno, name, party_number, slot,
				          len(party.mons)))
			if not 1 <= move_slot <= NUM_MOVES:
				sys.exit("%s:%d: move slot %d is outside 1-%d" %
				         (SPECIAL_MOVES_ASM, lineno, move_slot, NUM_MOVES))
			rows.append([name, str(party_number), str(slot), party.mons[slot - 1][1],
			             str(move_slot), fields[2]])
			empty = False
	if trainer is not None:
		sys.exit("%s: %s party %d is missing its terminator" %
		         (SPECIAL_MOVES_ASM, trainer[0], trainer[1]))
	if not rows:
		sys.exit("no special moves found in %s" % SPECIAL_MOVES_ASM)
	return rows


if __name__ == "__main__":
	all_parties = read_parties()
	map_ids, indoor = read_map_ids()
	town_map = (map_ids, indoor) + read_town_map_entries()
	town_map_order = read_town_map_order(town_map)
	docgen.main(PARTIES_DOC, [
		("parties", PARTY_COLUMNS, lambda: build_parties(all_parties, town_map, town_map_order)),
		("special-moves", MOVE_COLUMNS, lambda: build_special_moves(all_parties)),
	], __doc__)
