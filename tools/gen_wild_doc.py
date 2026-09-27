#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the encounters table in docs/updates/pokemon/LOCATIONS.md.

One row per (Pokemon, place, method), grouped by Pokemon in Pokedex order - the
lookup the data files can't answer, because a species' homes are spread over the
62 files in data/wild/maps plus a dozen map scripts. The reverse question (what
lives on this map) is what those files already are, so it isn't duplicated here.

Where the rows come from:

  Grass/Water  data/wild/maps/*.asm, reached through the WildDataPointers table
               in data/wild/grass_water.asm - the table is indexed by map id, so
               it's what says which map a FooWildMons label belongs to.
  Super Rod    data/wild/super_rod.asm. The four slots aren't equally likely;
               the thresholds are read out of GenerateRandomFishingEncounter.
  Static       Two shapes. A legendary or a Voltorb is an 8-argument
               object_event in data/maps/objects whose 7th field is a species
               instead of an OPP_ class (the level is the 8th). A Snorlax or the
               Marowak ghost is a script writing wCurOpponent/wCurEnemyLevel.
  Gift         `call GivePokemon` in scripts/, with the species and level read
               off the call: `lb bc, SPECIES, LEVEL` when it's a fixed mon, and
               the last species loaded into a before it when the script picks
               one at runtime (the Fighting Dojo). The fossil mon is chosen in
               engine/events/cinnabar_lab.asm, so all three are listed.
  Trade        data/events/trades.asm for the pairs, and the `ld a, TRADE_FOR_X`
               in scripts/ for where each one is.
  Prize        data/events/prizes.asm for the Game Corner's mons and their cost,
               data/events/prize_mon_levels.asm for the levels.

Only the table between the generated: markers is rewritten; the prose around it
stays.

Usage:
  gen_wild_doc.py            rewrite the table in place
  gen_wild_doc.py --check    exit nonzero if the table is stale (no write)
  gen_wild_doc.py --stdout   print the generated table only
"""

import glob
import os
import re
import sys

import docgen

POKEMON_CONSTANTS_ASM = docgen.path("constants", "pokemon_constants.asm")
POKEDEX_CONSTANTS_ASM = docgen.path("constants", "pokedex_constants.asm")
SCRIPT_CONSTANTS_ASM = docgen.path("constants", "script_constants.asm")
DEX_ORDER_ASM = docgen.path("data", "pokemon", "dex_order.asm")
WILD_POINTERS_ASM = docgen.path("data", "wild", "grass_water.asm")
WILD_MAPS_DIR = docgen.path("data", "wild", "maps")
PROBABILITIES_ASM = docgen.path("data", "wild", "probabilities.asm")
SUPER_ROD_ASM = docgen.path("data", "wild", "super_rod.asm")
GOOD_ROD_ASM = docgen.path("data", "wild", "good_rod.asm")
SUPER_ROD_ENGINE_ASM = docgen.path("engine", "items", "super_rod.asm")
ITEM_EFFECTS_ASM = docgen.path("engine", "items", "item_effects.asm")
CINNABAR_LAB_ASM = docgen.path("engine", "events", "cinnabar_lab.asm")
TRADES_ASM = docgen.path("data", "events", "trades.asm")
PRIZES_ASM = docgen.path("data", "events", "prizes.asm")
PRIZE_LEVELS_ASM = docgen.path("data", "events", "prize_mon_levels.asm")
OBJECTS_DIR = docgen.path("data", "maps", "objects")
SCRIPTS_DIR = docgen.path("scripts")
LOCATIONS_DOC = docgen.path("docs", "updates", "pokemon", "LOCATIONS.md")

COLUMNS = ("Pokémon", "Location", "Method", "Levels", "Chance", "Notes")

SLOTS = 10       # wild slots per map per terrain; see WildMonEncounterSlotChances
ROD_SLOTS = 4    # super rod slots per map

# Methods, in the order they should run under one Pokemon: the places you can
# grind for it first, then the one-offs.
METHODS = ("Grass", "Water", "Old Rod", "Good Rod", "Super Rod",
           "Static", "Gift", "Trade", "Prize")

# The Old and Good Rods hook the same thing wherever you cast them, so they have
# no map to file under.
ANYWHERE = "any water"

# What a row says when there's nothing to say: the Pokemon can't be met, given or
# bought anywhere in the game.
UNAVAILABLE = "--"

LABEL_RE = re.compile(r"^(\w+):")
DW_RE = re.compile(r"^\s*dw\s+([\w-]+)")
DB_RE = re.compile(r"^\s*db\s+([^;]*?)\s*$")
LD_A_RE = re.compile(r"^\s*ld\s+a,\s*([\w$]+)\s*$")
# `ld a, [wFossilMon]` - the one indirect species load a gift site uses.
LD_A_FOSSIL_RE = re.compile(r"^\s*ld\s+a,\s*\[wFossilMon\]\s*$")
LD_B_RE = re.compile(r"^\s*ld\s+b,\s*([\w$]+)\s*$")
LD_C_RE = re.compile(r"^\s*ld\s+c,\s*([\w$]+)\s*$")
LB_BC_RE = re.compile(r"^\s*lb\s+bc,\s*([\w$]+),\s*([\w$]+)\s*$")
STORE_RE = re.compile(r"^\s*ld\s+\[(wCurOpponent|wCurEnemyLevel)\],\s*a\s*$")
CP_RE = re.compile(r"^\s*cp\s+\$([0-9A-Fa-f]+)\s*$")
ALIAS_RE = re.compile(r"^DEF\s+(\w+)\s+EQU\s+(\w+)\s*$")
TRADE_FOR_RE = re.compile(r"\bTRADE_FOR_(\w+)\b")
BCD2_RE = re.compile(r"^\s*bcd2\s+(\d+)")

# The static battles a script sets up that aren't something you can own: the
# Pikachu cutscene that opens the game and the old man's catching demo. Both
# write wCurOpponent like a real encounter, so they'd otherwise show up as
# places to find Pikachu and Rattata.
SCRIPTED_DEMOS = {
	("PALLET_TOWN", "PIKACHU"): "cutscene - Oak catches it for you",
	("VIRIDIAN_CITY", "RATTATA"): "the old man's catching demo, not a real encounter",
}

# Statics whose script name for the species isn't the species: the Pokemon Tower
# ghost is RESTLESS_SOUL, an alias for MAROWAK.
STATIC_NOTES = {
	("POKEMON_TOWER_6F", "MAROWAK"): "the restless soul - needs the Poké Flute's "
	                                 "Silph Scope reveal",
}

# Gifts the map hands out one of rather than all of.
GIFT_NOTES = {
	("FIGHTING_DOJO", "HITMONLEE"): "one of the two, your pick",
	("FIGHTING_DOJO", "HITMONCHAN"): "one of the two, your pick",
	# Not a gift at all - the salesman sells it - but it arrives the same way.
	("MT_MOON_POKECENTER", "MAGIKARP"): "sold to you for ¥500",
}


def species_name(constant):
	"""A species constant as the doc prints it - NIDORAN_M reads badly as is."""
	return {"NIDORAN_M": "NIDORAN♂", "NIDORAN_F": "NIDORAN♀"}.get(constant, constant)


def read_forms(dex, species_ids):
	"""{alternate form: (the species it's a form of, what to call the form)}.

	A form is a species sharing a dex number with a lower-id one - FLOATING_WEEZING
	with WEEZING, ARMORED_MEWTWO with MEWTWO. It's the same Pokedex entry, so the
	table prints the base form's name and says which form in the notes rather than
	inventing a second Pokemon.
	"""
	shared = {}
	for name, number in dex.items():
		if number:
			shared.setdefault(number, []).append(name)
	forms = {}
	for number, names in shared.items():
		base = min(names, key=lambda name: species_ids[name])
		for name in names:
			if name == base:
				continue
			suffix = "_" + base
			# Normally the constant is <FORM>_<BASE>; anything else is named
			# after itself rather than guessed at.
			label = name[:-len(suffix)] if name.endswith(suffix) else name
			forms[name] = (base, label)
	return forms



def read_species():
	"""({species constant: id}, {alias: the species it stands for}).

	The aliases are the `DEF STARTER_PIKACHU EQU PIKACHU` lines at the bottom of
	the constants: scripts load those, and a row saying RESTLESS_SOUL wouldn't
	group with the rest of Marowak's homes.
	"""
	ids, indexes = docgen.read_constants(POKEMON_CONSTANTS_ASM)
	aliases = {}
	for lineno, line in docgen.read_lines(POKEMON_CONSTANTS_ASM):
		match = ALIAS_RE.match(line.strip())
		if match and match.group(2) in ids:
			aliases[match.group(1)] = match.group(2)
	return ids, aliases, indexes


def read_dex_numbers(species_ids, indexes):
	"""({species constant: Pokedex number}, [(dex number, species)] for the whole dex).

	Two hops for the first: PokedexOrder is indexed by species id and holds a
	DEX_ constant, and the DEX_ constants are the dex numbers. 0 means the species
	has no dex slot at all - MISSINGNO., the fossil sprites, the ghost.

	The second is the roster the table is filled out against, one species per dex
	number. Where an alternate form shares its base form's number - the floating
	Weezing, armored Mewtwo - the lower species id wins, which is the base form in
	every case, so a form never stands in for the Pokemon it's a form of.
	"""
	dex_ids, dex_end = docgen.read_constants(POKEDEX_CONSTANTS_ASM)

	order = []
	for lineno, line in docgen.read_lines(DEX_ORDER_ASM):
		match = DB_RE.match(line)
		if match:
			name = match.group(1).strip()
			# The MISSINGNO. gaps in the table are a literal `db 0`, not a
			# DEX_ constant.
			if name.isdigit():
				order.append(int(name))
			elif name in dex_ids:
				order.append(dex_ids[name])
			else:
				sys.exit("%s:%d: unknown dex constant %s" % (DEX_ORDER_ASM, lineno, name))
	# The table asserts itself against NUM_POKEMON_INDEXES, which is one less than
	# the value the species constants end on - so a mismatch here means the ids
	# were miscounted, not that the asm is wrong.
	if len(order) != indexes - 1:
		sys.exit("%s: %d entries for %d species indexes - the ids were misread" %
		         (DEX_ORDER_ASM, len(order), indexes - 1))

	# Species ids are 1-based (NO_MON is $00), and the table's first entry is id 1.
	dex = {name: order[value - 1] if 1 <= value <= len(order) else 0
	       for name, value in species_ids.items()}

	# NUM_POKEMON is one less than the value the dex constants end on.
	roster = []
	for number in range(1, dex_end - 1 + 1):
		named = sorted((species_ids[name], name)
		               for name, value in dex.items() if value == number)
		if not named:
			sys.exit("%s: nothing in the dex is #%d - the table has a hole" %
			         (DEX_ORDER_ASM, number))
		roster.append((number, named[0][1]))
	return dex, roster


def read_slot_chances():
	"""The 10 grass/water slot chances, as fractions of 256.

	WildMonEncounterSlotChances holds cumulative thresholds and the engine takes
	the first slot whose threshold is >= the roll, so a slot's own share is the
	gap up to it.
	"""
	chances = []
	previous = -1
	for lineno, line in docgen.read_lines(PROBABILITIES_ASM):
		match = DB_RE.match(line)
		if not match:
			continue
		threshold = docgen.number(match.group(1).split(",")[0], PROBABILITIES_ASM, lineno)
		chances.append((threshold - previous) / 256.0)
		previous = threshold
	if len(chances) != SLOTS:
		sys.exit("%s: expected %d slot chances, got %d" %
		         (PROBABILITIES_ASM, SLOTS, len(chances)))
	if previous != 255:
		sys.exit("%s: slot chances stop at %d, not 255" % (PROBABILITIES_ASM, previous))
	return chances


def read_rod_chances():
	"""The 4 super rod slot chances, from GenerateRandomFishingEncounter.

	It's a ladder of `cp $XX / jr c`, so slot 0 takes everything under the first
	threshold and slot 3 takes whatever is left over 256.
	"""
	thresholds = []
	inside = False
	for lineno, line in docgen.read_lines(SUPER_ROD_ENGINE_ASM):
		if LABEL_RE.match(line):
			inside = line.startswith("GenerateRandomFishingEncounter:")
			continue
		if not inside:
			continue
		match = CP_RE.match(line)
		if match:
			thresholds.append(int(match.group(1), 16))
	if len(thresholds) != ROD_SLOTS - 1:
		sys.exit("%s: expected %d thresholds in GenerateRandomFishingEncounter, got %d" %
		         (SUPER_ROD_ENGINE_ASM, ROD_SLOTS - 1, len(thresholds)))
	bounds = [0] + thresholds + [256]
	return [(bounds[i + 1] - bounds[i]) / 256.0 for i in range(ROD_SLOTS)]


def read_wild_pointers(map_ids):
	"""{FooWildMons label: [the map constants pointing at it]}.

	WildDataPointers is indexed by map id, which is the only thing that says
	which map a label is for - the labels themselves are just names.
	"""
	by_id = [name for name, value in sorted(map_ids.items(), key=lambda pair: pair[1])]
	labels = {}
	index = 0
	for lineno, line in docgen.read_lines(WILD_POINTERS_ASM):
		match = DW_RE.match(line)
		if not match:
			continue
		label = match.group(1)
		if label == "-1":  # end of table
			break
		if index >= len(by_id):
			sys.exit("%s:%d: more wild data pointers than maps" % (WILD_POINTERS_ASM, lineno))
		labels.setdefault(label, []).append(by_id[index])
		index += 1
	if index != len(by_id):
		sys.exit("%s: %d wild data pointers for %d maps - the tables have drifted apart" %
		         (WILD_POINTERS_ASM, index, len(by_id)))
	return labels


def read_wild_map(asm):
	"""{label: {"Grass"/"Water": (encounter rate, [(level, species)])}}.

	A file is usually one label, but nothing stops it holding more, so they're
	keyed rather than assumed.
	"""
	slates = {}
	label = None
	terrain = None
	for lineno, line in docgen.read_lines(asm):
		match = LABEL_RE.match(line)
		if match:
			label = match.group(1)
			continue
		stripped = line.strip()
		for name, macro in (("Grass", "def_grass_wildmons"), ("Water", "def_water_wildmons")):
			if stripped.startswith(macro + " "):
				if label is None:
					sys.exit("%s:%d: %s before any label" % (asm, lineno, macro))
				rate = docgen.number(stripped.split()[1], asm, lineno)
				terrain = name
				slates.setdefault(label, {})[name] = (rate, [])
				break
		else:
			if stripped.startswith(("end_grass_wildmons", "end_water_wildmons")):
				terrain = None
				continue
			match = DB_RE.match(line)
			if match and terrain:
				fields = [field.strip() for field in match.group(1).split(",")]
				if len(fields) != 2:
					sys.exit("%s:%d: expected `db level, species`, got %r" %
					         (asm, lineno, match.group(1)))
				level = docgen.number(fields[0], asm, lineno)
				slates[label][terrain][1].append((level, fields[1]))
	for label, terrains in slates.items():
		for name, (rate, mons) in terrains.items():
			# A rate of 0 means the terrain is unreachable, and those slates are
			# left empty in the asm; anything else has to fill all ten slots.
			if mons and len(mons) != SLOTS:
				sys.exit("%s: %s %s has %d slots, expected %d" %
				         (asm, label, name, len(mons), SLOTS))
			# The two have to agree: a slate behind a rate of 0 can never be
			# rolled, and a rate with nothing behind it would read whatever
			# follows it in the bank.
			if bool(rate) != bool(mons):
				sys.exit("%s: %s %s has a rate of %d and %d Pokemon - a slate and "
				         "its rate are both there or neither is" %
				         (asm, label, name, rate, len(mons)))
	return slates


def read_super_rod(map_ids):
	"""{map constant: [(species, level)]}, four slots each."""
	slots = {}
	for lineno, line in docgen.read_lines(SUPER_ROD_ASM):
		match = DB_RE.match(line)
		if not match:
			continue
		fields = [field.strip() for field in match.group(1).split(",")]
		if fields == ["-1"]:  # end of table
			break
		if len(fields) != 1 + 2 * ROD_SLOTS:
			sys.exit("%s:%d: expected a map and %d species/level pairs, got %d fields" %
			         (SUPER_ROD_ASM, lineno, ROD_SLOTS, len(fields)))
		map_name = fields[0]
		if map_name not in map_ids:
			sys.exit("%s:%d: unknown map %s" % (SUPER_ROD_ASM, lineno, map_name))
		slots[map_name] = [(fields[i], docgen.number(fields[i + 1], SUPER_ROD_ASM, lineno))
		                   for i in range(1, len(fields), 2)]
	if not slots:
		sys.exit("%s: no fishing slots found" % SUPER_ROD_ASM)
	return slots


def read_good_rod():
	"""[(level, species)] - the Good Rod's mons, which don't depend on the map.

	ItemUseGoodRod rerolls until it lands on one of them, so they're equally
	likely; the count is what says how likely.
	"""
	mons = []
	for lineno, line in docgen.read_lines(GOOD_ROD_ASM):
		match = DB_RE.match(line)
		if match:
			fields = [field.strip() for field in match.group(1).split(",")]
			if len(fields) != 2:
				sys.exit("%s:%d: expected `db level, species`, got %r" %
				         (GOOD_ROD_ASM, lineno, match.group(1)))
			mons.append((docgen.number(fields[0], GOOD_ROD_ASM, lineno), fields[1]))
	if not mons:
		sys.exit("%s: no good rod mons found" % GOOD_ROD_ASM)
	return mons


def read_old_rod():
	"""(level, species) - the Old Rod's one mon, written into ItemUseOldRod.

	It has no data file at all: the `lb bc, 5, MAGIKARP` in the item's handler is
	the whole of it.
	"""
	inside = False
	for lineno, line in docgen.read_lines(ITEM_EFFECTS_ASM):
		if LABEL_RE.match(line):
			inside = line.startswith("ItemUseOldRod:")
			continue
		if not inside:
			continue
		match = LB_BC_RE.match(line)
		if match:
			return (docgen.number(match.group(1), ITEM_EFFECTS_ASM, lineno),
			        match.group(2))
	sys.exit("%s: no `lb bc, level, species` in ItemUseOldRod" % ITEM_EFFECTS_ASM)



def read_object_statics(species_ids, map_ids):
	"""[(map, species, level)] for the statics that are map objects.

	An 8-argument object_event is the engine's "walk into this and a battle
	starts" object: field 7 is a trainer class for a trainer and a species for a
	wild static, and field 8 is the party number or the level.
	"""
	statics = []
	for asm in sorted(glob.glob(os.path.join(OBJECTS_DIR, "*.asm"))):
		map_name = None
		for lineno, line in docgen.read_lines(asm):
			stripped = line.strip()
			if not stripped.startswith("object_event"):
				continue
			fields = [field.strip()
			          for field in stripped[len("object_event"):].split(",")]
			if len(fields) != 8 or fields[6] not in species_ids:
				continue
			if map_name is None:
				map_name = docgen.script_map(asm, map_ids)
			statics.append((map_name, fields[6],
			                docgen.number(fields[7], asm, lineno)))
	if not statics:
		sys.exit("%s: no static encounters found - the object_event shape changed?"
		         % os.path.relpath(OBJECTS_DIR, docgen.ROOT))
	return statics


def read_fossil_mons(species_ids):
	"""The mons the Cinnabar lab can hatch, from the fossil it was given.

	The choice is control flow - `ld b, <species>` per branch - which is why the
	gift site itself only knows wFossilMon.
	"""
	mons = []
	for lineno, line in docgen.read_lines(CINNABAR_LAB_ASM):
		match = LD_B_RE.match(line)
		if match and match.group(1) in species_ids and match.group(1) not in mons:
			mons.append(match.group(1))
	if not mons:
		sys.exit("%s: no fossil species found" % CINNABAR_LAB_ASM)
	return mons


def read_script_encounters(species_ids, aliases, map_ids, fossil_mons):
	"""([(map, species, level, note)] statics, [(map, species, level, note)] gifts).

	Both are read the same way: walk a script keeping the last species loaded into
	a and the last level into c, and read the pair off whatever the script does
	with them. Both are tracked from the last label, so a load in one routine
	can't leak into the next.

	A gift's species isn't always a literal: the Fighting Dojo loads it, shows the
	dex entry, and gives whatever wCurPartySpecies ended up as, and the Cinnabar
	lab gives wFossilMon, which is any of the three fossil mons.
	"""
	statics = []
	gifts = []
	for asm in sorted(glob.glob(os.path.join(SCRIPTS_DIR, "*.asm"))):
		map_name = None
		last_a = last_c = None
		fossil = False
		opponent = level = None
		for lineno, line in docgen.read_lines(asm):
			if LABEL_RE.match(line) or re.match(r"^\.\w+", line.strip()):
				last_a = last_c = None
				fossil = False
				opponent = level = None
				continue

			if LD_A_FOSSIL_RE.match(line):
				fossil = True
				continue
			match = LD_A_RE.match(line)
			if match:
				last_a = match.group(1)
				fossil = False
				continue
			match = LD_C_RE.match(line)
			if match:
				last_c = match.group(1)
				continue

			match = LB_BC_RE.match(line)
			if match:
				last_a, last_c = match.group(1), match.group(2)
				fossil = False
				continue

			# A static battle: the species and the level go to wCurOpponent and
			# wCurEnemyLevel in whichever order the script feels like.
			match = STORE_RE.match(line)
			if match:
				if match.group(1) == "wCurOpponent":
					opponent = last_a
				else:
					level = last_a
				if opponent is not None and level is not None:
					species = aliases.get(opponent, opponent)
					if species in species_ids:
						if map_name is None:
							map_name = docgen.script_map(asm, map_ids)
						statics.append((map_name, species,
						                docgen.number(level, asm, lineno),
						                STATIC_NOTES.get((map_name, species), "")))
					opponent = level = None
				continue

			if line.strip() == "call GivePokemon":
				if map_name is None:
					map_name = docgen.script_map(asm, map_ids)
				if last_c is None:
					sys.exit("%s:%d: GivePokemon with no level in c" % (asm, lineno))
				gift_level = docgen.number(last_c, asm, lineno)
				species = aliases.get(last_a, last_a)
				if fossil:
					for mon in fossil_mons:
						gifts.append((map_name, mon, gift_level,
						              "revived from the matching fossil"))
				elif species in species_ids:
					gifts.append((map_name, species, gift_level, ""))
				else:
					sys.exit("%s:%d: GivePokemon with %r in b - not a species" %
					         (asm, lineno, last_a))
				last_a = last_c = None
				fossil = False
	if not statics or not gifts:
		sys.exit("%s: no scripted statics or gifts found - the script shape changed?"
		         % os.path.relpath(SCRIPTS_DIR, docgen.ROOT))
	return statics, gifts


def read_trades(map_ids):
	"""[(map, you get, you hand over, nickname)] for the in-game trades.

	trades.asm is indexed by the TRADE_FOR_ constants and says nothing about
	where a trade happens, so the location comes from the script that asks for it.
	"""
	order = []
	for lineno, line in docgen.read_lines(SCRIPT_CONSTANTS_ASM):
		stripped = line.strip()
		if stripped.startswith("const TRADE_FOR_"):
			order.append(stripped.split()[1])

	entries = {}
	index = 0
	for lineno, line in docgen.read_lines(TRADES_ASM):
		stripped = line.strip()
		if not stripped.startswith("npctrade "):
			continue
		fields = [field.strip() for field in stripped[len("npctrade"):].split(",")]
		if len(fields) != 4:
			sys.exit("%s:%d: expected 4 npctrade fields, got %d" %
			         (TRADES_ASM, lineno, len(fields)))
		if index >= len(order):
			sys.exit("%s:%d: more trades than TRADE_FOR_ constants" % (TRADES_ASM, lineno))
		entries[order[index]] = (fields[1], fields[0], fields[3].strip('"'))
		index += 1
	if index != len(order):
		sys.exit("%s: %d trades for %d TRADE_FOR_ constants - the tables have drifted "
		         "apart" % (TRADES_ASM, index, len(order)))

	trades = []
	seen = set()
	for asm in sorted(glob.glob(os.path.join(SCRIPTS_DIR, "*.asm"))):
		map_name = None
		for lineno, line in docgen.read_lines(asm):
			# Only a plain load asks for a trade; the flag arithmetic around
			# wCompletedInGameTradeFlags mentions the constants too.
			if not LD_A_RE.match(line):
				continue
			match = TRADE_FOR_RE.search(line)
			if not match:
				continue
			constant = "TRADE_FOR_" + match.group(1)
			if constant in seen:
				continue
			seen.add(constant)
			if map_name is None:
				map_name = docgen.script_map(asm, map_ids)
			trades.append((map_name,) + entries[constant])
	if not trades:
		sys.exit("%s: no trade is asked for by any script" % TRADES_ASM)
	return trades


def read_prizes(species_ids, map_ids):
	"""[(species, level or None, cost in coins)] for the Game Corner's mons.

	The prize windows are species lists paired with cost lists, and only the
	window PrizeMenuIsItemWindow marks FALSE hands out Pokemon.
	"""
	levels = {}
	for lineno, line in docgen.read_lines(PRIZE_LEVELS_ASM):
		match = DB_RE.match(line)
		if match:
			fields = [field.strip() for field in match.group(1).split(",")]
			if len(fields) == 2 and fields[0] in species_ids:
				levels[fields[0]] = docgen.number(fields[1], PRIZE_LEVELS_ASM, lineno)

	mons = []
	costs = []
	label = None
	for lineno, line in docgen.read_lines(PRIZES_ASM):
		match = LABEL_RE.match(line)
		if match:
			label = match.group(1)
			continue
		match = BCD2_RE.match(line)
		if match and label and label.endswith("Cost"):
			costs.append(int(match.group(1)))
			continue
		match = DB_RE.match(line)
		if match and label and label.endswith("Entries"):
			name = match.group(1).strip()
			if name in species_ids:
				mons.append(name)
	if not mons:
		sys.exit("%s: no Pokemon prizes found" % PRIZES_ASM)
	if len(costs) < len(mons):
		sys.exit("%s: %d prize Pokemon but only %d costs" %
		         (PRIZES_ASM, len(mons), len(costs)))
	return [(name, levels.get(name), cost) for name, cost in zip(mons, costs)]


def chance(fraction):
	"""A slot share as a percentage, at the resolution 256ths actually have."""
	return "%.1f%%" % (fraction * 100)


def levels(values):
	"""A run of levels: one number, or the range it spans."""
	if min(values) == max(values):
		return "%d" % values[0]
	return "%d-%d" % (min(values), max(values))


def build_rows(data, scripted):
	"""Every encounter in the game, one row each, grouped by Pokemon."""
	species_ids, indexes, map_ids, town_map, rank = data
	dex, roster = read_dex_numbers(species_ids, indexes)
	forms = read_forms(dex, species_ids)
	slot_chances = read_slot_chances()
	rod_chances = read_rod_chances()

	rows = []
	present = set()

	def add(species, map_name, method, level_text, chance_text, note):
		present.add(species)
		base, form = forms.get(species, (species, None))
		if form:
			note = "%s; %s" % (form, note) if note else form
		if map_name is None:
			# The rods you can cast anywhere sort in front of the real places.
			where, map_order, location = -1, -1, ANYWHERE
		else:
			spot = docgen.town_map_spot(map_name, town_map)
			# A map the town map order doesn't reach sorts after the ones it
			# does, by map id, rather than silently landing at the front.
			where = rank.get(spot, len(rank) + map_ids[map_name])
			map_order = map_ids[map_name]
			location = docgen.place_name(map_name)
		rows.append(((dex[species] or 999, species_ids[species], where, map_order,
		              METHODS.index(method)),
		             [species_name(base), location, method,
		              level_text, chance_text, note]))

	# Grass and water, per map, with each species' slots folded into one row.
	labels = read_wild_pointers(map_ids)
	for asm in sorted(glob.glob(os.path.join(WILD_MAPS_DIR, "*.asm"))):
		for label, terrains in read_wild_map(asm).items():
			if label not in labels:
				continue  # nothing on any map points at it
			for map_name in labels[label]:
				for method, (rate, mons) in sorted(terrains.items()):
					if not mons:
						continue
					slots = {}
					for slot, (level, species) in enumerate(mons):
						if species not in species_ids:
							sys.exit("%s: %s is not a species" % (asm, species))
						slots.setdefault(species, []).append((slot, level))
					for species, found in slots.items():
						add(species, map_name, method,
						    levels([level for _, level in found]),
						    chance(sum(slot_chances[slot] for slot, _ in found)), "")

	# Fishing. The Old and Good Rods ignore where you are; only the Super Rod has
	# a per-map slate.
	old_level, old_species = read_old_rod()
	add(old_species, None, "Old Rod", "%d" % old_level, chance(1.0),
	    "every Old Rod bite, wherever you cast it")
	good_rod = read_good_rod()
	for level, species in good_rod:
		add(species, None, "Good Rod", "%d" % level, chance(1.0 / len(good_rod)),
		    "one of the Good Rod's %d mons, wherever you cast it" % len(good_rod))

	for map_name, slots in read_super_rod(map_ids).items():
		folded = {}
		for slot, (species, level) in enumerate(slots):
			if species not in species_ids:
				sys.exit("%s: %s is not a species" % (SUPER_ROD_ASM, species))
			folded.setdefault(species, []).append((slot, level))
		for species, found in folded.items():
			add(species, map_name, "Super Rod",
			    levels([level for _, level in found]),
			    chance(sum(rod_chances[slot] for slot, _ in found)),
			    "slot %s" % ", ".join(str(slot + 1) for slot, _ in found))

	# Statics: the map objects, then the scripted ones. The Power Plant's Voltorbs
	# are eight separate objects at two levels, so identical ones are counted into
	# one row instead of repeating.
	statics, gifts = scripted
	counts = {}
	for map_name, species, level in read_object_statics(species_ids, map_ids):
		counts[(map_name, species, level)] = counts.get((map_name, species, level), 0) + 1
	for map_name, species, level, note in statics:
		counts.setdefault((map_name, species, level), 0)
		counts[(map_name, species, level)] += 1
	scripted_notes = {(map_name, species): note
	                  for map_name, species, _, note in statics}
	for (map_name, species, level), count in counts.items():
		note = (SCRIPTED_DEMOS.get((map_name, species))
		        or STATIC_NOTES.get((map_name, species))
		        or scripted_notes.get((map_name, species))
		        or "one per save")
		if count > 1:
			note = "%d of them, %s" % (count, note)
		add(species, map_name, "Static", "%d" % level, "—", note)

	for map_name, species, level, note in gifts:
		add(species, map_name, "Gift", "%d" % level, "—",
		    note or GIFT_NOTES.get((map_name, species), ""))

	for map_name, gets, gives, nickname in read_trades(map_ids):
		add(gets, map_name, "Trade", "yours", "—",
		    "trade a %s; arrives as %s" % (species_name(gives), nickname))

	for species, level, cost in read_prizes(species_ids, map_ids):
		# A level of None means the prize isn't in PrizeMonLevelDictionary, which
		# GetPrizeMonLevel reads past the end of - see docs/updates/items/PRIZES.md,
		# whose generator is the one that complains about it.
		add(species, "GAME_CORNER_PRIZE_ROOM", "Prize",
		    "?" if level is None else "%d" % level, "—",
		    "%d coins%s" % (cost, "" if level is not None
		                    else " - **no level in PrizeMonLevelDictionary**"))

	# Fill the dex out, so a Pokemon you can only evolve or trade for is visibly
	# absent rather than just missing from the table. The roster is one species per
	# dex number, so an alternate form never gets a row of its own here - but its
	# base form still does if the base form is the one you can't get.
	for _, species in roster:
		if species not in present:
			rows.append(((dex[species], species_ids[species], -2, -2, -1),
			             [species_name(species)] + [UNAVAILABLE] * (len(COLUMNS) - 1)))

	rows.sort(key=lambda row: row[0])
	return [row for _, row in rows]


if __name__ == "__main__":
	all_species, all_aliases, num_indexes = read_species()
	all_maps, indoor = docgen.read_map_ids()
	whole_town_map, progress = docgen.read_town_map()
	fossils = read_fossil_mons(all_species)
	scripted = read_script_encounters(all_species, all_aliases, all_maps, fossils)
	docgen.main(LOCATIONS_DOC, [
		("locations", COLUMNS,
		 lambda: build_rows((all_species, num_indexes, all_maps, whole_town_map, progress),
		                    scripted)),
	], __doc__)
