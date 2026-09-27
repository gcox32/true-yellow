# Game Corner prizes

What the Celadon Game Corner's prize counters hand out, and what they charge in coins. The
table below is generated - `make` rewrites it (or run `tools/gen_prizes_doc.py`) after you
edit `data/events/prizes.asm` or `data/events/prize_mon_levels.asm`. Hand edits to it will
be overwritten; the prose around it is preserved.

All three counters are in the Game Corner prize room, one per vendor, left to right.

## Reading the table

**Counter** is the vendor, numbered the way the engine numbers them: the text id of the
vendor you talk to becomes `wWhichPrizeWindow` (0-2), which indexes
`PrizeDifferentMenuPtrs`. Whether a counter hands out Pokemon or items isn't implied by the
order - `PrizeMenuIsItemWindow` says so explicitly, and that flag is what the bracket
reports.

**Prize** is the species constant for a Pokemon, or the name the menu shows for an item.
TMs aren't in `data/items/names.asm` - the game builds those names from the number - so
they're shown as the menu shows them, with the move they teach in brackets.

**Level** only means anything on a Pokemon counter, and comes from
`PrizeMonLevelDictionary` in `data/events/prize_mon_levels.asm`. A `—` is an item counter,
where a level would be meaningless.

**Cost** is the `bcd2` coin price from the list paired with the counter's offers.

A **Counter** of `none` is the last group of rows: a `PrizeMonLevelDictionary` entry that no
counter offers. Those aren't prizes - they're levels with nothing to apply to - and they're
listed so the table covers both files rather than half of each.

## The level dictionary can fall out of step

`prizes.asm` and `prize_mon_levels.asm` are joined by nothing but the species, and
`GetPrizeMonLevel` walks the dictionary comparing species until one matches - with no
end-of-table check. A prize that isn't in the dictionary therefore doesn't get a default
level: the scan runs off the end of the table and whatever byte follows becomes the level.

A **Level** of `?` in the table means exactly that, and the generator warns about it on
every build. The two files agree as things stand, so no row says `?` today.

The mismatch runs both ways, and a **Counter** of `none` is the other direction - a level
with no prize to apply it to. That one breaks nothing, so it's a row rather than a warning.
A `?` and a `none` row appearing together is the shape to watch for: it means a prize was
swapped out on one counter and its level left behind in the dictionary, so changing the
offers in `prizes.asm` means changing the dictionary too.

<!-- generated:prizes -->
| Counter     | Prize              | Level | Cost       |
|-------------|--------------------|-------|------------|
| 1 (Pokémon) | ABRA               | 15    | 250 coins  |
| 1 (Pokémon) | EEVEE              | 18    | 1000 coins |
| 1 (Pokémon) | DRATINI            | 22    | 3000 coins |
| 2 (Pokémon) | OMANYTE            | 20    | 3000 coins |
| 2 (Pokémon) | KABUTO             | 20    | 3000 coins |
| 2 (Pokémon) | AERODACTYL         | 20    | 3000 coins |
| 3 (items)   | TM23 (DRAGON RAGE) | —     | 5000 coins |
| 3 (items)   | TM15 (HYPER BEAM)  | —     | 6000 coins |
| 3 (items)   | TM50 (SUBSTITUTE)  | —     | 7000 coins |
<!-- /generated:prizes -->
