# Marts

Everywhere in the game that sells something, and what it charges. The table below is
generated - run `make docs` (or `tools/gen_marts_doc.py`) after editing
`data/items/marts.asm`, `data/items/prices.asm`, `data/items/tm_prices.asm`,
`data/items/names.asm` or `data/items/vending_prices.asm`. Hand edits to it will be
overwritten; the prose around it is preserved.

## Reading the table

Rows run in the order the player can reach the shops, following
`data/maps/town_map_order.asm`, and within one shop in the order its menu lists the stock -
which is the order `script_mart` writes it.

**Shop** is the map the clerk is on. `data/items/marts.asm` keys its stock by clerk label,
not by map, so each label is placed by finding the `scripts/` file that points at it. Where
one shop has two clerks with separate stock - Celadon Mart's TM floors - the clerk is named
too.

**Price** is what the clerk charges. It comes from one of three places depending on the
item, which is the main reason this table is worth generating:

- an ordinary item's price is `data/items/prices.asm`, indexed by item id
- a TM's price is *not* in that table - `prices.asm` stops before the TM ids. It's one
  nybble per TM in `data/items/tm_prices.asm`, in thousands, so a nybble of 3 is ¥3000
- the three drinks are `data/items/vending_prices.asm`, which the roof machine reads
  directly instead of going through either table

`not for sale` means the item is stocked but `prices.asm` has 0 for it, so the clerk would
give it away. Nothing in the reachable shops is in that state today.

**Item** is the name the game prints, from `data/items/names.asm`. TMs and HMs aren't in
that list - the game builds those names from the number - so they're shown the way the
menu shows them, with the move they teach in brackets.

## Shops nothing can reach

Two `script_mart` entries have no map pointing at them and are marked `(unused)`:
`UnusedBikeShopClerkText`, which would sell a bicycle, and `UnusedMartClerkText`. They're
listed at the end rather than dropped, since the stock is real data and wiring a clerk up
to one is a one-line change.

<!-- generated:marts -->
| Shop                                | Item                | Price        |
|-------------------------------------|---------------------|--------------|
| Viridian Mart                       | POKé BALL           | ¥200         |
| Viridian Mart                       | POTION              | ¥300         |
| Viridian Mart                       | ANTIDOTE            | ¥100         |
| Viridian Mart                       | PARLYZ HEAL         | ¥200         |
| Viridian Mart                       | BURN HEAL           | ¥250         |
| Pewter Mart                         | POKé BALL           | ¥200         |
| Pewter Mart                         | POTION              | ¥300         |
| Pewter Mart                         | ESCAPE ROPE         | ¥550         |
| Pewter Mart                         | ANTIDOTE            | ¥100         |
| Pewter Mart                         | BURN HEAL           | ¥250         |
| Pewter Mart                         | AWAKENING           | ¥200         |
| Pewter Mart                         | PARLYZ HEAL         | ¥200         |
| Cerulean Mart                       | POKé BALL           | ¥200         |
| Cerulean Mart                       | POTION              | ¥300         |
| Cerulean Mart                       | ESCAPE ROPE         | ¥550         |
| Cerulean Mart                       | REPEL               | ¥350         |
| Cerulean Mart                       | ANTIDOTE            | ¥100         |
| Cerulean Mart                       | BURN HEAL           | ¥250         |
| Cerulean Mart                       | AWAKENING           | ¥200         |
| Cerulean Mart                       | PARLYZ HEAL         | ¥200         |
| Vermilion Mart                      | POKé BALL           | ¥200         |
| Vermilion Mart                      | SUPER POTION        | ¥700         |
| Vermilion Mart                      | ICE HEAL            | ¥250         |
| Vermilion Mart                      | AWAKENING           | ¥200         |
| Vermilion Mart                      | PARLYZ HEAL         | ¥200         |
| Vermilion Mart                      | REPEL               | ¥350         |
| Lavender Mart                       | GREAT BALL          | ¥600         |
| Lavender Mart                       | SUPER POTION        | ¥700         |
| Lavender Mart                       | REVIVE              | ¥1500        |
| Lavender Mart                       | ESCAPE ROPE         | ¥550         |
| Lavender Mart                       | SUPER REPEL         | ¥500         |
| Lavender Mart                       | ANTIDOTE            | ¥100         |
| Lavender Mart                       | BURN HEAL           | ¥250         |
| Lavender Mart                       | ICE HEAL            | ¥250         |
| Lavender Mart                       | PARLYZ HEAL         | ¥200         |
| Celadon Mart 2F (clerk 1)           | TM12 (WATER GUN)    | ¥1000        |
| Celadon Mart 2F (clerk 1)           | TM14 (BLIZZARD)     | ¥5000        |
| Celadon Mart 2F (clerk 1)           | TM16 (PAY DAY)      | ¥5000        |
| Celadon Mart 2F (clerk 1)           | TM17 (SUBMISSION)   | ¥3000        |
| Celadon Mart 2F (clerk 1)           | TM18 (COUNTER)      | ¥2000        |
| Celadon Mart 2F (clerk 1)           | TM19 (SEISMIC TOSS) | ¥3000        |
| Celadon Mart 2F (clerk 1)           | TM20 (RAGE)         | ¥2000        |
| Celadon Mart 2F (clerk 1)           | TM22 (SOLARBEAM)    | ¥5000        |
| Celadon Mart 2F (clerk 1)           | TM28 (DIG)          | ¥2000        |
| Celadon Mart 2F (clerk 2)           | TM01 (MEGA PUNCH)   | ¥3000        |
| Celadon Mart 2F (clerk 2)           | TM02 (RAZOR WIND)   | ¥2000        |
| Celadon Mart 2F (clerk 2)           | TM03 (SWORDS DANCE) | ¥2000        |
| Celadon Mart 2F (clerk 2)           | TM04 (WHIRLWIND)    | ¥1000        |
| Celadon Mart 2F (clerk 2)           | TM05 (MEGA KICK)    | ¥3000        |
| Celadon Mart 2F (clerk 2)           | TM07 (HORN DRILL)   | ¥2000        |
| Celadon Mart 2F (clerk 2)           | TM08 (BODY SLAM)    | ¥4000        |
| Celadon Mart 2F (clerk 2)           | TM09 (TAKE DOWN)    | ¥3000        |
| Celadon Mart 2F (clerk 2)           | TM10 (DOUBLE EDGE)  | ¥4000        |
| Celadon Mart 4F                     | POKé DOLL           | ¥1000        |
| Celadon Mart 4F                     | FIRE STONE          | ¥2100        |
| Celadon Mart 4F                     | THUNDERSTONE        | ¥2100        |
| Celadon Mart 4F                     | WATER STONE         | ¥2100        |
| Celadon Mart 4F                     | LEAF STONE          | ¥2100        |
| Celadon Mart 5F (clerk 1)           | TM30 (TELEPORT)     | ¥1000        |
| Celadon Mart 5F (clerk 1)           | TM32 (DOUBLE TEAM)  | ¥1000        |
| Celadon Mart 5F (clerk 1)           | TM33 (REFLECT)      | ¥1000        |
| Celadon Mart 5F (clerk 1)           | TM37 (EGG BOMB)     | ¥2000        |
| Celadon Mart 5F (clerk 1)           | TM40 (SKULL BASH)   | ¥4000        |
| Celadon Mart 5F (clerk 1)           | TM43 (SKY ATTACK)   | ¥5000        |
| Celadon Mart 5F (clerk 1)           | TM44 (REST)         | ¥2000        |
| Celadon Mart 5F (clerk 1)           | TM45 (THUNDER WAVE) | ¥2000        |
| Celadon Mart 5F (clerk 1)           | TM47 (EXPLOSION)    | ¥3000        |
| Celadon Mart 5F (clerk 2)           | HP UP               | ¥9800        |
| Celadon Mart 5F (clerk 2)           | IRON                | ¥9800        |
| Celadon Mart 5F (clerk 2)           | PROTEIN             | ¥9800        |
| Celadon Mart 5F (clerk 2)           | CARBOS              | ¥9800        |
| Celadon Mart 5F (clerk 2)           | CALCIUM             | ¥9800        |
| Celadon Mart 5F (clerk 2)           | PP UP               | ¥3000        |
| Celadon Mart Roof (vending machine) | FRESH WATER         | ¥50          |
| Celadon Mart Roof (vending machine) | SODA POP            | ¥50          |
| Celadon Mart Roof (vending machine) | LEMONADE            | ¥50          |
| Saffron Mart                        | GREAT BALL          | ¥600         |
| Saffron Mart                        | HYPER POTION        | ¥1500        |
| Saffron Mart                        | MAX REPEL           | ¥700         |
| Saffron Mart                        | ESCAPE ROPE         | ¥550         |
| Saffron Mart                        | FULL HEAL           | ¥600         |
| Saffron Mart                        | REVIVE              | ¥1500        |
| Fuchsia Mart                        | ULTRA BALL          | ¥1200        |
| Fuchsia Mart                        | GREAT BALL          | ¥600         |
| Fuchsia Mart                        | HYPER POTION        | ¥1500        |
| Fuchsia Mart                        | REVIVE              | ¥1500        |
| Fuchsia Mart                        | FULL HEAL           | ¥600         |
| Fuchsia Mart                        | SUPER REPEL         | ¥500         |
| Fuchsia Mart                        | RARE CANDY          | ¥3000        |
| Cinnabar Mart                       | ULTRA BALL          | ¥1200        |
| Cinnabar Mart                       | GREAT BALL          | ¥600         |
| Cinnabar Mart                       | HYPER POTION        | ¥1500        |
| Cinnabar Mart                       | MAX REPEL           | ¥700         |
| Cinnabar Mart                       | ESCAPE ROPE         | ¥550         |
| Cinnabar Mart                       | FULL HEAL           | ¥600         |
| Cinnabar Mart                       | REVIVE              | ¥1500        |
| Indigo Plateau Lobby                | FULL HEAL           | ¥600         |
| Indigo Plateau Lobby                | HYPER POTION        | ¥1500        |
| Indigo Plateau Lobby                | MAX POTION          | ¥2500        |
| Indigo Plateau Lobby                | FULL RESTORE        | ¥3000        |
| Indigo Plateau Lobby                | REVIVE              | ¥1500        |
| Indigo Plateau Lobby                | MAX REVIVE          | ¥4000        |
| Bike Shop (unused)                  | BICYCLE             | not for sale |
| Mart (unused)                       | GREAT BALL          | ¥600         |
| Mart (unused)                       | HYPER POTION        | ¥1500        |
| Mart (unused)                       | SUPER POTION        | ¥700         |
| Mart (unused)                       | FULL HEAL           | ¥600         |
| Mart (unused)                       | REVIVE              | ¥1500        |
<!-- /generated:marts -->
