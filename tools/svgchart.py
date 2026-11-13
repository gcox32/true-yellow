#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
The frame the generated doc charts are drawn in, as SVG text: the size, the
title block, the axes and a legend, plus the shared stylesheet.

Colors are CSS classes with a dark-mode override, so a chart follows the
viewer's color scheme when a doc embeds it as an image. Every number is written
at a fixed precision, so the same data always renders to the same bytes and
`make check-docs` can compare it.
"""

import math
from xml.sax.saxutils import escape

DEFAULT_WIDTH = 960
DEFAULT_HEIGHT = 400
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

	def __init__(self, title, subtitle, description,
	             width=DEFAULT_WIDTH, height=DEFAULT_HEIGHT, left=MARGIN_LEFT):
		self.parts = []
		self.width = width
		self.height = height
		self.left = left
		self.right = width - MARGIN_RIGHT
		self.top = MARGIN_TOP
		self.bottom = height - MARGIN_BOTTOM
		WIDTH, HEIGHT = width, height
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
		         (fmt((self.left + self.right) / 2), self.height - 10, escape(title)))

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
