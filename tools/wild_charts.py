#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
The availability timeline drawn beside docs/updates/pokemon/LOCATIONS.md, as
SVG text.

One row per Pokedex species, one column per place, in play order. A filled cell
is a place you can catch it, darker the more of that place's encounters it
makes up; a ring is a one-off (a static encounter, a gift, a trade or a prize).
Rows are sorted by the first place a species turns up, so the chart reads as a
staircase: the steeper it falls, the faster the game is handing out new
species. Species with no row of marks can't be got without evolving something.

A place is a spot on the town map, the same grouping town_map_order.asm uses -
every floor of Mt. Moon is one column - and the columns run in
docgen.play_order, the order the parties doc and its level curve use.

It takes the Encounter list gen_wild_doc.build_rows fills in.
"""

import re
from xml.sax.saxutils import escape

import docgen
from svgchart import Chart, fmt

# The Old and Good Rods work on any water, so there's no map to file them under.
# They're placed where you're handed the rod instead.
ROD_SOURCES = {
	"Old Rod": "VERMILION_OLD_ROD_HOUSE",
	"Good Rod": "FUCHSIA_GOOD_ROD_HOUSE",
}

# Maps whose town map spot isn't one town_map_order.asm lists, filed under the
# place you're at when you walk into them. (Cerulean Cave isn't listed either,
# and is left to sort last, which is where the postgame belongs.)
MAP_PLACES = {
	"MT_MOON_POKECENTER": "MT_MOON_1F",        # the Magikarp salesman
	"UNDERGROUND_PATH_ROUTE_5": "ROUTE_5",     # a trade
	"ROUTE_11_GATE_2F": "ROUTE_11",            # a trade
	"ROUTE_18_GATE_2F": "ROUTE_18",            # a trade
}

# The methods that are a slate you can keep rolling, and so have a rate. The
# rest - Static, Gift, Trade, Prize - happen once.
REPEATABLE = ("Grass", "Water", "Old Rod", "Good Rod", "Super Rod")

# A cell's shade, by the species' share of that place's encounters: the upper
# bound of each step (exclusive), and the fill opacity it gets.
SHADES = ((0.05, 0.4), (0.15, 0.6), (0.30, 0.8), (2.0, 1.0))
SHADE_LABELS = ("under 5%", "5-15%", "15-30%", "30%+")

# Column names a place's own map names don't give well. Keyed by the first map
# at that place in map id order.
PLACE_NAMES = {
	"CINNABAR_ISLAND": "Cinnabar / Mansion",
	"VERMILION_CITY": "Vermilion",
	"FUCHSIA_CITY": "Fuchsia",
	"CELADON_CITY": "Celadon",
	"SAFFRON_CITY": "Saffron",
	"LAVENDER_TOWN": "Lavender",
}

WIDTH = 960
ROW = 9            # px per species
LABEL_WIDTH = 92   # room for the species names
HEADER = 178       # room for the legend, then the rotated place names
LABEL_OVERHANG = 56  # the last rotated place name leans this far past its column
# Room under the last row - nothing hangs below it but the frame.
MARGIN_BOTTOM_ROWS = 16

STYLE_EXTRA = """
  .cell { fill: #2a78d6; }
  .ring { fill: none; stroke: #2a78d6; stroke-width: 1.5; }
  .stripe { fill: #f1f0ec; }
  .row-label { fill: #52514e; font-size: 8px; }
  .col-label { fill: #0b0b0b; font-size: 10px; }
  .section { fill: #0b0b0b; font-size: 10px; font-weight: 600; }
  @media (prefers-color-scheme: dark) {
    .cell { fill: #3987e5; }
    .ring { stroke: #3987e5; }
    .stripe { fill: #232322; }
    .row-label { fill: #c3c2b7; }
    .col-label, .section { fill: #f0efec; }
  }
"""


def strip_floor(name):
	"""Mt. Moon B1F -> Mt. Moon."""
	words = name.split()
	while words and (re.match(r"^B?\d+F$", words[-1])):
		words.pop()
	return " ".join(words)


def place_label(map_names, map_ids):
	"""What to call a column: the words its maps' names all start with, or an
	override from PLACE_NAMES."""
	first = min(map_names, key=lambda name: map_ids[name])
	if first in PLACE_NAMES:
		return PLACE_NAMES[first]
	names = [strip_floor(docgen.place_name(name)).split() for name in
	         sorted(map_names, key=lambda name: map_ids[name])]
	common = []
	for words in zip(*names):
		if len(set(words)) != 1:
			break
		common.append(words[0])
	return " ".join(common) if common else " ".join(names[0])


def availability(encounters, roster, species_label, town_map, order, map_ids):
	"""The availability timeline. roster: [(dex number, species)];
	species_label: species -> the name to print."""
	dex_number = {species: number for number, species in roster}

	# Group the encounters into places.
	places = {}       # spot -> {"maps": set, "cells": {species: [Encounter]}}
	for encounter in encounters:
		map_name = encounter.map_name or ROD_SOURCES[encounter.method]
		spot = docgen.town_map_spot(MAP_PLACES.get(map_name, map_name), town_map)
		place = places.setdefault(spot, {"maps": set(), "cells": {}})
		place["maps"].add(MAP_PLACES.get(map_name, map_name))
		place["cells"].setdefault(encounter.species, []).append(encounter)

	def place_rank(spot):
		# A place the play order doesn't reach goes after the ones it does, by
		# its lowest map id, rather than silently landing at the front.
		if spot in order:
			return (0, order[spot])
		return (1, min(map_ids[name] for name in places[spot]["maps"]))

	columns = sorted(places, key=place_rank)
	labels = [place_label(places[spot]["maps"], map_ids) for spot in columns]

	first_seen = {}
	for index, spot in enumerate(columns):
		for species in places[spot]["cells"]:
			first_seen.setdefault(species, index)
	found = sorted(first_seen, key=lambda species: (first_seen[species], dex_number[species]))
	missing = [species for _, species in roster if species not in first_seen]

	gap_rows = 2 if missing else 0  # a blank row, then the section heading
	rows = len(found) + gap_rows + len(missing)
	height = HEADER + MARGIN_BOTTOM_ROWS + rows * ROW

	chart = Chart(
		"Where each species can be caught, through the game",
		"%d of %d species can be caught, met or handed over somewhere · rows sorted by "
		"the first place they turn up" % (len(found), len(roster)),
		"Grid of Pokedex species against places in play order. Filled cells are "
		"places the species can be caught, shaded by its share of that place's "
		"encounters; rings are one-off encounters, gifts, trades and prizes.",
		width=WIDTH, height=height, left=LABEL_WIDTH)
	chart.head[3] = chart.head[3].replace("</style>", STYLE_EXTRA + "</style>")
	chart.top = HEADER
	chart.right -= LABEL_OVERHANG
	slot = (chart.right - chart.left) / len(columns)

	def col_x(index):
		return chart.left + index * slot

	def row_y(index):
		return chart.top + index * ROW

	# Every other column is banded, so a cell can be followed up to its name.
	for index in range(0, len(columns), 2):
		chart.add('<rect class="stripe" x="%s" y="%d" width="%s" height="%d"/>' %
		          (fmt(col_x(index)), chart.top - 4, fmt(slot), rows * ROW + 4))

	for index, label in enumerate(labels):
		x = col_x(index) + slot / 2
		chart.add('<text class="col-label" transform="translate(%s %d) rotate(-60)">%s</text>' %
		          (fmt(x + 3), chart.top - 8, escape(label)))

	def draw_row(row, species):
		y = row_y(row)
		chart.add('<text class="row-label" x="%d" y="%s" text-anchor="end" '
		          'dominant-baseline="middle">%s</text>' %
		          (chart.left - 6, fmt(y + ROW / 2), escape(species_label(species))))
		for index, spot in enumerate(columns):
			found_here = places[spot]["cells"].get(species)
			if not found_here:
				continue
			rates = [e.rate for e in found_here if e.method in REPEATABLE]
			tip = "%s - %s: %s" % (species_label(species), labels[index], ", ".join(
				"%s %.1f%%" % (e.method, e.rate * 100) if e.rate is not None else e.method
				for e in found_here))
			cx = col_x(index) + slot / 2
			cy = y + ROW / 2
			if rates:
				best = max(rates)
				opacity = next(alpha for bound, alpha in SHADES if best < bound)
				size = min(slot, ROW) - 2
				chart.add('<rect class="cell" x="%s" y="%s" width="%s" height="%s" rx="1.5" '
				          'fill-opacity="%s"><title>%s</title></rect>' %
				          (fmt(cx - size / 2), fmt(cy - size / 2), fmt(size), fmt(size),
				           opacity, escape(tip)))
			else:
				chart.add('<circle class="ring" cx="%s" cy="%s" r="2.6"><title>%s</title>'
				          '</circle>' % (fmt(cx), fmt(cy), escape(tip)))

	for row, species in enumerate(found):
		draw_row(row, species)
	if missing:
		heading_row = len(found) + 1
		chart.add('<text class="section" x="%d" y="%s" dominant-baseline="middle">'
		          'Not found anywhere - only by evolving another Pokémon</text>' %
		          (chart.left, fmt(row_y(heading_row) + ROW / 2)))
		for offset, species in enumerate(missing):
			draw_row(len(found) + gap_rows + offset, species)

	entries = [('<rect class="cell" x="2" y="-4" width="8" height="8" rx="1.5" '
	            'fill-opacity="%s"/>' % alpha, label)
	           for (_, alpha), label in zip(SHADES, SHADE_LABELS)]
	entries.append(('<circle class="ring" cx="6" cy="0" r="3"/>',
	                "One-off: static, gift, trade, prize"))
	chart.legend(entries)
	return chart.render()
