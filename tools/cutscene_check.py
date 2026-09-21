#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Static map/cutscene inspector for the follower collision work.

Reconstructs a map's walkability grid in *map coordinates* straight from the
repo data (no emulator, no guessing), and optionally overlays a scripted NPC
walk on top of it, so a cutscene can be reasoned about before touching asm.

Background: Misty/Brock are nudged out of scripted NPCs' paths by writing
wPositionTrailY/X. Picking those destinations used to be guesswork - see the
"can't verify walkability from here" caveats in MtMoonB2FScript_MoveFollowers-
AsideForRockets. This makes the destination verifiable at build time.

Usage:
  cutscene_check.py --list-scenes
  cutscene_check.py MtMoonB2F
  cutscene_check.py MtMoonB2F --path MtMoonB2FJessieJamesExitMovement --from 9,3
  cutscene_check.py MtMoonB2F --path <label> --from-object MTMOONB2F_JESSIE
  cutscene_check.py MtMoonB2F --at 25,9 --radius 3
"""

import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def path(*parts):
	return os.path.join(ROOT, *parts)


def read(*parts):
	with open(path(*parts), "r", encoding="utf-8") as f:
		return f.read()


def strip_comment(line):
	# no string literals in the data files we parse, so a plain split is safe
	return line.split(";")[0].rstrip()


def parse_number(tok):
	tok = tok.strip()
	if tok.startswith("$"):
		return int(tok[1:], 16)
	if tok.startswith("%"):
		return int(tok[1:], 2)
	return int(tok, 0)


# --- repo data parsing ------------------------------------------------------

def parse_map_dims():
	"""MAP_CONST -> (width, height) in blocks, from constants/map_constants.asm."""
	dims = {}
	for line in read("constants", "map_constants.asm").splitlines():
		m = re.match(r"\s*map_const\s+(\w+)\s*,\s*(\d+)\s*,\s*(\d+)", strip_comment(line))
		if m:
			dims[m.group(1)] = (int(m.group(2)), int(m.group(3)))
	return dims


def parse_map_header(map_name):
	"""-> (MAP_CONST, TILESET_CONST) from data/maps/headers/<Map>.asm."""
	src = read("data", "maps", "headers", map_name + ".asm")
	m = re.search(r"^\s*map_header\s+(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,", src, re.M)
	if not m:
		raise SystemExit("no map_header found in headers/%s.asm" % map_name)
	return m.group(2), m.group(3)


def parse_tileset_table():
	"""TILESET_CONST -> CamelCase tileset label, matched by table index."""
	consts = []
	in_table = False
	for line in read("constants", "tileset_constants.asm").splitlines():
		line = strip_comment(line)
		if "const_def" in line:
			in_table = True
			continue
		m = re.match(r"\s*const\s+(\w+)", line)
		if in_table and m:
			consts.append(m.group(1))

	names = []
	for line in read("data", "tilesets", "tileset_headers.asm").splitlines():
		m = re.match(r"\s*tileset\s+(\w+)\s*,", strip_comment(line))
		if m:
			names.append(m.group(1))

	if len(consts) != len(names):
		raise SystemExit("tileset const/header count mismatch (%d vs %d)" % (len(consts), len(names)))
	return dict(zip(consts, names))


def parse_collision_sets():
	"""Tileset CamelCase label -> set of passable tile ids.

	Labels can be stacked (RedsHouse1_Coll:: RedsHouse2_Coll:: coll_tiles ...),
	so accumulate pending labels until the coll_tiles line that fills them.
	"""
	sets = {}
	pending = []
	for line in read("data", "tilesets", "collision_tile_ids.asm").splitlines():
		line = strip_comment(line)
		m = re.match(r"\s*(\w+)_Coll::", line)
		if m:
			pending.append(m.group(1))
			continue
		m = re.match(r"\s*coll_tiles\s+(.*)$", line)
		if m and pending:
			ids = {parse_number(t) for t in m.group(1).split(",") if t.strip()}
			for label in pending:
				sets[label] = ids
			pending = []
	return sets


def parse_blockset_files():
	"""Tileset CamelCase label -> .bst path, from gfx/tilesets.asm.

	Labels can stack across lines when tilesets share a blockset
	(Mart_Block:: / Pokecenter_Block::), same as the collision lists.
	"""
	files = {}
	pending = []
	for line in read("gfx", "tilesets.asm").splitlines():
		line = strip_comment(line)
		m = re.match(r'\s*(\w+)_Block::\s*(?:INCBIN\s+"([^"]+)")?', line)
		if not m:
			continue
		pending.append(m.group(1))
		if m.group(2):
			for label in pending:
				files[label] = m.group(2)
			pending = []
	return files


def parse_objects(map_name):
	"""-> (warps, objects); coords are map coords."""
	src = read("data", "maps", "objects", map_name + ".asm")
	m = re.search(r"^\s*db\s+(\$?\w+)\s*;\s*border block", src, re.M)
	border = parse_number(m.group(1)) if m else 0
	warps, objects = [], []
	for line in src.splitlines():
		line = strip_comment(line)
		m = re.match(r"\s*warp_event\s+(.*)$", line)
		if m:
			a = [t.strip() for t in m.group(1).split(",")]
			warps.append({"x": parse_number(a[0]), "y": parse_number(a[1]), "dest": a[2]})
			continue
		m = re.match(r"\s*object_event\s+(.*)$", line)
		if m:
			a = [t.strip() for t in m.group(1).split(",")]
			objects.append({"x": parse_number(a[0]), "y": parse_number(a[1]),
			                "sprite": a[2], "movement": a[3], "facing": a[4]})
	# the const_export block names the objects in the same order they appear
	names = re.findall(r"^\s*const_export\s+(\w+)", src, re.M)
	for i, obj in enumerate(objects):
		obj["name"] = names[i] if i < len(names) else "OBJECT_%d" % i
	return warps, objects, border


SYMBOLS = {
	"NPC_MOVEMENT_DOWN": 0x00, "NPC_MOVEMENT_UP": 0x40,
	"NPC_MOVEMENT_LEFT": 0x80, "NPC_MOVEMENT_RIGHT": 0xC0,
	"NPC_CHANGE_FACING": 0xE0, "WALK": 0xFE, "STAY": 0xFF,
}

NPC_CHANGE_FACING = 0xE0
STAY = 0xFF

# Yellow-only lookup table (Func_5288, engine/overworld/movement.asm). These
# bytes are matched BEFORE the range dispatch below and end in `scf; ret`, so
# they never reach it - which matters because all of them are numerically in
# the "< $40 = down" range. Getting this wrong makes every Jessie/James scene
# (Mt Moon B2F, Pokemon Tower 7F, Rocket Hideout B4F - the three scripts that
# use these bytes) decode as walking down through walls.
# $4/$12 -> Func_531f (down), $5/$11 -> Func_5325 (up),
# $6/$13 -> Func_5331 (left), $7/$14 -> Func_532b (right).
YELLOW_MOVEMENT_TABLE = {
	0x04: (0, 1, "down"),  0x12: (0, 1, "down"),
	0x05: (0, -1, "up"),   0x11: (0, -1, "up"),
	0x06: (-1, 0, "left"), 0x13: (-1, 0, "left"),
	0x07: (1, 0, "right"), 0x14: (1, 0, "right"),
}


def decode_movement_byte(value):
	"""-> (dx, dy, name)."""
	if value in YELLOW_MOVEMENT_TABLE:
		return YELLOW_MOVEMENT_TABLE[value]
	# NPC_CHANGE_FACING is matched before the range test, so it turns the sprite
	# without moving it despite landing in the RIGHT range.
	if value == NPC_CHANGE_FACING:
		return 0, 0, "face"
	if value < 0x40:
		return 0, 1, "down"
	if value < 0x80:
		return 0, -1, "up"
	if value < 0xC0:
		return -1, 0, "left"
	return 1, 0, "right"


def parse_movement(map_name, label):
	"""-> list of (dx, dy, name) for the `db` run starting at `label`.

	Movement data blocks are often entered at more than one label (e.g.
	MovementData_f9e65 falls through into MovementData_f9e66), so intervening
	labels are skipped rather than treated as the end of the data.
	"""
	lines = read("scripts", map_name + ".asm").splitlines()
	start = None
	for i, line in enumerate(lines):
		if re.match(r"\s*%s:" % re.escape(label), line):
			start = i + 1
			break
	if start is None:
		raise SystemExit("movement label %s not found in scripts/%s.asm" % (label, map_name))

	steps = []
	for line in lines[start:]:
		line = strip_comment(line).strip()
		if not line or re.match(r"^[A-Za-z_.]\w*:", line):
			continue
		m = re.match(r"db\s+(\S+)", line)
		if not m:
			raise SystemExit("unexpected line in movement data %s: %r" % (label, line))
		tok = m.group(1).rstrip(",")
		value = SYMBOLS[tok] if tok in SYMBOLS else parse_number(tok) & 0xFF
		if value == STAY:
			break
		steps.append(decode_movement_byte(value))
	return steps


# --- walkability grid -------------------------------------------------------

class MapGrid:
	def __init__(self, map_name):
		self.name = map_name
		map_const, tileset_const = parse_map_header(map_name)
		self.map_const = map_const
		block_w, block_h = parse_map_dims()[map_const]
		self.block_w, self.block_h = block_w, block_h
		self.width = block_w * 2   # map coords
		self.height = block_h * 2

		tileset = parse_tileset_table()[tileset_const]
		self.tileset = tileset
		passable = parse_collision_sets()[tileset]
		with open(path(parse_blockset_files()[tileset]), "rb") as f:
			blockset = f.read()
		with open(path("maps", map_name + ".blk"), "rb") as f:
			blocks = f.read()

		self.warps, self.objects, border = parse_objects(map_name)

		# A handful of .blk files are shorter than their declared dimensions
		# (inherited from vanilla - the last rows are never reachable). Pad with
		# the map's border block rather than refusing to render the map.
		expected = block_w * block_h
		self.short_by = max(0, expected - len(blocks))
		if len(blocks) < expected:
			blocks = blocks + bytes([border]) * self.short_by
		elif len(blocks) > expected:
			blocks = blocks[:expected]

		# Collision tile for map cell (x, y) is the bottom-left tile of its 2x2
		# sub-block: block-local row 2*(y&1)+1, col 2*(x&1). Derived from
		# LoadCurrentMapView's wYBlockCoord/wXBlockCoord offsets (home/overworld.asm)
		# plus the player always rendering at screen tile (8, 9), and
		# wXBlockCoord = wXCoord & 1 (engine/overworld/tilesets.asm).
		self.walkable = [[False] * self.width for _ in range(self.height)]
		self.tile_id = [[0] * self.width for _ in range(self.height)]
		for y in range(self.height):
			for x in range(self.width):
				block = blocks[(y >> 1) * block_w + (x >> 1)]
				local = (2 * (y & 1) + 1) * 4 + (2 * (x & 1))
				tile = blockset[block * 16 + local]
				self.tile_id[y][x] = tile
				self.walkable[y][x] = tile in passable

	def in_bounds(self, x, y):
		return 0 <= x < self.width and 0 <= y < self.height

	def is_walkable(self, x, y):
		return self.in_bounds(x, y) and self.walkable[y][x]

	def walk_path(self, start, steps):
		"""Follow scripted movement from `start`. Scripted NPC walks ignore
		collision (CanWalkOntoTile early-outs for scripted movement), so this
		reports blocked tiles rather than stopping at them."""
		x, y = start
		out = [(x, y)]
		for dx, dy, _name in steps:
			x, y = x + dx, y + dy
			out.append((x, y))
		return out


# --- rendering --------------------------------------------------------------

def render(grid, overlays=None, marks=None):
	"""overlays: list of (set_of_xy, char). marks: dict (x,y) -> char (wins)."""
	overlays = overlays or []
	marks = marks or {}

	occupied = {}
	for w in grid.warps:
		occupied[(w["x"], w["y"])] = "w"
	for i, o in enumerate(grid.objects):
		occupied[(o["x"], o["y"])] = "0123456789abcdefghijklmnopqrstuvwxyz"[i % 36]

	lines = []
	# column ruler
	tens = "    " + "".join(str((x // 10) % 10) if x % 5 == 0 else " " for x in range(grid.width))
	ones = "    " + "".join(str(x % 10) if x % 5 == 0 else " " for x in range(grid.width))
	lines.append(tens)
	lines.append(ones)

	for y in range(grid.height):
		row = []
		for x in range(grid.width):
			if (x, y) in marks:
				row.append(marks[(x, y)])
				continue
			ch = None
			for cells, c in overlays:
				if (x, y) in cells:
					ch = c
					break
			if ch is None:
				ch = occupied.get((x, y))
			if ch is None:
				ch = "." if grid.walkable[y][x] else "#"
			row.append(ch)
		lines.append("%3d %s" % (y, "".join(row)))
	return "\n".join(lines)


# --- scene inventory --------------------------------------------------------

LOOKBACK = 30


def find_scenes():
	"""Every scripted NPC walk in the game: each `call/jp MoveSprite` site.

	MoveSprite is the single choke point for scripted NPC movement, so this is
	the complete inventory. For each site, recover the movement data label
	(`ld de, <label>`) and the walking sprite (`ld a, <OBJECT>` feeding
	`ldh [hSpriteIndex]`) by scanning back over the enclosing script - both are
	set within a few instructions of the call in every case in this codebase.
	Branchy sites (Route 22, Pokemon Tower 7F, ...) pick between two labels, so
	all candidates found in the window are reported, not just the nearest.
	"""
	scenes = []
	for fn in sorted(os.listdir(path("scripts"))):
		if not fn.endswith(".asm"):
			continue
		map_name = fn[:-4]
		lines = read("scripts", fn).splitlines()
		enclosing = "?"
		for n, raw in enumerate(lines):
			m = re.match(r"^([A-Za-z_]\w*):", raw)
			if m:
				enclosing = m.group(1)
			if not re.search(r"\b(call|jp)\s+MoveSprite\b", strip_comment(raw)):
				continue
			window = [strip_comment(w).strip() for w in lines[max(0, n - LOOKBACK):n]]
			labels, sprite = [], None
			for w in window:
				mm = re.match(r"ld\s+de\s*,\s*([A-Za-z_]\w*)", w)
				if mm and mm.group(1) not in labels:
					labels.append(mm.group(1))
				mm = re.match(r"ld\s+a\s*,\s*([A-Z][A-Z0-9_]*)", w)
				if mm:
					sprite = mm.group(1)   # last one before the call wins
			scenes.append({"map": map_name, "script": enclosing, "line": n + 1,
			               "labels": labels, "sprite": sprite})
	return scenes


def list_scenes():
	scenes = find_scenes()
	for s in scenes:
		print("%-20s %-44s %-24s %s" % (s["map"], s["script"], s["sprite"] or "?",
		                                ",".join(s["labels"]) or "?"))
	print("\n%d scripted NPC walks in %d maps"
	      % (len(scenes), len({s["map"] for s in scenes})))


def audit():
	"""Walk every scene's path and report any that leaves walkable ground.

	A path that clips a wall means the scene is decoded wrong (bad start coord
	or movement bytes), so this doubles as a regression test on the parsers.
	"""
	grids, problems, checked, skipped = {}, [], 0, []
	for s in find_scenes():
		if s["map"] not in grids:
			try:
				grids[s["map"]] = MapGrid(s["map"])
			except Exception as e:
				grids[s["map"]] = None
				skipped.append("%s (%s)" % (s["map"], e))
		grid = grids[s["map"]]
		if grid is None:
			continue
		start = next((( o["x"], o["y"]) for o in grid.objects
		              if o["name"] == s["sprite"]), None)
		if start is None:
			skipped.append("%s %s: sprite %s" % (s["map"], s["script"], s["sprite"]))
			continue
		for label in s["labels"]:
			try:
				steps = parse_movement(s["map"], label)
			except SystemExit:
				continue
			checked += 1
			cells = grid.walk_path(start, steps)
			bad = [c for c in cells if not grid.is_walkable(*c)]
			if bad:
				problems.append((s, label, cells, bad))

	for s, label, cells, bad in problems:
		print("%s  %s  (%s via %s)" % (s["map"], s["script"], s["sprite"], label))
		print("    path (%d,%d) -> (%d,%d); off walkable ground at %s"
		      % (cells[0][0], cells[0][1], cells[-1][0], cells[-1][1],
		         " ".join("(%d,%d)" % c for c in bad)))
	print("\n%d path(s) checked, %d with non-walkable tiles" % (checked, len(problems)))
	print("NB: every path is traced from the NPC's object_event coord. Multi-stage scenes"
	      "\n    move the NPC first, so re-check those by hand with --from / --after."
	      "\n    An NPC leaving a scene is also expected to walk off the map edge.")
	for s in skipped:
		print("  not checked: %s" % s)


# --- main -------------------------------------------------------------------

def main():
	ap = argparse.ArgumentParser(description=__doc__,
	                             formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument("map", nargs="?", help="map name, e.g. MtMoonB2F")
	ap.add_argument("--list-scenes", action="store_true",
	                help="list every scripted NPC walk (call MoveSprite) in the game")
	ap.add_argument("--audit", action="store_true",
	                help="walk every scene's path and flag any that leaves walkable ground")
	ap.add_argument("--path", help="movement data label in scripts/<map>.asm")
	ap.add_argument("--from", dest="start", metavar="X,Y",
	                help="NPC start position in map coords")
	ap.add_argument("--from-object", metavar="NAME",
	                help="NPC start position, taken from the named object_event")
	ap.add_argument("--skip", type=int, default=0,
	                help="drop the first N movement bytes (scripts that `inc de`)")
	ap.add_argument("--after", action="append", default=[], metavar="LABEL",
	                help="apply an earlier stage's movement first (repeatable). Multi-stage "
	                     "scenes move the NPC before the walk you care about, so their start "
	                     "is not the object_event coord")
	ap.add_argument("--at", metavar="X,Y", help="highlight a tile (e.g. a trigger coord)")
	ap.add_argument("--radius", type=int, default=0,
	                help="with --at, also shade tiles within N walkable steps")
	args = ap.parse_args()

	if args.list_scenes:
		list_scenes()
		return

	if args.audit:
		audit()
		return

	if not args.map:
		ap.error("map is required (or use --list-scenes)")

	grid = MapGrid(args.map)
	overlays, marks = [], {}

	print("%s  (%s, tileset %s)  %dx%d blocks = %dx%d map coords"
	      % (grid.name, grid.map_const, grid.tileset,
	         grid.block_w, grid.block_h, grid.width, grid.height))

	if args.at:
		ax, ay = (int(v) for v in args.at.split(","))
		marks[(ax, ay)] = "P"
		if args.radius:
			ring = bfs(grid, (ax, ay), args.radius)
			overlays.append((ring - {(ax, ay)}, "o"))
			print("reachable within %d step(s) of (%d,%d): %d tiles"
			      % (args.radius, ax, ay, len(ring) - 1))

	if args.path:
		start = resolve_start(grid, args)
		for earlier in args.after:
			start = grid.walk_path(start, parse_movement(args.map, earlier))[-1]
			print("after %s: NPC is at (%d,%d)" % (earlier, start[0], start[1]))
		steps = parse_movement(args.map, args.path)[args.skip:]
		cells = grid.walk_path(start, steps)
		blocked = [c for c in cells if not grid.is_walkable(*c)]
		overlays.append((set(cells), "*"))
		marks[cells[0]] = "S"
		marks[cells[-1]] = "E"
		print("%s: %d step(s) from (%d,%d) to (%d,%d)  [%s]"
		      % (args.path, len(steps), cells[0][0], cells[0][1], cells[-1][0], cells[-1][1],
		         " ".join(s[2] for s in steps)))
		print("path: " + " ".join("(%d,%d)" % c for c in cells))
		if blocked:
			print("WARNING: path crosses non-walkable tiles: "
			      + " ".join("(%d,%d)" % c for c in blocked))

	print()
	print(render(grid, overlays, marks))
	print()
	print("legend: . walkable   # blocked   w warp   S/E path start/end   * path"
	      "   P marked tile   o within radius")
	for i, o in enumerate(grid.objects):
		print("  %s  (%2d,%2d) %-22s %s" %
		      ("0123456789abcdefghijklmnopqrstuvwxyz"[i % 36], o["x"], o["y"],
		       o["name"], o["sprite"]))


def resolve_start(grid, args):
	if args.start:
		x, y = (int(v) for v in args.start.split(","))
		return (x, y)
	if args.from_object:
		for o in grid.objects:
			if o["name"] == args.from_object:
				return (o["x"], o["y"])
		raise SystemExit("no object named %s on %s" % (args.from_object, grid.name))
	raise SystemExit("--path needs --from X,Y or --from-object NAME")


def bfs(grid, start, radius):
	"""Walkable tiles within `radius` steps of start (start always included)."""
	seen = {start}
	frontier = [start]
	for _ in range(radius):
		nxt = []
		for (x, y) in frontier:
			for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0)):
				c = (x + dx, y + dy)
				if c not in seen and grid.is_walkable(*c):
					seen.add(c)
					nxt.append(c)
		frontier = nxt
	return seen


if __name__ == "__main__":
	try:
		main()
	except BrokenPipeError:
		sys.exit(0)
