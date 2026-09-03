# Spec: In-game "alternate form" species conversion

How PureRGB lets an NPC/interaction permanently transform a party Pokémon into a
new, Pokédex-invisible species that keeps the base form's dex number but has its
own stats, types, sprite, cry and movepool.

Scope of this port — **three conversions only**:

| Base | → New form | Trigger location | New type? |
|---|---|---|---|
| `WEEZING` | `FLOATING_WEEZING` | Saffron abandoned building — helium pipe (`scripts/SilphCo1F.asm`) | `FLOATING` |
| `MAGNETON` | `FLOATING_MAGNETON` | Power Plant — giant magnet (`scripts/PowerPlant.asm`) | `FLOATING` |
| `MEWTWO` | `ARMORED_MEWTWO` (and back) | Secret Lab machine (`scripts/SecretLab.asm`) | — |

PureRGB also has `POWERED_HAUNTER`, `HARDENED_ONIX`, `VOLCANIC_MAGMAR`,
`WINTER_DRAGONAIR`, the `SPIRIT_*` set, etc. — all the same machinery. Ignore
those; wherever this repo lists them in a table, your port just omits those rows.

---

## 1. Core concept

A "form" is a **new internal species index** that:

- is **not** in the regional/national Pokédex — it has no dex entry of its own;
- maps, via the `PokedexOrder` table, back to the **base form's dex number**, so
  "seen/owned" flags, dex UI, Pokédex-indexed palette, and dex text all resolve
  to the base form automatically ("references fall off");
- has its **own row** in every table that is indexed by *internal species index*
  (name, cry, base stats, evos/moves pointer, front-sprite toggle);
- is produced only by `ChangePartyPokemonSpecies`, never by wild encounters or
  evolution (though trainers may carry one directly — see §7).

### Index-space trick (do this first)

Gen 1 disassemblies keep ~µ190 internal index slots, most of them unused
"MissingNo" gaps declared as `const_skip` in `constants/pokemon_constants.asm`.
**Convert three `const_skip` slots into named constants** instead of appending:

```
; constants/pokemon_constants.asm  — replace existing const_skip lines
	const FLOATING_MAGNETON   ; e.g. $38  (was const_skip)
	const FLOATING_WEEZING    ; e.g. $92  (was const_skip)
	const ARMORED_MEWTWO      ; e.g. $AE  (was const_skip)
DEF NUM_POKEMON_INDEXES EQU const_value - 1
```

Because a `const_skip` already counted toward `const_value`, `NUM_POKEMON_INDEXES`
is unchanged, and every `assert_table_length NUM_POKEMON_INDEXES` still passes —
you're *filling* a placeholder row, not adding one. (`NUM_POKEMON`, the dex
length, must also stay unchanged — do **not** add a `pokedex_constants.asm`
entry.)

Pick slots whose current placeholder rows you can find in the index-keyed tables
(§4). In this repo they landed at `$38`, `$92`, `$AE`.

---

## 2. Engine function: `ChangePartyPokemonSpecies`

`engine/pokemon/change_mon_species.asm` — the whole feature's payload. ~50 lines,
copy it near-verbatim.

```
; input:
;   [wCurPartySpecies] = target species index
;   [wWhichPokemon]    = party slot (0-5)
ChangePartyPokemonSpecies::
	; 1. GetMonHeader for the target species  (see §3 — must resolve the new form)
	; 2. write target species into wPartySpecies[slot]
	; 3. write target species into wPartyMon[slot].Species
	; 4. CalcStats using the mon's existing level + EXP + DVs  → new stats
	; 5. set current HP = new max HP
	; 6. overwrite the mon's Type1/Type2 from wMonHType1/2
	ret
```

Notes:
- It does **not** rename the mon; an unnamed `WEEZING` keeps the nickname string
  "WEEZING". PureRGB has a separate `CheckMonNickNameDefault` used only for
  Haunter/Gengar/Cubone — out of scope here.
- It does **not** touch moves, EXP, DVs, or status — only species/stats/types/HP.
- Level is read from the party struct; stats are fully recalculated so the form's
  higher base stats take effect immediately.
- `wCurEnemyLevel` is (ab)used as the `CalcStats` level input — keep that line.

### Callers (trigger scripts) — pattern

```
	ld a, FLOATING_WEEZING
	ld [wCurPartySpecies], a
	callfar ChangePartyPokemonSpecies
```

`[wWhichPokemon]` is already set by the party-menu selection the script just did.

---

## 3. Engine function: `GetMonHeader` / `GetMonHeader2` lookup chain

`engine/pokemon/get_mon_header.asm`. This is the "specific function with lookups"
that makes a non-dex species resolve to real data. When `GetMonHeader` is asked
for `[wCurSpecies]`:

1. **`NonPokemonSpecies`** array — fossil/ghost battle sprites. Not relevant to
   the three forms; keep or drop as your project already has it.
2. **`NonDexPokemonSpecies`** array — a flat list of the non-dex form indexes.
   `IsInArray` returns the ordinal `b`; that ordinal indexes
   **`NonDexMonsBaseStats`** (a second base-stats table, parallel to the array).
   ```
   NonDexPokemonSpecies:
       db MISSINGNO
       db ARMORED_MEWTWO
       db FLOATING_MAGNETON
       db FLOATING_WEEZING
       db -1
   NonDexMonsBaseStats::
   INCLUDE "data/pokemon/base_stats/missingno.asm"
   INCLUDE "data/pokemon/base_stats/armored_mewtwo.asm"
   INCLUDE "data/pokemon/base_stats/floating_magneton.asm"
   INCLUDE "data/pokemon/base_stats/floating_weezing.asm"
   ```
   **Order of the two must match.** MissingNo is entry 0 in both.
3. Otherwise: normal path — `IndexToPokedex` then index `BaseStats` by dex number.

`UncompressMonSprite` in the same file uses `NonPokemonSpecies` only for the
fossil/ghost bank override; the three forms fall through to the normal
`wMonHPicBank` path, so their front sprite comes straight from their
`NonDexMonsBaseStats` row (`dw XxxPicFront, XxxPicBackSW` + the bank bytes).

If your project keeps `GetMonHeader` in the home bank and has no `GetMonHeader2`
split, you must move it out of home (it now needs `IsInArray`, a far table, and
`predef IndexToPokedex`) — PureRGB did exactly this (`get_mon_header.asm:1`).

---

## 4. Data tables — the full checklist

### 4a. Tables indexed by INTERNAL species index — need a new row at the form's slot

| File | What to add |
|---|---|
| `constants/pokemon_constants.asm` | 3 consts replacing `const_skip` (§1) |
| `data/pokemon/names.asm` | name string at each form's slot (PureRGB just duplicates the base name: `"MAGNETON@@"`, `"WEEZING@@@"`, `"MEWTWO@@@@"`) |
| `data/pokemon/cries.asm` (`CryData`, len `NUM_POKEMON_INDEXES`) | `mon_cry` line per form. Floating forms copy the base cry exactly; Armored Mewtwo copies Mewtwo's cry (pitch remap done in code, §6) |
| `data/pokemon/evos_moves.asm` (`EvosMovesPointerTable`, len `NUM_POKEMON_INDEXES`) | `dw MagnetonEvosMoves` / `dw WeezingEvosMoves` / `dw MewtwoEvosMoves` at the form slots — reuse the base form's evos/moves data (forms don't evolve) |
| `data/pokemon/dex_order.asm` (`PokedexOrder`, len `NUM_POKEMON_INDEXES`) | `db DEX_MAGNETON` / `db DEX_WEEZING` / `db DEX_MEWTWO` at the form slots — **this is what makes dex references "fall off"** |
| `engine/pokemon/get_mon_header.asm` | add to `NonDexPokemonSpecies` + `NonDexMonsBaseStats` (§3) |
| `engine/gfx/front_sprite_toggler.asm` `SpriteOptionMapping` | `db ARMORED_MEWTWO, BIT_MEWTWO_SPRITE, 1` so the "alt Mewtwo sprite" option also applies to the armored form (skip if your project has no front-sprite option system) |
| `engine/battle/move_effects/conversion.asm` `ConversionAttackTable` | **PureRGB-only** table (reworked Conversion move), len `NUM_POKEMON_INDEXES`. Add a row only if your project has this table |
| `engine/debug/debug_party.asm` | optional debug party entries |

### 4b. Tables indexed by POKÉDEX number — NO change needed

Because `PokedexOrder` maps the form to the base dex number, these all resolve
correctly with zero edits:

- `data/pokemon/palettes.asm` (`MonsterPalettes`, len `NUM_POKEMON`) — form uses
  base form's colour.
- Pokédex entry text / height / weight — form shows the base entry.
- `wPokedexSeen` / `wPokedexOwned` — `add_mon.asm` / `core.asm` run
  `IndexToPokedex` before setting the bit, so catching or converting sets the
  **base** form's dex flag.

### 4c. New base-stats files

`data/pokemon/base_stats/floating_weezing.asm`, `floating_magneton.asm`,
`armored_mewtwo.asm`. Standard `base_stats` layout. Key fields:

- **`db DEX_<base>`** as the pokedex id (first byte) — must be the base form's.
- Buffed stat line, and for the floating forms **`db <ptype>, FLOATING`** as the
  type pair.
- `INCBIN "gfx/pokemon/front/<pic>.pic", 0, 1` for sprite dimensions +
  `dw <Front>, <BackSW>`.
  - Floating forms reuse the base sprite (`WeezingPicFront`, `MagnetonPicFront`).
  - Armored Mewtwo has its own `gfx/pokemon/front|back|back_sw/armored_mewtwo*`
    plus a `front_alt` pic, declared in `gfx/pics.asm`
    (`ArmoredMewtwoPicFront::` etc.).
- Level-1 learnset, growth rate, TM/HM bitfield, then the 4 pic-bank bytes and
  the trailing `dw <altFront>, <back>` (PureRGB's extended base-stats format —
  match whatever trailer your project's `base_stats` macro/files use).

---

## 5. New `FLOATING` type (floating weezing + magneton only)

Armored Mewtwo needs none of this. For the floating forms:

| File | Change |
|---|---|
| `constants/type_constants.asm` | `const FLOATING` in an unused special-type slot (`$12` here). Sits in the `SPECIAL` half so it takes special stat for damage |
| `data/types/names.asm` | `dw .Floating` in the pointer list + `.Floating: db "FLOATING@"` |
| `data/types/type_matchups.asm` | `db GROUND, FLOATING, NO_EFFECT` — the form's whole gimmick (immune to Ground / Earthquake). Add any other matchups you want |
| `data/pokemon/base_stats/floating_*.asm` | second type byte = `FLOATING` |

`set_types.asm` / `SetPartyMonTypes` needs no change — it copies `wMonHType1/2`
which now come from the form's base-stats row.

If your project has a Ground-type "can it hit this mon" special-case list
(PureRGB's `BONEMERANG_TYPE` can), decide whether `FLOATING` belongs there.

---

## 6. Armored Mewtwo cry remap (Armored Mewtwo only)

`CryData` gives Armored Mewtwo the same header as Mewtwo; the "armored" sound is
made by re-pitching at playback:

- `home/pokemon.asm` `PlayCry`: after `GetCryData` / `_PlaySound`,
  `cp ARMORED_MEWTWO` → `callfar RemapArmoredMewtwoCry`.
- `audio/remap_armored_mewtwo_cry.asm`: dispatches on `wAudioROMBank` to
  `PlayArmoredMewtwoCry1/2/3` (one per audio engine bank).
- `audio/…`: `PlayArmoredMewtwoCry1` (in `alternate_tempo.asm`),
  `…Cry2` (`poke_flute.asm`), `…Cry3` (`play_armored_mewtwo_cry3.asm`) — each
  tweaks frequency/tempo modifiers then plays `SFX_CRY_xx` for Mewtwo.

Simplest port: skip the remap entirely (Armored Mewtwo just uses Mewtwo's cry),
or give it a distinct `mon_cry` row instead of runtime pitching.

---

## 7. Trainers carrying a form directly

`data/trainers/parties.asm` may list `FLOATING_MAGNETON` / `FLOATING_WEEZING`
in a party (PureRGB's Champion Arena does). The enemy-mon load path already goes
through `GetMonHeader`, so §3 covers it — nothing else to do. `ARMORED_MEWTWO`
as a trainer ace works the same way.

---

## 8. Trigger scripts

Each trigger is: talk to an object → print flavour text → open party menu →
validate the chosen mon → convert → play an overworld "floating up" animation →
set an event so it isn't repeatable.

### 8a. Shared script helpers (add once)

| Helper | Source in this repo | Purpose |
|---|---|---|
| `GenericShowPartyMenuSelection` | `scripts/DiamondMine.asm:634` | save screen, `DisplayPartyMenu`, restore; returns carry set = cancelled, else `[wWhichPokemon]` = slot |
| `FindPokemonInParty` | `scripts/BillsGarden.asm:507` | `d` = species → carry set + `d` = slot if present |
| `GetPartyMonName2` | `home/pokemon.asm:374` | load chosen mon's nick into the text buffer |
| `FloatingAnimation` | `scripts/PowerPlant.asm:760` | sprite wobble + slide-up + bob, `[hSpriteIndex]` = which OW sprite, `de` = SFX |
| `DoBallPoofOnNPC` | `scripts/PowerPlant.asm:746` | poké-ball "poof" smoke on an NPC tile |
| `ChangePartyPokemonSpecies` | §2 | the conversion |

### 8b. `FLOATING_WEEZING` — `scripts/SilphCo1F.asm`

Relevant labels: `SaffronAbandonedBuildingHeliumPipe` (bg interaction),
`SaffronAbandonedBuildingHeliumPipeText` (the `text_asm`),
`CheckFloatingWeezingAnimation` (per-frame animation runner),
`SaffronAbandonedBuildingWeezingText` (post-anim "it learned to float" + item).

Flow (`…HeliumPipeText`):
1. play a looping air SFX (`PlayNewSoundChannel8`), print "the pipe hisses…".
2. `callfar GenericShowPartyMenuSelection`; `jr c` → print `.forgetIt`, done.
3. `GetPartyMonName2`; read chosen mon's species from `wPartyMon1Species +
   slot*partyMonSize`:
   - `WEEZING` → `.weezing`: `SetEvent EVENT_FLOATING_WEEZING_ANIMATION`,
     `ld a, FLOATING_WEEZING` / `ld [wCurPartySpecies]` /
     `callfar ChangePartyPokemonSpecies`, print success text.
   - `KOFFING` → "it's not evolved enough" text.
   - `FLOATING_WEEZING` → "already floating" text.
   - else → generic "wrong Pokémon" text (`_SecretLabMewtwoReactionText4`).
4. `CheckFloatingWeezingAnimation` runs from `SilphCo1F_Script` every frame:
   `CheckAndResetEvent EVENT_FLOATING_WEEZING_ANIMATION` (one-shot); mute music;
   face player up; reposition a spare hidden NPC slot
   (`wSprite09StateData2MapY/X`) next to the player; `DoBallPoofOnNPC`; load the
   Weezing menu-icon sprite (or a Seel fallback if enhanced sprites are off) into
   `vNPCSprites`; `FloatingAnimation` with `GasSound`; display
   `TEXT_WEEZING_STARTED_FLOATING`; poof again; move the sprite back off-screen.

Object/text plumbing:
- a `SILPHCO1F_WEEZING_PROXY` object const + off-screen `object_event` used as the
  animation puppet;
- `dw_const DoRet, TEXT_SILPHCO1F_WEEZING_PROXY` and
  `dw_const SaffronAbandonedBuildingWeezingText, TEXT_WEEZING_STARTED_FLOATING`
  in `SilphCo1F_TextPointers`;
- `SaffronAbandonedBuildingHeliumPipe` is invoked from a `bg_event` /
  `PredefID`-style hook when the player faces the pipe.

### 8c. `FLOATING_MAGNETON` — `scripts/PowerPlant.asm`

Labels: `PowerPlantMagnet` (interaction), `PowerPlantMagnetText` (`text_asm`),
`MagnetonSuperchargeAnimation` (`SCRIPT_MAGNETON_SUPERCHARGE` map-script state),
`MagnetonWasSuperChargedText`.

Same shape as 8b, differences:
- gated behind `EVENT_BEAT_ZAPDOS` (power must be on) — else print "power's out".
- success path sets a **map-script state** rather than a bare event:
  `ld a, SCRIPT_MAGNETON_SUPERCHARGE` / `ld [wPowerPlantCurScript], a`, then
  convert. `MagnetonSuperchargeAnimation` is a `PowerPlant_ScriptPointers` entry
  (`dw_const MagnetonSuperchargeAnimation, SCRIPT_MAGNETON_SUPERCHARGE`) that runs
  the float-up animation next frame and resets `wPowerPlantCurScript` to
  `SCRIPT_POWERPLANT_DEFAULT` when done.
- reuses a hidden `HS_ELECTRODE_1` missable object as the puppet
  (`predef ShowObject` / `HideObject`).
- species checks: `MAGNETON` → convert; `MAGNEMITE` → "not evolved"; 
  `FLOATING_MAGNETON` → "already"; else wrong-mon.

### 8d. `ARMORED_MEWTWO` — `scripts/SecretLab.asm`

Labels: `SecretLabMewtwoMachineText`, `SecretLabMewtwoTransformation`.
Two-way (`MEWTWO ⇄ ARMORED_MEWTWO`):
1. `FindPokemonInParty` for `MEWTWO` **or** `ARMORED_MEWTWO`; if neither, "nothing
   happens" text.
2. Gate on `EVENT_OPENED_MACHINE_DOOR`.
3. `DisplayPartyMenu`; validate `wCurPartySpecies` is `MEWTWO` or `ARMORED_MEWTWO`
   (else `_SecretLabMewtwoReactionText4`).
4. `SecretLabMewtwoTransformation`: branch on current species → set
   `wCurPartySpecies` to the *other* one; rumble SFX + screen-shake; a full
   fade-to-white cutscene that `GetMonHeader` + `LoadFlippedFrontSpriteByMonIndex`
   + `PlayCry` the target form on screen; `callfar ChangePartyPokemonSpecies`;
   fade back; "transformation complete" text.
5. Other NPCs (`scripts/BillsGarden.asm` Mr Fuji & Giovanni) check for
   `MEWTWO` *or* `ARMORED_MEWTWO` with `FindPokemonInParty` and pick alt dialogue.

---

## 9. Constants / events

```
; constants/event_constants.asm
	const EVENT_FLOATING_WEEZING_ANIMATION   ; one-shot animation latch (Silph)
	; Magneton uses a map-script state (SCRIPT_MAGNETON_SUPERCHARGE), not an event
	; Mewtwo reuses EVENT_OPENED_MACHINE_DOOR (Secret Lab) as its gate
```

```
; constants/map_script_constants (or the map's script-id block)
	const SCRIPT_MAGNETON_SUPERCHARGE     ; added to PowerPlant script pointers
```

No new hide/show constants — both floating animations borrow an existing hidden
NPC/object slot on the map and shove it off-screen when done.

---

## 10. What "falls off" (don't implement)

- **No new Pokédex entry, dex text, dex flags, or palette** — `PokedexOrder`
  remap handles all of it.
- **No evolution data** — forms point at the base form's `EvosMoves`.
- **No wild-encounter / grass / nest edits** — forms are conversion-only.
- **No name string beyond a base-name duplicate** unless you want a distinct
  in-menu name (PureRGB shows "WEEZING"/"MAGNETON"/"MEWTWO").
- Every other PureRGB form (`POWERED_HAUNTER`, `HARDENED_ONIX`, `SPIRIT_*`,
  `VOLCANIC_MAGMAR`, `WINTER_DRAGONAIR`, `VOLCANIC`/`MAGMA`/`CRYSTAL` types,
  `RemapArmoredMewtwoCry` if you skip §6) — drop those rows entirely.

---

## 11. Porting notes (vanilla pokered baseline)

| Assumption | Vanilla pokered | Adjust |
|---|---|---|
| `const_skip` MissingNo slots exist to repurpose | ✅ present | pick 3 |
| `GetMonHeader` can be extended in place | ❌ it's in the home bank, tiny | move to a new bank as `GetMonHeader2`, add `IsInArray` + far `NonDexMonsBaseStats` |
| Extended base-stats trailer (`db 4×picbank`, `dw altfront,back`) | ❌ vanilla base_stats end after TM/HM | match vanilla's shorter format; drop the alt-pic fields and the `front_sprite_toggler` row |
| `PokedexOrder` is index→dex | ✅ same (`IndexToPokedex`) | just add rows |
| `CryData` / `MonsterNames` / `EvosMovesPointerTable` are index-keyed, `NUM_POKEMON_INDEXES` long | ✅ same | add rows at the repurposed slots |
| `MonsterPalettes` is dex-keyed, `NUM_POKEMON` long | ✅ same | **no** change |
| RST vectors (`rst _PrintText`, `rst _PlaySound`, `rst TextScriptEnd`) | ❌ vanilla uses `call` | substitute |
| `callfar` / `predef` for `ChangePartyPokemonSpecies` | new function | put it in a free bank, call via `callfar` |
| `PlayNewSoundChannel5/8`, `FloatingAnimation`, `DoBallPoofOnNPC` | ❌ PureRGB-added | port the helpers from the referenced files, or simplify the animation to a poof + text |
| Conversion move rework table | ❌ not in vanilla | ignore |
| New `FLOATING` type slot free in type table | ✅ pokered has unused type indices | add name + matchups |

Minimum viable version: §1 + §2 + §3 + §4a + §4c + one trigger script with just
`poof → ChangePartyPokemonSpecies → text`. Types (§5) and cry remap (§6) are
independent add-ons.

---

## 12. Test checklist

- [ ] Build: all `assert_table_length` pass; `NUM_POKEMON` and
      `NUM_POKEMON_INDEXES` unchanged from before.
- [ ] Convert Weezing → stats jump, type shows `POISON/FLOATING`, HP refills to
      new max, moves/EXP/DVs/nickname unchanged.
- [ ] Earthquake / Dig / any Ground move does **0** damage to Floating Weezing &
      Floating Magneton; Ground-type still normal on other mons.
- [ ] Party menu, status screen, and box show the form with the base sprite
      (Floating *) or the armored sprite (Armored Mewtwo) and correct name.
- [ ] Pokédex still lists Weezing/Magneton/Mewtwo as owned; no phantom
      191st/192nd dex slot; dex entry/height/weight = base form.
- [ ] Deposit the form in the PC and withdraw → still the form, stats intact.
- [ ] Trigger each conversion:
  - [ ] wrong Pokémon selected → "wrong mon" text, no change.
  - [ ] unevolved (Koffing / Magnemite) → "not ready" text.
  - [ ] already-converted → "already" text.
  - [ ] cancel out of party menu → "forget it" text.
- [ ] Each conversion is not repeatable (event / script-state latch); re-entering
      the map doesn't replay the animation.
- [ ] Overworld float-up animation plays, puppet sprite ends up hidden
      off-screen, music resumes, no stuck `wJoyIgnore`.
- [ ] Secret Lab: Mewtwo → Armored and Armored → Mewtwo both work; Mr Fuji /
      Giovanni give the Mewtwo-line dialogue for either form.
- [ ] Armored Mewtwo cry sounds distinct (if §6 implemented) in battle, party
      menu, and Pokédex-style contexts (all three audio banks).
- [ ] A trainer carrying `FLOATING_MAGNETON` (if added) loads and battles
      correctly.
- [ ] Faint the form, revive at a Pokémon Center → fine. Level it up → stats grow
      from the form's bases.
- [ ] Save, reset, reload → species and stats persist.
