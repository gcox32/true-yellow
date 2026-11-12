# Locations

Where every Pokemon can be got, one row per place and method. Every Pokemon in the dex
has at least one row, so the ones you can't meet, be given or buy anywhere are visible as
gaps rather than absences. The table below is generated - `make` rewrites it (or run
`tools/gen_wild_doc.py`) after you edit anything under `data/wild/`, a map's
`data/maps/objects/` file, or a script that hands out or sets up a Pokemon. Hand edits to
it will be overwritten; the prose around it is preserved.

This is deliberately the Pokemon-first view. The other direction - what lives on a given
map - is what `data/wild/maps/*.asm` already is, one file per map, so it isn't duplicated
here.

## Reading the table

**Location** is the map the encounter is on, spelled out from its `constants/map_constants.asm`
name. Rows run in Pokedex order, and within one Pokemon by how early the game lets you
reach each place, following `data/maps/town_map_order.asm`.

**Method** is how the encounter happens:

- **Grass** - walking in tall grass, or anywhere on a cave/dungeon floor. The engine
  treats any non-grass, non-water tile on an indoor map as grass, so a cave's whole floor
  uses the grass slate.
- **Water** - surfing. Only reachable on maps whose water rate isn't 0.
- **Old Rod** / **Good Rod** - fishing with either of the early rods. Neither cares where
  you are, so their **Location** is `any water` and they sort in front of a Pokemon's real
  homes. The Old Rod's catch is written straight into `ItemUseOldRod` in
  `engine/items/item_effects.asm`; the Good Rod's pair is `data/wild/good_rod.asm`, and
  `ItemUseGoodRod` rerolls until it lands on one of them, so they're equally likely.
- **Super Rod** - fishing with the Super Rod, which does have a per-map slate, in
  `data/wild/super_rod.asm`.
- **Static** - a fixed encounter you walk into: the legendaries, the Snorlax blocking a
  road, the Power Plant's Voltorbs, the Pokemon Tower ghost. One per save.
- **Gift** - handed to you, already caught.
- **Trade** - an in-game trade. The Pokemon arrives at the level of whatever you handed
  over, so **Levels** reads `yours`.
- **Prize** - bought with Game Corner coins.

**Levels** is the range across that species' slots in that slate, not a random roll - a
Pokemon in four slots at four levels shows the span.

Two different dashes, and the difference matters:

- **`--`** across the whole row means the game has nowhere to get that Pokemon. It's in
  the dex, it has base stats and a cry, and no encounter, gift, trade or prize produces
  one - it has to be evolved, traded in, or brought from another cartridge.
- **`—`** in **Chance** alone means the encounter is a one-off, so a probability would be
  meaningless. The row is a real place you can get the Pokemon.

**Chance** is the share of *that* slate the species takes, so the Grass rows for one map
sum to 100%. It answers "given an encounter here, what are the odds it's this one", not
"how often does an encounter happen" - that second roll is the map's own encounter rate
byte, in `data/wild/maps/`, and it's the same for every row on a map. Route 1 Spearow at
100% means every grass encounter there is a Spearow, however much walking each one costs.

**Notes** is why a row isn't the ordinary case: which form it is, what a one-off costs or
needs, how many of a static there are.

The ten grass/water slots aren't equally likely - 19.9%, 19.9%, 15.2%, 9.8%, 9.8%, 9.8%,
5.1%, 5.1%, 4.3%, 1.2%, from `data/wild/probabilities.asm`. Neither are the Super Rod's
four: 39.8%, 29.7%, 19.9%, 10.5%, from the `cp` ladder in `GenerateRandomFishingEncounter`.
Both sets of weights are read out of the asm rather than assumed, so a **Chance** column is
only ever as wrong as the source. Every slate in the table sums to 100%.

One-off encounters - Static, Gift, Trade, Prize - have no meaningful chance and show `—`.

## The dex roster, and the alternate forms

The table is filled out against the Pokedex, not the species list. In this build that's 152
entries - `DEX_DONPHAN` is #152 - and every one of them gets at least one row.

`constants/pokemon_constants.asm` holds four species that are alternate forms rather than
Pokemon of their own: `FLOATING_MAGNETON`, `FLOATING_WEEZING`, `BROCK_ONIX` and
`ARMORED_MEWTWO`. Each shares a dex number with its base form, so the table prints the base
form's name and puts the form in **Notes** - a catchable Floating Weezing is a `WEEZING` row
noted `FLOATING`, not a second Pokemon in the first column. Its rows sort just after the base
form's, since they're the same dex entry.

Nothing about that is hardcoded: any species sharing a dex number with a lower-id one is
read as a form of it, and the part of the constant in front of the base form's name is what
**Notes** says. A new form needs no change here.

Only the base form counts towards filling the dex out, so a form that isn't catchable - as
`BROCK_ONIX` and `ARMORED_MEWTWO` aren't - never produces a `--` row, and a base form still
gets one when it's the one you can't get.

## Not counted as a way to get one

Starters are absent, as is anything a script hands over without going through
`GivePokemon` - which is how the Pikachu in Oak's lab arrives, and why only the Pikachu
battle that opens the game shows up under Pallet Town.

Two Static rows aren't really encounters and say so in **Notes**: the Pikachu Oak catches
for you, and the old man's catching demo in Viridian City. Both set up a real battle, so
they're listed rather than quietly dropped.

<!-- generated:locations -->
| Pokémon    | Location                   | Method    | Levels | Chance | Notes                                                         |
|------------|----------------------------|-----------|--------|--------|---------------------------------------------------------------|
| BULBASAUR  | Cerulean Melanie's House   | Gift      | 10     | —      |                                                               |
| IVYSAUR    | Route 16                   | Grass     | 20-22  | 39.8%  |                                                               |
| VENUSAUR   | Cerulean Cave B1F          | Grass     | 90     | 4.3%   |                                                               |
| CHARMANDER | Route 24                   | Gift      | 10     | —      |                                                               |
| CHARMANDER | Route 9                    | Grass     | 20     | 4.3%   |                                                               |
| CHARMANDER | Pokémon Mansion 1F         | Grass     | 33     | 9.8%   |                                                               |
| CHARMELEON | Safari Zone North          | Grass     | 28     | 1.2%   |                                                               |
| CHARIZARD  | Cerulean Cave B1F          | Grass     | 90     | 5.1%   |                                                               |
| SQUIRTLE   | Route 24                   | Grass     | 8      | 4.3%   |                                                               |
| SQUIRTLE   | Vermilion City             | Gift      | 10     | —      |                                                               |
| WARTORTLE  | Seafoam Islands B1F        | Grass     | 30     | 9.8%   |                                                               |
| WARTORTLE  | Seafoam Islands B2F        | Grass     | 32     | 5.1%   |                                                               |
| BLASTOISE  | Cerulean Cave B1F          | Water     | 78-85  | 25.0%  |                                                               |
| BLASTOISE  | Cerulean Cave 1F           | Water     | 64     | 1.2%   |                                                               |
| CATERPIE   | Viridian Forest            | Grass     | 4-5    | 29.7%  |                                                               |
| METAPOD    | Route 25                   | Grass     | 10     | 5.1%   |                                                               |
| BUTTERFREE | S.S. Anne 2F Rooms         | Trade     | yours  | —      | trade a RATICATE; arrives as BUTTERFREE                       |
| BUTTERFREE | Route 13                   | Grass     | 27-30  | 44.9%  |                                                               |
| WEEDLE     | Viridian Forest            | Grass     | 4-5    | 35.2%  |                                                               |
| KAKUNA     | Viridian Forest            | Grass     | 4-6    | 14.8%  |                                                               |
| BEEDRILL   | Viridian Forest            | Grass     | 9-10   | 5.5%   |                                                               |
| BEEDRILL   | Route 13                   | Grass     | 28-35  | 39.5%  |                                                               |
| PIDGEY     | Route 2                    | Grass     | 4-7    | 24.2%  |                                                               |
| PIDGEY     | Viridian Forest            | Grass     | 6      | 9.8%   |                                                               |
| PIDGEY     | Route 24                   | Grass     | 7      | 19.9%  |                                                               |
| PIDGEY     | Route 5                    | Grass     | 15-17  | 29.7%  |                                                               |
| PIDGEY     | Route 6                    | Grass     | 15-17  | 29.7%  |                                                               |
| PIDGEY     | Route 8                    | Grass     | 22     | 19.9%  |                                                               |
| PIDGEY     | Route 7                    | Grass     | 20     | 19.9%  |                                                               |
| PIDGEY     | Route 11                   | Grass     | 16     | 19.9%  |                                                               |
| PIDGEY     | Route 22                   | Grass     | 4-6    | 5.5%   |                                                               |
| PIDGEOTTO  | Viridian Forest            | Grass     | 7      | 5.1%   |                                                               |
| PIDGEOTTO  | Route 5                    | Grass     | 17     | 5.1%   |                                                               |
| PIDGEOTTO  | Route 6                    | Grass     | 17     | 5.1%   |                                                               |
| PIDGEOTTO  | Route 7                    | Grass     | 24     | 9.8%   |                                                               |
| PIDGEOTTO  | Route 11                   | Grass     | 20     | 5.1%   |                                                               |
| PIDGEOTTO  | Route 12                   | Grass     | 27     | 9.8%   |                                                               |
| PIDGEOT    | Route 23                   | Grass     | 44     | 5.1%   |                                                               |
| RATTATA    | Viridian City              | Static    | 5      | —      | the old man's catching demo, not a real encounter             |
| RATTATA    | Route 2                    | Grass     | 4      | 35.2%  |                                                               |
| RATTATA    | Route 3                    | Grass     | 8-12   | 35.9%  |                                                               |
| RATTATA    | Route 4                    | Grass     | 8-12   | 35.9%  |                                                               |
| RATTATA    | Route 5                    | Grass     | 14-16  | 29.7%  |                                                               |
| RATTATA    | Route 6                    | Grass     | 14-16  | 29.7%  |                                                               |
| RATTATA    | Route 10                   | Grass     | 18     | 19.9%  |                                                               |
| RATTATA    | Route 8                    | Grass     | 20     | 15.2%  |                                                               |
| RATTATA    | Route 7                    | Grass     | 20     | 15.2%  |                                                               |
| RATTATA    | Route 11                   | Grass     | 15     | 19.9%  |                                                               |
| RATTATA    | Route 16                   | Grass     | 21-22  | 25.0%  |                                                               |
| RATTATA    | Pokémon Mansion 3F         | Grass     | 36     | 15.2%  |                                                               |
| RATTATA    | Route 22                   | Grass     | 3      | 9.8%   |                                                               |
| RATICATE   | S.S. Anne 2F Rooms         | Trade     | yours  | —      | trade a BUTTERFREE; arrives as RATICATE                       |
| RATICATE   | Route 16                   | Grass     | 23-24  | 19.5%  |                                                               |
| RATICATE   | Pokémon Mansion 2F         | Grass     | 36     | 5.1%   |                                                               |
| RATICATE   | Pokémon Mansion B1F        | Grass     | 39     | 9.8%   |                                                               |
| SPEAROW    | Route 1                    | Grass     | 4-8    | 100.0% |                                                               |
| SPEAROW    | Route 3                    | Grass     | 10     | 9.8%   |                                                               |
| SPEAROW    | Route 4                    | Grass     | 10     | 9.8%   |                                                               |
| SPEAROW    | Route 11                   | Grass     | 18     | 15.2%  |                                                               |
| SPEAROW    | Route 18                   | Grass     | 25     | 15.2%  |                                                               |
| FEAROW     | Route 9                    | Grass     | 19     | 1.2%   |                                                               |
| FEAROW     | Route 18                   | Grass     | 28-30  | 24.6%  |                                                               |
| FEAROW     | Route 23                   | Grass     | 41     | 9.8%   |                                                               |
| EKANS      | Route 3                    | Grass     | 9-11   | 24.2%  |                                                               |
| EKANS      | Route 4                    | Grass     | 9-11   | 24.2%  |                                                               |
| EKANS      | Route 12                   | Grass     | 25     | 19.9%  |                                                               |
| EKANS      | Route 15                   | Grass     | 26     | 19.9%  |                                                               |
| ARBOK      | Route 12                   | Grass     | 26     | 5.1%   |                                                               |
| ARBOK      | Route 23                   | Grass     | 40     | 15.2%  |                                                               |
| ARBOK      | Victory Road 3F            | Grass     | 48     | 5.1%   |                                                               |
| ARBOK      | Cerulean Cave 2F           | Grass     | 60     | 9.8%   |                                                               |
| PIKACHU    | Pallet Town                | Static    | 5      | —      | cutscene - Oak catches it for you                             |
| PIKACHU    | Power Plant                | Grass     | 30     | 19.9%  |                                                               |
| RAICHU     | Power Plant                | Grass     | 28     | 9.8%   |                                                               |
| RAICHU     | Cerulean Cave B1F          | Grass     | 84     | 15.2%  |                                                               |
| SANDSHREW  | Route 3                    | Grass     | 8-10   | 14.8%  |                                                               |
| SANDSHREW  | Mt. Moon 1F                | Grass     | 6      | 9.8%   |                                                               |
| SANDSHREW  | Mt. Moon B1F               | Grass     | 10     | 9.8%   |                                                               |
| SANDSHREW  | Mt. Moon B2F               | Grass     | 11     | 9.8%   |                                                               |
| SANDSHREW  | Route 4                    | Grass     | 8-10   | 14.8%  |                                                               |
| SANDSHREW  | Route 15                   | Grass     | 26     | 19.9%  |                                                               |
| SANDSLASH  | Victory Road 1F            | Grass     | 40     | 9.8%   |                                                               |
| SANDSLASH  | Cerulean Cave 2F           | Grass     | 60     | 15.2%  |                                                               |
| NIDORAN♀   | Route 2                    | Grass     | 4-6    | 14.8%  |                                                               |
| NIDORAN♀   | Route 9                    | Grass     | 16-18  | 29.7%  |                                                               |
| NIDORAN♀   | Route 10                   | Grass     | 17     | 9.8%   |                                                               |
| NIDORAN♀   | Safari Zone East           | Grass     | 24     | 19.9%  |                                                               |
| NIDORAN♀   | Safari Zone West           | Grass     | 24     | 9.8%   |                                                               |
| NIDORAN♀   | Safari Zone Center         | Grass     | 23     | 15.2%  |                                                               |
| NIDORAN♀   | Route 22                   | Grass     | 2-4    | 29.7%  |                                                               |
| NIDORINA   | Route 9                    | Grass     | 18     | 5.1%   |                                                               |
| NIDORINA   | Safari Zone East           | Grass     | 30     | 1.2%   |                                                               |
| NIDORINA   | Route 23                   | Grass     | 43     | 9.8%   |                                                               |
| NIDOQUEEN  | Victory Road 2F            | Grass     | 45     | 5.1%   |                                                               |
| NIDORAN♂   | Route 2                    | Grass     | 4-6    | 14.8%  |                                                               |
| NIDORAN♂   | Route 9                    | Grass     | 16-18  | 29.7%  |                                                               |
| NIDORAN♂   | Route 10                   | Grass     | 17     | 9.8%   |                                                               |
| NIDORAN♂   | Safari Zone East           | Grass     | 25     | 9.8%   |                                                               |
| NIDORAN♂   | Safari Zone North          | Grass     | 24     | 19.9%  |                                                               |
| NIDORAN♂   | Safari Zone Center         | Grass     | 23     | 9.8%   |                                                               |
| NIDORAN♂   | Route 22                   | Grass     | 2-4    | 29.7%  |                                                               |
| NIDORINO   | Route 9                    | Grass     | 18     | 5.1%   |                                                               |
| NIDORINO   | Safari Zone North          | Grass     | 26     | 9.8%   |                                                               |
| NIDORINO   | Route 23                   | Grass     | 44     | 9.8%   |                                                               |
| NIDOKING   | Victory Road 1F            | Grass     | 42     | 5.1%   |                                                               |
| NIDOKING   | Victory Road 3F            | Grass     | 47     | 9.8%   |                                                               |
| CLEFAIRY   | Mt. Moon 1F                | Grass     | 8-11   | 20.7%  |                                                               |
| CLEFAIRY   | Mt. Moon B1F               | Grass     | 9      | 5.5%   |                                                               |
| CLEFAIRY   | Mt. Moon B2F               | Grass     | 9-13   | 10.5%  |                                                               |
| CLEFABLE   | Cerulean Cave B1F          | Grass     | 88     | 5.1%   |                                                               |
| VULPIX     | Pokémon Tower 5F           | Grass     | 29     | 1.2%   |                                                               |
| VULPIX     | Pokémon Tower 6F           | Grass     | 26     | 9.8%   |                                                               |
| VULPIX     | Route 8                    | Grass     | 20-24  | 29.7%  |                                                               |
| VULPIX     | Pokémon Mansion 1F         | Grass     | 33-38  | 25.0%  |                                                               |
| VULPIX     | Pokémon Mansion 2F         | Grass     | 40     | 9.8%   |                                                               |
| VULPIX     | Pokémon Mansion 3F         | Grass     | 35     | 19.9%  |                                                               |
| NINETALES  | Pokémon Tower 7F           | Grass     | 24     | 5.1%   |                                                               |
| NINETALES  | Victory Road 2F            | Grass     | 46     | 4.3%   |                                                               |
| JIGGLYPUFF | Route 5                    | Grass     | 10-14  | 9.4%   |                                                               |
| JIGGLYPUFF | Route 6                    | Grass     | 10-14  | 9.4%   |                                                               |
| JIGGLYPUFF | Route 8                    | Grass     | 24     | 5.1%   |                                                               |
| JIGGLYPUFF | Route 7                    | Grass     | 19     | 5.1%   |                                                               |
| JIGGLYPUFF | Route 14                   | Grass     | 28-29  | 25.0%  |                                                               |
| WIGGLYTUFF | Route 14                   | Grass     | 29-30  | 19.5%  |                                                               |
| WIGGLYTUFF | Cerulean Cave B1F          | Grass     | 85     | 9.8%   |                                                               |
| ZUBAT      | Mt. Moon 1F                | Grass     | 8      | 19.9%  |                                                               |
| ZUBAT      | Mt. Moon B1F               | Grass     | 8      | 19.9%  |                                                               |
| ZUBAT      | Mt. Moon B2F               | Grass     | 10-11  | 29.7%  |                                                               |
| ZUBAT      | Rock Tunnel 1F             | Grass     | 19     | 19.9%  |                                                               |
| ZUBAT      | Rock Tunnel B1F            | Grass     | 20-21  | 35.2%  |                                                               |
| ZUBAT      | Seafoam Islands 1F         | Grass     | 22     | 9.8%   |                                                               |
| GOLBAT     | Rock Tunnel B1F            | Grass     | 22     | 4.3%   |                                                               |
| GOLBAT     | Seafoam Islands B1F        | Grass     | 28     | 5.1%   |                                                               |
| GOLBAT     | Seafoam Islands B2F        | Grass     | 30     | 9.8%   |                                                               |
| GOLBAT     | Seafoam Islands B3F        | Grass     | 32     | 9.8%   |                                                               |
| GOLBAT     | Seafoam Islands B4F        | Grass     | 34     | 9.8%   |                                                               |
| GOLBAT     | Seafoam Islands 1F         | Grass     | 29     | 4.3%   |                                                               |
| GOLBAT     | Victory Road 1F            | Grass     | 38-40  | 35.2%  |                                                               |
| GOLBAT     | Victory Road 3F            | Grass     | 46     | 9.8%   |                                                               |
| GOLBAT     | Cerulean Cave 1F           | Grass     | 58     | 19.9%  |                                                               |
| ODDISH     | Mt. Moon 1F                | Grass     | 7      | 19.9%  |                                                               |
| ODDISH     | Mt. Moon B1F               | Grass     | 7      | 19.9%  |                                                               |
| ODDISH     | Mt. Moon B2F               | Grass     | 12     | 9.8%   |                                                               |
| ODDISH     | Route 11                   | Grass     | 17     | 9.8%   |                                                               |
| ODDISH     | Route 15                   | Grass     | 28     | 9.8%   |                                                               |
| GLOOM      | Route 12                   | Grass     | 29     | 5.1%   |                                                               |
| GLOOM      | Route 15                   | Grass     | 30     | 5.1%   |                                                               |
| VILEPLUME  | Cerulean Cave 2F           | Grass     | 61     | 5.1%   |                                                               |
| PARAS      | Mt. Moon 1F                | Grass     | 8-10   | 14.8%  |                                                               |
| PARAS      | Mt. Moon B1F               | Grass     | 9-11   | 14.8%  |                                                               |
| PARAS      | Mt. Moon B2F               | Grass     | 13     | 5.1%   |                                                               |
| PARAS      | Rock Tunnel B1F            | Grass     | 20     | 9.8%   |                                                               |
| PARAS      | Safari Zone East           | Grass     | 23     | 19.9%  |                                                               |
| PARASECT   | Safari Zone East           | Grass     | 28     | 9.8%   |                                                               |
| PARASECT   | Safari Zone Center         | Grass     | 30     | 4.3%   |                                                               |
| PARASECT   | Route 18 Gate 2F           | Trade     | yours  | —      | trade a TANGELA; arrives as SPIKE                             |
| PARASECT   | Cerulean Cave 2F           | Grass     | 60     | 5.1%   |                                                               |
| VENONAT    | Route 8                    | Grass     | 15     | 9.8%   |                                                               |
| VENONAT    | Route 15                   | Grass     | 24     | 15.2%  |                                                               |
| VENONAT    | Safari Zone West           | Grass     | 23     | 15.2%  |                                                               |
| VENONAT    | Safari Zone Center         | Grass     | 24     | 9.8%   |                                                               |
| VENOMOTH   | Route 8                    | Grass     | 20     | 4.3%   |                                                               |
| VENOMOTH   | Route 15                   | Grass     | 30     | 1.2%   |                                                               |
| VENOMOTH   | Safari Zone North          | Grass     | 29     | 5.1%   |                                                               |
| VENOMOTH   | Safari Zone West           | Grass     | 29     | 5.1%   |                                                               |
| VENOMOTH   | Victory Road 3F            | Grass     | 47     | 9.8%   |                                                               |
| VENOMOTH   | Cerulean Cave 1F           | Grass     | 61     | 5.1%   |                                                               |
| DIGLETT    | Diglett's Cave             | Grass     | 15-21  | 89.5%  |                                                               |
| DIGLETT    | Rock Tunnel B1F            | Grass     | 19     | 5.1%   |                                                               |
| DUGTRIO    | Diglett's Cave             | Grass     | 29-31  | 9.4%   |                                                               |
| DUGTRIO    | Victory Road 2F            | Grass     | 42     | 19.9%  |                                                               |
| DUGTRIO    | Route 11 Gate 2F           | Trade     | yours  | —      | trade a LICKITUNG; arrives as GURIO                           |
| MEOWTH     | Route 8                    | Grass     | 19-22  | 14.8%  |                                                               |
| MEOWTH     | Route 14                   | Grass     | 25     | 19.9%  |                                                               |
| MEOWTH     | Route 15                   | Grass     | 32     | 9.8%   |                                                               |
| PERSIAN    | Route 14                   | Grass     | 26-30  | 30.1%  |                                                               |
| PERSIAN    | Route 15                   | Grass     | 27     | 4.3%   |                                                               |
| PSYDUCK    | Route 24                   | Water     | 31     | 9.8%   |                                                               |
| PSYDUCK    | Route 6                    | Water     | 13-19  | 55.5%  |                                                               |
| PSYDUCK    | Safari Zone East           | Water     | 28     | 9.8%   |                                                               |
| PSYDUCK    | Safari Zone North          | Water     | 24-28  | 44.9%  |                                                               |
| PSYDUCK    | Safari Zone Center         | Water     | 28     | 9.8%   |                                                               |
| PSYDUCK    | Seafoam Islands B1F        | Grass     | 28     | 9.8%   |                                                               |
| PSYDUCK    | Seafoam Islands B2F        | Grass     | 31     | 9.8%   |                                                               |
| PSYDUCK    | Seafoam Islands 1F         | Grass     | 26     | 19.9%  |                                                               |
| PSYDUCK    | Route 22                   | Grass     | 3      | 5.1%   |                                                               |
| PSYDUCK    | Route 22                   | Water     | 31     | 9.8%   |                                                               |
| GOLDUCK    | Route 24                   | Water     | 32-36  | 10.5%  |                                                               |
| GOLDUCK    | Safari Zone East           | Water     | 32     | 4.3%   |                                                               |
| GOLDUCK    | Safari Zone North          | Water     | 29-33  | 10.5%  |                                                               |
| GOLDUCK    | Safari Zone Center         | Water     | 32     | 4.3%   |                                                               |
| GOLDUCK    | Seafoam Islands B2F        | Grass     | 36     | 5.1%   |                                                               |
| GOLDUCK    | Seafoam Islands B3F        | Grass     | 36     | 5.1%   |                                                               |
| GOLDUCK    | Seafoam Islands B4F        | Grass     | 36     | 9.8%   |                                                               |
| GOLDUCK    | Route 22                   | Water     | 32-36  | 10.5%  |                                                               |
| MANKEY     | Route 2                    | Grass     | 5-7    | 10.9%  |                                                               |
| MANKEY     | Route 3                    | Grass     | 9      | 15.2%  |                                                               |
| MANKEY     | Route 4                    | Grass     | 9      | 15.2%  |                                                               |
| MANKEY     | Rock Tunnel 1F             | Grass     | 20     | 9.8%   |                                                               |
| MANKEY     | Route 16                   | Grass     | 23-25  | 5.5%   |                                                               |
| MANKEY     | Route 22                   | Grass     | 3      | 15.2%  |                                                               |
| PRIMEAPE   | Route 23                   | Grass     | 41     | 19.9%  |                                                               |
| PRIMEAPE   | Victory Road 1F            | Grass     | 39     | 9.8%   |                                                               |
| GROWLITHE  | Route 7                    | Grass     | 19-22  | 29.7%  |                                                               |
| GROWLITHE  | Pokémon Mansion 1F         | Grass     | 33-38  | 25.0%  |                                                               |
| GROWLITHE  | Pokémon Mansion 2F         | Grass     | 33-35  | 39.8%  |                                                               |
| GROWLITHE  | Pokémon Mansion 3F         | Grass     | 30-35  | 29.7%  |                                                               |
| GROWLITHE  | Pokémon Mansion B1F        | Grass     | 36     | 15.2%  |                                                               |
| ARCANINE   | Route 23                   | Grass     | 46     | 5.1%   |                                                               |
| ARCANINE   | Cerulean Cave 2F           | Grass     | 62     | 9.8%   |                                                               |
| POLIWAG    | any water                  | Good Rod  | 10     | 50.0%  | one of the Good Rod's 2 mons, wherever you cast it            |
| POLIWAG    | Viridian City              | Super Rod | 5-15   | 100.0% | slot 1, 2, 3, 4                                               |
| POLIWAG    | Route 24                   | Water     | 30     | 19.9%  |                                                               |
| POLIWAG    | Route 6                    | Water     | 12     | 9.8%   |                                                               |
| POLIWAG    | Safari Zone East           | Water     | 26-28  | 35.2%  |                                                               |
| POLIWAG    | Safari Zone North          | Water     | 23     | 9.8%   |                                                               |
| POLIWAG    | Safari Zone Center         | Water     | 26     | 19.9%  |                                                               |
| POLIWAG    | Route 22                   | Grass     | 3      | 5.1%   |                                                               |
| POLIWAG    | Route 22                   | Water     | 30     | 19.9%  |                                                               |
| POLIWAG    | Route 22                   | Super Rod | 5-15   | 89.5%  | slot 1, 2, 3                                                  |
| POLIWAG    | Route 23                   | Super Rod | 25-30  | 69.5%  | slot 1, 2                                                     |
| POLIWHIRL  | Route 24                   | Water     | 25-28  | 20.3%  |                                                               |
| POLIWHIRL  | Route 6                    | Water     | 16     | 9.8%   |                                                               |
| POLIWHIRL  | Safari Zone East           | Water     | 28-29  | 19.5%  |                                                               |
| POLIWHIRL  | Safari Zone North          | Water     | 27     | 5.1%   |                                                               |
| POLIWHIRL  | Safari Zone Center         | Water     | 28     | 5.1%   |                                                               |
| POLIWHIRL  | Route 22                   | Water     | 25-28  | 20.3%  |                                                               |
| POLIWHIRL  | Route 22                   | Super Rod | 15     | 10.5%  | slot 4                                                        |
| POLIWHIRL  | Route 23                   | Water     | 37-39  | 14.8%  |                                                               |
| POLIWHIRL  | Route 23                   | Super Rod | 30-40  | 30.5%  | slot 3, 4                                                     |
| POLIWRATH  | Safari Zone East           | Water     | 34     | 1.2%   |                                                               |
| POLIWRATH  | Victory Road 2F            | Grass     | 44     | 9.8%   |                                                               |
| ABRA       | Route 24                   | Grass     | 10-12  | 25.0%  |                                                               |
| ABRA       | Route 25                   | Grass     | 8-12   | 44.9%  |                                                               |
| ABRA       | Route 5                    | Grass     | 10-12  | 25.0%  |                                                               |
| ABRA       | Route 6                    | Grass     | 10-12  | 25.0%  |                                                               |
| ABRA       | Route 7                    | Grass     | 15     | 9.8%   |                                                               |
| ABRA       | Game Corner Prize Room     | Prize     | 15     | —      | 250 coins                                                     |
| KADABRA    | Route 5                    | Grass     | 14     | 1.2%   |                                                               |
| KADABRA    | Route 6                    | Grass     | 14     | 1.2%   |                                                               |
| KADABRA    | Route 8                    | Grass     | 27     | 1.2%   |                                                               |
| KADABRA    | Route 7                    | Grass     | 24     | 1.2%   |                                                               |
| KADABRA    | Cerulean Cave 1F           | Grass     | 60     | 9.8%   |                                                               |
| ALAKAZAM   | Cerulean Cave 1F           | Grass     | 64     | 4.3%   |                                                               |
| MACHOP     | Rock Tunnel 1F             | Grass     | 20     | 19.9%  |                                                               |
| MACHOP     | Rock Tunnel B1F            | Grass     | 20     | 9.8%   |                                                               |
| MACHOP     | Route 10                   | Grass     | 16     | 4.3%   |                                                               |
| MACHOKE    | Victory Road 2F            | Grass     | 42     | 19.9%  |                                                               |
| MACHOKE    | Underground Path Route 5   | Trade     | yours  | —      | trade a CUBONE; arrives as RICKY                              |
| MACHAMP    | Victory Road 1F            | Grass     | 45     | 1.2%   |                                                               |
| MACHAMP    | Victory Road 3F            | Grass     | 46-52  | 21.1%  |                                                               |
| BELLSPROUT | Route 25                   | Grass     | 9-14   | 44.5%  |                                                               |
| BELLSPROUT | Route 11                   | Grass     | 18     | 5.1%   |                                                               |
| BELLSPROUT | Route 15                   | Grass     | 28     | 9.8%   |                                                               |
| BELLSPROUT | Route 21                   | Grass     | 21-23  | 19.5%  |                                                               |
| WEEPINBELL | Route 12                   | Grass     | 27     | 9.8%   |                                                               |
| WEEPINBELL | Route 15                   | Grass     | 30     | 5.1%   |                                                               |
| WEEPINBELL | Route 21                   | Grass     | 35     | 9.8%   |                                                               |
| VICTREEBEL | Route 21                   | Grass     | 30-35  | 9.4%   |                                                               |
| TENTACOOL  | Pallet Town                | Super Rod | 10-20  | 40.2%  | slot 2, 4                                                     |
| TENTACOOL  | Vermilion City             | Super Rod | 10-20  | 89.5%  | slot 1, 2, 3                                                  |
| TENTACOOL  | Vermilion Dock             | Super Rod | 10-15  | 69.5%  | slot 1, 2                                                     |
| TENTACOOL  | Route 11                   | Super Rod | 10-20  | 89.5%  | slot 1, 2, 3                                                  |
| TENTACOOL  | Route 12                   | Water     | 25     | 19.9%  |                                                               |
| TENTACOOL  | Route 13                   | Water     | 29     | 15.2%  |                                                               |
| TENTACOOL  | Route 13                   | Super Rod | 10     | 19.9%  | slot 3                                                        |
| TENTACOOL  | Route 17                   | Super Rod | 5-15   | 69.5%  | slot 1, 2                                                     |
| TENTACOOL  | Route 18                   | Super Rod | 15     | 39.8%  | slot 1                                                        |
| TENTACOOL  | Route 19                   | Water     | 30-32  | 39.8%  |                                                               |
| TENTACOOL  | Route 19                   | Super Rod | 15-30  | 59.8%  | slot 1, 3                                                     |
| TENTACOOL  | Route 20                   | Water     | 30-32  | 39.8%  |                                                               |
| TENTACOOL  | Route 20                   | Super Rod | 20     | 39.8%  | slot 1                                                        |
| TENTACOOL  | Cinnabar Island            | Super Rod | 15-30  | 40.2%  | slot 2, 4                                                     |
| TENTACOOL  | Route 21                   | Water     | 30-32  | 19.5%  |                                                               |
| TENTACOOL  | Route 21                   | Super Rod | 15-30  | 59.8%  | slot 1, 3                                                     |
| TENTACRUEL | Route 12                   | Water     | 30     | 5.1%   |                                                               |
| TENTACRUEL | Route 13                   | Water     | 33     | 4.3%   |                                                               |
| TENTACRUEL | Route 19                   | Water     | 32-36  | 5.5%   |                                                               |
| TENTACRUEL | Route 19                   | Super Rod | 30     | 10.5%  | slot 4                                                        |
| TENTACRUEL | Route 20                   | Water     | 32-36  | 5.5%   |                                                               |
| TENTACRUEL | Route 20                   | Super Rod | 20-40  | 40.2%  | slot 2, 4                                                     |
| TENTACRUEL | Route 21                   | Water     | 36     | 5.1%   |                                                               |
| TENTACRUEL | Route 21                   | Super Rod | 30     | 10.5%  | slot 4                                                        |
| TENTACRUEL | Cerulean Cave B1F          | Water     | 80     | 9.8%   |                                                               |
| TENTACRUEL | Cerulean Cave 1F           | Water     | 60     | 19.9%  |                                                               |
| GEODUDE    | Mt. Moon 1F                | Grass     | 8-10   | 14.8%  |                                                               |
| GEODUDE    | Mt. Moon B1F               | Grass     | 7-10   | 30.1%  |                                                               |
| GEODUDE    | Mt. Moon B2F               | Grass     | 11-13  | 35.2%  |                                                               |
| GEODUDE    | Rock Tunnel 1F             | Grass     | 19-21  | 25.0%  |                                                               |
| GEODUDE    | Rock Tunnel B1F            | Grass     | 19-21  | 29.7%  |                                                               |
| GRAVELER   | Rock Tunnel B1F            | Grass     | 24     | 1.2%   |                                                               |
| GRAVELER   | Victory Road 1F            | Grass     | 39     | 19.9%  |                                                               |
| GOLEM      | Victory Road 2F            | Grass     | 48     | 1.2%   |                                                               |
| GOLEM      | Victory Road 3F            | Grass     | 46     | 19.9%  |                                                               |
| PONYTA     | Route 9                    | Grass     | 16-19  | 25.0%  |                                                               |
| PONYTA     | Route 11                   | Grass     | 17     | 1.2%   |                                                               |
| PONYTA     | Route 17                   | Grass     | 26-28  | 55.1%  |                                                               |
| PONYTA     | Route 18                   | Grass     | 25-27  | 49.6%  |                                                               |
| PONYTA     | Safari Zone West           | Grass     | 24-27  | 29.7%  |                                                               |
| RAPIDASH   | Safari Zone West           | Grass     | 32     | 1.2%   |                                                               |
| RAPIDASH   | Victory Road 2F            | Grass     | 45     | 5.1%   |                                                               |
| SLOWPOKE   | Route 12                   | Water     | 26-29  | 40.2%  |                                                               |
| SLOWPOKE   | Route 13                   | Water     | 29-30  | 29.7%  |                                                               |
| SLOWPOKE   | Safari Zone East           | Water     | 30     | 5.1%   |                                                               |
| SLOWPOKE   | Safari Zone West           | Water     | 26-30  | 44.9%  |                                                               |
| SLOWPOKE   | Safari Zone Center         | Water     | 27     | 9.8%   |                                                               |
| SLOWPOKE   | Seafoam Islands B1F        | Grass     | 29     | 9.8%   |                                                               |
| SLOWPOKE   | Seafoam Islands 1F         | Grass     | 28     | 5.1%   |                                                               |
| SLOWBRO    | Route 12                   | Water     | 33     | 1.2%   |                                                               |
| SLOWBRO    | Route 13                   | Water     | 32     | 5.1%   |                                                               |
| SLOWBRO    | Safari Zone West           | Water     | 31     | 5.1%   |                                                               |
| SLOWBRO    | Seafoam Islands B4F        | Grass     | 38     | 4.3%   |                                                               |
| SLOWBRO    | Seafoam Islands 1F         | Grass     | 38     | 1.2%   |                                                               |
| MAGNEMITE  | Route 10                   | Grass     | 16-22  | 50.0%  |                                                               |
| MAGNEMITE  | Pokémon Mansion 1F         | Grass     | 31     | 9.8%   |                                                               |
| MAGNEMITE  | Pokémon Mansion B1F        | Grass     | 35     | 19.9%  |                                                               |
| MAGNEMITE  | Power Plant                | Grass     | 30     | 29.7%  |                                                               |
| MAGNETON   | Power Plant                | Grass     | 32     | 5.1%   |                                                               |
| MAGNETON   | Cerulean Cave B1F          | Grass     | 82     | 19.9%  | FLOATING                                                      |
| FARFETCHD  | Route 12                   | Grass     | 28-29  | 14.1%  |                                                               |
| DODUO      | Route 16                   | Grass     | 21-22  | 10.2%  |                                                               |
| DODUO      | Route 17                   | Grass     | 26-27  | 19.5%  |                                                               |
| DODUO      | Safari Zone West           | Grass     | 24     | 19.9%  |                                                               |
| DODUO      | Safari Zone Center         | Grass     | 25     | 9.8%   |                                                               |
| DODRIO     | Route 17                   | Grass     | 29-31  | 19.9%  |                                                               |
| DODRIO     | Safari Zone West           | Grass     | 29     | 5.1%   |                                                               |
| SEEL       | Seafoam Islands B1F        | Grass     | 28     | 19.9%  |                                                               |
| SEEL       | Seafoam Islands B2F        | Grass     | 30     | 19.9%  |                                                               |
| SEEL       | Seafoam Islands B3F        | Grass     | 33     | 15.2%  |                                                               |
| SEEL       | Seafoam Islands B3F        | Water     | 34     | 9.8%   |                                                               |
| SEEL       | Seafoam Islands B4F        | Grass     | 34     | 15.2%  |                                                               |
| SEEL       | Seafoam Islands 1F         | Grass     | 26     | 19.9%  |                                                               |
| SEEL       | Route 23                   | Water     | 38-39  | 35.2%  |                                                               |
| DEWGONG    | Seafoam Islands B1F        | Grass     | 38     | 1.2%   |                                                               |
| DEWGONG    | Seafoam Islands B2F        | Grass     | 35     | 4.3%   |                                                               |
| DEWGONG    | Seafoam Islands B3F        | Grass     | 35     | 5.1%   |                                                               |
| DEWGONG    | Seafoam Islands B3F        | Water     | 35     | 5.1%   |                                                               |
| DEWGONG    | Seafoam Islands B4F        | Grass     | 35     | 19.9%  |                                                               |
| DEWGONG    | Seafoam Islands B4F        | Water     | 36     | 9.8%   |                                                               |
| DEWGONG    | Cinnabar Lab Trade Room    | Trade     | yours  | —      | trade a GROWLITHE; arrives as CEZANNE                         |
| DEWGONG    | Route 23                   | Water     | 42-46  | 35.2%  |                                                               |
| GRIMER     | Celadon City               | Water     | 25-32  | 94.5%  |                                                               |
| GRIMER     | Pokémon Mansion 1F         | Grass     | 33     | 9.8%   |                                                               |
| GRIMER     | Pokémon Mansion 2F         | Grass     | 34     | 9.8%   |                                                               |
| GRIMER     | Pokémon Mansion 3F         | Grass     | 34     | 9.8%   |                                                               |
| GRIMER     | Pokémon Mansion B1F        | Grass     | 36     | 9.8%   |                                                               |
| MUK        | Celadon City               | Water     | 33-36  | 5.5%   |                                                               |
| MUK        | Cinnabar Lab Fossil Room   | Trade     | yours  | —      | trade a KANGASKHAN; arrives as STICKY                         |
| MUK        | Pokémon Mansion 2F         | Grass     | 38     | 5.1%   |                                                               |
| MUK        | Pokémon Mansion 3F         | Grass     | 36     | 5.1%   |                                                               |
| MUK        | Pokémon Mansion B1F        | Grass     | 42     | 4.3%   |                                                               |
| SHELLDER   | Vermilion Dock             | Super Rod | 10     | 10.5%  | slot 4                                                        |
| SHELLDER   | Route 12                   | Water     | 26     | 9.8%   |                                                               |
| SHELLDER   | Route 13                   | Water     | 29     | 9.8%   |                                                               |
| SHELLDER   | Route 17                   | Super Rod | 25-35  | 30.5%  | slot 3, 4                                                     |
| SHELLDER   | Route 18                   | Super Rod | 20-40  | 60.2%  | slot 2, 3, 4                                                  |
| SHELLDER   | Seafoam Islands B1F        | Grass     | 28     | 19.9%  |                                                               |
| SHELLDER   | Seafoam Islands B2F        | Grass     | 30     | 15.2%  |                                                               |
| SHELLDER   | Seafoam Islands B3F        | Grass     | 32     | 19.9%  |                                                               |
| SHELLDER   | Seafoam Islands B3F        | Water     | 33     | 19.9%  |                                                               |
| SHELLDER   | Seafoam Islands 1F         | Grass     | 27     | 5.1%   |                                                               |
| CLOYSTER   | Seafoam Islands B3F        | Grass     | 36     | 4.3%   |                                                               |
| CLOYSTER   | Seafoam Islands B3F        | Water     | 38     | 1.2%   |                                                               |
| CLOYSTER   | Seafoam Islands B4F        | Grass     | 37     | 5.1%   |                                                               |
| CLOYSTER   | Seafoam Islands B4F        | Water     | 38     | 5.1%   |                                                               |
| CLOYSTER   | Cerulean Cave B1F          | Water     | 82     | 9.8%   |                                                               |
| CLOYSTER   | Cerulean Cave 1F           | Water     | 62     | 9.8%   |                                                               |
| GASTLY     | Pokémon Tower 3F           | Grass     | 18-24  | 89.5%  |                                                               |
| GASTLY     | Pokémon Tower 4F           | Grass     | 22-28  | 75.8%  |                                                               |
| GASTLY     | Pokémon Tower 5F           | Grass     | 23-26  | 74.6%  |                                                               |
| GASTLY     | Pokémon Tower 6F           | Grass     | 23-25  | 55.1%  |                                                               |
| GASTLY     | Pokémon Tower 7F           | Grass     | 24-25  | 39.8%  |                                                               |
| GASTLY     | Pokémon Mansion B1F        | Grass     | 36     | 5.1%   |                                                               |
| HAUNTER    | Pokémon Tower 3F           | Grass     | 25     | 1.2%   |                                                               |
| HAUNTER    | Pokémon Tower 4F           | Grass     | 24-25  | 14.8%  |                                                               |
| HAUNTER    | Pokémon Tower 5F           | Grass     | 23-25  | 14.1%  |                                                               |
| HAUNTER    | Pokémon Tower 6F           | Grass     | 24-29  | 25.8%  |                                                               |
| HAUNTER    | Pokémon Tower 7F           | Grass     | 23-25  | 34.8%  |                                                               |
| GENGAR     | Pokémon Tower 7F           | Grass     | 29-30  | 5.5%   |                                                               |
| GENGAR     | Cerulean Cave 2F           | Grass     | 60     | 9.8%   |                                                               |
| ONIX       | Diglett's Cave             | Grass     | 31     | 1.2%   |                                                               |
| ONIX       | Rock Tunnel 1F             | Grass     | 20     | 5.1%   |                                                               |
| ONIX       | Rock Tunnel B1F            | Grass     | 20     | 5.1%   |                                                               |
| ONIX       | Route 23                   | Grass     | 60     | 4.3%   |                                                               |
| ONIX       | Victory Road 1F            | Grass     | 40     | 9.8%   |                                                               |
| ONIX       | Victory Road 2F            | Grass     | 44     | 15.2%  |                                                               |
| DROWZEE    | Route 7                    | Grass     | 24-26  | 9.4%   |                                                               |
| DROWZEE    | Route 11                   | Grass     | 15-17  | 19.5%  |                                                               |
| HYPNO      | Cerulean Cave 1F           | Grass     | 60     | 19.9%  |                                                               |
| KRABBY     | Route 24                   | Grass     | 12-14  | 24.6%  |                                                               |
| KRABBY     | Route 25                   | Super Rod | 10-15  | 69.5%  | slot 1, 2                                                     |
| KRABBY     | Route 10                   | Super Rod | 15-20  | 69.5%  | slot 1, 2                                                     |
| KRABBY     | Route 12                   | Water     | 26     | 9.8%   |                                                               |
| KRABBY     | Route 13                   | Water     | 28     | 19.9%  |                                                               |
| KRABBY     | Route 18                   | Grass     | 28     | 5.1%   |                                                               |
| KRABBY     | Seafoam Islands B1F        | Grass     | 29     | 5.1%   |                                                               |
| KRABBY     | Seafoam Islands B3F        | Super Rod | 25     | 39.8%  | slot 1                                                        |
| KRABBY     | Seafoam Islands B4F        | Super Rod | 25     | 39.8%  | slot 1                                                        |
| KRABBY     | Seafoam Islands 1F         | Grass     | 26     | 9.8%   |                                                               |
| KINGLER    | Route 25                   | Super Rod | 15-25  | 30.5%  | slot 3, 4                                                     |
| KINGLER    | Route 10                   | Super Rod | 25     | 10.5%  | slot 4                                                        |
| KINGLER    | Route 12                   | Water     | 30     | 4.3%   |                                                               |
| KINGLER    | Route 13                   | Water     | 32     | 5.1%   |                                                               |
| KINGLER    | Route 18                   | Grass     | 30-34  | 5.5%   |                                                               |
| KINGLER    | Seafoam Islands B3F        | Grass     | 33     | 9.8%   |                                                               |
| KINGLER    | Seafoam Islands B3F        | Super Rod | 35     | 19.9%  | slot 3                                                        |
| KINGLER    | Seafoam Islands B4F        | Grass     | 34     | 19.9%  |                                                               |
| KINGLER    | Seafoam Islands B4F        | Super Rod | 35     | 19.9%  | slot 3                                                        |
| KINGLER    | Cerulean Cave 1F           | Grass     | 62     | 9.8%   |                                                               |
| VOLTORB    | Fuchsia Gym                | Grass     | 20-41  | 100.0% |                                                               |
| VOLTORB    | Power Plant                | Grass     | 33     | 15.2%  |                                                               |
| VOLTORB    | Power Plant                | Static    | 40     | —      | 5 of them, one per save                                       |
| ELECTRODE  | Power Plant                | Grass     | 35     | 9.8%   |                                                               |
| ELECTRODE  | Power Plant                | Static    | 43     | —      | 2 of them, one per save                                       |
| ELECTRODE  | Cerulean Cave B1F          | Grass     | 84     | 9.8%   |                                                               |
| EXEGGCUTE  | Route 12                   | Grass     | 25-28  | 35.2%  |                                                               |
| EXEGGCUTE  | Safari Zone East           | Grass     | 24     | 15.2%  |                                                               |
| EXEGGCUTE  | Safari Zone North          | Grass     | 25     | 15.2%  |                                                               |
| EXEGGCUTE  | Safari Zone West           | Grass     | 25     | 9.8%   |                                                               |
| EXEGGCUTE  | Safari Zone Center         | Grass     | 24     | 19.9%  |                                                               |
| EXEGGUTOR  | Route 12                   | Grass     | 31     | 1.2%   |                                                               |
| CUBONE     | Rock Tunnel 1F             | Grass     | 20     | 9.8%   |                                                               |
| CUBONE     | Route 10                   | Grass     | 20     | 5.1%   |                                                               |
| CUBONE     | Pokémon Tower 3F           | Grass     | 20-22  | 9.4%   |                                                               |
| CUBONE     | Pokémon Tower 4F           | Grass     | 20-22  | 9.4%   |                                                               |
| CUBONE     | Pokémon Tower 5F           | Grass     | 21-25  | 10.2%  |                                                               |
| CUBONE     | Pokémon Tower 6F           | Grass     | 21-23  | 9.4%   |                                                               |
| CUBONE     | Safari Zone East           | Grass     | 23     | 9.8%   |                                                               |
| MAROWAK    | Pokémon Tower 6F           | Static    | 30     | —      | the restless soul - needs the Poké Flute's Silph Scope reveal |
| MAROWAK    | Pokémon Tower 7F           | Grass     | 22-28  | 14.8%  |                                                               |
| MAROWAK    | Safari Zone East           | Grass     | 28     | 5.1%   |                                                               |
| MAROWAK    | Victory Road 3F            | Grass     | 47     | 15.2%  |                                                               |
| MAROWAK    | Cerulean Cave 2F           | Grass     | 60     | 19.9%  |                                                               |
| HITMONLEE  | Rock Tunnel 1F             | Grass     | 20     | 5.1%   |                                                               |
| HITMONLEE  | Fighting Dojo              | Gift      | 30     | —      | one of the two, your pick                                     |
| HITMONLEE  | Victory Road 1F            | Grass     | 42     | 5.1%   |                                                               |
| HITMONCHAN | Rock Tunnel 1F             | Grass     | 20-22  | 5.5%   |                                                               |
| HITMONCHAN | Fighting Dojo              | Gift      | 30     | —      | one of the two, your pick                                     |
| HITMONCHAN | Victory Road 1F            | Grass     | 42     | 4.3%   |                                                               |
| LICKITUNG  | Route 24                   | Grass     | 12     | 1.2%   |                                                               |
| LICKITUNG  | Cerulean Cave 2F           | Grass     | 62     | 4.3%   |                                                               |
| KOFFING    | Pokémon Mansion 1F         | Grass     | 34     | 15.2%  |                                                               |
| KOFFING    | Pokémon Mansion 2F         | Grass     | 36     | 15.2%  |                                                               |
| KOFFING    | Pokémon Mansion 3F         | Grass     | 34     | 9.8%   |                                                               |
| KOFFING    | Pokémon Mansion B1F        | Grass     | 32     | 19.9%  |                                                               |
| WEEZING    | Route 17                   | Grass     | 32-35  | 5.5%   |                                                               |
| WEEZING    | Pokémon Mansion 2F         | Grass     | 32     | 9.8%   |                                                               |
| WEEZING    | Pokémon Mansion B1F        | Grass     | 40     | 5.1%   | FLOATING                                                      |
| WEEZING    | Cerulean Cave 1F           | Grass     | 59     | 5.1%   | FLOATING                                                      |
| RHYHORN    | Safari Zone North          | Grass     | 25     | 19.9%  |                                                               |
| RHYHORN    | Safari Zone Center         | Grass     | 27     | 5.1%   |                                                               |
| RHYDON     | Cinnabar Lab Trade Room    | Trade     | yours  | —      | trade a GOLDUCK; arrives as BUFFY                             |
| RHYDON     | Route 23                   | Grass     | 60     | 1.2%   |                                                               |
| RHYDON     | Victory Road 2F            | Grass     | 44     | 9.8%   |                                                               |
| RHYDON     | Victory Road 3F            | Grass     | 50     | 5.1%   |                                                               |
| RHYDON     | Cerulean Cave 2F           | Grass     | 62     | 19.9%  |                                                               |
| CHANSEY    | Safari Zone East           | Grass     | 26     | 5.1%   |                                                               |
| CHANSEY    | Safari Zone Center         | Grass     | 26     | 1.2%   |                                                               |
| CHANSEY    | Route 23                   | Grass     | 40     | 19.9%  |                                                               |
| CHANSEY    | Cerulean Cave B1F          | Grass     | 82-100 | 21.1%  |                                                               |
| TANGELA    | Route 13                   | Grass     | 36-38  | 5.5%   |                                                               |
| TANGELA    | Route 21                   | Grass     | 21-30  | 55.1%  |                                                               |
| KANGASKHAN | Safari Zone North          | Grass     | 27-30  | 14.8%  |                                                               |
| KANGASKHAN | Safari Zone West           | Grass     | 28     | 4.3%   |                                                               |
| KANGASKHAN | Victory Road 3F            | Grass     | 50     | 4.3%   |                                                               |
| HORSEA     | Route 25                   | Water     | 20-30  | 44.9%  |                                                               |
| HORSEA     | Vermilion City             | Super Rod | 5      | 10.5%  | slot 4                                                        |
| HORSEA     | Route 10                   | Super Rod | 10     | 19.9%  | slot 3                                                        |
| HORSEA     | Route 11                   | Super Rod | 5      | 10.5%  | slot 4                                                        |
| HORSEA     | Route 12                   | Super Rod | 20-25  | 69.5%  | slot 1, 2                                                     |
| HORSEA     | Route 13                   | Super Rod | 15-20  | 69.5%  | slot 1, 2                                                     |
| HORSEA     | Route 19                   | Water     | 28-31  | 25.0%  |                                                               |
| HORSEA     | Seafoam Islands B1F        | Grass     | 29     | 15.2%  |                                                               |
| HORSEA     | Seafoam Islands B2F        | Grass     | 31     | 9.8%   |                                                               |
| HORSEA     | Seafoam Islands B3F        | Water     | 33     | 19.9%  |                                                               |
| HORSEA     | Seafoam Islands 1F         | Grass     | 27     | 9.8%   |                                                               |
| HORSEA     | Route 20                   | Water     | 28-31  | 25.0%  |                                                               |
| SEADRA     | Route 25                   | Water     | 32     | 4.3%   |                                                               |
| SEADRA     | Route 12                   | Super Rod | 25-35  | 30.5%  | slot 3, 4                                                     |
| SEADRA     | Route 13                   | Super Rod | 20     | 10.5%  | slot 4                                                        |
| SEADRA     | Seafoam Islands B1F        | Grass     | 32     | 4.3%   |                                                               |
| SEADRA     | Seafoam Islands B3F        | Grass     | 34     | 9.8%   |                                                               |
| SEADRA     | Seafoam Islands B3F        | Water     | 34     | 9.8%   |                                                               |
| SEADRA     | Seafoam Islands B4F        | Grass     | 36     | 5.1%   |                                                               |
| SEADRA     | Seafoam Islands B4F        | Water     | 36     | 15.2%  |                                                               |
| SEADRA     | Route 21                   | Water     | 35-40  | 5.5%   |                                                               |
| SEADRA     | Cerulean Cave B1F          | Water     | 82     | 5.1%   |                                                               |
| SEADRA     | Cerulean Cave 1F           | Water     | 63     | 4.3%   |                                                               |
| GOLDEEN    | any water                  | Good Rod  | 10     | 50.0%  | one of the Good Rod's 2 mons, wherever you cast it            |
| GOLDEEN    | Route 4                    | Super Rod | 20-30  | 89.5%  | slot 1, 2, 3                                                  |
| GOLDEEN    | Cerulean City              | Super Rod | 25-30  | 69.5%  | slot 1, 2                                                     |
| GOLDEEN    | Route 24                   | Water     | 32     | 19.9%  |                                                               |
| GOLDEEN    | Route 24                   | Super Rod | 20-30  | 89.5%  | slot 1, 2, 3                                                  |
| GOLDEEN    | Route 6                    | Water     | 12-15  | 25.0%  |                                                               |
| GOLDEEN    | Route 6                    | Super Rod | 5-20   | 100.0% | slot 1, 2, 3, 4                                               |
| GOLDEEN    | Celadon City               | Super Rod | 5-20   | 100.0% | slot 1, 2, 3, 4                                               |
| GOLDEEN    | Safari Zone East           | Water     | 27     | 19.9%  |                                                               |
| GOLDEEN    | Safari Zone North          | Water     | 25     | 19.9%  |                                                               |
| GOLDEEN    | Safari Zone West           | Water     | 25     | 9.8%   |                                                               |
| GOLDEEN    | Safari Zone Center         | Water     | 27-29  | 35.2%  |                                                               |
| GOLDEEN    | Route 21                   | Water     | 30-36  | 55.1%  |                                                               |
| GOLDEEN    | Route 22                   | Water     | 32     | 19.9%  |                                                               |
| GOLDEEN    | Cerulean Cave B1F          | Super Rod | 30     | 39.8%  | slot 1                                                        |
| GOLDEEN    | Cerulean Cave 1F           | Super Rod | 25     | 39.8%  | slot 1                                                        |
| SEAKING    | Route 4                    | Super Rod | 30     | 10.5%  | slot 4                                                        |
| SEAKING    | Cerulean City              | Super Rod | 30-40  | 30.5%  | slot 3, 4                                                     |
| SEAKING    | Route 24                   | Water     | 30     | 19.5%  |                                                               |
| SEAKING    | Route 24                   | Super Rod | 30     | 10.5%  | slot 4                                                        |
| SEAKING    | Safari Zone East           | Water     | 30     | 5.1%   |                                                               |
| SEAKING    | Safari Zone North          | Water     | 27     | 9.8%   |                                                               |
| SEAKING    | Safari Zone West           | Water     | 29     | 5.1%   |                                                               |
| SEAKING    | Safari Zone Center         | Water     | 30-35  | 16.0%  |                                                               |
| SEAKING    | Route 21                   | Water     | 32-33  | 14.8%  |                                                               |
| SEAKING    | Route 22                   | Water     | 30     | 19.5%  |                                                               |
| SEAKING    | Route 23                   | Water     | 41-42  | 14.8%  |                                                               |
| SEAKING    | Cerulean Cave B1F          | Super Rod | 40-60  | 60.2%  | slot 2, 3, 4                                                  |
| SEAKING    | Cerulean Cave 1F           | Super Rod | 35-55  | 60.2%  | slot 2, 3, 4                                                  |
| STARYU     | Pallet Town                | Super Rod | 5-10   | 59.8%  | slot 1, 3                                                     |
| STARYU     | Route 24                   | Grass     | 8-13   | 25.0%  |                                                               |
| STARYU     | Vermilion Dock             | Super Rod | 15     | 19.9%  | slot 3                                                        |
| STARYU     | Route 12                   | Water     | 27     | 9.8%   |                                                               |
| STARYU     | Route 13                   | Water     | 29     | 9.8%   |                                                               |
| STARYU     | Route 19                   | Water     | 30     | 19.5%  |                                                               |
| STARYU     | Route 19                   | Super Rod | 20     | 29.7%  | slot 2                                                        |
| STARYU     | Seafoam Islands B3F        | Super Rod | 20-40  | 40.2%  | slot 2, 4                                                     |
| STARYU     | Seafoam Islands B4F        | Super Rod | 20-40  | 40.2%  | slot 2, 4                                                     |
| STARYU     | Seafoam Islands 1F         | Grass     | 28     | 15.2%  |                                                               |
| STARYU     | Route 20                   | Water     | 30     | 19.5%  |                                                               |
| STARYU     | Route 20                   | Super Rod | 30     | 19.9%  | slot 3                                                        |
| STARYU     | Cinnabar Island            | Super Rod | 10-15  | 59.8%  | slot 1, 3                                                     |
| STARYU     | Route 21                   | Super Rod | 20     | 29.7%  | slot 2                                                        |
| STARMIE    | Route 13                   | Water     | 35     | 1.2%   |                                                               |
| STARMIE    | Cerulean Cave B1F          | Water     | 80     | 9.8%   |                                                               |
| STARMIE    | Cerulean Cave 1F           | Grass     | 62     | 15.2%  |                                                               |
| STARMIE    | Cerulean Cave 1F           | Water     | 60     | 15.2%  |                                                               |
| MR_MIME    | Route 2 Trade House        | Trade     | yours  | —      | trade a CLEFAIRY; arrives as MILES                            |
| MR_MIME    | Route 21                   | Grass     | 28-32  | 6.2%   |                                                               |
| SCYTHER    | Route 11                   | Grass     | 19     | 4.3%   |                                                               |
| SCYTHER    | Route 13                   | Grass     | 30     | 5.1%   |                                                               |
| SCYTHER    | Safari Zone East           | Grass     | 28     | 4.3%   |                                                               |
| JYNX       | Seafoam Islands B2F        | Grass     | 31     | 19.9%  |                                                               |
| JYNX       | Seafoam Islands B3F        | Grass     | 33     | 19.9%  |                                                               |
| JYNX       | Seafoam Islands B4F        | Grass     | 35     | 9.8%   |                                                               |
| JYNX       | Cerulean Cave 1F           | Grass     | 60     | 9.8%   |                                                               |
| ELECTABUZZ | Power Plant                | Grass     | 35     | 5.1%   |                                                               |
| MAGMAR     | Pokémon Mansion 1F         | Grass     | 33     | 4.3%   |                                                               |
| MAGMAR     | Pokémon Mansion 2F         | Grass     | 36     | 4.3%   |                                                               |
| MAGMAR     | Pokémon Mansion 3F         | Grass     | 38     | 5.1%   |                                                               |
| MAGMAR     | Victory Road 2F            | Grass     | 43     | 9.8%   |                                                               |
| PINSIR     | Route 25                   | Grass     | 7-8    | 5.5%   |                                                               |
| PINSIR     | Route 13                   | Grass     | 32     | 5.1%   |                                                               |
| PINSIR     | Safari Zone North          | Grass     | 27     | 9.8%   |                                                               |
| TAUROS     | Route 14                   | Grass     | 28-32  | 5.5%   |                                                               |
| TAUROS     | Safari Zone North          | Grass     | 27     | 4.3%   |                                                               |
| TAUROS     | Safari Zone Center         | Grass     | 26-29  | 25.0%  |                                                               |
| MAGIKARP   | any water                  | Old Rod   | 5      | 100.0% | every Old Rod bite, wherever you cast it                      |
| MAGIKARP   | Route 25                   | Water     | 25-35  | 25.0%  |                                                               |
| MAGIKARP   | Fuchsia City               | Super Rod | 5-15   | 89.5%  | slot 1, 2, 3                                                  |
| MAGIKARP   | Safari Zone East           | Super Rod | 5-15   | 89.5%  | slot 1, 2, 3                                                  |
| MAGIKARP   | Safari Zone North          | Super Rod | 5-15   | 89.5%  | slot 1, 2, 3                                                  |
| MAGIKARP   | Safari Zone West           | Water     | 20-25  | 29.7%  |                                                               |
| MAGIKARP   | Safari Zone West           | Super Rod | 5-15   | 89.5%  | slot 1, 2, 3                                                  |
| MAGIKARP   | Safari Zone Center         | Super Rod | 5-10   | 69.5%  | slot 1, 2                                                     |
| MAGIKARP   | Route 19                   | Water     | 35     | 5.1%   |                                                               |
| MAGIKARP   | Route 20                   | Water     | 35     | 5.1%   |                                                               |
| MAGIKARP   | Mt. Moon Poké Center       | Gift      | 5      | —      | sold to you for ¥500                                          |
| GYARADOS   | Route 25                   | Water     | 25     | 5.1%   |                                                               |
| GYARADOS   | Fuchsia City               | Super Rod | 15     | 10.5%  | slot 4                                                        |
| GYARADOS   | Safari Zone West           | Water     | 29     | 4.3%   |                                                               |
| GYARADOS   | Route 19                   | Water     | 25     | 5.1%   |                                                               |
| GYARADOS   | Route 20                   | Water     | 25     | 5.1%   |                                                               |
| GYARADOS   | Cerulean Cave B1F          | Water     | 78-85  | 24.2%  |                                                               |
| GYARADOS   | Cerulean Cave 1F           | Water     | 60-63  | 25.0%  |                                                               |
| LAPRAS     | Silph Co. 7F               | Gift      | 15     | —      |                                                               |
| LAPRAS     | Seafoam Islands B3F        | Water     | 32-35  | 20.3%  |                                                               |
| LAPRAS     | Seafoam Islands B4F        | Water     | 34-40  | 35.9%  |                                                               |
| LAPRAS     | Cerulean Cave B1F          | Water     | 80     | 15.2%  |                                                               |
| LAPRAS     | Cerulean Cave 1F           | Water     | 62     | 5.1%   |                                                               |
| DITTO      | Pokémon Mansion B1F        | Grass     | 40     | 1.2%   |                                                               |
| DITTO      | Cerulean Cave B1F          | Grass     | 85     | 9.8%   |                                                               |
| DITTO      | Cerulean Cave 1F           | Grass     | 63     | 1.2%   |                                                               |
| EEVEE      | Celadon Mansion Roof House | Gift      | 25     | —      |                                                               |
| EEVEE      | Game Corner Prize Room     | Prize     | 18     | —      | 1000 coins                                                    |
| VAPOREON   | Seafoam Islands B2F        | Grass     | 37     | 1.2%   |                                                               |
| VAPOREON   | Seafoam Islands B3F        | Grass     | 39     | 1.2%   |                                                               |
| VAPOREON   | Seafoam Islands B4F        | Grass     | 40     | 1.2%   |                                                               |
| JOLTEON    | Power Plant                | Grass     | 36     | 1.2%   |                                                               |
| FLAREON    | Pokémon Mansion 1F         | Grass     | 36     | 1.2%   |                                                               |
| FLAREON    | Pokémon Mansion 2F         | Grass     | 39     | 1.2%   |                                                               |
| FLAREON    | Pokémon Mansion 3F         | Grass     | 35-37  | 5.5%   |                                                               |
| PORYGON    | Pokémon Mansion B1F        | Grass     | 40     | 9.8%   |                                                               |
| PORYGON    | Power Plant                | Grass     | 33     | 4.3%   |                                                               |
| OMANYTE    | Game Corner Prize Room     | Prize     | 20     | —      | 3000 coins                                                    |
| OMANYTE    | Cinnabar Lab Fossil Room   | Gift      | 30     | —      | revived from the matching fossil                              |
| OMASTAR    | Cerulean Cave 1F           | Water     | 61     | 9.8%   |                                                               |
| KABUTO     | Game Corner Prize Room     | Prize     | 20     | —      | 3000 coins                                                    |
| KABUTO     | Cinnabar Lab Fossil Room   | Gift      | 30     | —      | revived from the matching fossil                              |
| KABUTOPS   | Cerulean Cave 1F           | Water     | 61     | 9.8%   |                                                               |
| AERODACTYL | Game Corner Prize Room     | Prize     | 20     | —      | 3000 coins                                                    |
| AERODACTYL | Cinnabar Lab Fossil Room   | Gift      | 30     | —      | revived from the matching fossil                              |
| SNORLAX    | Route 12                   | Static    | 30     | —      | one per save                                                  |
| SNORLAX    | Route 16                   | Static    | 30     | —      | one per save                                                  |
| ARTICUNO   | Seafoam Islands B4F        | Static    | 50     | —      | one per save                                                  |
| ZAPDOS     | Power Plant                | Static    | 50     | —      | one per save                                                  |
| MOLTRES    | Victory Road 2F            | Static    | 50     | —      | one per save                                                  |
| DRATINI    | Route 25                   | Water     | 15-30  | 19.5%  |                                                               |
| DRATINI    | Game Corner Prize Room     | Prize     | 22     | —      | 3000 coins                                                    |
| DRATINI    | Safari Zone East           | Super Rod | 15     | 10.5%  | slot 4                                                        |
| DRATINI    | Safari Zone North          | Super Rod | 15     | 10.5%  | slot 4                                                        |
| DRATINI    | Safari Zone West           | Water     | 25     | 1.2%   |                                                               |
| DRATINI    | Safari Zone West           | Super Rod | 15     | 10.5%  | slot 4                                                        |
| DRATINI    | Safari Zone Center         | Super Rod | 10     | 19.9%  | slot 3                                                        |
| DRAGONAIR  | Route 25                   | Water     | 40     | 1.2%   |                                                               |
| DRAGONAIR  | Safari Zone Center         | Super Rod | 15     | 10.5%  | slot 4                                                        |
| DRAGONAIR  | Seafoam Islands B3F        | Water     | 33-36  | 14.1%  |                                                               |
| DRAGONAIR  | Seafoam Islands B4F        | Water     | 35-40  | 34.0%  |                                                               |
| DRAGONITE  | Cerulean Cave B1F          | Water     | 90     | 1.2%   |                                                               |
| MEWTWO     | Cerulean Cave B1F          | Static    | 70     | —      | one per save                                                  |
| MEW        | Vermilion Dock             | Static    | 7      | —      | one per save                                                  |
| DONPHAN    | Route 10                   | Grass     | 25     | 1.2%   |                                                               |
| DONPHAN    | Cerulean Cave 2F           | Grass     | 70     | 1.2%   |                                                               |
<!-- /generated:locations -->
