# Raise the PC item limit from 50 to 65

## Goal

Raise the PC item storage limit from **50** to **65** distinct item types by moving the PC item list into an unused 133-byte gap in Main Data. Main Data stays the same size and no code changes are needed.

## Background

- `PC_ITEM_CAPACITY EQU 50` (`constants/menu_constants.asm:2`). The list is `wNumBoxItems` (count) + `wBoxItems` (item/quantity pairs + `$FF` terminator), so 50 slots take 102 bytes.
- WRAM0 is completely full (`TOTAL EMPTY: $0000` in `pokeyellow.map`), so the list can't simply grow where it is.
- Main Data has two padding blocks with only a label between them: `ds 77` at the end of `wGameProgressFlags` and `ds 56` after `wGameProgressFlagsEnd` (`ram/wram.asm`, around lines 2341–2344). Together they make **133 contiguous free bytes**, and nothing in the code references them.
- 65 slots need 1 count byte + 65 × 2 + 1 terminator byte = 132 bytes, which fits.

## Save compatibility

The list's saved location changes, so an existing save will load with an **empty PC item list**. Everything else in the save stays where it was. This is acceptable because the PC will be emptied on the current save before updating, so **no migration is planned**.

## Changes

### 1. `constants/menu_constants.asm:2`

```asm
DEF PC_ITEM_CAPACITY  EQU 65
```

### 2. `ram/wram.asm`: free up the old location (around line 2192)

Replace:

```asm
wNumBoxItems:: db
; item, quantity
wBoxItems:: ds PC_ITEM_CAPACITY * 2 + 1
```

with:

```asm
	ds 102 ; was wNumBoxItems/wBoxItems (old 50-slot PC item list)
```

Hard-code 102 so the fields after it stay where they are when the constant changes.

### 3. `ram/wram.asm`: put the list in the gap (around lines 2340–2344)

Replace:

```asm
wVermilionDockCurScript:: db ; mew-under-the-truck feature
	ds 77
wGameProgressFlagsEnd::

	ds 56
```

with:

```asm
wVermilionDockCurScript:: db ; mew-under-the-truck feature
wGameProgressFlagsEnd::

wNumBoxItems:: db
; item, quantity
wBoxItems:: ds PC_ITEM_CAPACITY * 2 + 1
	ds 133 - (1 + PC_ITEM_CAPACITY * 2 + 1)
	ASSERT PC_ITEM_CAPACITY <= 65, "PC item list overflows its 133-byte slot"
```

**Moving `wGameProgressFlagsEnd` up is required.** `InitPlayerData2` empties the PC item list and then clears everything from `wGameProgressFlags` to `wGameProgressFlagsEnd` (`engine/movie/oak_speech/init_player_data.asm:26,49`). If the label stayed below the list, that clear would zero the list's `$FF` terminator on a new game. The clear will cover 77 fewer bytes, and nothing is stored in them.

## What doesn't change

- **Code:** everything refers to the list by label or by `PC_ITEM_CAPACITY`:
  - the capacity check in `engine/items/inventory.asm:14`
  - `engine/menus/players_pc.asm`
  - list init in `init_player_data.asm`
  - Oak's starting Potion in `oak_speech.asm:61`

  The count is a single byte, so 65 is safe.
- **Save format size:** `wMainDataEnd - wMainDataStart` is unchanged, so the SRAM layout (`sMainData` onward) and the checksum range stay the same.

## Build checks

- The "Main Data" section in `pokeyellow.map` is still `$0789` bytes.
- WRAM0 still reports `TOTAL EMPTY: $0000`, so nothing else has shifted.
- `wNumBoxItems` is now right after `wVermilionDockCurScript` in `pokeyellow.sym`.

## Emulator tests

1. **Before updating the ROM:** withdraw everything from the PC on the current save, then save the game.
2. **Existing save:** load it. The PC should show an empty item list (no garbage entries), and the bag, money, badges and story progress should be unchanged.
3. **Capacity:** deposit items until the PC refuses. You should get 65 distinct item types in before the "no room" message. Scrolling to the end of the list and withdrawing from the bottom should work.
4. **Persistence:** save, reset and reload. The PC list should still be intact.
5. **New game:** the PC should start with exactly one Potion.

## Further options (not planned)

- **More than 65 slots:** grow the list where it is and shift the fields after it into later padding. This breaks existing saves unless a migration is written.
- **Store PC items in SRAM:** bank 1 has about 2.7 KB free. This would need a rewrite of the PC and list-menu code, and deposits would stick without saving.
