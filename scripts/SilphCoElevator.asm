SilphCoElevator_Script:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	push hl
	call nz, SilphCoElevatorStoreWarpEntriesScript
	pop hl
	bit BIT_CUR_MAP_USED_ELEVATOR, [hl]
	res BIT_CUR_MAP_USED_ELEVATOR, [hl]
	call nz, SilphCoElevatorShakeScript
	xor a
	ld [wAutoTextBoxDrawingControl], a
	inc a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret

SilphCoElevatorStoreWarpEntriesScript:
	ld hl, wWarpEntries
	ld a, [wWarpedFromWhichWarp]
	ld b, a
	ld a, [wWarpedFromWhichMap]
	ld c, a
	call .StoreWarpEntry
	; fallthrough
.StoreWarpEntry:
	inc hl
	inc hl
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ret

SilphCoElevatorCopyWarpMapsScript:
	ld hl, SilphCoElevatorFloors
	call LoadItemList
	ld hl, SilphCoElevatorWarpMaps
	ld de, wElevatorWarpMaps
	ld bc, SilphCoElevatorWarpMaps.End - SilphCoElevatorWarpMaps
	call CopyData
	ret

SilphCoElevatorFloors:
	item_list FLOOR_1F, FLOOR_2F, FLOOR_3F, FLOOR_4F, FLOOR_5F, FLOOR_6F, \
	          FLOOR_7F, FLOOR_8F, FLOOR_9F, FLOOR_10F, FLOOR_11F

; These specify where the player goes after getting out of the elevator.
SilphCoElevatorWarpMaps:
	; warp number, map id
	db 3, SILPH_CO_1F
	db 2, SILPH_CO_2F
	db 2, SILPH_CO_3F
	db 2, SILPH_CO_4F
	db 2, SILPH_CO_5F
	db 2, SILPH_CO_6F
	db 2, SILPH_CO_7F
	db 2, SILPH_CO_8F
	db 2, SILPH_CO_9F
	db 2, SILPH_CO_10F
	db 1, SILPH_CO_11F
.End:

SilphCoElevatorShakeScript:
	call Delay3
	farcall ShakeElevator
	ret

SilphCoElevator_TextPointers:
	def_text_pointers
	dw_const SilphCoElevatorElevatorText, TEXT_SILPHCOELEVATOR_ELEVATOR

SilphCoElevatorElevatorText:
	text_asm
	call SilphCoElevatorCopyWarpMapsScript
	ld hl, SilphCoElevatorWarpMaps
	predef DisplayElevatorFloorMenu
	jp TextScriptEnd
