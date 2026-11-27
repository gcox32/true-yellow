PalletTown_Script:
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	jr z, .next
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS
.next
	; After the lab, Pallet only ever runs the Daisy script. This also moves
	; saves made under the old script table (Daisy was index 8) onto it, and
	; tidies away the rival, whose HS slot used to be Misty's.
	ld a, [wStatusFlags4]
	bit BIT_GOT_STARTER, a
	jr z, .runScript
	ld a, [wPalletTownCurScript]
	cp SCRIPT_PALLETTOWN_DAISY
	jr z, .runScript
	ld a, SCRIPT_PALLETTOWN_DAISY
	ld [wPalletTownCurScript], a
	ld a, HS_PALLET_TOWN_RIVAL
	ld [wMissableObjectIndex], a
	predef HideObject
.runScript
	call EnableAutoTextBoxDrawing
	ld hl, PalletTown_ScriptPointers
	ld a, [wPalletTownCurScript]
	jp CallFunctionInTable

PalletTown_ScriptPointers:
	def_script_pointers
	dw_const PalletTownDefaultScript,           SCRIPT_PALLETTOWN_DEFAULT
	dw_const PalletTownPlayerPushedBackScript,  SCRIPT_PALLETTOWN_PLAYER_PUSHED_BACK
	dw_const PalletTownRivalLeavesScript,       SCRIPT_PALLETTOWN_RIVAL_LEAVES
	dw_const PalletTownDaisyScript,             SCRIPT_PALLETTOWN_DAISY

; Episode 1: no OAK in the tall grass. The player overslept, and has to get
; to the lab on their own before <RIVAL> rubs it in and the road opens.
PalletTownDefaultScript:
	ld a, [wYCoord]
	and a ; at the north exit?
	jr nz, .checkRival
	ld a, TEXT_PALLETTOWN_GO_TO_LAB
	ldh [hTextID], a
	call DisplayTextID
	call StartSimulatingJoypadStates
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	ld a, PAD_DOWN
	ld [wSimulatedJoypadStatesEnd], a
	xor a
	ld [wSpritePlayerStateData1FacingDirection], a
	ld [wJoyIgnore], a
	ldh [hJoyHeld], a
	ld a, SCRIPT_PALLETTOWN_PLAYER_PUSHED_BACK
	ld [wPalletTownCurScript], a
	ret

.checkRival
	CheckEvent EVENT_RIVAL_TAUNTED_OUTSIDE_LAB
	ret nz
	; The lab door (12,11) is only reachable along row 12, past one of these.
	ld hl, .RivalTauntCoords
	call ArePlayerCoordsInArray
	ret nc
	SetEvent EVENT_RIVAL_TAUNTED_OUTSIDE_LAB
	xor a
	ldh [hJoyHeld], a
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	; He's a STAY DOWN object: whenever his movement delay runs out, the engine's
	; "random movement" turns him back to face down. Park him in the delay state
	; with the longest delay, so he holds the turn through the "!" bubble; the
	; text box and then MoveSprite take over from there.
	ld a, $2
	ld [wSprite04StateData1MovementStatus], a
	ld a, $ff
	ld [wSprite04StateData2MovementDelay], a
	; face each other across row 12: a = rival's facing, b/c = player's
	ld a, [wXCoord]
	cp 12
	ld a, SPRITE_FACING_LEFT
	lb bc, SPRITE_FACING_RIGHT, PLAYER_DIR_RIGHT
	jr c, .gotFacings
	ld a, SPRITE_FACING_RIGHT
	lb bc, SPRITE_FACING_LEFT, PLAYER_DIR_LEFT
.gotFacings
	ldh [hSpriteFacingDirection], a
	ld a, b
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, c
	ld [wPlayerMovingDirection], a
	ld a, PALLETTOWN_RIVAL
	ldh [hSpriteIndex], a
	call SetSpriteFacingDirectionAndDelay
	ld c, BANK(Music_MeetRival)
	ld a, MUSIC_MEET_RIVAL
	call PlayMusic
	ld a, PALLETTOWN_RIVAL
	ld [wEmotionBubbleSpriteIndex], a
	xor a ; EXCLAMATION_BUBBLE
	ld [wWhichEmotionBubble], a
	predef EmotionBubble
	ld a, TEXT_PALLETTOWN_RIVAL
	ldh [hTextID], a
	call DisplayTextID
	farcall Music_RivalAlternateStart
	; walk off the far side of the screen, away from the player
	ld de, .RivalWalksRight
	ld a, [wXCoord]
	cp 12
	jr c, .moveRival
	ld de, .RivalWalksLeft
.moveRival
	ld a, PALLETTOWN_RIVAL
	ldh [hSpriteIndex], a
	call MoveSprite
	ld a, SCRIPT_PALLETTOWN_RIVAL_LEAVES
	ld [wPalletTownCurScript], a
	ret

.RivalTauntCoords
	dbmapcoord  9, 12
	dbmapcoord 16, 12
	db -1 ; end

.RivalWalksRight
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

.RivalWalksLeft
	db NPC_MOVEMENT_LEFT
	db NPC_MOVEMENT_LEFT
	db NPC_MOVEMENT_LEFT
	db NPC_MOVEMENT_LEFT
	db -1 ; end

PalletTownPlayerPushedBackScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	ld a, SCRIPT_PALLETTOWN_DEFAULT
	ld [wPalletTownCurScript], a
	ret

PalletTownRivalLeavesScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	ld a, HS_PALLET_TOWN_RIVAL
	ld [wMissableObjectIndex], a
	predef HideObject
	call PlayDefaultMusic
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_PALLETTOWN_DEFAULT
	ld [wPalletTownCurScript], a
	ret

PalletTownDaisyScript:
	CheckEvent EVENT_DAISY_WALKING
	jr nz, .next
	CheckBothEventsSet EVENT_GOT_TOWN_MAP, EVENT_ENTERED_BLUES_HOUSE, 1
	jr nz, .next
	SetEvent EVENT_DAISY_WALKING
	ld a, HS_DAISY_SITTING
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_DAISY_WALKING
	ld [wMissableObjectIndex], a
	predef_jump ShowObject
.next
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	ret z
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS_2
	ret

PalletTown_TextPointers:
	def_text_pointers
	dw_const PalletTownOakText,              TEXT_PALLETTOWN_OAK
	dw_const PalletTownGirlText,             TEXT_PALLETTOWN_GIRL
	dw_const PalletTownFisherText,           TEXT_PALLETTOWN_FISHER
	dw_const PalletTownRivalText,            TEXT_PALLETTOWN_RIVAL
	dw_const PalletTownOaksLabSignText,      TEXT_PALLETTOWN_OAKSLAB_SIGN
	dw_const PalletTownSignText,             TEXT_PALLETTOWN_SIGN
	dw_const PalletTownPlayersHouseSignText, TEXT_PALLETTOWN_PLAYERSHOUSE_SIGN
	dw_const PalletTownRivalsHouseSignText,  TEXT_PALLETTOWN_RIVALSHOUSE_SIGN
	dw_const PalletTownGoToLabText,          TEXT_PALLETTOWN_GO_TO_LAB

; this object is never shown any more (see data/maps/objects/PalletTown.asm)
PalletTownOakText:
	text_far _PalletTownGoToLabText
	text_end

PalletTownRivalText:
	text_far _PalletTownRivalSnoozeYouLoseText
	text_end

PalletTownGoToLabText:
	text_far _PalletTownGoToLabText
	text_end

PalletTownGirlText:
	text_far _PalletTownGirlText
	text_end

PalletTownFisherText:
	text_far _PalletTownFisherText
	text_end

PalletTownOaksLabSignText:
	text_far _PalletTownOaksLabSignText
	text_end

PalletTownSignText:
IF DEF(_DEBUG)
	text_asm
	ld a, 239
	inc a
	ld [wWhichPewterGuy], a
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_decimal wWhichPewterGuy, 1, 3
	text "bit"
	done
ELSE
	text_far _PalletTownSignText
	text_end
ENDC

PalletTownPlayersHouseSignText:
	text_far _PalletTownPlayersHouseSignText
	text_end

PalletTownRivalsHouseSignText:
	text_far _PalletTownRivalsHouseSignText
	text_end
