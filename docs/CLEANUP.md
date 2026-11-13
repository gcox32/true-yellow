# Cleanup

Leftovers from the original disassembly: placeholder names that still need
real ones, and known bugs inherited from the original game that haven't been
fixed. Everything under **Naming** is a pure rename and must rebuild the ROM
byte-for-byte identical; everything under **Inherited bugs** changes behavior.

Counts are as of 2026-11-13.

## Naming

The disassembly labels anything nobody has identified yet by its address:
`Func_fc745` is code at `$fc745`, `wd492` is RAM at `$d492`. Labels don't
exist in the built ROM, so renaming one is always safe.

### How to rename safely

1. Build, then copy `pokeyellow.gbc` and `pokeyellow.sym` somewhere safe.
2. Check the new name isn't already taken (`git grep -w NewName`).
3. Rename every use with a word-boundary match (`\bFunc_fc745\b`), including
   `.md` files and comments.
4. **Delete `pokeyellow.gbc` before rebuilding**, so a failed build can't be
   compared against the stale ROM.
5. `cmp` the new ROM against the saved copy; for RAM renames, also diff the
   sorted address column of the two `.sym` files. Both must be identical.
6. For flag bytes, name the bits in `constants/ram_constants.asm` and replace
   only the `bit`/`set`/`res` operands that directly follow a read of that byte.

`tools/unnamed.py pokeyellow.sym` undercounts: it only reports labels whose
number still matches their real address, and this project's code has shifted.
To count properly, scan the source:

```sh
git grep -nE '^(Func|Unkn|GFX|Pic|Data|Tilemap|Jumptable|asm|Pointer|PointerTable)_[0-9a-fA-F]{4,5}::?' -- '*.asm'
git grep -nE '^(w[cd][0-9a-f]{3})::' -- 'ram/*.asm'
```

### Done

- `engine/pikachu/pikachu_follow.asm`: all routines, tables and local labels.
- `wd431`/`wd432` -> `wPikachuIdleHopOffsetY`/`X`; `wd471` -> `wPikachuPartyFlags`
  (bits: `BIT_PIKACHU_SPAWN_PLACED`, `BIT_SURFING_PIKACHU_IN_PARTY`,
  `BIT_STARTER_PIKACHU_ALIVE_IN_PARTY`).
- `Func_1510`/`Func_151d` -> `HidePikachuForWarpAnim`/`ShowPikachuAfterWarpAnim`.

### RAM (38 variables)

Most useful first. The "what it seems to be" column is a starting lead from
reading the uses, not a confirmed meaning.

| Variable | Files | What it seems to be |
|---|---|---|
| `wd492` | 11 | Misc flag byte: bits 0, 1, 2, 7 used by map scripts (Pewter City, Summer Beach House), poison, Surfing Pikachu |
| `wd49b` | 5 | Written alongside `wPikachuMood` by items and poison; read by Pikachu happiness, which skips its update if it's nonzero |
| `wd472` | 4 | Surf sprite mode (start menu, field-move prompts, `surf_sprite.asm`; mode 3 = Lapras) |
| `wd435` | 3 | Nonzero during a follower-sprite interaction (`chain_follow.asm`, Pikachu emotions, `home/overworld.asm`) |
| `wd433` | 1 | Written by `sprite_collisions.asm` during follower collision checks |
| `wd451` | 1 | `pikachu_movement.asm` |
| `wd474` | 2 | Bit 7 is Cinnabar Gym quiz state |
| `wd479` | 1 | `home/play_time.asm` |
| `wdef4` | 2 | Battle animations / HUD Poké Ball graphics |
| `wc0f3` | 2 | Pikachu sound (`pikachu_pcm.asm`, `home/init.asm`) |
| `wc634` | 2 | Animated objects / Surfing Pikachu |
| `wcae2` | 3 | Game Boy Printer |
| 16 × `wc5xx`/`wc63x` | 1 each | Surfing Pikachu minigame only |
| 5 × `wcbxx`/`wc6fx` | 1 each | Game Boy Printer only |
| `wc5d8`, `wc6ea`–`wc6ed` | 0 | Defined but never used |

The 18 `wUnused…`/`hUnused…` variables already have descriptive names.

### Code and data labels (390 placeholders)

Counted: `Func_` 203, `Unkn_` 89, plus `GFX_`/`Pic_`/`Data_`/`Tilemap_`/`Jumptable_`/`Pointer_`
and 8 bare global `asm_` labels.

**Low value: self-contained systems (~330).** Only worth doing if you start
working in that code:

| Area | Count |
|---|---|
| Surfing Pikachu minigame (`engine/minigame/surfing_pikachu.asm` + `data/sprite_anims/surfing_pikachu_frames.asm`) | 125 |
| Debug menu (`engine/debug/debug_menu.asm`) | 77 |
| Pikachu graphics (`gfx/pikachu.asm`, `data/pikachu/pikachu_pic_animation.asm`) | 63 |
| Yellow intro (`engine/movie/intro_yellow.asm` + `data/sprite_anims/intro_*.asm`) | 42 |
| Game Boy Printer (`engine/printer/printer2.asm`) | 32 |
| Link menu (`engine/menus/link_menu.asm`) | 11 |

**Worth doing: scattered through core code (~40).**

| File | Labels |
|---|---|
| `home/overworld.asm` | `Func_0db5` (marked `; XXX`), `asm_0dbd`, `Func_0ffe` |
| `home/audio.asm` | `Func_2223` |
| `home/cgb_palettes.asm` | `Func_3082` |
| `engine/battle/core.asm` | `Func_3d4f5`, `Func_3d523`, `Func_3d529`, `asm_3d52d`, `Func_3d536` |
| `engine/battle/animations.asm` | `Func_78e98`, `Func_79929` |
| `engine/pokemon/evos_moves.asm` | `Func_3b079`, `Func_3b0a2`, `Func_3b10f` |
| `engine/pikachu/pikachu_movement.asm` | `Data_fd731`, `Func_fd851`, `asm_fd908` |
| `engine/overworld/sprite_collisions.asm` | `Func_4d0a` |
| `engine/gfx/sprite_oam.asm` | `Func_4a7b` |
| `engine/events/pokecenter.asm` | `Func_6eaa`, `Func_6ebb` |
| `engine/events/poison.asm` | `Func_c4c7` |
| `engine/items/item_effects.asm` | `Func_d85d`, `Func_e4bf` |
| `engine/menus/main_menu.asm` | `Func_5cc1` |
| `engine/movie/hall_of_fame.asm` | `Func_7033f` |
| `scripts/BillsHouse_2.asm` | `Func_f24ae`, `Func_f24d5`, `Func_f250b`, `Data_f2505`, `Data_f251c`, `Data_f2521` |
| `scripts/CeladonMansion1F_2.asm` | `Func_f1ea2` |
| `scripts/CinnabarGym_3.asm` | `Func_f2150` |
| `scripts/SummerBeachHouse_2.asm` | `Func_f23d0` |
| `data/pokemon/unknown_list.asm` | `Pointer_3b0ee` |

Marked `; unreferenced`, so delete rather than name them (that frees bytes,
so the ROM won't stay identical): `Func_70f87` (`town_map.asm`),
`Pointer_f4669` (`title_yellow.asm`), `Func_f0a54`
(`unused_load_missable_object_data.asm`).

### Lower priority

- **127 half-named labels** like `CinnabarGymText_75xxx` or
  `PikachuMovementData_xxxx`. The prefix already says what they are; only the
  suffix is an address. Most are in map scripts (`SilphCo11F`,
  `CeladonMansion1F_2`, `CinnabarGym_3` have about 10 each).
- **216 local `.asm_xxxxx` jump labels** inside already-named routines. The
  most are in `debug_menu.asm` (36), `surfing_pikachu.asm` (19),
  `link_menu.asm` (14), `battle/animations.asm` (11), `evos_moves.asm` (10).

## Inherited bugs

Bugs from the original Yellow. They used to be listed in
`docs/bugs_and_glitches.md`, which has been removed. Its fourth entry
(unexpected Counter damage) no longer applies because COUNTER is now a
draining move (`4c6a149a`).

### Fixed

- **Options menu shifted options if Left/Right was held as it opened.**
  `InitOptionsMenu` draws each option by running its handler, and the handlers
  act on `hJoy5`, which still held the Start menu's input. `DisplayOptionMenu_`
  (`engine/menus/options.asm`) now clears `hJoy5` first. (The old doc's
  suggested fix, calling `JoypadLowSensitivity`, would still let a press made
  on that exact frame through.)
- **Battle transition read garbage with an empty party.** When Oak catches
  Pikachu you have no Pokémon, so `GetBattleTransitionID_CompareLevels`
  (`engine/battle/battle_transitions.asm`) walked past the party data and let
  `wRivalName` pick the transition. It now checks `wPartyCount` and uses the
  weaker transition when it's zero.
- **Pikachu follow-command buffer overflow ("Pikawalk").**
  `AppendPikachuFollowCommandToBuffer` (`engine/pikachu/pikachu_follow.asm`)
  never checked for a full 16-entry buffer, so a Pikachu that stopped consuming
  commands (asleep in Pewter Pokémon Center) let each step write a byte further
  into RAM. It now drops the command when the buffer is full. Misty and Brock's
  trail is recorded before this, so it's unaffected. To fit the check in bank
  $3F, two jumps to the very next instruction were removed from the same file.
