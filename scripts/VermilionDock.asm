VermilionDock_Script:
	call EnableAutoTextBoxDrawing
	ld hl, VermilionDockTrainerHeaders
	ld de, VermilionDock_ScriptPointers
	ld a, [wVermilionDockCurScript]
	call ExecuteCurMapScriptInTable
	ld [wVermilionDockCurScript], a
	call TruckCheck
	CheckEventHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	jr nz, .walking_out_of_dock
	CheckEventReuseHL EVENT_GOT_HM01
	ret z
	ld a, [wDestinationWarpID]
	cp $1
	ret nz
	CheckEventReuseHL EVENT_SS_ANNE_LEFT
	jp z, VermilionDockSSAnneLeavesScript
	SetEventReuseHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	call Delay3
	ld hl, wStatusFlags5
	set BIT_SCRIPTED_MOVEMENT_STATE, [hl]
	ld hl, wSimulatedJoypadStatesEnd
	ld a, PAD_UP
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $3
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wSpritePlayerStateData2MovementByte1], a
	ld [wOverrideSimulatedJoypadStatesMask], a
	dec a
	ld [wJoyIgnore], a
	ret
.walking_out_of_dock
	CheckEventAfterBranchReuseHL EVENT_WALKED_OUT_OF_DOCK, EVENT_STARTED_WALKING_OUT_OF_DOCK
	ret nz
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld [wJoyIgnore], a
	SetEventReuseHL EVENT_WALKED_OUT_OF_DOCK
	ret

VermilionDock_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_VERMILIONDOCK_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_VERMILIONDOCK_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_VERMILIONDOCK_END_BATTLE

VermilionDockSSAnneLeavesScript:
; The S.S. ANNE returns to port once the SOUL BADGE is obtained, so from that
; point on the departure cutscene must never play (the dock stays reachable).
	ld a, [wObtainedBadges]
	bit BIT_SOULBADGE, a
	ret nz
	SetEventForceReuseHL EVENT_SS_ANNE_LEFT
	ld a, $ff
	ld [wJoyIgnore], a
	call StopAllMusic
	ld c, BANK(Music_Surfing)
	ld a, MUSIC_SURFING
	call PlayMusic
	farcall LoadSmokeTileFourTimes
	xor a
	ld [wSpritePlayerStateData1ImageIndex], a
	ld c, 120
	call DelayFrames
	ld b, HIGH(vBGMap1)
	call CopyScreenTileBufferToVRAM
	hlcoord 0, 10
	ld bc, SCREEN_WIDTH * 6
	ld a, $14 ; water tile
	call FillMemory
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld [wSSAnneSmokeDriftAmount], a
	ldh [rOBP1], a
	call UpdateCGBPal_OBP1
	ld a, 88
	ld [wSSAnneSmokeX], a
	ld hl, wMapViewVRAMPointer
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	push hl
	ld a, SFX_SS_ANNE_HORN
	call PlaySoundWaitForCurrent
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld d, $0
	ld e, $8
.shift_columns_up
	ld hl, $2
	add hl, bc
	ld a, l
	ld [wMapViewVRAMPointer], a
	ld a, h
	ld [wMapViewVRAMPointer + 1], a
	push hl
	push de
	call ScheduleEastColumnRedraw
	call VermilionDock_EmitSmokePuff
	pop de
	ld b, $10
.smoke_puff_drift_loop
	call VermilionDock_AnimSmokePuffDriftRight
	ld c, $8
.delay_between_drifts
	call VermilionDock_SyncScrollWithLY
	dec c
	jr nz, .delay_between_drifts
	inc d
	dec b
	jr nz, .smoke_puff_drift_loop
	pop bc
	dec e
	jr nz, .shift_columns_up
	xor a
	ldh [rWY], a
	ldh [hWY], a
	call VermilionDock_EraseSSAnne
	ld a, $90
	ldh [hWY], a
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	pop hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	call LoadPlayerSpriteGraphics
	ld hl, wNumberOfWarps
	dec [hl]
	ret

VermilionDock_AnimSmokePuffDriftRight:
	push bc
	push de
	ld hl, wShadowOAMSprite04XCoord
	ld a, [wSSAnneSmokeDriftAmount]
	swap a
	ld c, a
	ld de, 4
.drift_loop
	inc [hl]
	inc [hl]
	add hl, de
	dec c
	jr nz, .drift_loop
	pop de
	pop bc
	ret

VermilionDock_EmitSmokePuff:
; new smoke puff above the S.S. Anne's front smokestack
	ld a, [wSSAnneSmokeX]
	sub 16
	ld [wSSAnneSmokeX], a
	ld c, a
	ld b, 100 ; Y
	ld a, [wSSAnneSmokeDriftAmount]
	inc a
	ld [wSSAnneSmokeDriftAmount], a
	ld a, $1
	ld de, VermilionDockOAMBlock
	call WriteOAMBlock
	ret

VermilionDockOAMBlock:
; tile ID, attributes
	db $fc, OAM_PAL1
	db $fd, OAM_PAL1
	db $fe, OAM_PAL1
	db $ff, OAM_PAL1

VermilionDock_SyncScrollWithLY:
	ld h, d
	ld l, $50
	call .sync_scroll_ly
	ld h, $0
	ld l, $80
.sync_scroll_ly
	ldh a, [rLY]
	cp l
	jr nz, .sync_scroll_ly
	ld a, h
	ldh [rSCX], a
.wait_for_ly_match
	ldh a, [rLY]
	cp h
	jr z, .wait_for_ly_match
	ret

VermilionDock_EraseSSAnne:
; Fill the area the S.S. Anne occupies in BG map 0 with water tiles.
	ld hl, wVermilionDockTileMapBuffer
	ld bc, wVermilionDockTileMapBufferEnd - wVermilionDockTileMapBuffer
	ld a, $14 ; water tile
	call FillMemory
	hlbgcoord 0, 10
	ld de, wVermilionDockTileMapBuffer
	lb bc, BANK(wVermilionDockTileMapBuffer), 12
	call CopyVideoData

; Replace the blocks of the lower half of the ship with water blocks. This
; leaves the upper half alone, but that doesn't matter because replacing any of
; the blocks is unnecessary because the blocks the ship occupies are south of
; the player and won't be redrawn when the player automatically walks north and
; exits the map. This code could be removed without affecting anything.
	hlowcoord 5, 2, VERMILION_DOCK_WIDTH
	ld a, $d ; water block
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 120
	call DelayFrames
	ret

; -----------------------------------------------------------------------------
; "Mew is under the truck" (port of PureRGB's implementation)
;
; The truck already exists on the dock as block $03 at block coord (col 10,
; row 0). With Strength active, the player stands at coord (22, 0) - the tile
; directly right of the truck - and presses Left twice. The truck slides away
; (8 hardware sprites + boulder-push SFX + dust) and a static Level 50 wild Mew
; appears where it was. EVENT_FOUND_MEW makes the shifted state permanent.
; -----------------------------------------------------------------------------

TruckOAMTable:
	db $50, $28, $c0, $10
	db $50, $30, $c1, $10
	db $50, $38, $c2, $10
	db $50, $40, $c3, $10
	db $58, $28, $c4, $10
	db $58, $30, $c5, $10
	db $58, $38, $c6, $10
	db $58, $40, $c7, $10

TruckSpriteGFX: INCBIN "gfx/sprites/truck.2bpp"

NoTruckAction:
	ld hl, wCurrentMapScriptFlags
	res BIT_CUR_MAP_USED_ELEVATOR, [hl]
	ret

TruckCheck:
	CheckEventHL EVENT_FOUND_MEW
	jp nz, ChangeTruckTile
	ld hl, wCurrentMapScriptFlags
	res BIT_CUR_MAP_LOADED_1, [hl]
; keep the overworld Mew sprite hidden until the truck has actually been moved
	lb bc, FLAG_TEST, HS_MEW_VERMILION_DOCK
	ld hl, wMissableObjectFlags
	predef FlagActionPredef
	ld a, c
	and a
	jr nz, .mewAlreadyHidden
	ld a, HS_MEW_VERMILION_DOCK
	ld [wMissableObjectIndex], a
	predef HideObject
.mewAlreadyHidden
	ld a, [wStatusFlags1]
	bit BIT_STRENGTH_ACTIVE, a ; using Strength?
	jr z, NoTruckAction
; the push position is (x=22, y=0)
	ld hl, wYCoord
	ld a, [hli]
	and a
	jr nz, NoTruckAction
	ld a, [hl] ; wXCoord
	cp 22
	jr nz, NoTruckAction
; is the player trying to walk left?
	ld a, [wPlayerMovingDirection]
	bit PLAYER_DIR_BIT_LEFT, a
	jr z, NoTruckAction
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_USED_ELEVATOR, [hl]
	set BIT_CUR_MAP_USED_ELEVATOR, [hl] ; first Left press just primes the push
	ret z
	ldh a, [hJoyHeld]
	bit B_PAD_LEFT, a ; is Left still held?
	ret z
	res BIT_CUR_MAP_USED_ELEVATOR, [hl]
	ld a, $ff
	ld [wJoyIgnore], a
	ld [wUpdateSpritesEnabled], a
; load the truck sprite tiles and lay out the 8 hardware sprites over the truck
	ld bc, (BANK(TruckSpriteGFX) << 8) | 8
	ld hl, vChars1 + $400
	ld de, TruckSpriteGFX
	call CopyVideoData
	ld hl, TruckOAMTable
	ld bc, $20
	ld de, wShadowOAM + $20
	call CopyData
; drop an empty block where the truck was so the BG doesn't fight the sprites
	ld a, $c
	ld [wNewTileBlockID], a
	ld bc, $a
	predef ReplaceTileBlock
; the truck sprites use OBP1 (attr $10); make sure it holds a sane palette
	ld a, %11100100
	ldh [rOBP1], a
	call UpdateCGBPal_OBP1
; slide the 8 truck sprites left
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	ld b, 32
	ld de, 4
.slideTruck
	ld hl, wShadowOAM + $21
	ld a, 8
.slideTruckSprites
	dec [hl]
	add hl, de
	dec a
	jr nz, .slideTruckSprites
	ld c, 2
	call DelayFrames
	dec b
	jr nz, .slideTruck
; put the truck block one block to the left of where it started
	ld a, $3
	ld [wNewTileBlockID], a
	ld bc, $9
	predef ReplaceTileBlock
	callfar AnimateBoulderDust
	call ShowMew
	ld c, 20
	call DelayFrames
	xor a
	ld [wJoyIgnore], a
	SetEvent EVENT_FOUND_MEW
	ret

ShowMew:
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	ld a, HS_MEW_VERMILION_DOCK
	ld [wMissableObjectIndex], a
	predef_jump ShowObject

ChangeTruckTile:
; runs once per map load after EVENT_FOUND_MEW: redraw the "truck already moved"
; state by shifting the truck block one block to the left in the block map.
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_USED_ELEVATOR, [hl]
	ret z
	hlowcoord 9, 0, VERMILION_DOCK_WIDTH
	ld a, [hl]
	cp $3
	ret z
	ld a, $3
	ld [hli], a
	ld [hl], $c
	CheckEvent EVENT_ENCOUNTERED_MEW
	call z, ShowMew
	jpfar RedrawMapView

VermilionDock_TextPointers:
	def_text_pointers
	dw_const VermilionDockMewText, TEXT_VERMILIONDOCK_MEW

VermilionDockTrainerHeaders:
	def_trainers 6
MewTrainerHeader:
	trainer EVENT_ENCOUNTERED_MEW, 0, MewBattleText, MewBattleText, MewBattleText
	db -1 ; end

VermilionDockMewText:
	text_asm
	ld hl, MewTrainerHeader
	call TalkToTrainer
	ld a, [wCurMapScript]
	ld [wVermilionDockCurScript], a
	jp TextScriptEnd

MewBattleText:
	text_far _MewtwoBattleText ; "Mew!"
	text_asm
	ld a, MEW
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd
