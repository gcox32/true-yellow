#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Regenerate the shop table in docs/updates/items/MARTS.md.

One row per (shop, item), in the order the shop's menu lists them - which is the
order data/items/marts.asm writes them, so a mart's rows read like its menu.

The stock and the prices live apart, and a price can come from any of three
places, which is what this pulls together:

  data/items/marts.asm        each clerk's stock, as a `script_mart` of item ids.
                              A clerk's label says nothing about where it is, so
                              the shop is placed by which scripts/ file points at
                              the label - which also picks out the two marts
                              nothing points at.
  data/items/prices.asm       the price for an ordinary item, in BCD.
  data/items/tm_prices.asm    the price for a TM, which prices.asm doesn't hold:
                              one nybble each, in thousands.
  data/items/names.asm        the name the game prints. TMs and HMs aren't in it
                              - the game builds those names from the number - so
                              a TM is named here the way it's named on screen,
                              with the move it teaches alongside.
  data/items/vending_prices.asm  the Celadon Mart roof machine, which isn't a
                              mart at all but is the only other place that sells
                              anything.

Only the table between the generated: markers is rewritten; the prose around it
stays.

Usage:
  gen_marts_doc.py            rewrite the table in place
  gen_marts_doc.py --check    exit nonzero if the table is stale (no write)
  gen_marts_doc.py --stdout   print the generated table only
"""

import glob
import os
import re
import sys

import docgen

MARTS_ASM = docgen.path("data", "items", "marts.asm")
PRICES_ASM = docgen.path("data", "items", "prices.asm")
TM_PRICES_ASM = docgen.path("data", "items", "tm_prices.asm")
VENDING_ASM = docgen.path("data", "items", "vending_prices.asm")
SCRIPTS_DIR = docgen.path("scripts")
MARTS_DOC = docgen.path("docs", "updates", "items", "MARTS.md")

COLUMNS = ("Shop", "Item", "Price")

LABEL_RE = re.compile(r"^(\w+)::?")
MART_RE = re.compile(r"^\s*script_mart\s+([^;]*?)\s*$")
VEND_RE = re.compile(r"^\s*vend_item\s+(\w+),\s*(\d+)\s*$")
BCD3_RE = re.compile(r"^\s*bcd3\s+(\d+)")
NYBBLE_RE = re.compile(r"^\s*nybble\s+(\d+)")
DW_CONST_RE = re.compile(r"^\s*dw_const\s+(\w+)\s*,")

# A clerk label with the map's name taken off it, so two clerks in one shop can
# be told apart. Anything else in the label is left in the shop name.
CLERK_RE = re.compile(r"Clerk(\d*)Text$")

TM_PRICE_UNIT = 1000  # tm_prices.asm holds prices in thousands



def read_item_prices():
	"""[price], indexed from item id 1. 0 means the item isn't for sale."""
	prices = []
	for lineno, line in docgen.read_lines(PRICES_ASM):
		match = BCD3_RE.match(line)
		if match:
			prices.append(int(match.group(1)))
	if not prices:
		sys.exit("%s: no item prices found" % PRICES_ASM)
	return prices


def read_tm_prices(item_ids):
	"""{TM item constant: price}.

	The nybbles are prices in thousands - GetMachinePrice reads one per TM and
	shifts it into the middle BCD byte, so a nybble of 3 is 3000. They're in TM
	number order, which the item ids follow from TM01 up.
	"""
	by_id = {value: name for name, value in item_ids.items()}
	if "TM01" not in item_ids and "TM_MEGA_PUNCH" not in item_ids:
		sys.exit("%s: no TM item ids" % docgen.ITEM_CONSTANTS_ASM)
	first = min(value for name, value in item_ids.items() if name.startswith("TM_"))
	prices = {}
	for lineno, line in docgen.read_lines(TM_PRICES_ASM):
		match = NYBBLE_RE.match(line)
		if not match:
			continue
		item = by_id.get(first + len(prices))
		if item is None or not item.startswith("TM_"):
			sys.exit("%s:%d: more TM prices than TM items" % (TM_PRICES_ASM, lineno))
		prices[item] = int(match.group(1)) * TM_PRICE_UNIT
	if not prices:
		sys.exit("%s: no TM prices found" % TM_PRICES_ASM)
	return prices




def read_marts():
	"""[(clerk label, [item constants])], in the asm's order."""
	marts = []
	label = None
	for lineno, line in docgen.read_lines(MARTS_ASM):
		match = LABEL_RE.match(line)
		if match:
			label = match.group(1)
			continue
		match = MART_RE.match(line)
		if match:
			if label is None:
				sys.exit("%s:%d: script_mart before any label" % (MARTS_ASM, lineno))
			items = [item.strip() for item in match.group(1).split(",") if item.strip()]
			if not items:
				sys.exit("%s:%d: empty mart" % (MARTS_ASM, lineno))
			marts.append((label, items))
			label = None
	if not marts:
		sys.exit("%s: no marts found" % MARTS_ASM)
	return marts


def read_vending():
	"""[(item constant, price)] for the Celadon Mart roof machine."""
	drinks = []
	for lineno, line in docgen.read_lines(VENDING_ASM):
		match = VEND_RE.match(line)
		if match:
			drinks.append((match.group(1), int(match.group(2))))
	if not drinks:
		sys.exit("%s: no vending machine items found" % VENDING_ASM)
	return drinks


def read_text_owners(map_ids):
	"""{a text label: the map whose script points at it}.

	A clerk's stock sits in marts.asm under a label that says nothing about where
	the clerk is; the map's own script is what names the label.
	"""
	owners = {}
	for asm in sorted(glob.glob(os.path.join(SCRIPTS_DIR, "*.asm"))):
		map_name = None
		for lineno, line in docgen.read_lines(asm):
			match = DW_CONST_RE.match(line)
			if not match:
				continue
			if map_name is None:
				map_name = docgen.script_map(asm, map_ids)
			owners.setdefault(match.group(1), map_name)
	if not owners:
		sys.exit("%s: no dw_const text tables found" % os.path.relpath(SCRIPTS_DIR, docgen.ROOT))
	return owners



def item_price(item, prices, item_ids, tm_prices):
	"""What a shop charges, or None where nothing in the data says.

	prices.asm stops before the TM ids, so a TM's price comes from its own table
	instead - keyed by TM number, which is where the item id lands past TM01.
	"""
	if item in tm_prices:
		return tm_prices[item]
	if item not in item_ids:
		sys.exit("%s: %s is not an item constant" % (MARTS_ASM, item))
	index = item_ids[item] - 1
	if not 0 <= index < len(prices):
		sys.exit("%s: no price for item %s (id %d)" % (PRICES_ASM, item, item_ids[item]))
	return prices[index] or None


def shop_name(label, map_ids, owners, suffix=None):
	"""(the map, its id, the name to print).

	A clerk with no map pointing at it is stock nothing can buy - the asm marks
	two that way - so it's named as unused and sorted to the end.
	"""
	match = CLERK_RE.search(label)
	clerk = match.group(1) if match else ""
	base = label[:match.start()] if match else re.sub(r"Text$", "", label)

	map_name = owners.get(label)
	if map_name is None:
		# Nothing reaches it; the label's own name is the best there is, minus the
		# Unused the asm already puts on it - the marker says that once.
		spaced = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", re.sub(r"^Unused", "", base))
		return (None, None, "%s (unused)" % spaced.strip())

	name = docgen.place_name(map_name)
	for note in (("clerk %s" % clerk) if clerk else None, suffix):
		if note:
			name = "%s (%s)" % (name, note)
	return (map_name, map_ids[map_name], name)


def build_rows(map_ids, town_map, rank):
	"""Every shop's menu, in the order the player can reach the shops."""
	names, item_ids = docgen.read_item_names()
	prices = read_item_prices()
	tm_prices = read_tm_prices(item_ids)
	owners = read_text_owners(map_ids)

	shops = []
	for label, items in read_marts():
		shops.append((shop_name(label, map_ids, owners), False, items))
	# The roof machine sells the only things sold outside a mart. It sorts after
	# the clerks where it is rather than by map id, which would drop the roof in
	# among Celadon Mart's floors.
	drinks = read_vending()
	shops.append((shop_name("CeladonMartRoofVendingMachineText", map_ids, owners,
	                        "vending machine"), True, [item for item, _ in drinks]))
	vending_prices = dict(drinks)

	rows = []
	for (map_name, map_id, name), vending, items in shops:
		if map_name is None:
			where = (2, 0, 0, 0)  # unreachable stock, after everything reachable
		else:
			spot = docgen.town_map_spot(map_name, town_map)
			where = ((0, rank[spot]) if spot in rank else (1, 0)) + (vending, map_id)
		for order, item in enumerate(items):
			price = vending_prices.get(item)
			if price is None:
				price = item_price(item, prices, item_ids, tm_prices)
			if item not in names:
				sys.exit("%s: no name for %s" % (docgen.ITEM_NAMES_ASM, item))
			rows.append((where + (name, order),
			             [name, names[item],
			              "¥%d" % price if price else "not for sale"]))
	if not rows:
		sys.exit("no shop stock found in %s" % MARTS_ASM)
	rows.sort(key=lambda row: row[0])
	return [row for _, row in rows]


if __name__ == "__main__":
	all_maps, indoor = docgen.read_map_ids()
	whole_town_map, progress = docgen.read_town_map()
	docgen.main(MARTS_DOC, [
		("marts", COLUMNS,
		 lambda: build_rows(all_maps, whole_town_map, progress)),
	], __doc__)
