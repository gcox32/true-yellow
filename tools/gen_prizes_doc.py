#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the prize table in docs/updates/items/PRIZES.md.

One row per prize on the Game Corner's three counters, in counter order and then
menu order.

  data/events/prizes.asm            what each counter offers and what it costs.
                                    The counters are three parallel pairs of
                                    lists - what's on offer and what it costs -
                                    reached through PrizeDifferentMenuPtrs, and
                                    PrizeMenuIsItemWindow is what says whether a
                                    counter hands out Pokemon or items.
  data/events/prize_mon_levels.asm  the level a prize Pokemon arrives at. Nothing
                                    ties this to the offers except the species,
                                    and GetPrizeMonLevel scans it without a bound
                                    check, so a prize missing from it is a bug -
                                    this reports both directions of the mismatch.
  constants/item_constants.asm      the TM numbering, for naming an item prize
                                    the way the menu does.

Only the table between the generated: markers is rewritten; the prose around it
stays.

Usage:
  gen_prizes_doc.py            rewrite the table in place
  gen_prizes_doc.py --check    exit nonzero if the table is stale (no write)
  gen_prizes_doc.py --stdout   print the generated table only
"""

import os
import re
import sys

import docgen

PRIZES_ASM = docgen.path("data", "events", "prizes.asm")
PRIZE_LEVELS_ASM = docgen.path("data", "events", "prize_mon_levels.asm")
POKEMON_CONSTANTS_ASM = docgen.path("constants", "pokemon_constants.asm")
PRIZES_DOC = docgen.path("docs", "updates", "items", "PRIZES.md")

COLUMNS = ("Counter", "Prize", "Level", "Cost")

LABEL_RE = re.compile(r"^(\w+):")
DB_RE = re.compile(r"^\s*db\s+([^;]*?)\s*$")
BCD2_RE = re.compile(r"^\s*bcd2\s+(\d+)")
DW_RE = re.compile(r"^\s*dw\s+([^;]*?)\s*$")

# What a counter that doesn't hand out Pokemon has instead of a level.
NO_LEVEL = "—"
MISSING_LEVEL = "?"

# A PrizeMonLevelDictionary entry no counter offers still gets a row, so the doc
# covers both files rather than quietly dropping half of one.
NO_COUNTER = "none"
NO_COST = "—"


def read_menu_pointers():
	"""[(offers label, costs label)] per counter, in wWhichPrizeWindow order."""
	counters = []
	label = None
	for lineno, line in docgen.read_lines(PRIZES_ASM):
		match = LABEL_RE.match(line)
		if match:
			label = match.group(1)
			continue
		if label != "PrizeDifferentMenuPtrs":
			continue
		match = DW_RE.match(line)
		if match:
			fields = [field.strip() for field in match.group(1).split(",")]
			if len(fields) != 2:
				sys.exit("%s:%d: expected `dw entries, cost`, got %r" %
				         (PRIZES_ASM, lineno, match.group(1)))
			counters.append((fields[0], fields[1]))
	if not counters:
		sys.exit("%s: no PrizeDifferentMenuPtrs table" % PRIZES_ASM)
	return counters


def read_menus():
	"""({label: [entry]}, {label: [cost]}, the PrizeMenuIsItemWindow flags).

	Both list kinds are terminated by a `db "@"`, so the label they sit under is
	all that tells them apart.
	"""
	entries = {}
	costs = {}
	flags = []
	label = None
	for lineno, line in docgen.read_lines(PRIZES_ASM):
		match = LABEL_RE.match(line)
		if match:
			label = match.group(1)
			continue
		if label is None:
			continue
		match = BCD2_RE.match(line)
		if match:
			costs.setdefault(label, []).append(int(match.group(1)))
			continue
		match = DB_RE.match(line)
		if match:
			field = match.group(1).strip()
			if field == '"@"':  # end of list
				continue
			if label == "PrizeMenuIsItemWindow":
				flags.append(field == "TRUE")
			else:
				entries.setdefault(label, []).append(field)
	if not flags:
		sys.exit("%s: no PrizeMenuIsItemWindow flags" % PRIZES_ASM)
	return entries, costs, flags


def read_prize_levels(species_ids):
	"""{species constant: level} from PrizeMonLevelDictionary."""
	levels = {}
	for lineno, line in docgen.read_lines(PRIZE_LEVELS_ASM):
		match = DB_RE.match(line)
		if not match:
			continue
		fields = [field.strip() for field in match.group(1).split(",")]
		if len(fields) != 2:
			sys.exit("%s:%d: expected `db species, level`, got %r" %
			         (PRIZE_LEVELS_ASM, lineno, match.group(1)))
		if fields[0] not in species_ids:
			sys.exit("%s:%d: %s is not a species" % (PRIZE_LEVELS_ASM, lineno, fields[0]))
		levels[fields[0]] = docgen.number(fields[1], PRIZE_LEVELS_ASM, lineno)
	if not levels:
		sys.exit("%s: no prize levels found" % PRIZE_LEVELS_ASM)
	return levels


def build_rows():
	"""Every counter's menu, with each prize's level and cost joined on."""
	item_names, _ = docgen.read_item_names()
	species_ids, _ = docgen.read_constants(POKEMON_CONSTANTS_ASM)
	entries, costs, flags = read_menus()
	counters = read_menu_pointers()
	levels = read_prize_levels(species_ids)

	if len(flags) != len(counters):
		sys.exit("%s: %d counters but %d PrizeMenuIsItemWindow flags - keep them in "
		         "sync" % (PRIZES_ASM, len(counters), len(flags)))

	rows = []
	wanted = set()
	for index, ((offers, prices), items) in enumerate(zip(counters, flags), 1):
		if offers not in entries:
			sys.exit("%s: counter %d points at %s, which has no entries" %
			         (PRIZES_ASM, index, offers))
		if prices not in costs:
			sys.exit("%s: counter %d points at %s, which has no costs" %
			         (PRIZES_ASM, index, prices))
		offered, charged = entries[offers], costs[prices]
		if len(offered) != len(charged):
			sys.exit("%s: %s offers %d prizes but %s has %d costs" %
			         (PRIZES_ASM, offers, len(offered), prices, len(charged)))
		counter = "%d (%s)" % (index, "items" if items else "Pokémon")
		for prize, cost in zip(offered, charged):
			if items:
				if prize not in item_names:
					sys.exit("%s: %s is not an item" % (PRIZES_ASM, prize))
				rows.append([counter, item_names[prize], NO_LEVEL, "%d coins" % cost])
				continue
			if prize not in species_ids:
				sys.exit("%s: %s is neither an item nor a species" % (PRIZES_ASM, prize))
			wanted.add(prize)
			if prize in levels:
				level = "%d" % levels[prize]
			else:
				# GetPrizeMonLevel walks the dictionary until the species matches,
				# with no end-of-table check, so it reads past it and uses whatever
				# byte follows as the level.
				level = MISSING_LEVEL
				sys.stderr.write("warning: %s is a prize with no entry in %s - "
				                 "GetPrizeMonLevel reads past the table\n" %
				                 (prize, os.path.relpath(PRIZE_LEVELS_ASM, docgen.ROOT)))
			rows.append([counter, prize, level, "%d coins" % cost])

	# The other direction: a level for something no counter offers is dead weight,
	# and usually means a prize was swapped out and its level left behind. It's a
	# row rather than a warning - nothing is broken, there's just data going spare.
	for species, level in levels.items():
		if species not in wanted:
			rows.append([NO_COUNTER, species, "%d" % level, NO_COST])
	if not rows:
		sys.exit("%s: no prizes found" % PRIZES_ASM)
	return rows


if __name__ == "__main__":
	docgen.main(PRIZES_DOC, [("prizes", COLUMNS, build_rows)], __doc__)
