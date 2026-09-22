# Cutscene Collisions with Followers

## Problem

Vanilla Yellow's scripted cutscenes were choreographed around a party of two: the
player and Pikachu. An NPC walking into place only ever had to avoid the tile
directly behind the player.

With Misty on `trail[1]` and Brock on `trail[2]`, the two tiles *behind that* are
now occupied as well, and several scripted walks run straight through them - the
NPC visibly walks over a follower. Scripted movement deliberately skips collision
(`CanWalkOntoTile` early-outs for scripted sprites, `engine/overworld/movement.asm`),
so nothing stops it.

The established fix is to walk the followers out of the way first, by overwriting
their position-trail entries before the NPC moves - see
`MtMoonB2FScript_MoveFollowersAsideForRockets` (`scripts/MtMoonB2F.asm`) and
`PokemonTower2FScript_MoveFollowersAsideForRival` (`scripts/PokemonTower2F.asm`).
The player's next couple of real steps cascade fresh trail values back in, so the
override is transient and self-correcting.

## Why picking a destination was guesswork

Both existing fixes carry the same caveat in their comments: *"we can't verify
walkability from here"*. Writing one needs two facts the asm can't see:

1. **Where the follower actually is.** It's not a fixed offset from the player -
   it's the player's real step history, which varies with how they approached.
2. **Which nearby tiles are walkable.** Nothing at runtime can cheaply answer
   "is map tile (4,5) solid rock?".

Both are static data, so both are answerable at build time. That's what
`tools/cutscene_check.py` does, and it turns the relative "nudge them a bit and
hope" pattern into verified absolute destinations.

## The tool

`tools/cutscene_check.py` reconstructs any map's walkability grid in map
coordinates from repo data alone - `maps/*.blk` + `gfx/blocksets/*.bst` +
`data/tilesets/collision_tile_ids.asm` + `data/maps/headers/` +
`data/maps/objects/` - then traces scripted NPC walks over it.

```
cutscene_check.py --list-scenes         every scripted NPC walk in the game
cutscene_check.py --audit               trace them all, flag paths hitting walls
cutscene_check.py MtMoonB2F             walkability grid, objects, warps
cutscene_check.py MtMoonB2F --triggers  candidate scene trigger tiles

# does this cutscene run over Misty or Brock, and does a candidate fix help?
cutscene_check.py MtMoonB2F --trigger 3,5 --forced up \
    --path MovementData_f9e65 --from-object MTMOONB2F_JESSIE \
    --nudge-misty 0,-2 --nudge-brock 1,-1
```

`--nudge-*` is the acceptance test for a fix: it shifts every tile a follower
could be on by the given delta, then reports both destinations that land in walls
and collisions that survive.

### Where the followers can be

At rest each follower sits on its trail slot, and `RecordPlayerPositionToTrail`
stores the player's position at the *start* of each step - so with the player
stationary, `trail[n]` is simply where they stood `n+1` steps ago:

| Slot | Follower | Tile |
|------|----------|------|
| `trail[0]` | Pikachu | player's previous position |
| `trail[1]` | Misty   | 2 steps ago |
| `trail[2]` | Brock   | 3 steps ago |

So the complete set of tiles a follower can occupy when a scene fires is found by
enumerating every legal 3-step walk *into* the trigger tile. Tiles may repeat - a
player pacing back and forth is a real approach, and produces placements that
straight-line approaches never do. Each scripted forced step (Mt Moon B2F's
`PAD_UP`, say) shifts the trail one slot further back; `--forced` models that.

### Two derivations it depends on

**Collision tile for a map cell.** Map coordinates step 2 tiles at a time, so each
4x4 block covers 2x2 map cells. The cell `(x, y)` takes its collision tile from
block `[y>>1][x>>1]`, block-local row `2*(y&1)+1`, col `2*(x&1)` - the bottom-left
tile of its 2x2 sub-block. Derived from `LoadCurrentMapView`'s
`wYBlockCoord`/`wXBlockCoord` offsets (`home/overworld.asm`) plus the player always
rendering at screen tile (8,9), with `wXBlockCoord = wXCoord & 1`
(`engine/overworld/tilesets.asm`).

**`TryExtendedMovementCode`** (`engine/overworld/movement.asm`, formerly the
unnamed `Func_5288`). A Yellow-only table that intercepts movement bytes *before*
the usual quadrant decoding and `scf`s so the quadrant path never runs:

| Codes | Effect |
|-------|--------|
| `$04` down `$05` up `$06` left `$07` right | one full tile at double speed; map coords updated |
| `$11` up `$12` down `$13` left `$14` right | half a tile, visual only; map coords **not** updated |

Every one of these is numerically inside the `< $40` = "down" quadrant, so
movement data like `db $06` reads as a plain step down unless the table is applied
first. All three Team Rocket scenes use these codes and walk **sideways**, not
down. Misreading them decodes those scenes as walking through solid rock.

### How the grid was validated

- **Rule bake-off.** All four candidate sub-block rules, checked against every
  `object_event` and `warp_event` in the game: bottom-left leaves **3.84%** of 1746
  coords on non-walkable tiles, versus 34-47% for the other three.
- **Graphics overlay.** Rendering the tileset with the collision grid drawn on top
  matches cell-for-cell, down to the one-tile doorway at Mt Moon B2F (3,5).
- **Independent scene.** Route 22's rival walks right 4 and lands exactly below the
  player's `dbmapcoord 29, 4` trigger.

The residual 3.84% are all legitimate: swimmers on water `$14`, items on furniture
`$1d`/`$35`/`$36`, and door tiles `$4a`/`$30`/`$55` that warp on contact rather
than being passable.

## Scene inventory

`call MoveSprite` is the single choke point for scripted NPC movement, so the
inventory is closed: **35 sites across 17 maps** (`--list-scenes`). Three more live
in `engine/overworld/auto_movement.asm` as `*MovementScriptPointerTable`s (Pallet
Oak, the Pewter museum guy, the Pewter gym guy), which drive the player by
simulated joypad as well.

`--audit` traces all of them; 32 of 38 paths are clean. The 6 flagged are two
benign categories, not bugs: NPCs deliberately exiting off the map edge, and
multi-stage scenes where an earlier stage already moved the NPC (re-check those
with `--from` / `--after`).

## Findings

Tiles listed are where that follower can be standing *on the NPC's path*.

| Scene | Trigger | Misty | Brock |
|-------|---------|-------|-------|
| MtMoon B2F - Jessie | (3,5) +up | clear | (3,3) |
| MtMoon B2F - James | (3,5) +up | clear | (4,4) |
| PkmnTower2F - rival ON_LEFT | (15,5) | (14,6) (15,7) | (14,7) (16,7) |
| PkmnTower2F - player below | (14,6) | (15,5) (15,7) | (15,6) (16,7) |
| Route22 rival 1 - exit 1 | (29,4) | (30,5) | (29,5) (31,5) |
| Route22 rival 1 - exit 2 | (29,5) | (28,4) (30,4) (31,5) | (29,4) (31,4) (28,5) (31,6) |
| Route22 rival 2 - exit 1 | (29,4) | (28,5) | (27,5) (29,5) |
| Route22 rival 2 - exit 2 | (29,5) | (27,5) | (26,5) (28,5) |
| SS Anne 2F - approach, player right | (37,8) | (36,7) | (36,6) (36,8) |
| SS Anne 2F - approach, player below | (36,8) | (36,6) | (36,5) (36,7) |
| SS Anne 2F - exit, player right | (37,8) | (36,9) | (36,8) (36,10) |
| SS Anne 2F - exit, walk around | (36,8) | (37,7) (37,9) | (36,7) (37,8) (37,10) |
| SilphCo7F - exit right | (3,2) | (4,3) | (3,3) (5,3) |
| SilphCo7F - walk around | (3,3) | (2,2) (4,2) (5,3) (2,4) | (3,2) (5,2) (2,3) (3,4) |
| PkmnTower7F - both Rockets | (10,12) | (10,10) (11,11) | (10,9) (11,10) (10,11) (11,12) |
| PkmnTower7F - both Rockets | (11,12) | (11,10) (10,11) | (11,9) (10,10) (11,11) (10,12) |
| RocketHideout B4F - both Rockets | (24,14) | (24,12) (25,13) | (24,11) (25,12) (24,13) (25,14) |
| RocketHideout B4F - both Rockets | (25,14) | (25,12) (24,13) | (25,11) (24,12) (25,13) (24,14) |
| GameCorner - direct route | (8,6) | clear | (10,5) |
| GameCorner - walk around | (8,6) | (10,6) | (9,6) (11,6) |
| **SilphCo11F - Jessie + James** | (6,13) | **clear** | **clear** |

This settles the open "Team rocket cut scenes with similar issue?" under
"Cut scene collisions" in the repo-root `TODO.md`: yes for
Pokemon Tower 7F, Rocket Hideout B4F and Game Corner; **no** for Silph Co 11F,
where the Rockets flee upward, away from the player. It also adds scenes that
weren't on the list at all (SS Anne's approach as well as its exit, both Silph
Co 7F branches, both Game Corner routes).

Rows where a Rocket pair shares a trigger list both NPCs' paths together, since
one park table has to keep the followers clear of both.

Tiles an NPC is already standing on are excluded - the player can't walk through
them, so no follower can be trailing there. That removes the rival's own (14,5)
on Pokemon Tower 2F and the Rocket's (9,5) in the Game Corner.

Note how often a follower's possible tiles include the player's own tile - that's
the degenerate case where the player steps off a tile and is pushed straight back
onto it, leaving a follower's trail target under their feet.

## Bugs in the fixes already in the tree

**`PokemonTower2FScript_MoveFollowersAsideForRival`** claims *"the other route
stays clear"* and early-outs on `EVENT_POKEMON_TOWER_RIVAL_ON_LEFT`. The other
route is not clear - it collides on five tiles and is currently unhandled. On the
branch it does handle, the flat `+1 row` nudge leaves collisions in place and can
push a follower into a wall.

**`MtMoonB2FScript_MoveFollowersAsideForRockets`** has a reachable wall landing for
Brock. Walking the real conditional cascade: Brock at (3,7) has `trailY = 11`,
which decrements twice to `9` (map row 5), with `X+1` giving a target of **(4,5)** -
inside the row-5 wall band. The approach that produces it is the most ordinary one
available: up the corridor `(3,7) -> (3,6) -> (3,5)`, then the scripted step up.
Followers don't collision-check, so Brock walks in and stands in the rock.

The Misty half of that same routine never has anything to dodge - Misty can only
be on (3,4) or (3,6), and neither Rocket's path touches either.

## What the model does not cover

- A player who entered the map fewer than three steps ago has a **seeded** trail
  (`InitializePositionTrail`, doorway modes) rather than a walked one.
- Ledge hops and sprite-sprite collision are ignored when enumerating approaches.
- Followers are assumed settled on their targets; one still in transit when the
  scene fires can be on an intermediate tile.

All three make the reported sets a **superset**, never an underset - a scene the
tool calls clear is clear.

## The shared primitive

`ParkFollowers` (`engine/followers/chain_follow.asm`) replaces the bespoke
per-scene nudge routines. A script points `de` at a table and farcalls it:

```asm
	ld de, MtMoonB2FRocketsParkTable
	farcall ParkFollowers
	ret

MtMoonB2FRocketsParkTable:
	;              slot              danger  destination
	park_follower BROCK_TRAIL_SLOT,   3, 3,    3, 2
	park_follower BROCK_TRAIL_SLOT,   4, 4,    4, 2
	park_followers_end
```

`de`, not `hl`, because `farcall` clobbers `hl` and `b`. The routine lives in
ROMX, so the size-locked ROM0 is untouched; each scene costs one `farcall` plus
5 bytes per table entry. `park_follower` takes plain map coords and folds in the
+4 the position trail stores (`macros/coords.asm`).

**Conditional, not a constant delta.** An entry fires only when that follower is
spawned *and* its trail entry is exactly the danger tile. This is not a
refinement - it's forced. Searching every constant delta within 3 tiles for Mt
Moon's Brock returns **none**: his possible positions span both the open room and
the corridor, and any single delta that rescues one start shoves another into the
row-5 wall. That is precisely how the old code's cascade ended up targeting
(4,5). Moving only the follower who is actually in the way also means nobody
takes a pointless step.

### ParkFollowers and its tables share one section

`farcall` maps the follower bank *before* the routine runs, so a table sitting
in the calling script's bank is read from whatever occupies the same address in
the follower bank instead. This is silent and destructive rather than merely
broken: the garbage first byte is taken as a trail slot, and `wPositionTrailY +
<garbage>` writes off the end of the trail into unrelated WRAM.

The routine and every table therefore live together in
`engine/followers/park_followers.asm`, under a single
`SECTION "Park Followers", ROMX`. One section means the linker can place the
whole unit in whichever bank has room - it cannot split them - so the bank
assertion below holds wherever it lands. (The tables started out in
`chain_follow.asm`; adding SS Anne's overflowed that bank by 11 bytes, which is
what prompted the move. Being able to relocate freely is the point.)

### The bank assertion

`farcall` maps the follower bank *before* the routine runs, so a table sitting
in the calling script's bank is read from whatever occupies the same address in
the follower bank instead. This is silent and destructive rather than merely
broken: the garbage first byte is taken as a trail slot, and `wPositionTrailY +
<garbage>` writes off the end of the trail into unrelated WRAM.

That cost a long debugging session, so scripts call through a macro that
asserts the shared bank at link time:

```asm
MACRO park_followers
	ASSERT BANK(\1) == BANK(ParkFollowers), "..."
	ld de, \1
	farcall ParkFollowers
ENDM
```

Putting a table back in a script's bank now fails the build instead of
corrupting memory at runtime.

The symptom to recognise, if something like this recurs: behaviour that doesn't
track the data. Identical coordinates worked in one build and not the next, and
an inline write in the script's own bank worked where the same values in a
table did not.

### Battles do not disturb the trail

Confirmed in-game: fighting the rival leaves the position trail alone, so the
followers stay wherever the player's walk-in put them. The approach enumeration
therefore applies to post-battle scenes exactly as it does to the rest, and the
findings table needs no special-casing for them.

### Unconditional parking, and why Pokemon Tower can't use it

`park_follower_always SLOT, x, y` parks a follower regardless of where they
stand ($ff in the danger-Y byte is the wildcard). It suits a scene with only
one possible arrangement - but not this one. Searching every walkable tile on
Pokemon Tower 2F for a destination safe from *all* approaches returns nothing:
Brock coming from (13,4) routes Y-first through the wall at (13,6), and several
other starts cross the rival's route after he has already reached it. Hence the
conditional tables, whose short per-tile hops are verifiable.

### Trigger tiles are one-way, and can seal a room

Stepping on a trigger tile starts the scene, so the player can never have walked
*through* one. Any approach path crossing a trigger is impossible - and where
the triggers sit across the only route in, that seals off everything beyond
them.

Silph Co 7F is the extreme case. Its triggers (3,2) and (3,3) block every path
from the 3F teleport pad at (5,3) to the rest of the floor, so before the scene
fires the player can only ever have stood on **(5,3), (4,3), (5,2), (4,2)**.
That cuts the arrangements from 20 per branch to 4, and it means the rival's
walk *up* to meet the player can never reach a follower - only his exit needs a
table. Confirmed in-game: no approach collision is reachable there.

Scenes can declare this with a `region` in `PARKED_SCENES`; without one the
enumeration assumes the player could have come from anywhere walkable, which is
a superset and therefore safe, just looser.

### Followers move faster than scripted NPCs

A destination has to be reached before the NPC arrives, so the comparison needs
real speeds, not step counts:

| Mover | Frames per tile |
|-------|-----------------|
| Follower closing a gap of 2+ tiles (status 5) | 4 |
| Follower's final step (status 3) | 8 |
| Scripted NPC via `TryWalking` | 16 |
| Scripted NPC using the Yellow fast codes `$04`-`$07` | 8 |

So a follower is 2-4x faster than a normal-speed NPC. Comparing step indices
one-to-one - as this tool first did - rejects perfectly safe routes: it failed
Misty's 4-step walk to Silph Co 7F (1,3) even though she clears the rival's loop
with frames to spare. The check now derives the NPC's step time from its
movement encoding and compares against a follower at a conservative 8 frames,
so Mt Moon's fast Rockets still get a strict 1:1 test while normal NPCs get the
honest 2:1.

### Both followers must be solved together

Destinations are solved against every *joint* (Misty, Brock) arrangement, not
two independent sets. They come from the same approach walk, so their tiles are
correlated, and parking one onto a tile the other simultaneously occupies just
trades one overlap for another.

SS Anne 2F is the cautionary example. The rival and player share a two-tile-wide
corridor (cols 36-37) and he exits down whichever column the player isn't in.
The obvious fix - step each follower across to the other column - is wrong,
because in a two-wide corridor the followers occupy *both* columns, so moving
one across lands it on the other. `--verify-parks` caught it:

```
[FAIL] SS Anne 2F - rival exits down column 36
       approach Misty=(36,9) Brock=(37,9): both end on (37,9)
```

The real answer spreads them out, one dropping to the wider stretch at row 10.
No amount of reading the map catches this; the joint check does.

### Choosing destinations

Destinations are solved against every *joint* (Misty, Brock) outcome, not two
independent sets - both come from the same approach walk, so their tiles are
correlated, and parking Misty onto a tile Brock simultaneously occupies just
trades one overlap for another. A destination must be walkable, off the NPC
path, not the player's tile, distinct from where the other follower ends up, and
reachable by the follower's greedy Y-then-X walk **before** the NPC arrives -
crossing the path is fine if the follower has moved on by then, which is what
lets Brock go (4,4) -> (4,2) through (4,3).

Two corrections that came out of doing this:

- **NPCs block the player.** The rival stands on Pokemon Tower 2F (14,5), so no
  follower can ever trail there; treating it as reachable produced a danger tile
  with no solution. `follower_tiles` now excludes object tiles from approach
  walks (slightly conservative: hidden missable objects don't really block).
- **Mt Moon's Misty half was dead code.** Misty can only be on (3,4) or (3,6),
  and neither Rocket touches either. The converted script parks Brock only.

### Verification

`cutscene_check.py --verify-parks` reads the tables back out of the scripts and
re-checks them against the scene they guard, so the asm stays the source of
truth:

```
[ok] Mt Moon B2F - Jessie and James corner the player  (2 entries, 7 approach outcomes)
[ok] Pokemon Tower 2F - rival exits, player on the right  (4 entries, 17 approach outcomes)
[ok] Pokemon Tower 2F - rival exits, player below  (4 entries, 14 approach outcomes)
```

It exits nonzero on failure, so it can become a `make` target. Confirmed to
actually catch regressions: pointing Brock at (4,5) reports both "not walkable"
and the route crossing a wall, and parking him on his own danger tile reports
"still on the path".

`PARKED_SCENES` in the tool holds the per-scene facts the asm can't state - the
trigger tile, any forced player step, and which NPC walks to avoid. Adding a
scene means adding a table to its script and an entry there.

## Still to convert

Both scenes with existing fixes are done. The rest of the findings table is
unconverted, and each follows the same recipe: find the trigger (`--triggers`),
confirm the branch pairing in the script, solve the table, add it, and register
the scene in `PARKED_SCENES`.

Watch for branch pairing - Pokemon Tower 7F and Rocket Hideout B4F each have two
trigger tiles that swap which Rocket gets which movement, and both rival scenes
on Route 22 pick their exit from `wSavedCoordIndex`. Get the pairing wrong and
the danger tiles are plausible but wrong.

Where no safe destination exists, the fallback is a second primitive: hide the
follower for the scene and restore after.

### Remaining work

**Every scene is now converted.** `--verify-parks` covers 11 of them.

Applying the sealed-region rule to every branch removed a great deal of
phantom work - several scenes the looser model flagged turn out to be
collisions the map makes unreachable.

| Map | Outcome |
|-----|---------|
| Mt Moon B2F | converted · tested |
| Pokemon Tower 2F (x2) | converted · tested |
| Silph Co 7F (x2) | converted · tested |
| Game Corner (x2) | converted · tested |
| Route 22 rival 1 (x2) | converted |
| SS Anne 2F (x2) | converted |
| **Pokemon Tower 7F** | **clear - no work** |
| **Rocket Hideout B4F** | **clear - no work** |
| **Silph Co 11F** | **clear - no work** |
| **Route 22 rival 2** | **clear - no work** |

Every *approach* stage is clear except Mt Moon's, because in each case the
triggers span the only route in, so the NPC walks down to a player whose
followers are always behind them. Only exits needed tables.

Why the clear ones are clear:

- **Pokemon Tower 7F** is a vertical corridor. Row 13 is two tiles wide, so the
  only way north is onto a trigger. Followers can never leave rows 13-15; the
  Rockets never come below row 12.
- **Rocket Hideout B4F** is sealed harder still: the elevator at (24,15)/(25,15)
  is a **two-tile pocket** whose only exits are the triggers. Exactly one legal
  approach. Jessie and James standing on (24,10)/(25,10) are themselves the only
  tiles joining the trigger area to the north half of the floor - they wall off
  their own scene.
- **Silph Co 11F** was always clear: the Rockets flee upward, away from the player.
- **Route 22 rival 2** exits *westward*, back the way he came, while the
  followers trail east of the player.

**Route 22 rival 1** needs only Misty. Beating Pewter Gym grants the Boulder
Badge (which is what makes Brock follow) and in the same script resets
`EVENT_1ST_ROUTE22_RIVAL_BATTLE` (`scripts/PewterGym.asm`), so Brock and that
scene are mutually exclusive by construction. `PARKED_SCENES` records this with
a `followers` list, so the verifier doesn't demand coverage for a follower who
cannot attend.

**Game Corner** was the odd one out: its Rocket has no trainer header, so he
never walks up - he's engaged by talking, and the player is simply adjacent.
Three talk positions exist, (8,5), (10,5) and (9,6) ((9,4) is wall), and the
script picks his route from the player's coords rather than a coord-array
trigger, so the park call mirrors that same condition. Talking from (8,5) needs
no entries: reaching a tile on his route from there means walking through him,
and he blocks his own tile. Verified in-game, all three positions.

No scene needed the hide-and-restore fallback.
