#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Shared plumbing for the docs whose tables are generated from the game data.

A generated table lives between a pair of markers in the doc:

    <!-- generated:moves -->
    ...table...
    <!-- /generated:moves -->

Everything outside the markers is left untouched, so hand-written notes around
the table survive regeneration. See gen_moves_doc.py / gen_types_doc.py.
"""

import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def path(*parts):
	return os.path.join(ROOT, *parts)


MAP_CONSTANTS_ASM = path("constants", "map_constants.asm")
TOWN_MAP_ENTRIES_ASM = path("data", "maps", "town_map_entries.asm")
TOWN_MAP_ORDER_ASM = path("data", "maps", "town_map_order.asm")
ITEM_CONSTANTS_ASM = path("constants", "item_constants.asm")
ITEM_NAMES_ASM = path("data", "items", "names.asm")

# constants/item_constants.asm declares its TMs and HMs through wrappers rather
# than `const`, so read_constants needs telling what they define.
ITEM_MACROS = {"add_tm": "TM_%s", "add_hm": "HM_%s"}

LI_RE = re.compile(r'^\s*li\s+"([^"]*)"')


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


def read_town_map():
	"""(the tuple town_map_spot wants, {coordinates: progress rank}).

	The two halves of "where is this map, and how early do you get there" - read
	together because nothing needs one without the other.
	"""
	maps = read_map_ids() + read_town_map_entries()
	return maps, read_town_map_order(maps)
# A map name that isn't its constant with the underscores turned into spaces and
# each word capitalized. Floor suffixes (1F, B2F) are left alone by that rule.
NAME_WORDS = {
	"Ss": "S.S.",
	"Mt": "Mt.",
	"Co": "Co.",
	"Pokemon": "Pokémon",
	"Pokecenter": "Poké Center",
	"Melanies": "Melanie's",
	"Digletts": "Diglett's",
}

def place_name(map_constant):
	"""A map constant as prose: ROUTE_1 -> Route 1, MT_MOON_B2F -> Mt. Moon B2F."""
	words = []
	for word in map_constant.split("_"):
		if re.match(r"^B?\d+F$", word) or word.isdigit():
			words.append(word)          # floor numbers and route numbers as-is
		else:
			word = word.capitalize()
			words.append(NAME_WORDS.get(word, word))
	return " ".join(words)




def read_lines(asm):
	"""(line number, code with the comment stripped) for each line of an asm file."""
	with open(asm, encoding="utf-8") as f:
		return [(lineno, line.split(";")[0].rstrip())
		        for lineno, line in enumerate(f, 1)]

def read_constants(asm, macros=None):
	"""({constant: value}, the value one past the last one).

	`const_skip` is a hole in the numbering, not a constant - pokemon_constants
	is full of them, and counting `const` lines alone puts every species after
	the first hole at the wrong id.

	`const_next` jumps the count to an absolute value, which is how the item ids
	leave a gap between the elevator floors and the HMs.

	`macros` covers the wrappers that define a constant without saying `const`,
	as {macro: a format for the name it defines}: item_constants.asm declares its
	TMs with `add_tm MEGA_PUNCH`, which is a `const TM_MEGA_PUNCH`. Lines inside a
	MACRO body are skipped, because that's where the wrapper's own `const TM_\1`
	lives and it isn't a constant.
	"""
	values = {}
	value = 0
	in_macro = False
	for lineno, line in read_lines(asm):
		line = line.strip()
		if line.startswith("MACRO "):
			in_macro = True
			continue
		if line == "ENDM":
			in_macro = False
			continue
		if in_macro:
			continue
		if line.startswith("const_def"):
			fields = line.split()
			value = number(fields[1], asm, lineno) if len(fields) > 1 else 0
		elif line.startswith("const_next"):
			value = number(line.split()[1], asm, lineno)
		elif line.startswith("const_skip"):
			fields = line.split()
			value += number(fields[1], asm, lineno) if len(fields) > 1 else 1
		elif line.startswith("const "):
			values[line.split()[1]] = value
			value += 1
		else:
			for macro, form in (macros or {}).items():
				if line.startswith(macro + " "):
					values[form % line.split()[1]] = value
					value += 1
					break
	if in_macro:
		sys.exit("%s: a MACRO is never closed" % asm)
	if not values:
		sys.exit("no constants found in %s" % asm)
	return values, value

def script_map(asm, map_ids):
	"""The map a file under scripts/ or data/maps/objects/ belongs to.

	The file name is the map constant in CamelCase, sometimes with a _2 on the
	end where one map's scripts are split over two files, so they're matched with
	the punctuation taken out rather than by guessing where the words break.
	"""
	stem = re.sub(r"_\d+$", "", os.path.basename(asm)[:-len(".asm")])
	key = stem.upper()
	for name in map_ids:
		if name.replace("_", "") == key:
			return name
	sys.exit("%s: no map constant matches the file name" % os.path.relpath(asm, ROOT))


def read_item_names():
	"""{item constant: the name a menu shows for it}.

	data/items/names.asm covers the ordinary items, in id order. TMs and HMs
	aren't in it - GetItemName builds those names from the number - so they're
	named the way the menu names them, with the move they teach after, which is
	the only thing that makes a shelf of nine TMs readable.
	"""
	ids, _ = read_constants(ITEM_CONSTANTS_ASM, ITEM_MACROS)

	listed = []
	for lineno, line in read_lines(ITEM_NAMES_ASM):
		match = LI_RE.match(line)
		if match:
			listed.append(match.group(1))
	if not listed:
		sys.exit("%s: no item names found" % ITEM_NAMES_ASM)

	names = {}
	for macro, form in (("add_tm", "TM%02d (%s)"), ("add_hm", "HM%02d (%s)")):
		number = 0
		for lineno, line in read_lines(ITEM_CONSTANTS_ASM):
			stripped = line.strip()
			if stripped.startswith(macro + " "):
				move = stripped.split()[1]
				number += 1
				names[ITEM_MACROS[macro] % move] = form % (number, move.replace("_", " "))
		if not number:
			sys.exit("%s: no %s lines found" % (ITEM_CONSTANTS_ASM, macro))

	for name, value in ids.items():
		# Item ids are 1-based, and the names list starts at id 1. The TM and HM
		# ids run past the end of it, and those are named above.
		if name not in names and 1 <= value <= len(listed):
			names[name] = listed[value - 1]
	return names, ids


def render_table(headers, rows):
	"""Markdown table, columns padded so the source stays readable."""
	widths = [max(len(cell) for cell in col) for col in zip(headers, *rows)]

	def render(cells):
		return "| " + " | ".join(c.ljust(w) for c, w in zip(cells, widths)) + " |"

	lines = [render(headers)]
	lines.append("|" + "|".join("-" * (w + 2) for w in widths) + "|")
	lines.extend(render(row) for row in rows)
	return "\n".join(lines) + "\n"


def splice(doc, doc_path, name, table):
	open_marker = "<!-- generated:%s -->" % name
	close_marker = "<!-- /generated:%s -->" % name
	pattern = re.compile(r"%s\n.*?%s" % (re.escape(open_marker), re.escape(close_marker)),
	                     re.DOTALL)
	if not pattern.search(doc):
		sys.exit("%s: missing %s ... %s markers" %
		         (os.path.relpath(doc_path, ROOT), open_marker, close_marker))
	replacement = "%s\n%s%s" % (open_marker, table, close_marker)
	return pattern.sub(lambda _: replacement, doc, count=1)


def main(doc_path, blocks, description):
	"""blocks: (marker name, headers, build_rows) per generated table in the doc."""
	parser = argparse.ArgumentParser(description=description,
	                                 formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument("--check", action="store_true",
	                    help="fail if the doc is out of date instead of rewriting it")
	parser.add_argument("--stdout", action="store_true",
	                    help="print the generated tables instead of writing the doc")
	args = parser.parse_args()

	tables = []
	for name, headers, build_rows in blocks:
		rows = build_rows()
		tables.append((name, render_table(headers, rows), len(rows)))

	if args.stdout:
		sys.stdout.write("\n".join(table for _, table, _ in tables))
		return

	rel = os.path.relpath(doc_path, ROOT)
	counts = ", ".join("%s: %d rows" % (name, count) for name, _, count in tables)

	with open(doc_path, encoding="utf-8") as f:
		doc = f.read()
	updated = doc
	for name, table, _ in tables:
		updated = splice(updated, doc_path, name, table)

	if updated == doc:
		print("%s is up to date (%s)" % (rel, counts))
		return
	if args.check:
		sys.exit("%s is out of date; run `make docs`" % rel)
	with open(doc_path, "w", encoding="utf-8") as f:
		f.write(updated)
	print("Regenerated %s (%s)" % (rel, counts))
