# Spec: Vermilion Gym trash-can switch fix

> FEATURES.md:379 — *"The vermilion gym puzzle won't reset if you choose the
> wrong second switch. RNG time waster be gone!"*

One file: `engine/events/hidden_objects/vermilion_gym_trash.asm` (`GymTrashScript`).
Two edits, both small. Introduced in commit `3e218d79`.

---

## 1. Background — how the puzzle works

L.T. Surge's gym has 15 trash cans (`data/events/hidden_objects.asm`,
`VermilionGymHiddenObjects` — index 0-14, all run `GymTrashScript` with the can
index as `wHiddenObjectFunctionArgument` → `wGymTrashCanIndex`).

State:

| var | meaning | set where |
|---|---|---|
| `wFirstLockTrashCanIndex` | which can holds the 1st switch | `scripts/VermilionCity.asm` on map-load: `Random` & `$e` → a random **even** index 0..14 |
| `wSecondLockTrashCanIndex` | which can holds the 2nd switch | `GymTrashScript` when the 1st switch is found — picked from a per-can adjacency list in `GymTrashCans` |
| `EVENT_1ST_LOCK_OPENED` / `EVENT_2ND_LOCK_OPENED` | progress | `GymTrashScript` |
| `BIT_CUR_MAP_LOADED_2` of `wCurrentMapScriptFlags` | tells `VermilionGym_Script` to animate the door open | set on 2nd lock |

Flow: search cans → find 1st switch (`EVENT_1ST_LOCK_OPENED`, 2nd switch location
rolled) → find 2nd switch (`EVENT_2ND_LOCK_OPENED`, gym doors open).

---

## 2. The fix — don't reset on a wrong second guess

`.trySecondLock` runs when the player flips a switch after the first lock is
already open. If the can isn't the one holding the second lock:

### Vanilla pokered

```
.trySecondLock
	ld a, [wSecondLockTrashCanIndex]
	ld b, a
	ld a, [wGymTrashCanIndex]
	cp b
	jr z, .openSecondLock
; Reset the cans.
	ResetEvent EVENT_1ST_LOCK_OPENED      ; <-- puzzle thrown all the way back
	call Random
	and $e
	ld [wFirstLockTrashCanIndex], a       ; <-- 1st switch relocated at random
	tx_pre_id VermilionGymTrashFailText   ; "Oops! ... reset!"
	jr .done
```

Miss the second switch once and you start over: hunt for the first switch again
(now in a new random can), then re-hunt the second. Pure RNG busywork.

### PureRGB

```
.trySecondLock
	ld a, [wSecondLockTrashCanIndex]
	ld b, a
	ld a, [wGymTrashCanIndex]
	cp b
	jr z, .openSecondLock
; Reset the cans. ; PureRGBnote: CHANGED: don't reset locks because it's just an annoying waste of time
	;ResetEvent EVENT_1ST_LOCK_OPENED
	;call Random
	;and $e
	;ld [wFirstLockTrashCanIndex], a
	;tx_pre_id VermilionGymTrashFailText
	tx_pre_id VermilionGymTrashText       ; plain "just a trash can" text
	jr .done
```

The four reset lines and the fail text are commented out; a wrong second guess
now shows the neutral trash-can text. `EVENT_1ST_LOCK_OPENED` and
`wSecondLockTrashCanIndex` are untouched, so the player just keeps trying cans
until they hit the second switch.

Side effects:
- `VermilionGymTrashFailText` / `_VermilionGymTrashFailText` become unreferenced
  (leave them; harmless).
- `wFirstLockTrashCanIndex` is now only ever written on map-load.

---

## 3. Secondary fix — "AND to 0" underflow in the second-lock roll

Same commit, in `.openFirstLock` where `wSecondLockTrashCanIndex` is chosen:

```
	ldh [hGymTrashCanRandNumMask], a   ; a = candidate count for this can (2/3/4)
	push hl
.tryagain                              ; <-- PureRGB: new label
	call Random
	swap a
	ld b, a
	ldh a, [hGymTrashCanRandNumMask]
	and b
	jr z, .tryagain                     ; <-- PureRGB: re-roll if the AND is 0
	dec a
	pop hl
	; hl += a  -> read candidate can index from the GymTrashCans entry
```

The long-standing pokered bug (see the comment block in the file): if
`mask & random == 0`, `dec a` makes `a = $ff`, `add hl, de` then walks 255 bytes
past the `GymTrashCans` entry into the zero-padding at the end of the ROM bank,
and `wSecondLockTrashCanIndex` gets a garbage value (typically 0) — so the second
lock could land in a can outside the intended adjacency list, including one the
player already checked or the current one.

`jr z, .tryagain` re-rolls `Random` until the mask and the random value share a
set bit, so `a` is always ≥ 1 and the read stays inside the entry. (It doesn't
"fix" the deeper design flaw the comment describes about the mask not being a
real bitmask — it just removes the out-of-bounds read.)

---

## 4. Implementation checklist (porting to another pokered fork)

1. `engine/events/hidden_objects/vermilion_gym_trash.asm`, `.trySecondLock`:
   delete/comment `ResetEvent EVENT_1ST_LOCK_OPENED`, the `Random` + `and $e` +
   `ld [wFirstLockTrashCanIndex]`, and change `tx_pre_id VermilionGymTrashFailText`
   → `tx_pre_id VermilionGymTrashText`.
2. Same file, second-lock roll: add a `.tryagain` label before `call Random` and
   `jr z, .tryagain` right after `and b`.
3. Nothing else — no new constants, WRAM, events, text, or map data.

Both edits are independent; #1 is the FEATURES.md item, #2 is a latent-bug
cleanup that ships with it.

---

## 5. Test checklist

- [ ] Enter the gym, flip switches until the first one is found ("...switch!").
- [ ] Flip a **wrong** second can → neutral trash text, **no** "reset" message,
      first switch stays found (leave and re-enter — still found).
- [ ] Keep flipping cans → eventually hit the real second switch → doors open,
      `SFX_GO_INSIDE`, gym proceeds normally.
- [ ] The second switch is always in a can adjacent to the first (per
      `GymTrashCans`), never a wild out-of-range can (regression test for the
      AND-to-0 fix — hard to observe directly; verify by save-state RNG or by
      confirming `wSecondLockTrashCanIndex` is always 0-14 and in the first
      can's candidate list).
- [ ] Re-entering the gym after opening both locks: `EVENT_2ND_LOCK_OPENED` set,
      puzzle stays solved, doors stay open.
