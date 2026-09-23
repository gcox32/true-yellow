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
