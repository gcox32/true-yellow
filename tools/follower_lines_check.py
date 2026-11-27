#!/usr/bin/env python3
"""Check data/followers/follower_lines.asm.

- Every text/line/cont/para string fits in 17 tiles (the 18-tile text box
  minus the column the "more text" arrow is drawn in)
  (<PLAYER>/<RIVAL> counted as 7, "#" as 4 for POKé).
- No "--" in dialogue.
- Every text tagged "; EPxxx" is an exact line by that speaker in that
  episode (docs/anime/lines.tsv, gitignored; skipped if missing).
  Allowed differences: case, spacing/punctuation, Ash -> <PLAYER>,
  and the transcript typos listed in TYPO_FIXES.

Usage: python3 tools/follower_lines_check.py
"""
import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASM = ROOT / "data/followers/follower_lines.asm"
TSV = ROOT / "docs/anime/lines.tsv"
WIDTH = 17  # 18 tiles, minus 1 for the "more text" arrow
TYPO_FIXES = {"disguisting": "disgusting"}

# multi-character tiles (constants/charmap.asm)
TOKENS = [("<PLAYER>", 7), ("<RIVAL>", 7), ("<TM>", 2), ("#", 4),
          ("'d", 1), ("'l", 1), ("'s", 1), ("'t", 1), ("'v", 1), ("'r", 1), ("'m", 1)]


def tiles(s):
    n = i = 0
    while i < len(s):
        for tok, w in TOKENS:
            if s.startswith(tok, i):
                n += w
                i += len(tok)
                break
        else:
            n += 1
            i += 1
    return n


def norm(s):
    s = s.lower().replace("<player>", "ash").replace("#", "poké")
    s = s.replace("ash ketchum", "ash")
    for bad, good in TYPO_FIXES.items():
        s = s.replace(bad, good)
    return re.sub(r"[^a-z0-9é]", "", s)


def parse_texts():
    texts, cur = [], None
    for num, line in enumerate(ASM.read_text().splitlines(), 1):
        m = re.match(r"^(\.?\w+):(?:\s*;\s*EP(\d+))?\s*$", line)
        if m:
            cur = {"label": m.group(1), "ep": m.group(2), "lines": [], "at": num}
            texts.append(cur)
            continue
        m = re.match(r'^\s*(text|line|cont|para)\s+"(.*)"', line)
        if m and cur is not None:
            cur["lines"].append((num, m.group(2)))
    return [t for t in texts if t["lines"]]


def main():
    errors = 0
    texts = parse_texts()
    for t in texts:
        for num, s in t["lines"]:
            w = tiles(s)
            if w > WIDTH:
                print(f"{ASM.name}:{num}: {w} tiles > {WIDTH}: \"{s}\"")
                errors += 1
            if "--" in s:
                print(f"{ASM.name}:{num}: no \"--\" in dialogue: \"{s}\"")
                errors += 1

    if TSV.exists():
        eps = {}
        with open(TSV) as f:
            for row in csv.DictReader(f, delimiter="\t"):
                eps.setdefault((int(row["ep"][2:]), row["speaker"].lower()), []).append(norm(row["line"]))
        quotes = 0
        for t in texts:
            if not t["ep"]:
                continue
            quotes += 1
            full = " ".join(s for _, s in t["lines"])
            m = re.match(r"(\w+):\s*(.*)", full)
            speaker, said = m.group(1).lower(), norm(m.group(2))
            source = eps.get((int(t["ep"]), speaker), [])
            if not any(said in line for line in source):
                print(f"{ASM.name}:{t['at']}: {t['label']} is not an exact "
                      f"EP{t['ep']} line by {speaker.upper()}")
                errors += 1
        print(f"{len(texts)} texts, {quotes} quotes checked against {TSV.relative_to(ROOT)}")
    else:
        print(f"{TSV.relative_to(ROOT)} missing: quote check skipped")

    if errors:
        print(f"{errors} problem(s)")
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
