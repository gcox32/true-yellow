#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the two tables in docs/updates/battle/TYPES.md.

  type-list  constants/type_constants.asm joined with data/types/names.asm:
             every type, its id, the name the game prints for it, and whether
             it is physical or special. The join is the point - several added
             types deliberately print as an existing type's name, so a type
             whose "Displays as" differs from its constant is one the player
             never sees by its real name.
  matchups   data/types/type_matchups.asm, in asm order (grouped by attacking
             type). Any pairing not listed is neutral.

Only the tables between the generated: markers are rewritten; the prose around
them stays.

Usage:
  gen_types_doc.py            rewrite the tables in place
  gen_types_doc.py --check    exit nonzero if a table is stale (no write)
  gen_types_doc.py --stdout   print the generated tables only
"""

import re
import sys

import docgen

TYPE_CONSTANTS_ASM = docgen.path("constants", "type_constants.asm")
NAMES_ASM = docgen.path("data", "types", "names.asm")
MATCHUPS_ASM = docgen.path("data", "types", "type_matchups.asm")
TYPES_DOC = docgen.path("docs", "updates", "battle", "TYPES.md")

TYPE_COLUMNS = ("Type", "ID", "Displays as", "Class")
COLUMNS = ("Attacker", "Defender", "Multiplier")

# `db ATTACKER, DEFENDER, EFFECTIVENESS` with an optional trailing comment.
MATCHUP_RE = re.compile(r"^\s*db\s+(.+?)\s*(?:;.*)?$")

# constants/battle_constants.asm, scaled by 10
MULTIPLIERS = {
	"SUPER_EFFECTIVE": "2x",
	"MORE_EFFECTIVE": "1.5x",
	"EFFECTIVE": "1x",
	"NOT_VERY_EFFECTIVE": "0.5x",
	"NO_EFFECT": "0x",
}


def read_type_constants():
	"""[(constant, id, "Physical"/"Special")] in id order, skipping the unused block.

	`const NAME` takes the next id; `const_next N` jumps the counter to N (that's
	the 17-wide UNUSED_TYPES gap). The PHYSICAL/SPECIAL markers split the list.
	"""
	types = []
	value = 0
	klass = None
	with open(TYPE_CONSTANTS_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if line.startswith("DEF PHYSICAL"):
				klass = "Physical"
			elif line.startswith("DEF SPECIAL"):
				klass = "Special"
			elif line.startswith("const_def"):
				parts = line.split()
				value = int(parts[1], 0) if len(parts) > 1 else 0
			elif line.startswith("const_next"):
				value = int(line.split()[1], 0)
			elif line.startswith("const "):
				types.append((line.split()[1], value, klass))
				value += 1
	if not types:
		sys.exit("no type constants found in %s" % TYPE_CONSTANTS_ASM)
	return types


def read_type_names():
	"""The TypeNames pointer table, resolved to the strings it points at.

	Entries inside the REPT block are the unused-type padding and have no
	constant of their own, so they're skipped to keep this aligned with
	read_type_constants().
	"""
	pointers = []
	strings = {}
	in_rept = False
	with open(NAMES_ASM, encoding="utf-8") as f:
		for line in f:
			line = line.split(";")[0].strip()
			if line.startswith("REPT"):
				in_rept = True
			elif line == "ENDR":
				in_rept = False
			elif line.startswith("dw ") and not in_rept:
				pointers.append(line.split(None, 1)[1].strip())
			else:
				match = re.match(r'^(\.\w+):\s*db\s+"([^"]*)@"', line)
				if match:
					strings[match.group(1)] = match.group(2)
	missing = [p for p in pointers if p not in strings]
	if missing:
		sys.exit("%s: no string for %s" % (NAMES_ASM, ", ".join(sorted(set(missing)))))
	return [strings[p] for p in pointers]


def build_type_list():
	types = read_type_constants()
	names = read_type_names()
	if len(types) != len(names):
		sys.exit("%d type constants but %d names - the tables have drifted apart" %
		         (len(types), len(names)))
	return [[constant, "$%02X" % value, name, klass or "?"]
	        for (constant, value, klass), name in zip(types, names)]


def read_matchups():
	matchups = []
	with open(MATCHUPS_ASM, encoding="utf-8") as f:
		for lineno, line in enumerate(f, 1):
			match = MATCHUP_RE.match(line)
			if not match:
				continue
			fields = [field.strip() for field in match.group(1).split(",")]
			if fields == ["-1"]:  # end of table
				break
			if len(fields) != len(COLUMNS):
				sys.exit("%s:%d: expected %d fields, got %d" %
				         (MATCHUPS_ASM, lineno, len(COLUMNS), len(fields)))
			attacker, defender, effectiveness = fields
			if effectiveness not in MULTIPLIERS:
				sys.exit("%s:%d: unknown effectiveness %s" %
				         (MATCHUPS_ASM, lineno, effectiveness))
			matchups.append([attacker, defender, MULTIPLIERS[effectiveness]])
	if not matchups:
		sys.exit("no matchups found in %s" % MATCHUPS_ASM)
	return matchups


if __name__ == "__main__":
	docgen.main(TYPES_DOC, [
		("type-list", TYPE_COLUMNS, build_type_list),
		("matchups", COLUMNS, read_matchups),
	], __doc__)
