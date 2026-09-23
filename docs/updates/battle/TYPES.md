# Types

Both tables below are generated - run `make docs` (or `tools/gen_types_doc.py`) after
editing `/constants/type_constants.asm`, `/data/types/names.asm` or
`/data/types/type_matchups.asm`. Hand edits to them will be overwritten; the prose
around them is preserved.

## Type list
`/constants/type_constants.asm` defines the internal types; `/data/types/names.asm`
maps each one to the name the game actually prints. Where **Displays as** differs from
the type's constant, that type is disguised - it exists for the battle math, but the
player only ever sees the name in that column. `TRI` shows as `NORMAL`, `MAGMA` as
`FIRE`, `BONEMERANG_TYPE` as `GROUND`.

**Class** is the physical/special split: types before the `SPECIAL` marker use
Attack/Defense, the rest use Special. The 17-wide unused-type gap between `$0A` and
`$11` is left out.

<!-- generated:type-list -->
| Type            | ID  | Displays as | Class    |
|-----------------|-----|-------------|----------|
| NORMAL          | $00 | NORMAL      | Physical |
| FIGHTING        | $01 | FIGHTING    | Physical |
| FLYING          | $02 | FLYING      | Physical |
| POISON          | $03 | POISON      | Physical |
| GROUND          | $04 | GROUND      | Physical |
| ROCK            | $05 | ROCK        | Physical |
| TYPELESS        | $06 | NONE        | Physical |
| BUG             | $07 | BUG         | Physical |
| GHOST           | $08 | GHOST       | Physical |
| BROCK_TYPE      | $09 | BROCK       | Physical |
| BONEMERANG_TYPE | $0A | GROUND      | Physical |
| TRI             | $11 | NORMAL      | Special  |
| FLOATING        | $12 | FLOAT       | Special  |
| MAGMA           | $13 | FIRE        | Special  |
| FIRE            | $14 | FIRE        | Special  |
| WATER           | $15 | WATER       | Special  |
| GRASS           | $16 | GRASS       | Special  |
| ELECTRIC        | $17 | ELECTRIC    | Special  |
| PSYCHIC_TYPE    | $18 | PSYCHIC     | Special  |
| ICE             | $19 | ICE         | Special  |
| DRAGON          | $1A | DRAGON      | Special  |
<!-- /generated:type-list -->

## Matchups
- `GHOST` now super effective against `PSYCHIC`
- `BUG` now neutral against `POISON`

Every non-neutral pairing, straight out of `/data/types/type_matchups.asm`. Anything
not listed is neutral (1x).

<!-- generated:matchups -->
| Attacker        | Defender     | Multiplier |
|-----------------|--------------|------------|
| WATER           | FIRE         | 2x         |
| FIRE            | GRASS        | 2x         |
| FIRE            | ICE          | 2x         |
| GRASS           | WATER        | 2x         |
| ELECTRIC        | WATER        | 2x         |
| WATER           | ROCK         | 2x         |
| GROUND          | FLYING       | 0x         |
| WATER           | WATER        | 0.5x       |
| FIRE            | FIRE         | 0.5x       |
| ELECTRIC        | ELECTRIC     | 0.5x       |
| ICE             | ICE          | 0.5x       |
| GRASS           | GRASS        | 0.5x       |
| PSYCHIC_TYPE    | PSYCHIC_TYPE | 0.5x       |
| FIRE            | WATER        | 0.5x       |
| GRASS           | FIRE         | 0.5x       |
| WATER           | GRASS        | 0.5x       |
| ELECTRIC        | GRASS        | 0.5x       |
| NORMAL          | ROCK         | 0.5x       |
| NORMAL          | GHOST        | 0x         |
| GHOST           | GHOST        | 2x         |
| FIRE            | BUG          | 2x         |
| FIRE            | ROCK         | 0.5x       |
| WATER           | GROUND       | 2x         |
| ELECTRIC        | GROUND       | 0x         |
| ELECTRIC        | FLYING       | 2x         |
| GRASS           | GROUND       | 2x         |
| GRASS           | BUG          | 0.5x       |
| GRASS           | POISON       | 0.5x       |
| GRASS           | ROCK         | 2x         |
| GRASS           | FLYING       | 0.5x       |
| ICE             | WATER        | 0.5x       |
| ICE             | GRASS        | 2x         |
| ICE             | GROUND       | 2x         |
| ICE             | FLYING       | 2x         |
| ICE             | FIRE         | 1x         |
| FIGHTING        | NORMAL       | 2x         |
| FIGHTING        | POISON       | 0.5x       |
| FIGHTING        | FLYING       | 0.5x       |
| FIGHTING        | PSYCHIC_TYPE | 0.5x       |
| FIGHTING        | BUG          | 0.5x       |
| FIGHTING        | ROCK         | 2x         |
| FIGHTING        | ICE          | 2x         |
| FIGHTING        | GHOST        | 0x         |
| POISON          | GRASS        | 2x         |
| POISON          | POISON       | 0.5x       |
| POISON          | GROUND       | 0.5x       |
| POISON          | BUG          | 2x         |
| POISON          | ROCK         | 0.5x       |
| POISON          | GHOST        | 0.5x       |
| GROUND          | FIRE         | 2x         |
| GROUND          | ELECTRIC     | 2x         |
| GROUND          | GRASS        | 0.5x       |
| GROUND          | BUG          | 0.5x       |
| GROUND          | ROCK         | 2x         |
| GROUND          | POISON       | 2x         |
| GROUND          | GHOST        | 0x         |
| GROUND          | FLOATING     | 0x         |
| FLYING          | ELECTRIC     | 0.5x       |
| FLYING          | FIGHTING     | 2x         |
| FLYING          | BUG          | 2x         |
| FLYING          | GRASS        | 2x         |
| FLYING          | ROCK         | 0.5x       |
| PSYCHIC_TYPE    | FIGHTING     | 2x         |
| PSYCHIC_TYPE    | POISON       | 2x         |
| BUG             | FIRE         | 0.5x       |
| BUG             | GRASS        | 2x         |
| BUG             | FIGHTING     | 0.5x       |
| BUG             | FLYING       | 0.5x       |
| BUG             | PSYCHIC_TYPE | 2x         |
| BUG             | GHOST        | 0.5x       |
| BUG             | POISON       | 2x         |
| ROCK            | FIRE         | 2x         |
| ROCK            | FIGHTING     | 0.5x       |
| ROCK            | GROUND       | 0.5x       |
| ROCK            | FLYING       | 2x         |
| ROCK            | BUG          | 2x         |
| ROCK            | ICE          | 2x         |
| GHOST           | NORMAL       | 0x         |
| GHOST           | PSYCHIC_TYPE | 2x         |
| FIRE            | DRAGON       | 0.5x       |
| WATER           | DRAGON       | 0.5x       |
| ELECTRIC        | DRAGON       | 0.5x       |
| GRASS           | DRAGON       | 0.5x       |
| ICE             | DRAGON       | 2x         |
| DRAGON          | DRAGON       | 2x         |
| TRI             | FIRE         | 0.5x       |
| TRI             | FLYING       | 2x         |
| TRI             | GRASS        | 2x         |
| TRI             | ELECTRIC     | 0.5x       |
| TRI             | ROCK         | 0.5x       |
| TRI             | BUG          | 2x         |
| ELECTRIC        | BROCK_TYPE   | 0.5x       |
| POISON          | BROCK_TYPE   | 0.5x       |
| BUG             | BROCK_TYPE   | 0.5x       |
| BONEMERANG_TYPE | FIRE         | 2x         |
| BONEMERANG_TYPE | ELECTRIC     | 2x         |
| BONEMERANG_TYPE | GRASS        | 0.5x       |
| BONEMERANG_TYPE | BUG          | 0.5x       |
| BONEMERANG_TYPE | ROCK         | 2x         |
| BONEMERANG_TYPE | POISON       | 2x         |
| BONEMERANG_TYPE | GHOST        | 0x         |
| WATER           | MAGMA        | 0x         |
| FIRE            | MAGMA        | 0x         |
<!-- /generated:matchups -->

## Miscellaneous
- `TYPELESS` replaces the unused `BIRD` type and is assigned to `STRUGGLE`
- `GHOST` is the exception to the Class column: its physical/special split is decided
  per-attacker at battle time (see `DynamicTypeCheckPlayer`/`DynamicTypeCheckEnemy` in
  `/engine/battle/core.asm`) - special if the attacker's base Special beats its base
  Attack, physical otherwise
