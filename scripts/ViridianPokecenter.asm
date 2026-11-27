ViridianPokecenter_Script:
	call ViridianPokecenterMistyScript
	call Serial_TryEstablishingExternallyClockedConnection
	jp EnableAutoTextBoxDrawing

; Episode 2: Misty catches up with the player at the #MON CENTER, over the
; bike they borrowed. She bursts in right behind them, so this runs on the
; door mat (only reachable when walking in; see the map-entry gotcha around
; BIT_CUR_MAP_LOADED_*). Until she joins, Viridian's sleeping old man keeps
; the road north shut, so the player can't skip her.
ViridianPokecenterMistyScript:
	CheckEvent EVENT_MISTY_FOLLOWING_PLAYER
	ret nz
	ld a, [wYCoord]
	cp 7
	ret nz
	ld a, [wXCoord]
	cp 3 ; Viridian's door lands on (3,7); Misty takes (2,7) beside it. Not
	     ; (4,7): Pikachu emerges from the doorway there and they overlapped.
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, HS_VIRIDIAN_POKECENTER_MISTY
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, SPRITE_FACING_LEFT
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, PLAYER_DIR_LEFT
	ld [wPlayerMovingDirection], a
	call UpdateSprites
	ld a, VIRIDIANPOKECENTER_MISTY
	ld [wEmotionBubbleSpriteIndex], a
	xor a ; EXCLAMATION_BUBBLE
	ld [wWhichEmotionBubble], a
	predef EmotionBubble
	ld a, TEXT_VIRIDIANPOKECENTER_MISTY
	ldh [hTextID], a
	call DisplayTextID
	xor a
	ld [wJoyIgnore], a
	ret

ViridianPokecenter_TextPointers:
	def_text_pointers
	dw_const ViridianPokecenterNurseText,            TEXT_VIRIDIANPOKECENTER_NURSE
	dw_const ViridianPokecenterGentlemanText,        TEXT_VIRIDIANPOKECENTER_GENTLEMAN
	dw_const ViridianPokecenterCooltrainerMText,     TEXT_VIRIDIANPOKECENTER_COOLTRAINER_M
	dw_const ViridianPokecenterLinkReceptionistText, TEXT_VIRIDIANPOKECENTER_LINK_RECEPTIONIST
	dw_const ViridianPokeCenterChanseyText,          TEXT_VIRIDIANPOKECENTER_CHANSEY
	dw_const ViridianPokecenterMistyText,            TEXT_VIRIDIANPOKECENTER_MISTY
ViridianPokecenterNurseText:
	script_pokecenter_nurse

ViridianPokecenterGentlemanText:
	text_far _ViridianPokecenterGentlemanText
	text_end

ViridianPokecenterCooltrainerMText:
	text_far _ViridianPokecenterCooltrainerMText
	text_end

ViridianPokecenterLinkReceptionistText:
	script_cable_club_receptionist

ViridianPokeCenterChanseyText:
	text_asm
	callfar PokecenterChanseyText
	jp TextScriptEnd

ViridianPokecenterMistyText:
	text_asm
	; Only reachable through ViridianPokecenterMistyScript: she is shown and
	; joins in the same breath, so she's never standing around to talk to.
	ld hl, .MistyJoinsText
	call PrintText
	SetEvent EVENT_MISTY_FOLLOWING_PLAYER
	ld a, HS_VIRIDIAN_POKECENTER_MISTY
	ld [wMissableObjectIndex], a
	predef HideObject
	; Hand her follower sprite the tile and facing the NPC object just had, so
	; the swap is invisible: her object_event (data/maps/objects/
	; ViridianPokecenter.asm) is X=2, Y=7, and MapY/MapX carry a +4 offset
	; (see object_event in macros/scripts/maps.asm).
	ld d, 7 + 4
	ld e, 2 + 4
	farcall JoinMistyFollowerInPlace
	; with Misty along, Viridian's old man wakes up and the road north opens
	; (this used to happen when OAK handed over the #DEX)
	ld a, SCRIPT_VIRIDIANCITY_AFTER_POKEDEX
	ld [wViridianCityCurScript], a
	ld a, HS_LYING_OLD_MAN
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_OLD_MAN_2
	ld [wMissableObjectIndex], a
	predef ShowObject
	jp TextScriptEnd

.MistyJoinsText:
	text_far _ViridianPokecenterMistyJoinsText
	text_end
