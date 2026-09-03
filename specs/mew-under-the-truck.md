# Spec: "Mew Under the Truck"

Port of PureRGB's implementation of the classic Gen 1 urban legend, made real.

> FEATURES.md:164 — *"Mew is under the truck!!! Use strength on it from the right
> side. If the SS Anne has left, it returns after obtaining the Soul Badge."*

This document describes how the feature works in PureRGB (a `pret/pokered`
disassembly fork) and gives a step‑by‑step plan for reproducing it in a similar
Gen 1 disassembly project. Line references point at `scripts/VermilionDock.asm`
in this repo unless stated otherwise.

---

## 1. Player-facing behavior

1. The truck sits on Vermilion Dock, on the water tile block just left of where
   the player arrives from the S.S. Anne gangway (overworld block coord `(0,9)`
   area — a 2×2 tile block in the `SHIP_PORT` tileset).
2. To reach the truck the player must be able to stand on the dock while the
   S.S. Anne is present (before taking the ship) **or** after the ship returns.
3. The player walks to tile `(x=22, y=0)` on the dock — the tile directly to the
   **right** of the truck — with **Strength active**, and presses **Left** into
   the truck.
   - First Left press: "primes" the push (bump animation + a one‑frame guard so a
     single mashed press doesn't skip it).
   - Next Left press while still held: the truck slides left with the
     boulder‑push SFX, a dust puff plays, and **Mew appears** where the truck was.
4. Mew is a static overworld sprite. Talking to it starts a one‑off Level 50 wild
   Mew battle (encounter flag, catchable, not a scripted give).
5. State is permanent: once the truck has been moved (`EVENT_FOUND_MEW`), every
   subsequent map load draws the map with the truck already shifted and Mew
   already placed (until caught/defeated).

### S.S. Anne return (supporting change)

Vanilla pokered makes the S.S. Anne leave forever after you get HM01 Cut and
walk out. PureRGB instead makes the ship **come back** once the player has the
**Soul Badge** (`BIT_SOULBADGE` in `wObtainedBadges`), so the dock — and the
truck — stay reachable for the rest of the game. This is a separate but
bundled change (see §7).

---

## 2. How it works in PureRGB — architecture

The whole feature is driven from the Vermilion Dock **map script**, which runs
every frame the player is on that map. There is no new engine system; it reuses:

| Mechanism | Purpose |
|---|---|
| `wCurrentMapScriptFlags` scratch bits | per‑map-visit state, auto‑cleared on map load |
| `EVENT_ENCOUNTERED_MEW` / `EVENT_FOUND_MEW` | permanent progress flags |
| Missable object (`HS_*` hide/show system) | show/hide the Mew overworld sprite |
| `object_event ... , MEW, 50` trainer form | turns the sprite into a wild battle |
| `trainer` header + `TalkToTrainer` | triggers the battle on interact |
| `ReplaceTileBlock` predef | swaps the truck block ⇄ water block on the map |
| Direct `wShadowOAM` writes + `truck_sprite.2bpp` | animates the truck sliding away |
| `AnimateBoulderDust` (`callfar`) | dust puff on push |

### Control flow

```
VermilionDock_Script
  └─ call TruckCheck                      ; every frame
        ├─ EVENT_FOUND_MEW set?  ── yes ─▶ ChangeTruckTile   ; redraw "already moved" state
        │                                     ├─ patch overworld block map (truck→shifted)
        │                                     ├─ if !EVENT_ENCOUNTERED_MEW: ShowMew
        │                                     └─ RedrawMapView
        └─ no:
             ├─ ensure Mew sprite hidden (missable object HIDE) unless already shown
             ├─ Strength active?                 ── no ─▶ NoTruckAction (clear scratch bit), ret
             ├─ player at (y=0, x=22)?            ── no ─▶ NoTruckAction, ret
             ├─ player moving/pressing Left?      ── no ─▶ NoTruckAction, ret
             ├─ scratch bit 7 clear? set it, ret  ; "prime" — wait for a second Left
             ├─ Left currently held?              ── no ─▶ ret
             └─ PUSH SEQUENCE:
                  ├─ wJoyIgnore = $ff, wUpdateSpritesEnabled = $ff
                  ├─ VermilionDockRedLeftAnimate           ; Red "pushing" arms (cosmetic)
                  ├─ copy truck_sprite.2bpp → vChars1+$400
                  ├─ copy TruckOAMTable → wShadowOAM+$20   ; 8 hardware sprites = the truck
                  ├─ ReplaceTileBlock (block $c) at (0,$a) ; put truck block on map behind OAM
                  ├─ SFX_PUSH_BOULDER; loop 32×: shift the 8 truck OAM sprites left 2px
                  ├─ ReplaceTileBlock (block $3) at (0,9)  ; restore water where truck was
                  ├─ callfar AnimateBoulderDust
                  ├─ call ShowMew                          ; ShowObject on the missable Mew
                  └─ SetEvent EVENT_FOUND_MEW
```

`NoTruckAction` / `ShowMew` / `ChangeTruckTile` / `GetOWCoord` /
`VermilionDockRedLeftAnimate` are all local helpers in the same file.

### Why the two events

- `EVENT_FOUND_MEW` — the truck has been physically moved. Gates the "draw the
  moved state on load" path (`ChangeTruckTile`).
- `EVENT_ENCOUNTERED_MEW` — the wild Mew battle has been started (it is the
  `trainer` header's flag, set automatically by `TalkToTrainer`). Once set, the
  overworld Mew sprite is no longer re‑shown on map load.

Catching/defeating Mew is handled by the normal wild‑battle + missable‑object
machinery; the overworld sprite is a missable object flagged HIDE by default in
`data/maps/hide_show_data.asm`.

---

## 3. Component checklist (what to add)

| # | File (this repo) | Change |
|---|---|---|
| 1 | `constants/event_constants.asm` | `EVENT_ENCOUNTERED_MEW`, `EVENT_FOUND_MEW` in the S.S. Anne event block |
| 2 | `constants/hide_show_constants.asm` | `HS_MEW_VERMILION_DOCK` |
| 3 | `data/maps/hide_show_data.asm` | `VermilionDockHS: db VERMILION_DOCK, VERMILIONDOCK_MEW, HIDE` + pointer in `MapHSPointers` |
| 4 | `data/maps/objects/VermilionDock.asm` | add `VERMILIONDOCK_MEW` object const + `object_event 21, 0, SPRITE_FAIRY, STAY, DOWN, TEXT_VERMILIONDOCK_MEW, MEW, 50` |
| 5 | `scripts/VermilionDock.asm` | the whole `TruckCheck` machinery + `call TruckCheck` in the map script; trainer header + battle text |
| 6 | `text/VermilionDock.asm` (+ shared battle text) | "MEW!" text (PureRGB reuses `_MewtwoBattleText`) |
| 7 | `gfx/sprites/truck_sprite.png` (+ `.2bpp` build rule) | 32×16 truck sprite, 8 tiles |
| 8 | `scripts/VermilionCity.asm` + `text/VermilionCity.asm` | S.S. Anne "comes back after Soul Badge" dialogue + gating (optional, §7) |
| 9 | `engine/menus/save_file_updater.asm` | force Mew hidden when importing an old save (optional, only if your project has a save updater) |

---

## 4. Detailed implementation

### 4.1 Constants

**`constants/event_constants.asm`** — inside the S.S. Anne block:

```
	const_skip
	const EVENT_ENCOUNTERED_MEW
	const EVENT_FOUND_MEW
	const_skip
```

`EVENT_ENCOUNTERED_MEW` **must** land on a bit index that matches the `trainer`
macro's first argument (it asserts `bit == CURRENT_TRAINER_BIT % 8`). PureRGB
places it right after a `const_skip` so it is bit 0 → `def_trainers` with no
argument (defaults `CURRENT_TRAINER_BIT = 1`)… note PureRGB actually uses
`trainer EVENT_ENCOUNTERED_MEW, 0, ...` with `def_trainers` default of 1, so
`EVENT_ENCOUNTERED_MEW` sits on **bit 1**. Match whatever your `def_trainers`
default is; the assembler will tell you if it's wrong.

**`constants/hide_show_constants.asm`** — append at the end of the list:

```
	const HS_MEW_VERMILION_DOCK
```

⚠️ **Ordering bug warning** (this repo hit it — commit `e86f2dbd`): the `HS_*`
list index is also used as the missable‑object array index. Inserting a constant
in the middle silently renumbers every entry after it and corrupts other maps'
hide/show state on existing saves. **Always append.**

### 4.2 Hide/show data

**`data/maps/hide_show_data.asm`**:

```
VermilionDockHS:
	db VERMILION_DOCK, VERMILIONDOCK_MEW, HIDE
```

and set the `MapHSPointers` entry for `VERMILION_DOCK` (index = map id) to
`dw VermilionDockHS` (it is `NoHS` in vanilla).

### 4.3 Map object

**`data/maps/objects/VermilionDock.asm`**:

```
	object_const_def
	const_export VERMILIONDOCK_MEW
	...
	def_object_events
	object_event 21, 0, SPRITE_FAIRY, STAY, DOWN, TEXT_VERMILIONDOCK_MEW, MEW, 50
```

- Position `(21, 0)` is the truck's own block (Mew appears there after the push).
- `MEW, 50` uses the `object_event` **trainer** form (`_NARG > 7`) → emits
  `db TRAINER | MEW`, `db 50` (level), `db <text id 0>`. This is the standard
  "static legendary as a wild battle" pattern (same as Articuno/Zapdos/Moltres).
- `SPRITE_FAIRY` is the overworld sprite used for Clefairy/Jigglypuff/etc.;
  reuse it or add a dedicated Mew OW sprite. Make sure `VERMILION_DOCK`'s
  sprite set in `data/maps/sprite_sets.asm` includes whatever sprite you pick.

### 4.4 Map script

Add to the top of `VermilionDock_Script` (after `ExecuteCurMapScriptInTable`):

```
	call TruckCheck
```

Then add the machinery. Reproduce these labels from
`scripts/VermilionDock.asm` (lines ~228–427):

- `TruckOAMTable` — 8 OAM entries (`Y, X, tile, attr`) laying out the 4×2‑tile
  truck at screen pos ~`(0x28,0x50)`. Tiles `$C0..$C7`.
- `TruckSpriteGFX: INCBIN "gfx/sprites/truck_sprite.2bpp"` — 8 tiles = `$80` bytes.
- `RedLeftOAMTable` + `VermilionDockRedLeftAnimate` — swaps the player sprite's
  tiles for a couple of `RedSprite`/`RedBikeSprite` tiles so Red looks like he's
  shoving. **Purely cosmetic** — safe to drop for a first pass.
- `NoTruckAction` — clears `BIT_CUR_MAP_USED_ELEVATOR` in `wCurrentMapScriptFlags`
  and returns. (That bit is repurposed here as the "push primed" scratch flag.)
- `TruckCheck` — the state machine described in §2. Key details:
  - `CheckEventHL EVENT_FOUND_MEW` → `jp nz, ChangeTruckTile`.
  - Uses `FlagActionPredef` (`FLAG_TEST`) on `wMissableObjectFlags` +
    `HS_MEW_VERMILION_DOCK` to check if Mew is already shown; if not, `HideObject`
    it (so it stays hidden until the truck moves).
  - Gate 1: `wStatusFlags1` bit `BIT_STRENGTH_ACTIVE`.
  - Gate 2: `wYCoord == 0` **and** `wXCoord == 22`.
  - Gate 3: `wPlayerMovingDirection` bit `PLAYER_DIR_BIT_LEFT`.
  - Prime/fire: `bit`/`set BIT_CUR_MAP_USED_ELEVATOR` in `wCurrentMapScriptFlags`,
    `ret z` (first press just primes). Then require `hJoyHeld` bit `BIT_D_LEFT`.
  - Push: `wJoyIgnore = wUpdateSpritesEnabled = $ff`; copy truck gfx to
    `vChars1 + $400`; copy `TruckOAMTable` into `wShadowOAM + $20` (8 sprites);
    `ReplaceTileBlock` with `wNewTileBlockID = $c` at `bc = $a`; play
    `SFX_PUSH_BOULDER`; 32 iterations of decrementing the 8 truck OAM X‑coords by
    1 twice with a 2‑frame delay; `ReplaceTileBlock` with `wNewTileBlockID = $3`
    at `bc = $9`; `callfar AnimateBoulderDust`; `call ShowMew`; 20‑frame delay;
    `xor a` / `ld [wJoyIgnore], a`; `SetEvent EVENT_FOUND_MEW`.
- `ShowMew` — `wUpdateSpritesEnabled = 1`, `wMissableObjectIndex =
  HS_MEW_VERMILION_DOCK`, `predef_jump ShowObject`.
- `ChangeTruckTile` — runs on every load once `EVENT_FOUND_MEW` is set:
  - Guarded by `BIT_CUR_MAP_LOADED_1` in `wCurrentMapScriptFlags` (run once per
    load): read/clear bit 5, also clear bit 7, `ret z` if it was already clear.
  - `ld bc, $9` / `call GetOWCoord` → pointer into `wOverworldMap` for the
    truck block. If it's already `$3`, `ret`. Otherwise write `$3` then `$c`
    into the two block slots (shifts the truck one block left in the block map).
  - `CheckEvent EVENT_ENCOUNTERED_MEW` / `call z, ShowMew` (re‑place Mew if not
    yet battled).
  - `jpfar RedrawMapView`.
- `GetOWCoord` — walks `wOverworldMap + 2` by `(wCurMapWidth + 6)` strides to
  reach block `(b, c)`; copy verbatim.

**Trainer header + battle:**

```
VermilionDock_TextPointers:
	def_text_pointers
	dw_const VermilionDockMewText, TEXT_VERMILIONDOCK_MEW

VermilionDockTrainerHeaders:
	def_trainers
MewTrainerHeader:
	trainer EVENT_ENCOUNTERED_MEW, 0, MewBattleText, MewBattleText, MewBattleText
	db -1

VermilionDockMewText:
	text_asm
	ld hl, MewTrainerHeader
	call TalkToTrainer
	rst TextScriptEnd

MewBattleText:
	text_far _MewtwoBattleText          ; "Mew!" — PureRGB reuses this string
	text_asm
	ld a, MEW
	call PlayCry
	call WaitForSoundToFinish
	rst TextScriptEnd
```

Also register `VermilionDockTrainerHeaders` in the map script's
`ExecuteCurMapScriptInTable` call and add the `CheckFightingMapTrainers` /
`DisplayEnemyTrainerTextAndStartBattle` / `EndTrainerBattle` script pointers if
the map doesn't already have trainer plumbing (Vermilion Dock does not in
vanilla — copy the three `dw_const` lines from `VermilionDock_ScriptPointers`).

### 4.5 Truck sprite

`gfx/sprites/truck_sprite.png` — **32×16**, 4bpp‑style GB palette, builds to a
128‑byte `.2bpp` (8 tiles). Add the build dependency the same way other
`gfx/sprites/*.2bpp` are produced (they fall out of the generic `%.2bpp: %.png`
rule in this repo's `Makefile`). The tile order must match `TruckOAMTable`
(row‑major: top row `$C0..$C3`, bottom row `$C4..$C7`).

The sprite is loaded into `vChars1 + $400` — verify that VRAM region is free on
this map (it is on Vermilion Dock: few OW sprites, no menu). Adjust the address
if your project's VRAM map differs.

---

## 5. Engine assumptions / porting notes

PureRGB is `pokered` + shinpokered + heavy edits. Check each of these against
your target project:

| Assumption | Vanilla `pokered` | If different |
|---|---|---|
| `ReplaceTileBlock` is a predef, `b`/`c` = block Y/X | ✅ same (`predef ReplaceTileBlock`) | PureRGB split it into redraw / no‑redraw variants — either works |
| `wShadowOAM` label | vanilla calls it `wOAMBuffer` | rename in `TruckOAMTable` copy + slide loop |
| `wCurrentMapScriptFlags` bits 5 & 7 are safe scratch on this map | ✅ generally | pick two unused bits; they auto‑clear on map load |
| `rst _PlaySound` / `rst _DelayFrames` / `rst TextScriptEnd` RST vectors | ❌ vanilla uses `call PlaySound` / `call DelayFrames` / `jp TextScriptEnd` | substitute the `call`/`jp` forms |
| `CheckEventHL` / `SetEvent` / `dw_const` / `def_trainers` macros | present in modern pret pokered | if older, use `EventFlagBit`/`ld`/`bit` manually |
| `wStatusFlags1` + `BIT_STRENGTH_ACTIVE` | vanilla: `wd728` bit 0 | rename |
| `AnimateBoulderDust` far‑callable | ✅ `engine/overworld/dust_smoke.asm` | drop the `callfar` if absent |
| `object_event` trainer form emits `TRAINER \| species, level` | ✅ modern pret | older forks: use the raw `db` layout |
| `DEFER_SHOWING_MAP` on the dock header → must `call GBPalNormal` in the SS‑Anne‑leaves script | shinpokered/GBC concern | non‑GBC projects can ignore the palette reset |
| Save file updater | PureRGB‑specific | skip §9 entirely |

The truck push does **not** need the auto‑walk‑out‑of‑dock scripting that
already exists in vanilla `VermilionDock_Script` (that's the HM01 flow) — leave
it untouched; just insert `call TruckCheck` ahead of it.

---

## 6. Historical bugs fixed in PureRGB (don't re‑introduce)

1. **`41fd8c3b` — prime flag** — originally used `wFlags_0xcd60` bit 6, which
   wasn't reliably cleared, so the push could fire on the first press or never.
   Fix: use a `wCurrentMapScriptFlags` bit (cleared on every map load) and the
   `set` / `ret z` idiom to require two presses.
2. **`5762bb20`** — added `callfar AnimateBoulderDust` for polish.
3. **`fd1c9423`** — with `DEFER_SHOWING_MAP`, entering the "S.S. Anne leaves"
   script straight from the warp left the screen black; added `call GBPalNormal`.
4. **`e86f2dbd`** — `HS_*` constant inserted mid‑list renumbered other maps'
   missable objects → Route 23 item vanished. Always append `HS_*` constants.
5. Delay after `ShowMew` trimmed 60→20 frames (`41fd8c3b`) — cosmetic.

---

## 7. S.S. Anne return (optional but recommended)

Without this the dock is unreachable after the story ship departs, so the truck
is a pre‑Cut‑only curiosity. PureRGB's approach:

- **`scripts/VermilionDock.asm`** `VermilionDockSSAnneLeavesScript` (the script
  run when you warp onto the dock after the ship left): first check
  `wObtainedBadges` bit `BIT_SOULBADGE`; `ret nz` so the "ship sails away"
  cutscene never plays once you have the Soul Badge — the ship is simply there.
- **`scripts/VermilionCity.asm`**: every place that branches on
  `EVENT_SS_ANNE_LEFT` (guard NPC, sailor dialogue, "you need the ticket" text)
  gets a preceding `ld a, [wObtainedBadges]` / `bit BIT_SOULBADGE, a` /
  `jr nz, .default` so post‑Soul‑Badge the city behaves as if the ship is in
  port. Add a "The S.S. ANNE is back!" text (`_VermilionCityText15` here).
- No new event flag is needed — the presence check is purely
  `EVENT_SS_ANNE_LEFT && !BIT_SOULBADGE`.

If you'd rather keep it simpler: gate the truck behind "before you board the
ship" only, and skip all of §7.

---

## 8. Save-file updater (optional, PureRGB-only)

`engine/menus/save_file_updater.asm` explicitly forces
`HS_MEW_VERMILION_DOCK` to HIDE when importing a save from a version that
predates the feature (`SaveFileUpdaterHideObjectEntry`), so the Mew sprite
doesn't appear floating on the dock. Only relevant if your project supports
importing legacy saves.

---

## 9. Test checklist

- [ ] Build passes (watch for the `trainer` macro bit assertion and `HS_*`
      length assertion).
- [ ] Truck is visible on the dock as a solid 2×2 block; walkable water around it.
- [ ] Standing at `(22,0)` **without** Strength + press Left → normal bump, no push.
- [ ] With Strength, wrong tile → no push.
- [ ] With Strength at `(22,0)`, press Left once → bump; press Left again → truck
      slides left with SFX + dust, Mew appears.
- [ ] Single held Left doesn't skip the prime step.
- [ ] Talk to Mew → Level 50 wild Mew battle, cry plays, "MEW!" text.
- [ ] Run from battle, re‑enter map → truck still shifted, Mew still there.
- [ ] Catch or defeat Mew, re‑enter map → truck shifted, **no** Mew sprite.
- [ ] Leave map and return before pushing → truck back in original spot, prime
      flag reset.
- [ ] (If §7) After Soul Badge, dock reachable, no "ship leaves" cutscene, city
      NPCs behave as ship‑present.
- [ ] Save, reset, reload → all of the above state persists.
- [ ] No VRAM corruption on the dock (truck gfx load into `vChars1+$400` doesn't
      clobber anything on this map).
