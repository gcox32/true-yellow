#!/usr/bin/env python3
"""
Render a map as a PNG with a map-coordinate grid, for picking object/warp spots.

Draws the real tiles (blockset + tileset gfx), then overlays:
  - a labelled x/y grid in map coords (the units object_event/warp_event use)
  - object_events as their actual sprite, facing the way the data says
  - warps (green, with destination), bg_events (yellow), hidden objects (purple)
  - with --collision, a red tint on every tile the player can't walk onto

Collision and map parsing come from cutscene_check.py, so the grid here agrees
with that tool's walkability output.

Output goes to docs/maps/ (gitignored), organised by the game's own town-map
locations (InternalMapEntries in data/maps/town_map_entries.asm):
  docs/maps/towns/pallet-town/{PalletTown,RedsHouse1F,OaksLab,...}.png
  docs/maps/routes/route-2/{Route2,Route2Gate,...}.png
  docs/maps/places/cerulean-cave/{CeruleanCave1F,CeruleanCave2F,...}.png
Pass --flat to write straight into the output directory instead.

Usage:
  map_grid.py CeruleanCave1F                 -> docs/maps/places/cerulean-cave/
  map_grid.py CeruleanCave1F PalletTown -o out/ --flat
  map_grid.py CeruleanCave1F --collision --scale 2
  map_grid.py --all                          every map with a header
"""

import argparse
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cutscene_check import (  # noqa: E402
	MapGrid, block_file, parse_blockset_files, parse_map_header, parse_number,
	parse_tileset_table, path, read, strip_comment,
)

try:
	NEAREST = Image.Resampling.NEAREST
	FLIP = Image.Transpose.FLIP_LEFT_RIGHT
except AttributeError:  # Pillow < 9.1
	NEAREST = Image.NEAREST
	FLIP = Image.FLIP_LEFT_RIGHT

COORD = 16  # pixels per map coord at scale 1 (2x2 tiles)

WARP_COLOR = (0, 170, 0)
BG_COLOR = (220, 170, 0)
HIDDEN_COLOR = (150, 60, 200)
OBJECT_COLOR = (30, 110, 255)
GRID_COLOR = (170, 170, 255)
LABEL_COLOR = (230, 0, 0)


# --- extra repo parsing (beyond what cutscene_check needs) -------------------

def parse_labelled_incbins(asm_file, suffix):
	"""Label -> INCBIN path, for files like gfx/tilesets.asm where several
	labels can stack above one INCBIN (Mart_GFX:: / Pokecenter_GFX::)."""
	files, pending = {}, []
	for line in read(asm_file).splitlines():
		line = strip_comment(line)
		m = re.match(r'\s*(\w+)%s::\s*(?:INCBIN\s+"([^"]+)")?' % suffix, line)
		if not m:
			continue
		pending.append(m.group(1))
		if m.group(2):
			for label in pending:
				files[label] = m.group(2)
			pending = []
	return files


def parse_sprite_pngs():
	"""SPRITE_CONST -> sprite sheet png path."""
	gfx = {}
	for line in read("gfx", "sprites.asm").splitlines():
		m = re.match(r'\s*(\w+)::\s*INCBIN\s+"([^"]+)"', strip_comment(line))
		if m:
			gfx[m.group(1)] = m.group(2)
	out = {}
	for line in read("data", "sprites", "sprites.asm").splitlines():
		m = re.match(r"\s*overworld_sprite\s+(\w+)\s*,.*;\s*(SPRITE_\w+)", line)
		if m and m.group(1) in gfx:
			out[m.group(2)] = gfx[m.group(1)].replace(".2bpp", ".png")
	return out


def parse_bg_events(map_name):
	src = read("data", "maps", "objects", map_name + ".asm")
	events = []
	for line in src.splitlines():
		m = re.match(r"\s*bg_event\s+(.*)$", strip_comment(line))
		if m:
			a = [t.strip() for t in m.group(1).split(",")]
			events.append({"x": parse_number(a[0]), "y": parse_number(a[1]), "text": a[2]})
	return events


def parse_hidden_objects(map_const):
	src = read("data", "events", "hidden_objects.asm")
	label = None
	for line in src.splitlines():
		m = re.match(r"\s*dbw\s+(\w+)\s*,\s*(\w+)", strip_comment(line))
		if m and m.group(1) == map_const:
			label = m.group(2)
			break
	if not label:
		return []
	out, inside = [], False
	for line in src.splitlines():
		line = strip_comment(line)
		if re.match(r"^%s:" % re.escape(label), line):
			inside = True
			continue
		if inside:
			m = re.match(r"\s*hidden_object\s+(.*)$", line)
			if m:
				a = [t.strip() for t in m.group(1).split(",")]
				out.append({"x": parse_number(a[0]), "y": parse_number(a[1]), "what": a[2]})
			elif re.match(r"\s*db\s+-1", line) or re.match(r"^\w+:", line):
				break
	return out


def map_ids():
	"""MAP_CONST -> map id, in map_constants.asm order."""
	ids = {}
	for line in read("constants", "map_constants.asm").splitlines():
		m = re.match(r"\s*map_const\s+(\w+)", strip_comment(line))
		if m:
			ids[m.group(1)] = len(ids)
	return ids


def kebab(camel):
	return re.sub(r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])", "-", camel).lower()


def location_dirs():
	"""MAP_CONST -> "towns/pallet-town" etc., using the same rules the town map
	uses to place you: outdoor maps index ExternalMapEntries, indoor maps take
	the first InternalMapEntries row whose max map id is >= theirs."""
	ids = map_ids()
	by_id = {v: k for k, v in ids.items()}
	src = read("data", "maps", "town_map_entries.asm")
	external = re.findall(r"^\s*external_map\s+\d+\s*,\s*\d+\s*,\s*(\w+)", src, re.M)
	internal = re.findall(r"^\s*internal_map\s+(\w+)\s*,\s*\d+\s*,\s*\d+\s*,\s*(\w+)", src, re.M)
	first_route = ids["ROUTE_1"]

	def group(name, outdoor_id=None):
		place = name[:-4] if name.endswith("Name") else name
		if place.startswith("Route"):
			top = "routes"
		elif outdoor_id is not None and outdoor_id < first_route or place in town_names:
			top = "towns"
		else:
			top = "places"
		return "%s/%s" % (top, kebab(place))

	town_names = {n[:-4] for n in external[:first_route] if n.endswith("Name")}
	out = {}
	for map_id, const in by_id.items():
		if map_id < len(external):
			out[const] = group(external[map_id], map_id)
			continue
		for max_const, name in internal:
			if map_id <= ids.get(max_const, -1):
				out[const] = group(name)
				break
		else:
			out[const] = "places/other"
	return out


def all_map_names():
	return sorted(f[:-4] for f in os.listdir(path("data", "maps", "headers")) if f.endswith(".asm"))


# --- rendering ---------------------------------------------------------------

def sprite_frame(png, facing):
	"""Standing frame for a facing; sheets are down/up/left (+ walking), right
	is left mirrored. One-frame sprites (balls, boulders) ignore facing.
	White (GB colour 0) becomes transparent."""
	sheet = Image.open(png).convert("L")
	frames = sheet.height // 16
	index = {"UP": 1, "LEFT": 2, "RIGHT": 2}.get(facing, 0) if frames >= 3 else 0
	frame = sheet.crop((0, index * 16, 16, index * 16 + 16))
	if facing == "RIGHT" and frames >= 3:
		frame = frame.transpose(FLIP)
	rgba = Image.new("RGBA", frame.size)
	rgba.putdata([(v, v, v, 0 if v == 255 else 255) for v in frame.getdata()])
	return rgba


def render(map_name, scale=3, collision=False):
	grid = MapGrid(map_name)
	_, tileset_const = parse_map_header(map_name)
	tileset = parse_tileset_table()[tileset_const]
	tiles_png = parse_labelled_incbins(os.path.join("gfx", "tilesets.asm"), "_GFX")[tileset]
	tiles = Image.open(path(tiles_png.replace(".2bpp", ".png"))).convert("RGB")
	per_row = tiles.width // 8
	with open(path(parse_blockset_files()[tileset]), "rb") as f:
		blockset = f.read()
	with open(path(block_file(map_name)), "rb") as f:
		blocks = f.read().ljust(grid.block_w * grid.block_h, b"\0")

	img = Image.new("RGBA", (grid.width * COORD, grid.height * COORD))
	for by in range(grid.block_h):
		for bx in range(grid.block_w):
			block = blocks[by * grid.block_w + bx]
			for i in range(16):
				t = blockset[block * 16 + i]
				sx, sy = (t % per_row) * 8, (t // per_row) * 8
				img.paste(tiles.crop((sx, sy, sx + 8, sy + 8)),
				          (bx * 32 + (i % 4) * 8, by * 32 + (i // 4) * 8))

	if collision:
		tint = Image.new("RGBA", img.size, (0, 0, 0, 0))
		d = ImageDraw.Draw(tint)
		for y in range(grid.height):
			for x in range(grid.width):
				if not grid.walkable[y][x]:
					d.rectangle([x * COORD, y * COORD, x * COORD + COORD - 1, y * COORD + COORD - 1],
					            fill=(255, 0, 0, 70))
		img = Image.alpha_composite(img, tint)

	sprites = parse_sprite_pngs()
	for obj in grid.objects:
		png = sprites.get(obj["sprite"])
		pos = (obj["x"] * COORD, obj["y"] * COORD - 4)  # sprites draw 4px up, like in-game
		if png and os.path.exists(path(png)):
			frame = sprite_frame(path(png), obj["facing"])
			img.alpha_composite(frame, (max(0, pos[0]), max(0, pos[1])))

	big = img.resize((img.width * scale, img.height * scale), NEAREST)
	d = ImageDraw.Draw(big)
	cell = COORD * scale
	font = ImageFont.load_default()

	for x in range(grid.width + 1):
		d.line([(x * cell, 0), (x * cell, big.height)], fill=GRID_COLOR)
	for y in range(grid.height + 1):
		d.line([(0, y * cell), (big.width, y * cell)], fill=GRID_COLOR)

	def box(x, y, color, label=None, width=3):
		d.rectangle([x * cell, y * cell, x * cell + cell - 1, y * cell + cell - 1],
		            outline=color, width=width)
		if label:
			d.text((x * cell + 3, y * cell + cell - 12), label, fill=color, font=font)

	for i, w in enumerate(grid.warps):
		box(w["x"], w["y"], WARP_COLOR, "w%d" % i)
	for e in parse_bg_events(map_name):
		box(e["x"], e["y"], BG_COLOR, "bg")
	for h in parse_hidden_objects(grid.map_const):
		box(h["x"], h["y"], HIDDEN_COLOR, "hid")
	for i, obj in enumerate(grid.objects):
		box(obj["x"], obj["y"], OBJECT_COLOR, str(i + 1), width=2)

	for x in range(grid.width):
		d.text((x * cell + 2, 1), str(x), fill=LABEL_COLOR, font=font)
	for y in range(grid.height):
		d.text((2, y * cell + 1), str(y), fill=LABEL_COLOR, font=font)

	return big.convert("RGB"), grid


def legend(map_name, grid):
	lines = ["%s (%s, %dx%d coords)" % (map_name, grid.map_const, grid.width, grid.height)]
	for i, obj in enumerate(grid.objects):
		lines.append("  %2d (%2d,%2d) %s %s %s" % (i + 1, obj["x"], obj["y"], obj["name"],
		                                          obj["sprite"], obj["facing"]))
	for i, w in enumerate(grid.warps):
		lines.append("  w%d (%2d,%2d) -> %s" % (i, w["x"], w["y"], w["dest"]))
	for e in parse_bg_events(map_name):
		lines.append("  bg (%2d,%2d) %s" % (e["x"], e["y"], e["text"]))
	for h in parse_hidden_objects(grid.map_const):
		lines.append("  hid (%2d,%2d) %s" % (h["x"], h["y"], h["what"]))
	return "\n".join(lines)


def main():
	ap = argparse.ArgumentParser(description=__doc__,
	                             formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument("maps", nargs="*", help="map names, e.g. CeruleanCave1F")
	ap.add_argument("--all", action="store_true", help="render every map")
	ap.add_argument("-o", "--out", default=path("docs", "maps"),
	                help="output directory (default: docs/maps, gitignored)")
	ap.add_argument("--flat", action="store_true",
	                help="don't sort into towns/routes/places location subdirs")
	ap.add_argument("--scale", type=int, default=3, help="pixel scale (default 3)")
	ap.add_argument("--collision", action="store_true",
	                help="tint tiles the player can't walk onto")
	ap.add_argument("--quiet", action="store_true", help="don't print the legend")
	args = ap.parse_args()

	names = all_map_names() if args.all else args.maps
	if not names:
		ap.error("give a map name or --all")
	dirs = {} if args.flat else location_dirs()
	failed = 0
	for name in names:
		try:
			img, grid = render(name, args.scale, args.collision)
		except (KeyError, FileNotFoundError, SystemExit) as e:
			print("%s: skipped (%s)" % (name, e), file=sys.stderr)
			failed += 1
			continue
		out_dir = os.path.join(args.out, dirs.get(grid.map_const, ""))
		os.makedirs(out_dir, exist_ok=True)
		out = os.path.join(out_dir, name + ".png")
		img.save(out)
		if not args.quiet:
			print(legend(name, grid))
		print("wrote", out)
	return 1 if failed and not args.all else 0


if __name__ == "__main__":
	sys.exit(main())
