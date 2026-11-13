#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
The two charts drawn beside docs/updates/trainers/PARTIES.md, as SVG text.

  species_frequency   how many species appear in trainer parties 0 times, once,
                      twice and so on, with a normal curve of the same mean and
                      spread laid over it, so over- and underused species stand
                      out as the tails.
  level_curve         every party's level range in the order the table lists
                      them - play order - with the gym leaders and the Elite
                      Four marked, so a spike or a dip against its neighbours
                      stands out.

Both take what gen_parties_doc.ordered_parties returns. They're plain SVG with
no dependencies, and everything in them is a fixed function of the parties, so
the output is byte-for-byte stable and `make check-docs` can compare it.

Colors are CSS custom properties with a dark-mode override, so the charts follow
the viewer's color scheme when the doc embeds them as images.
"""

import math
from xml.sax.saxutils import escape

import docgen

POKEMON_CONSTANTS_ASM = docgen.path("constants", "pokemon_constants.asm")
DEX_ORDER_ASM = docgen.path("data", "pokemon", "dex_order.asm")

# The Fighting Dojo's training-hall teams store a signed offset from the
# player's highest level rather than a level (see ReadTrainer), so they have no
# fixed place on a level axis.
RELATIVE_LEVEL_LOCATIONS = ("Fighting Dojo (training hall)",)

# The Rival's later battles come in three versions, picked by wRivalStarter
# (1-3) added to a base party number in the map script - PokemonTower2F,
# SilphCo7F, Route22 and ChampionsRoom. A player only ever meets one, so the
# charts count version 1 alone. {class: [first party number of each set]}
RIVAL_VERSIONS = 3
RIVAL_VERSION_SETS = {
	"RIVAL2": (2, 5, 8),
	"RIVAL3": (1,),
}

# Who to mark on the level curve, and what to call them: the eight badges, then
# the Elite Four and the champion. The E4 rooms are back to back, so they're
# marked once, at the first of them.
MILESTONES = {
	"BROCK": "Brock",
	"MISTY": "Misty",
	"LT_SURGE": "Lt. Surge",
	"ERIKA": "Erika",
	"KOGA": "Koga",
	"SABRINA": "Sabrina",
	"BLAINE": "Blaine",
	"LORELEI": "Elite Four",
	"RIVAL3": "Champion",
}
# Rows of milestone labels above the level curve, and a rough width per
# character of their 11px bold text, for keeping them apart.
LABEL_ROWS = 3
LABEL_CHAR_WIDTH = 7

# Giovanni is fought three times; only the gym battle is a badge.
GIOVANNI_GYM = "Viridian Gym"

WIDTH = 960
HEIGHT = 400
MARGIN_LEFT = 48
MARGIN_RIGHT = 20
MARGIN_TOP = 78
MARGIN_BOTTOM = 52

STYLE = """
  .surface { fill: #fcfcfb; }
  .title { fill: #0b0b0b; font-size: 15px; font-weight: 600; }
  .subtitle, .axis-title { fill: #52514e; font-size: 12px; }
  .tick { fill: #52514e; font-size: 11px; }
  .label { fill: #0b0b0b; font-size: 11px; font-weight: 600; }
  .grid { stroke: #e7e6e2; stroke-width: 1; }
  .axis { stroke: #a8a7a1; stroke-width: 1; }
  .marker-line { stroke: #a8a7a1; stroke-width: 1; stroke-dasharray: 2 3; }
  .bar { fill: #2a78d6; }
  .band { stroke: #2a78d6; stroke-opacity: 0.35; stroke-width: 2; }
  .line { fill: none; stroke: #2a78d6; stroke-width: 2; stroke-linejoin: round; }
  .fit { fill: none; stroke: #eb6834; stroke-width: 2; stroke-dasharray: 6 4; }
  .dot { fill: #2a78d6; stroke: #fcfcfb; stroke-width: 2; }
  @media (prefers-color-scheme: dark) {
    .surface { fill: #1a1a19; }
    .title, .label { fill: #f0efec; }
    .subtitle, .axis-title, .tick { fill: #c3c2b7; }
    .grid { stroke: #2e2e2c; }
    .axis, .marker-line { stroke: #6b6a65; }
    .bar { fill: #3987e5; }
    .band { stroke: #3987e5; }
    .line { stroke: #3987e5; }
    .fit { stroke: #d95926; }
    .dot { fill: #3987e5; stroke: #1a1a19; }
  }
"""


def other_rival_version(name, number):
	"""Whether a party is version 2 or 3 of one of the Rival's battles."""
	return any(first < number < first + RIVAL_VERSIONS
	           for first in RIVAL_VERSION_SETS.get(name, ()))


def fixed_levels(ordered):
	"""[(class, Party)] for the battles to chart: real levels only, and one
	version of each Rival battle."""
	return [(name, party) for name, number, party in ordered
	        if party.location not in RELATIVE_LEVEL_LOCATIONS
	        and not other_rival_version(name, number)]


def fmt(value):
	"""A coordinate, short and stable: at most one decimal place."""
	text = "%.1f" % value
	return text[:-2] if text.endswith(".0") else text


def nice_step(span, target):
	"""A 1/2/5 x 10^n tick step giving roughly `target` ticks over `span`."""
	raw = span / max(target, 1)
	power = 10 ** math.floor(math.log10(raw))
	for multiple in (1, 2, 5, 10):
		if raw <= multiple * power:
			return multiple * power
	return 10 * power


class Chart:
	"""An SVG being built up: a fixed frame, a plot area and a list of elements."""

	def __init__(self, title, subtitle, description):
		self.parts = []
		self.left = MARGIN_LEFT
		self.right = WIDTH - MARGIN_RIGHT
		self.top = MARGIN_TOP
		self.bottom = HEIGHT - MARGIN_BOTTOM
		self.head = [
			'<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
			'viewBox="0 0 %d %d" role="img" font-family="system-ui, -apple-system, '
			'Segoe UI, Helvetica, Arial, sans-serif">' % (WIDTH, HEIGHT, WIDTH, HEIGHT),
			"<title>%s</title>" % escape(title),
			"<desc>%s</desc>" % escape(description),
			"<style>%s</style>" % STYLE,
			'<rect class="surface" width="%d" height="%d" rx="8"/>' % (WIDTH, HEIGHT),
			'<text class="title" x="%d" y="26">%s</text>' % (self.left, escape(title)),
			'<text class="subtitle" x="%d" y="44">%s</text>' % (self.left, escape(subtitle)),
		]

	def add(self, element):
		self.parts.append(element)

	def y_axis(self, top_value, title, to_y):
		step = nice_step(top_value, 5)
		value = 0
		while value <= top_value:
			y = to_y(value)
			self.add('<line class="grid" x1="%d" x2="%d" y1="%s" y2="%s"/>' %
			         (self.left, self.right, fmt(y), fmt(y)))
			self.add('<text class="tick" x="%d" y="%s" text-anchor="end" '
			         'dominant-baseline="middle">%d</text>' % (self.left - 6, fmt(y), value))
			value += step
		self.add('<text class="axis-title" transform="translate(14 %s) rotate(-90)" '
		         'text-anchor="middle">%s</text>' %
		         (fmt((self.top + self.bottom) / 2), escape(title)))

	def x_axis(self, ticks, title):
		"""ticks: [(x, label)]"""
		self.add('<line class="axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' %
		         (self.left, self.right, self.bottom, self.bottom))
		for x, label in ticks:
			self.add('<line class="axis" x1="%s" x2="%s" y1="%d" y2="%d"/>' %
			         (fmt(x), fmt(x), self.bottom, self.bottom + 4))
			self.add('<text class="tick" x="%s" y="%d" text-anchor="middle">%s</text>' %
			         (fmt(x), self.bottom + 17, label))
		self.add('<text class="axis-title" x="%s" y="%d" text-anchor="middle">%s</text>' %
		         (fmt((self.left + self.right) / 2), HEIGHT - 10, escape(title)))

	def legend(self, entries):
		"""entries: [(swatch SVG at the origin, label)], laid out left to right."""
		x = self.left
		y = 60
		for swatch, label in entries:
			self.add('<g transform="translate(%d %d)">%s</g>' % (x, y, swatch))
			self.add('<text class="tick" x="%d" y="%d" dominant-baseline="middle">%s</text>' %
			         (x + 22, y, escape(label)))
			x += 34 + 7 * len(label)

	def render(self):
		return "\n".join(self.head + self.parts + ["</svg>"]) + "\n"


def read_species():
	"""({species constant: the Pokedex species it counts as}, [every Pokedex species]).

	Keyed through dex_order.asm, so an alternate form (BROCK_ONIX,
	FLOATING_WEEZING, ARMORED_MEWTWO) counts as its base species, and the
	internal ids with no Pokedex number (fossil and ghost sprites, unused slots)
	count as nothing. MissingNo. has a Pokedex number but isn't a species.
	"""
	ids, _ = docgen.read_constants(POKEMON_CONSTANTS_ASM)
	order = [line.split()[1] for _, line in docgen.read_lines(DEX_ORDER_ASM)
	         if line.strip().startswith("db ")]
	species = {}
	for name, value in ids.items():
		if 1 <= value <= len(order) and order[value - 1] not in ("0", "DEX_MISSINGNO"):
			species[name] = order[value - 1][len("DEX_"):]
	return species, sorted(set(species.values()))


def species_frequency(ordered):
	"""How many species turn up 0 times across the trainers, how many once, and
	so on - one bar per appearance count."""
	species_of, every_species = read_species()
	appearances = {name: 0 for name in every_species}
	for _, party in fixed_levels(ordered):
		for _, mon in party.mons:
			if mon not in species_of:
				raise SystemExit("%s: %s has no Pokedex species" % (DEX_ORDER_ASM, mon))
			appearances[species_of[mon]] += 1

	counts = list(appearances.values())
	total = len(counts)
	mean = sum(counts) / total
	spread = math.sqrt(sum((n - mean) ** 2 for n in counts) / total)
	median = sorted(counts)[total // 2]

	low = 0
	high = max(counts)
	per_count = {n: [] for n in range(low, high + 1)}
	for name in every_species:
		per_count[appearances[name]].append(name)

	def density(n):
		return total * math.exp(-((n - mean) ** 2) / (2 * spread ** 2)) / \
		       (spread * math.sqrt(2 * math.pi))

	peak = max(max(len(names) for names in per_count.values()), density(mean))
	top_value = nice_step(peak, 5) * math.ceil(peak / nice_step(peak, 5))

	chart = Chart(
		"How often each species appears",
		"%d species · %d trainer Pokémon, one version per Rival battle · "
		"mean %.1f appearances · median %d · SD %.1f" %
		(total, sum(counts), mean, median, spread),
		"Histogram of how many species appear a given number of times across all "
		"trainer parties, with a normal curve of the same mean and standard "
		"deviation.")

	slot = (chart.right - chart.left) / (high - low + 1)

	def to_x(n):
		"""The left edge of an appearance count's slot."""
		return chart.left + (n - low) * slot

	def to_y(value):
		return chart.bottom - value / top_value * (chart.bottom - chart.top)

	chart.y_axis(top_value, "Species", to_y)
	chart.x_axis([(to_x(n) + slot / 2, n) for n in range(low, high + 1)],
	             "Times the species appears in a trainer party")

	# A few wide slots: keep the bars slim, with the slot's space around them.
	gap = max(2, slot * 0.35)
	for n in range(low, high + 1):
		names = per_count[n]
		if not names:
			continue
		x = to_x(n) + gap / 2
		width = slot - gap
		y = to_y(len(names))
		radius = min(2, width / 2, chart.bottom - y)
		# Rounded on top only - the bar stands on the baseline.
		chart.add('<path class="bar" d="M%s %d V%s Q%s %s %s %s H%s Q%s %s %s %s V%d Z">'
		          '<title>%d species appear%s %d time%s: %s</title></path>' %
		          (fmt(x), chart.bottom, fmt(y + radius), fmt(x), fmt(y), fmt(x + radius),
		           fmt(y), fmt(x + width - radius), fmt(x + width), fmt(y), fmt(x + width),
		           fmt(y + radius), chart.bottom, len(names), "s" if len(names) == 1 else "",
		           n, "" if n == 1 else "s",
		           escape(", ".join(names))))
		chart.add('<text class="tick" x="%s" y="%s" text-anchor="middle">%d</text>' %
		          (fmt(x + width / 2), fmt(y - 5), len(names)))

	points = []
	value = float(low)
	while value <= high + 1:
		points.append("%s,%s" % (fmt(to_x(value)), fmt(to_y(density(value - 0.5)))))
		value += 0.25
	chart.add('<polyline class="fit" points="%s"/>' % " ".join(points))

	chart.legend([
		('<rect class="bar" x="0" y="-5" width="14" height="10" rx="2"/>',
		 "Species appearing that many times"),
		('<line class="fit" x1="0" x2="16" y1="0" y2="0"/>',
		 "Normal curve, same mean and SD"),
	])
	return chart.render()


def level_curve(ordered):
	"""Each party's level range, battle by battle, in play order."""
	battles = fixed_levels(ordered)
	count = len(battles)
	top_level = max(level for _, party in battles for level, _ in party.mons)
	top_value = nice_step(top_level, 5) * math.ceil(top_level / nice_step(top_level, 5))

	chart = Chart(
		"Trainer levels through the game",
		"%d battles in the order the table lists them · line: each team's highest "
		"level · band: its lowest to highest" % count,
		"Line chart of each trainer party's highest level, in play order, over a "
		"band from its lowest to highest level, with gym leaders and the Elite "
		"Four marked.")
	# Milestone labels sit in up to LABEL_ROWS rows above the plot.
	chart.top += 13 * LABEL_ROWS + 8

	def to_x(index):
		return chart.left + (index + 0.5) / count * (chart.right - chart.left)

	def to_y(level):
		return chart.bottom - level / top_value * (chart.bottom - chart.top)

	chart.y_axis(top_value, "Level", to_y)
	step = nice_step(count, 8)
	chart.x_axis([(to_x(index - 1), index) for index in range(step, count + 1, step)],
	             "Battle number")

	milestones = []
	for index, (name, party) in enumerate(battles):
		label = MILESTONES.get(name)
		if name == "GIOVANNI" and party.location == GIOVANNI_GYM:
			label = "Giovanni"
		if label and label not in [m[1] for m in milestones]:
			milestones.append((index, label))

	# Each label takes the first row where it clears the labels already there.
	# A label that would run off either end of the plot is anchored to that end.
	row_ends = [-math.inf] * LABEL_ROWS
	for index, label in milestones:
		x = to_x(index)
		width = LABEL_CHAR_WIDTH * len(label)
		anchor, start = "middle", x - width / 2
		if start < chart.left:
			anchor, start = "start", x - 4
		elif start + width > chart.right:
			anchor, start = "end", x + 4 - width
		row = next((r for r in range(LABEL_ROWS) if start > row_ends[r] + 6), LABEL_ROWS - 1)
		row_ends[row] = start + width
		label_y = chart.top - 13 * (LABEL_ROWS - row) + 1
		text_x = x - 4 if anchor == "start" else x + 4 if anchor == "end" else x
		chart.add('<line class="marker-line" x1="%s" x2="%s" y1="%d" y2="%d"/>' %
		          (fmt(x), fmt(x), label_y + 4, chart.bottom))
		chart.add('<text class="label" x="%s" y="%d" text-anchor="%s">%s</text>' %
		          (fmt(text_x), label_y, anchor, escape(label)))

	for index, (name, party) in enumerate(battles):
		levels = [level for level, _ in party.mons]
		low, high = min(levels), max(levels)
		x = to_x(index)
		if high > low:
			chart.add('<line class="band" x1="%s" x2="%s" y1="%s" y2="%s"/>' %
			          (fmt(x), fmt(x), fmt(to_y(low)), fmt(to_y(high))))

	chart.add('<polyline class="line" points="%s"/>' % " ".join(
		"%s,%s" % (fmt(to_x(index)), fmt(to_y(max(level for level, _ in party.mons))))
		for index, (_, party) in enumerate(battles)))

	marked = set(index for index, _ in milestones)
	for index, (name, party) in enumerate(battles):
		levels = [level for level, _ in party.mons]
		x, y = fmt(to_x(index)), fmt(to_y(max(levels)))
		if index in marked:
			chart.add('<circle class="dot" cx="%s" cy="%s" r="4"/>' % (x, y))
		# An invisible hit target per battle, for the tooltip when the SVG is
		# opened on its own.
		chart.add('<circle cx="%s" cy="%s" r="6" fill="transparent"><title>#%d %s, %s: L%s'
		          '</title></circle>' %
		          (x, y, index + 1, name, escape(party.location or ""),
		           "%d" % levels[0] if min(levels) == max(levels)
		           else "%d-%d" % (min(levels), max(levels))))

	chart.legend([
		('<line class="line" x1="0" x2="16" y1="0" y2="0"/>', "Highest level on the team"),
		('<line class="band" x1="8" x2="8" y1="-6" y2="6" style="stroke-width:4"/>',
		 "Lowest to highest"),
		('<circle class="dot" cx="8" cy="0" r="4"/>', "Gym leader / Elite Four"),
	])
	return chart.render()
