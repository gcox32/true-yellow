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
  cutscene_check.py --list-scenes            every scripted NPC walk in the game
  cutscene_check.py --audit                  trace them all, flag paths hitting walls
  cutscene_check.py MtMoonB2F                walkability grid, objects, warps
  cutscene_check.py MtMoonB2F --triggers     candidate scene trigger tiles

  # does this cutscene run over Misty or Brock, and does a candidate fix help?
  cutscene_check.py MtMoonB2F --trigger 3,5 --forced up \\
      --path MovementData_f9e65 --from-object MTMOONB2F_JESSIE \\
      --nudge-misty 0,-2 --nudge-brock 1,-1

Multi-stage scenes move the NPC before the walk you care about, so give the
real start with --from X,Y, or replay the earlier stage with --after LABEL.
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

# Yellow-only codes (TryExtendedMovementCode, engine/overworld/movement.asm).
# They are matched BEFORE the quadrant range dispatch below and end in
# `scf; ret`, so they never reach it - which matters because all of them are
# numerically in the "< $40 = down" range. Getting this wrong makes every
# Jessie/James scene (Mt Moon B2F, Pokemon Tower 7F, Rocket Hideout B4F - the
# three scripts that use these codes) decode as walking down through walls.
# $04-$07 step a full tile; $11-$14 slide half a tile without changing the
# sprite's map coordinate, so for path purposes they are not a step at all.
YELLOW_MOVEMENT_TABLE = {
	0x04: (0, 1, "down"),
	0x05: (0, -1, "up"),
	0x06: (-1, 0, "left"),
	0x07: (1, 0, "right"),
	# $11-$14 slide half a tile for show and never call AdvanceSpriteMapCoords,
	# so the sprite keeps its map coordinate: zero delta for path purposes.
	# Unused by any current script, but decode them correctly if one appears.
	0x11: (0, 0, "half-up"),    0x12: (0, 0, "half-down"),
	0x13: (0, 0, "half-left"),  0x14: (0, 0, "half-right"),
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


# --- follower reachability --------------------------------------------------

STEP_DIRS = {"down": (0, 1), "up": (0, -1), "left": (-1, 0), "right": (1, 0)}

# Who stands on which trail slot once everyone has settled (engine/followers).
# RecordPlayerPositionToTrail stores the player's position at the START of each
# step, so with the player stationary trail[n] is simply where they stood n+1
# steps ago.
TRAIL_OWNERS = ["Pikachu", "Misty", "Brock"]


def backward_walks(grid, end, n, blocked=frozenset()):
	"""Every legal n-step walk arriving at `end`, oldest position first.

	Tiles may repeat: a player pacing back and forth is a real approach, and
	those produce follower placements the straight-line cases never do.

	`blocked` holds tiles the player cannot stand on even though the terrain is
	passable - NPCs and ground items. Skipping this invents approaches that walk
	through the very NPC the scene is about, which then shows up as a follower
	"standing" on that NPC's start tile.
	"""
	if n <= 0:
		return [()]
	out = []

	def rec(cur, left, acc):
		if left == 0:
			out.append(tuple(reversed(acc)))
			return
		for dx, dy in STEP_DIRS.values():
			nxt = (cur[0] + dx, cur[1] + dy)
			if grid.is_walkable(*nxt) and nxt not in blocked:
				acc.append(nxt)
				rec(nxt, left - 1, acc)
				acc.pop()

	rec(end, n, [])
	return out


def follower_tiles(grid, trigger, forced=(), blocked=None):
	"""Tiles each follower can occupy when a scene acts, as {name: set}.

	`trigger` is the tile the scene fires on; `forced` are directions the script
	pushes the player before the NPCs move (Mt Moon B2F's PAD_UP, say), each of
	which shifts the trail one more slot.

	`blocked` defaults to every object_event tile on the map, since NPCs and
	ground items block the player. Hidden (missable) objects don't actually
	block until shown, so this can be slightly conservative.

	Caveats this does not model: a player who entered the map fewer than three
	steps ago has a seeded rather than walked trail, and ledge hops are ignored.
	"""
	if blocked is None:
		blocked = {(o["x"], o["y"]) for o in grid.objects}
	known = [trigger]
	cur = trigger
	for d in forced:
		cur = (cur[0] + STEP_DIRS[d][0], cur[1] + STEP_DIRS[d][1])
		known.append(cur)

	tiles = {name: set() for name in TRAIL_OWNERS}
	for prefix in backward_walks(grid, trigger, max(0, 4 - len(known)), blocked):
		history = list(prefix) + known           # oldest .. where they stand now
		for slot, name in enumerate(TRAIL_OWNERS):
			tiles[name].add(history[-(slot + 2)])
	return tiles, cur


def greedy_route(grid, start, target):
	"""Tiles a follower walks through to reach `target`.

	UpdateMistyIdleState / UpdateBrockIdleState (engine/followers/chain_follow.asm)
	close the Y gap first and only then the X gap, one tile per update. Followers
	don't collision-check either, so a route crossing a wall still arrives - it
	just looks broken on the way.
	"""
	x, y = start
	cells = [(x, y)]
	while y != target[1]:
		y += 1 if y < target[1] else -1
		cells.append((x, y))
	while x != target[0]:
		x += 1 if x < target[0] else -1
		cells.append((x, y))
	return cells


def evaluate_park(grid, starts, dest_for, npc_path, player):
	"""Problems with sending each start tile to dest_for(start). Empty == good."""
	bad = []
	for s in sorted(starts, key=lambda c: (c[1], c[0])):
		d = dest_for(s)
		if not grid.is_walkable(*d):
			bad.append("from (%d,%d): destination (%d,%d) is not walkable" % (s + d))
			continue
		route = greedy_route(grid, s, d)
		wall = [c for c in route[1:] if not grid.is_walkable(*c)]
		if wall:
			bad.append("from (%d,%d): route to (%d,%d) crosses %s"
			           % (s + d + (" ".join("(%d,%d)" % c for c in wall),)))
		if d in npc_path:
			bad.append("from (%d,%d): destination (%d,%d) is still on the NPC path" % (s + d))
		if d == player:
			bad.append("from (%d,%d): destination (%d,%d) is the player's tile" % (s + d))
	return bad


def search_park(grid, follower, starts, npc_path, player, reach=3):
	"""Deltas that move every possible start somewhere safe, nearest first.

	A constant delta is what the existing scene fixes encode (a few inc/dec on
	the trail entry), and short moves matter: the follower has to finish walking
	before the NPC reaches them.
	"""
	ok = []
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			if dx == 0 and dy == 0:
				continue
			if not evaluate_park(grid, starts, lambda s: (s[0] + dx, s[1] + dy),
			                     npc_path, player):
				ok.append((abs(dx) + abs(dy), dx, dy))
	ok.sort()
	print("  %s: %d clear delta(s)%s" % (follower, len(ok), ":" if ok else ""))
	for dist, dx, dy in ok[:8]:
		print("      (%+d,%+d)  max %d step(s)" % (dx, dy, dist))
	if not ok:
		print("      none within %d - needs absolute destinations or a stash" % reach)
	return ok


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


# --- park table verification -----------------------------------------------

# Scenes whose scripts call ParkFollowers, with the facts the asm can't state:
# where the scene fires, any scripted step it forces on the player, and which
# NPC walks it has to keep clear of. --verify-parks reads each table back out
# of the script and re-checks it, so the asm stays the source of truth.
PARKED_SCENES = [
	{
		"name": "Mt Moon B2F - Jessie and James corner the player",
		"map": "MtMoonB2F", "trigger": (3, 5), "forced": ["up"],
		"npc_paths": [((9, 3), "MovementData_f9e65"), ((9, 4), "MovementData_f9e66")],
		"table": "MtMoonB2FRocketsParkTable",
	},
	{
		"name": "Pokemon Tower 2F - rival exits, player on the right",
		"map": "PokemonTower2F", "trigger": (15, 5), "forced": [],
		"npc_paths": [((14, 5), "PokemonTower2FRivalDownThenRightMovement")],
		"table": "PokemonTower2FRivalOnLeftParkTable",
	},
	{
		"name": "Pokemon Tower 2F - rival exits, player below",
		"map": "PokemonTower2F", "trigger": (14, 6), "forced": [],
		"npc_paths": [((14, 5), "PokemonTower2FRivalRightThenDownMovement")],
		"table": "PokemonTower2FRivalBelowParkTable",
	},
]

SLOT_NAMES = {"MISTY_TRAIL_SLOT": "Misty", "BROCK_TRAIL_SLOT": "Brock"}


def parse_park_table(map_name, label):
	"""-> [(follower, danger, dest)] from the park_follower entries at `label`.

	Park tables live in the follower bank next to ParkFollowers, not beside the
	script that uses them - farcall maps that bank before the routine reads
	them. (Look in the script too, so a stray table there is still checked
	rather than silently skipped.)
	"""
	lines = read("engine", "followers", "chain_follow.asm").splitlines()
	start = next((i for i, l in enumerate(lines)
	              if re.match(r"\s*%s::?" % re.escape(label), l)), None)
	if start is None:
		lines = read("scripts", map_name + ".asm").splitlines()
		start = next((i for i, l in enumerate(lines)
		              if re.match(r"\s*%s::?" % re.escape(label), l)), None)
	if start is None:
		raise SystemExit("park table %s not found in chain_follow.asm or scripts/%s.asm"
		                 % (label, map_name))
	out = []
	for raw in lines[start + 1:]:
		line = strip_comment(raw).strip()
		if not line:
			continue
		if line.startswith("park_followers_end") or line == "db -1":
			break
		m = re.match(r"park_follower_always\s+(\w+)\s*,(.+)$", line)
		if m:
			nums = [parse_number(t) for t in m.group(2).split(",")]
			out.append((SLOT_NAMES[m.group(1)], None, (nums[0], nums[1])))
			continue
		m = re.match(r"park_follower\s+(\w+)\s*,(.+)$", line)
		if not m:
			raise SystemExit("unexpected line in park table %s: %r" % (label, line))
		nums = [parse_number(t) for t in m.group(2).split(",")]
		out.append((SLOT_NAMES[m.group(1)], (nums[0], nums[1]), (nums[2], nums[3])))
	return out


def joint_outcomes(grid, trigger, forced=()):
	"""(Misty, Brock) pairs from the SAME approach - their tiles are correlated."""
	known, cur = [trigger], trigger
	for d in forced:
		cur = (cur[0] + STEP_DIRS[d][0], cur[1] + STEP_DIRS[d][1])
		known.append(cur)
	blocked = {(o["x"], o["y"]) for o in grid.objects}
	out = set()
	for prefix in backward_walks(grid, trigger, max(0, 4 - len(known)), blocked):
		h = list(prefix) + known
		out.add((h[-3], h[-4]))
	return sorted(out), cur


def verify_parks():
	failures = 0
	for scene in PARKED_SCENES:
		grid = MapGrid(scene["map"])
		path, arrival = set(), {}
		for start, label in scene["npc_paths"]:
			cells = grid.walk_path(start, parse_movement(scene["map"], label))
			path |= set(cells)
			for i, c in enumerate(cells):
				arrival[c] = min(arrival.get(c, 99), i)
		table = parse_park_table(scene["map"], scene["table"])
		lookup = {(who, danger): dest for who, danger, dest in table}
		pairs, player = joint_outcomes(grid, scene["trigger"], scene["forced"])

		problems = []
		always = {who: dest for who, danger, dest in table if danger is None}
		if len(always) == 2 and len(set(always.values())) == 1:
			problems.append("both followers park on the same tile (%d,%d)"
			                % tuple(next(iter(always.values()))))
		for who, danger, dest in table:
			if not grid.is_walkable(*dest):
				problems.append("%s -> (%d,%d) is not walkable" % ((who,) + dest))
			if dest in path:
				problems.append("%s -> (%d,%d) is on the NPC path" % ((who,) + dest))
			if dest == player:
				problems.append("%s -> (%d,%d) is the player's tile" % ((who,) + dest))
			if danger is None:
				# park-always: the follower's start isn't known from the table,
				# so the route can't be traced - destination checks only.
				continue
			route = greedy_route(grid, danger, dest)
			for i, c in enumerate(route):
				if not grid.is_walkable(*c):
					problems.append("%s route to (%d,%d) crosses wall (%d,%d)"
					                % ((who,) + dest + c))
				elif c in arrival and i >= arrival[c]:
					problems.append("%s reaches (%d,%d) on step %d but the NPC is there "
					                "by step %d" % ((who,) + c + (i, arrival[c])))
		for m, b in pairs:
			m2 = always.get("Misty") or lookup.get(("Misty", m), m)
			b2 = always.get("Brock") or lookup.get(("Brock", b), b)
			for who, t in (("Misty", m2), ("Brock", b2)):
				if t in path:
					problems.append("approach Misty=%s Brock=%s: %s still on the path at "
					                "(%d,%d)" % (m, b, who, t[0], t[1]))
			if m2 == b2:
				problems.append("approach Misty=%s Brock=%s: both end on (%d,%d)"
				                % (m, b, m2[0], m2[1]))

		status = "FAIL" if problems else "ok"
		print("[%s] %s  (%d entr%s, %d approach outcome%s)"
		      % (status, scene["name"], len(table), "y" if len(table) == 1 else "ies",
		         len(pairs), "" if len(pairs) == 1 else "s"))
		for msg in dict.fromkeys(problems):
			print("       %s" % msg)
		failures += bool(problems)
	print("\n%d scene(s) checked, %d failing" % (len(PARKED_SCENES), failures))
	return failures


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


def find_triggers(map_name):
	"""Candidate tiles a scene can fire on, scraped from the map's script.

	Two shapes cover essentially every cutscene: a `dbmapcoord` table fed to
	ArePlayerCoordsInArray, and an inline `wXCoord`/`wYCoord` compare pair.
	Pairing a trigger with the right scene still needs eyes on the script -
	this just saves hunting for the numbers.
	"""
	lines = read("scripts", map_name + ".asm").splitlines()
	found = []
	label = "?"
	pending = {}
	for n, raw in enumerate(lines, 1):
		line = strip_comment(raw).strip()
		m = re.match(r"^([A-Za-z_.]\w*):", line)
		if m:
			label = m.group(1)
			pending = {}
		m = re.match(r"dbmapcoord\s+(\S+)\s*,\s*(\S+)", line)
		if m:
			found.append((label, parse_number(m.group(1)), parse_number(m.group(2)),
			              n, "dbmapcoord"))
			continue
		m = re.match(r"ld\s+a\s*,\s*\[w([XY])Coord\]", line)
		if m:
			pending["axis"] = m.group(1)
			continue
		m = re.match(r"cp\s+(\S+)$", line)
		if m and "axis" in pending:
			try:
				pending[pending.pop("axis")] = parse_number(m.group(1))
			except ValueError:
				pending.pop("axis", None)
			if "X" in pending and "Y" in pending:
				found.append((label, pending.pop("X"), pending.pop("Y"), n, "wXCoord/wYCoord"))
	return found


def list_triggers(map_name):
	rows = find_triggers(map_name)
	grid = MapGrid(map_name)
	for label, x, y, n, kind in rows:
		print("  (%2d,%2d) %-10s %-44s scripts/%s.asm:%d%s"
		      % (x, y, "" if grid.is_walkable(x, y) else "NOT WALKABLE",
		         label, map_name, n, "" if kind == "dbmapcoord" else "  [" + kind + "]"))
	print("%d candidate trigger tile(s) in %s" % (len(rows), map_name))


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
	ap.add_argument("--triggers", action="store_true",
	                help="list candidate scene trigger tiles scraped from the map's script")
	ap.add_argument("--verify-parks", action="store_true",
	                help="re-check every ParkFollowers table in the scripts against the "
	                     "scene it guards")
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
	ap.add_argument("--trigger", metavar="X,Y",
	                help="tile the scene fires on; enumerates every tile Misty/Brock "
	                     "can occupy there and intersects them with --path")
	ap.add_argument("--forced", metavar="DIRS",
	                help="comma-separated directions the script pushes the player before "
	                     "the NPCs move (e.g. 'up' for Mt Moon B2F's PAD_UP)")
	ap.add_argument("--nudge-misty", metavar="DX,DY",
	                help="test a candidate fix: shift every tile Misty could be on by this "
	                     "delta, then re-check walkability and collisions")
	ap.add_argument("--nudge-brock", metavar="DX,DY", help="same, for Brock")
	ap.add_argument("--search-park", action="store_true",
	                help="search for nudge deltas that move every possible follower "
	                     "position somewhere walkable, reachable and off the NPC path")
	ap.add_argument("--at", metavar="X,Y", help="highlight a tile (e.g. a trigger coord)")
	ap.add_argument("--radius", type=int, default=0,
	                help="with --at, also shade tiles within N walkable steps")
	args = ap.parse_args()

	if args.list_scenes:
		list_scenes()
		return

	if args.verify_parks:
		sys.exit(1 if verify_parks() else 0)

	if args.audit:
		audit()
		return

	if args.triggers:
		if not args.map:
			ap.error("--triggers needs a map")
		list_triggers(args.map)
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

	follower = None
	if args.trigger:
		tx, ty = (int(v) for v in args.trigger.split(","))
		forced = [d.strip() for d in args.forced.split(",")] if args.forced else []
		bad = [d for d in forced if d not in STEP_DIRS]
		if bad:
			raise SystemExit("unknown --forced direction(s): %s" % ", ".join(bad))
		if not grid.is_walkable(tx, ty):
			print("WARNING: trigger tile (%d,%d) is not walkable" % (tx, ty))
		follower, final = follower_tiles(grid, (tx, ty), forced)
		marks[final] = "P"
		print("trigger (%d,%d)%s -> player ends at (%d,%d)"
		      % (tx, ty, " + forced " + ">".join(forced) if forced else "", final[0], final[1]))
		for name in TRAIL_OWNERS:
			cells = sorted(follower[name], key=lambda c: (c[1], c[0]))
			print("  %-7s can be on %2d tile(s): %s"
			      % (name, len(cells), " ".join("(%d,%d)" % c for c in cells)))
		overlays.append((follower["Brock"] - follower["Misty"], "B"))
		overlays.append((follower["Misty"] - follower["Brock"], "M"))
		overlays.append((follower["Misty"] & follower["Brock"], "b"))

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

		if follower:
			hits = False
			for name in ("Misty", "Brock"):
				clash = sorted(follower[name] & set(cells), key=lambda c: (c[1], c[0]))
				if clash:
					hits = True
					print("COLLISION: %s can be standing on %s"
					      % (name, " ".join("(%d,%d)" % c for c in clash)))
					for c in clash:
						marks[c] = "!"
			if not hits:
				print("no collision: this path misses every tile a follower can reach")

			if args.search_park:
				print("safe park deltas (destination walkable, greedy route clear, "
				      "off the NPC path, not the player's tile):")
				for name in ("Misty", "Brock"):
					search_park(grid, name, follower[name], set(cells), final)

			nudges = {"Misty": args.nudge_misty, "Brock": args.nudge_brock}
			for name, spec in nudges.items():
				if not spec:
					continue
				dx, dy = (int(v) for v in spec.split(","))
				moved = {(c[0] + dx, c[1] + dy) for c in follower[name]}
				offmap = sorted(c for c in moved if not grid.is_walkable(*c))
				left = sorted(moved & set(cells), key=lambda c: (c[1], c[0]))
				print("nudge %s by (%+d,%+d):" % (name, dx, dy))
				if offmap:
					print("    LANDS ON NON-WALKABLE: "
					      + " ".join("(%d,%d)" % c for c in offmap))
				if left:
					print("    STILL COLLIDES on " + " ".join("(%d,%d)" % c for c in left))
				if not offmap and not left:
					print("    clear: every destination is walkable and off the path")

	print()
	print(render(grid, overlays, marks))
	print()
	print("legend: . walkable   # blocked   w warp   S/E path start/end   * path"
	      "   P player   o within radius"
	      "\n        M/B/b tiles Misty/Brock/either can occupy   ! collision")
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
