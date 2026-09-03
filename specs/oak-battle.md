# Spec: The Professor Oak battle

Restores Gen 1's unused `PROF_OAK` trainer class as a real, repeatable
post-game boss fight in Cerulean Cave.

> FEATURES.md:285 — *"There was an unused trainer class for Prof Oak. It's been
> added back into the game. Find him in Cerulean Cave after beating the Elite
> Four. He can be battled repeatedly. Just leave the area and come back."*

Files: `scripts/CeruleanCave2F.asm`, `scripts/CeruleanCave1F.asm`,
`data/maps/objects/CeruleanCave2F.asm`, `text/CeruleanCity.asm`,
`data/trainers/parties.asm`, and small hooks in the battle engine, Hall of Fame,
and the Cinnabar Lab colour-changer.

---

## 1. Does it happen twice?

**No — it is one battle object that is infinitely repeatable, with a one-time
"first defeat" branch layered on top.** Two things make it *look* like two
battles:

1. **Two event flags** (`§2`): `EVENT_BEAT_PROF_OAK` (transient, per-visit) and
   `EVENT_BEAT_PROF_OAK_ONCE` (permanent, first clear only).
2. **Two text boxes on the first win**: the normal end-of-battle line
   (`_OakBattleWinText`, "R-Remarkable!") shown by the battle engine, then —
   back in the overworld, only the first time and only if Alt Pkmn Palettes is
   on — a second cutscene line (`_OakFirstLoseText`) that hands you the note to
   the Cinnabar lab.

There is exactly **one** `OPP_PROF_OAK` encounter in the game. It is not scripted
anywhere else. (`OaksLab` / `HallOfFame` Oak sprites are unrelated NPCs.)

---

## 2. Event flags & lifecycle

`constants/event_constants.asm` (Cerulean Cave block, `const_next $8C0`):

```
	const EVENT_BEAT_PROF_OAK        ; transient "already beaten this visit"
	const EVENT_BEAT_MEWTWO
	const EVENT_BEAT_PROF_OAK_ONCE   ; permanent "beaten at least once"
```

| Flag | Set by | Cleared by | Purpose |
|---|---|---|---|
| `EVENT_BEAT_PROF_OAK` | `CeruleanCave2FAfterOakBattleScript` on a win | **`CeruleanCave1F_Script`** — reset every time the player is on B1F | Gates the NPC's talk text between "challenge me" (battle) and "already beaten" (chat). Being cleared on the floor below is the entire "leave and come back" rematch mechanism. |
| `EVENT_BEAT_PROF_OAK_ONCE` | same script, first win only, **and only if `BIT_ALT_PKMN_PALETTES` (`wOptions2`) is set** | never | Unlocks the Cinnabar Lab colour-changer (`§6`); triggers the one-time reward dialogue. |

`CeruleanCave1F_Script` in full:

```
CeruleanCave1F_Script:
	ResetEvent EVENT_BEAT_PROF_OAK
	jp EnableAutoTextBoxDrawing
```

### Rematch loop

1. Beat Elite Four → Cerulean Cave accessible.
2. Enter B2F, talk to Oak → battle. Win → `EVENT_BEAT_PROF_OAK` set.
3. Talk again → "already beaten" chat (`_OakBeatenText`), no battle.
4. Walk down to B1F → `EVENT_BEAT_PROF_OAK` reset.
5. Return to B2F → Oak is challengeable again. Repeat forever.

---

## 3. Trigger flow (`scripts/CeruleanCave2F.asm`)

The map uses `CallFunctionInTable` on `wCeruleanCave2FCurScript` with two states:

```
SCRIPT_CERULEANCAVE2F_DEFAULT            -> DoRet
SCRIPT_CERULEANCAVE2F_AFTER_OAK_BATTLE   -> CeruleanCave2FAfterOakBattleScript
```

### 3a. Talking to Oak — `OakCeruleanCaveText` (`text_asm`)

```
	CheckEvent EVENT_BEAT_PROF_OAK
	  set   -> print _OakBeatenText, done
	  clear -> PlayMusic MUSIC_MEET_PROF_OAK   (bank Music_MeetProfOak)
	           print _OakBattleStartText
	           call OakBattle
```

### 3b. `OakBattle` — hand-rolled manual trainer battle init

This is a stripped `StartTrainerBattle` (`home/trainers.asm`) that does **not**
call `InitBattleEnemyParameters` (the NPC has no `trainer` args in the object
file), setting everything by hand:

```
OakBattle:
	ld hl, OakBattleWinText
	ld de, OakBattleLoseText
	call SaveEndBattleTextPointers          ; engine prints these at battle end
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]         ; overworld loop -> start trainer battle
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld a, OPP_PROF_OAK
	ld [wCurOpponent], a
	ld a, [wPlayerStarter]
	call StarterToPartyID                   ; CHARMANDER->1, SQUIRTLE->2, BULBASAUR->3
	ld [wTrainerNo], a                      ; picks which of Oak's 3 teams
	ld a, SCRIPT_CERULEANCAVE2F_AFTER_OAK_BATTLE
	ld [wCeruleanCave2FCurScript], a        ; run the after-script when we return
	ret
```

Then `rst TextScriptEnd`; the overworld loop sees `BIT_TALKED_TO_TRAINER` +
`wCurOpponent` and launches the battle.

### 3c. After the battle — `CeruleanCave2FAfterOakBattleScript`

```
	ld a, [wIsInBattle]
	cp $ff                    ; $ff = player lost/drew -> skip rewards
	jr z, .done
	SetEvent EVENT_BEAT_PROF_OAK
	CheckEvent EVENT_BEAT_PROF_OAK_ONCE
	jr nz, .done              ; already had a first win
	ld a, [wOptions2]
	bit BIT_ALT_PKMN_PALETTES, a
	jr z, .done               ; first-defeat reward is gated on Alt Palettes ON
	ld a, TEXT_CERULEANCAVE2F_OAK_FIRST_DEFEAT
	ldh [hTextID], a
	call DisplayTextID        ; -> OakCeruleanCaveFirstDefeatText -> _OakFirstLoseText
	SetEvent EVENT_BEAT_PROF_OAK_ONCE
.done
	ld a, SCRIPT_CERULEANCAVE2F_DEFAULT
	ld [wCeruleanCave2FCurScript], a
	ret
```

Quirk: if the player's first win happens with Alt Palettes **off**,
`EVENT_BEAT_PROF_OAK_ONCE` is never set, so the first-defeat dialogue (and the
Cinnabar unlock) fires on the *next* win after they enable the option.

---

## 4. Opponent data

### 4a. Trainer class

- `constants/trainer_constants.asm`: `trainer_const PROF_OAK ; $19` (already
  present but unused in vanilla — `OPP_PROF_OAK = PROF_OAK + OPP_ID_OFFSET`).
- `data/trainers/parties.asm`: pointer `dw ProfOakData` at the `PROF_OAK` slot of
  `TrainerDataPointers`.
- `data/trainers/pic_pointers_money.asm`: `pic_money ProfOakPic, 9900` — base
  reward money 9900 × last mon's level (huge payout, ~700k+).
- `data/trainers/move_choices.asm`: `move_choices 1, 3, 4 ; PROF_OAK` — AI move
  modification types 1/3/4 (aggressive: avoids bad matchups, prefers
  super-effective and status/setup moves).
- `gfx/pics.asm`: `ProfOakPic:: INCBIN "gfx/trainers/prof.oak.pic"` (vanilla
  asset, already there).
- AI: `PROF_OAK` is `$19` — trainer AI "class number" ≥ certain threshold gives
  it many item uses / smart switching in `trainer_ai.asm` (inherits from the high
  class id).

### 4b. `ProfOakData` — three teams, chosen by the player's starter

```
ProfOakData:
	db $FE, 70, FLOATING_MAGNETON, 71, TAUROS, 72, EXEGGUTOR, 73, ARCANINE, 74, VENUSAUR,  75 + 128, GYARADOS, 0
	db $FE, 70, FLOATING_MAGNETON, 71, TAUROS, 72, EXEGGUTOR, 73, ARCANINE, 74, CHARIZARD, 75 + 128, GYARADOS, 0
	db $FE, 70, FLOATING_MAGNETON, 71, TAUROS, 72, EXEGGUTOR, 73, ARCANINE, 74, BLASTOISE, 75 + 128, GYARADOS, 0
```

| `wTrainerNo` | Player starter | Rival took | Oak's raised starter (5th mon) |
|---|---|---|---|
| 1 | Charmander | Squirtle | **Venusaur** |
| 2 | Squirtle | Bulbasaur | **Charizard** |
| 3 | Bulbasaur | Charmander | **Blastoise** |

Oak always raised the starter neither the player nor rival chose — same "leftover
starter" logic as the vanilla rival, using `wPlayerStarter` (set in
`scripts/OaksLab.asm`, `StarterToPartyID` in `home/pokemon.asm`).

Team is fixed otherwise: Floating Magneton (see
`specs/change-pokemon-species-forms.md`), Tauros, Exeggutor, Arcanine, the
starter, and Gyarados as the ace. Levels 70–75.

### 4c. Party data format — `$FE` and `+ 128`

`engine/battle/read_trainer_party.asm` (`ReadTrainer`):

- **`$FE` prefix** = PureRGB-added "special trainer with **alt-palette** team".
  Read like `$FF` (per-mon levels) via `.SpecialTrainerLoop`, but each level byte
  is also checked for **bit 7** (`BIT_ALT_PALETTE_TRAINER_MON`): if set, that mon
  loads with its alternate (shiny-ish) palette (`wIsAltPalettePkmnData = 1`),
  then the level is masked with `%01111111`. Max legit level is 100 so bit 7 is
  always free to reuse.
- So `75 + 128` = **level 75 Gyarados with the alternate palette**. Oak's ace
  Gyarados is visually distinct.
- (`$FD` prefix = "custom moveset trainer" — not used by Oak.)

If your project has no alt-palette system, use `$FF` and plain `75`.

### 4d. Original (vanilla) `ProfOakData`

`data/trainers/parties_original.asm` keeps the pristine unused data for
reference — `$FF, 65 MAGNETON … 69 <starter> … 70 GYARADOS`, row order
Blastoise/Venusaur/Charizard. PureRGB bumped levels, swapped Magneton →
Floating Magneton, re-ordered rows, and switched to `$FE` + alt Gyarados.

---

## 5. Battle-engine special cases

`OPP_PROF_OAK` / `PROF_OAK` is special-cased in three places — all small:

| File / line | Behaviour |
|---|---|
| `audio/play_battle_music.asm:21` | `cp OPP_PROF_OAK` → plays `MUSIC_FINAL_BATTLE` (the Champion/rival theme) instead of the trainer theme |
| `engine/battle/core.asm:~1012` | on victory, treat like a rival/gym-leader: play `MUSIC_DEFEATED_GYM_LEADER` victory fanfare |
| `engine/battle/core.asm:~1280` (`HandlePlayerBlackOut`) | `cp OPP_PROF_OAK` → print the trainer's **loss text** (`_OakBattleLoseText`, "Looks like I've still got it!") before blacking out, like the rival fights. Player still blacks out normally (the no-blackout exception is `OAKS_LAB` only). |

`engine/battle/core.asm:~1012` also references `PROF_OAK` in a comment block for
"special PROF oak battle" music handling — keep that branch.

---

## 6. Related touchpoints

### 6a. Hall of Fame — hide the starter ball Oak is "using"

`scripts/HallOfFame.asm:~98`: after entering the Hall of Fame, hide the third
starter's Poké Ball object in Oak's Lab (`HS_STARTER_BALL_1/2/3` chosen by
`wPlayerStarter`), because lore-wise Oak took that starter to Cerulean Cave to
train it. Cosmetic; only matters if you revisit Oak's Lab post-game.

### 6b. Cinnabar Lab colour-changer gate

`scripts/CinnabarLabFossilRoom.asm:144`:
`CheckEvent EVENT_BEAT_PROF_OAK_ONCE` / `call nz, VasIsDas` — the NPC who
re-colours your Pokémon only offers the service after Oak has been beaten once
(and Alt Palettes is on). `_OakFirstLoseText` is the in-fiction "take this note
to my colleague at Cinnabar" that motivates it.

### 6c. Text — `text/CeruleanCity.asm`

`_OakBattleStartText`, `_OakBattleWinText`, `_OakBattleLoseText`,
`_OakBeatenText`, `_OakFirstLoseText` (the last ends with
`sound_pokedex_rating`). Stored in the Cerulean City text bank, referenced from
the Cerulean Cave 2F script via `text_far`.

### 6d. Map object — `data/maps/objects/CeruleanCave2F.asm`

```
	object_const_def
	const_export CERULEANCAVE2F_OAK
	...
	object_event 11, 7, SPRITE_OAK, STAY, LEFT, TEXT_CERULEANCAVE2F_OAK
```

Plain stationary NPC — **not** declared as a `trainer` (no view-range / event-bit
args). The battle is entirely script-driven, which is why `OakBattle` sets
`wCurOpponent`/`wTrainerNo` itself.

`TEXT_CERULEANCAVE2F_OAK_FIRST_DEFEAT` is a text-pointer-only entry (index 5,
past the 4 real objects) invoked directly via `hTextID` — allowed because it is
not a `bg_event`.

---

## 7. Implementation checklist (for a fresh pokered-style project)

1. **Constants**
   - Confirm `PROF_OAK` trainer const exists (`$19` in vanilla — unused).
   - Add `EVENT_BEAT_PROF_OAK` + `EVENT_BEAT_PROF_OAK_ONCE` in a spare event
     region for your rematch map.
   - Add the two `SCRIPT_<MAP>_*` script-pointer constants.
2. **Trainer data**
   - `dw ProfOakData` at the `PROF_OAK` slot of `TrainerDataPointers`.
   - `ProfOakData` — 3 rows, `$FF` (or `$FE` if you have alt palettes), per-mon
     levels, ace = leftover starter's final evo, terminate each row with `0`.
   - `pic_money ProfOakPic, <money>`.
   - `move_choices` AI entry for `PROF_OAK`.
   - `ProfOakPic` INCBIN (vanilla `gfx/trainers/prof.oak.pic` exists).
3. **Battle engine** — three `cp OPP_PROF_OAK` / `cp PROF_OAK` branches:
   battle music = final-battle theme; victory music = gym-leader fanfare;
   `HandlePlayerBlackOut` prints loss text.
4. **Scripts**
   - Rematch map script: `CallFunctionInTable` on a `w<Map>CurScript` var with
     `DEFAULT` (`DoRet`) and `AFTER_OAK_BATTLE` states.
   - `OakCeruleanCaveText` (`text_asm`): branch on `EVENT_BEAT_PROF_OAK` →
     "beaten" chat or music + start text + `OakBattle`.
   - `OakBattle`: `SaveEndBattleTextPointers`, set `BIT_TALKED_TO_TRAINER` +
     `BIT_PRINT_END_BATTLE_TEXT`, set `wCurOpponent` / `wTrainerNo` (from
     `StarterToPartyID`), set script var to `AFTER_OAK_BATTLE`.
   - `…AfterOakBattleScript`: bail if `wIsInBattle == $ff`; else
     `SetEvent EVENT_BEAT_PROF_OAK`; first-time branch → optional reward text +
     `SetEvent EVENT_BEAT_PROF_OAK_ONCE`; reset script var.
   - **Adjacent map** (the "leave and come back" floor):
     `ResetEvent EVENT_BEAT_PROF_OAK` at the top of its map script.
5. **Object** — one `SPRITE_OAK`, `STAY`, plain text id (not a `trainer`).
6. **Text** — 5 strings in the appropriate text bank.
7. **Optional hooks** — Hall of Fame starter-ball hide; any post-game reward gate
   keyed on `EVENT_BEAT_PROF_OAK_ONCE`.

---

## 8. Porting notes

- The whole thing works in **vanilla pokered** with minimal change — `PROF_OAK`
  ($19), `ProfOakPic`, `ProfOakData` (unused), and `Music_MeetProfOak` all still
  ship. You are un-deleting dead content.
- RST vectors (`rst _PrintText`, `rst TextScriptEnd`) → `call PrintText` /
  `jp TextScriptEnd` in vanilla.
- `$FE` alt-palette party format is PureRGB-only — use `$FF`.
- `FLOATING_MAGNETON` → `MAGNETON` unless you also port
  `specs/change-pokemon-species-forms.md`.
- `BIT_ALT_PKMN_PALETTES` gate in the after-battle script is optional — drop it
  and always run the first-defeat branch, or drop the first-defeat branch
  entirely for a pure "repeatable superboss, no reward" version.
- Vanilla has no "final battle music for a trainer class" path in
  `play_battle_music.asm`; add the `cp OPP_PROF_OAK` branch.
- Money: vanilla caps `wAmountMoneyWon` at 999,999; `9900 × 75` overflows and is
  clamped — intentional (max payout).

---

## 9. Test checklist

- [ ] Oak NPC present on the rematch floor only after the Elite Four
      (guard on Cerulean Cave access, unchanged).
- [ ] Talk → "meet Oak" music, intro text, battle starts.
- [ ] Battle uses final-battle music; on win, gym-leader victory fanfare plays.
- [ ] Correct team for each of the 3 player starters (ace = leftover starter's
      final evolution).
- [ ] Ace Gyarados shows the alternate palette (if `$FE` used).
- [ ] Win → `_OakBattleWinText`; first win with Alt Palettes ON → also
      `_OakFirstLoseText` + Pokédex-rating jingle, then never again.
- [ ] First win with Alt Palettes OFF → no reward text, `ONCE` not set; enable
      the option, rematch, win → reward text fires that time.
- [ ] Talk again after winning → `_OakBeatenText`, no battle.
- [ ] Go down one floor, come back up → Oak challengeable again.
- [ ] Lose to Oak → `_OakBattleLoseText` shown, player blacks out normally, no
      flags set, no soft-lock; can re-challenge.
- [ ] Cinnabar Lab colour-changer becomes available only after
      `EVENT_BEAT_PROF_OAK_ONCE`.
- [ ] Money awarded is the (clamped) maximum.
- [ ] Save/reset mid-loop → `EVENT_BEAT_PROF_OAK` state and rematch behaviour
      survive (it re-clears on the floor below regardless).
