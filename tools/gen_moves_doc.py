#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the move table in docs/updates/battle/MOVES.md from data/moves/moves.asm.

The doc used to carry a hand-written "UPDATE" column describing how each move
differed from vanilla; it drifted out of sync with the asm and is gone. Only
the table between the generated: markers is rewritten - the prose around it
(intro, Animations, Effects) is left exactly as it was.

Usage:
  gen_moves_doc.py            rewrite the table in place
  gen_moves_doc.py --check    exit nonzero if the table is stale (no write)
  gen_moves_doc.py --stdout   print the generated table only
"""

import re
import sys

import docgen

MOVES_ASM = docgen.path("data", "moves", "moves.asm")
MOVES_DOC = docgen.path("docs", "updates", "battle", "MOVES.md")

COLUMNS = ("Move", "Effect", "Power", "Type", "Accuracy", "PP")

# `move NAME, EFFECT, POWER, TYPE, ACCURACY, PP` with an optional trailing comment.
MOVE_RE = re.compile(r"^\s*move\s+(.+?)\s*(?:;.*)?$")


def read_moves():
	moves = []
	with open(MOVES_ASM, encoding="utf-8") as f:
		for lineno, line in enumerate(f, 1):
			if line.lstrip().startswith("MACRO"):
				continue
			match = MOVE_RE.match(line)
			if not match:
				continue
			fields = [field.strip() for field in match.group(1).split(",")]
			if len(fields) != len(COLUMNS):
				sys.exit("%s:%d: expected %d fields, got %d" %
				         (MOVES_ASM, lineno, len(COLUMNS), len(fields)))
			moves.append(fields)
	if not moves:
		sys.exit("no moves found in %s" % MOVES_ASM)
	return moves


if __name__ == "__main__":
	docgen.main(MOVES_DOC, [("moves", COLUMNS, read_moves)], __doc__)
