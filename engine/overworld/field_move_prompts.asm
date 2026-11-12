; Gen 2-style field move prompts: pressing A while facing calm water, a
; cuttable tree, or a STRENGTH boulder offers to use the field move, if a
; party mon knows it and the badge that unlocks it is owned.
;
; Called (via jpfar) at the end of IsPlayerTalkingToFollowerOrPikachu, which
; the overworld loop runs (through Func_0ffe) right after
; IsSpriteOrSignInFrontOfPlayer on every A press. On return, hTextID == 0
; sends the overworld loop straight back to OverworldLoop, so whenever a
; prompt is shown we clear hTextID; otherwise we leave it untouched.
; Lives entirely in ROMX - no home-bank bytes spent.
CheckFieldMovePrompt::
	ldh a, [hTextID]
	and a
	jr nz, .checkBoulder

; nothing to talk to: check the tile in front for water or a cuttable tree
	predef GetTileAndCoordsInFrontOfPlayer ; wTileInFrontOfPlayer
	call .checkCutTree
	ret nc ; it was a tree (prompted or not)
	jr .checkWater

.checkBoulder
; hSpriteIndex aliases hTextID; values <= wNumSprites are sprites, not signs
	ld b, a
	ld a, [wNumSprites]
	cp b
	ret c ; it's a sign
	ld a, [wStatusFlags1]
	bit BIT_STRENGTH_ACTIVE, a
	ret nz ; STRENGTH already on: let the normal boulder text play
	ld a, b
	swap a ; * $10 (sprite state structs are $10 bytes, page-aligned)
	ld l, a
	ld h, HIGH(wSpriteStateData1)
	ASSERT LOW(wSpriteStateData1) == 0
	ASSERT SPRITESTATEDATA1_PICTUREID == 0
	ld a, [hl]
	cp SPRITE_BOULDER
	ret nz
	ld a, [wObtainedBadges]
	bit BIT_RAINBOWBADGE, a
	ret z
	ld d, STRENGTH
	call FindPartyMonWithMove
	ret nc
	ld hl, FieldMovePromptStrengthText
	call FieldMovePrompt_Ask
	jp nz, FieldMovePrompt_Close
	predef PrintStrengthText
	jp FieldMovePrompt_Close

; returns nc if a cut prompt was handled, carry if the tile isn't a tree
.checkCutTree
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	ld b, $3d ; overworld cut tree
	jr z, .gotTreeTile
	cp GYM
	scf
	ret nz
	ld b, $50 ; gym cut tree
.gotTreeTile
	ld a, [wTileInFrontOfPlayer]
	cp b
	scf
	ret nz
	ld a, [wObtainedBadges]
	bit BIT_CASCADEBADGE, a
	jr z, .handledNothing
	ld d, CUT
	call FindPartyMonWithMove
	jr nc, .handledNothing
	ld hl, FieldMovePromptCutText
	call FieldMovePrompt_Ask
	jr nz, .closeAndHandled
	predef UsedCut
.closeAndHandled
	call FieldMovePrompt_Close
.handledNothing
	and a ; nc
	ret

.checkWater
	ld a, [wWalkBikeSurfState]
	cp 2
	ret z ; already surfing
	ld a, [wObtainedBadges]
	bit BIT_SOULBADGE, a
	ret z
	farcall IsNextTileShoreOrWater ; Bankswitch preserves the carry flag
	ret nc
	; the same tile-pair check ItemUseSurfboard makes (no surfing off ledges, etc.)
	lda_coord 8, 9
	ld [wTilePlayerStandingOn], a
	ld hl, TilePairCollisionsWater
	call CheckForTilePairCollisions
	ret c
	ld d, SURF
	call FindPartyMonWithMove
	ret nc
	ld hl, FieldMovePromptSurfText
	call FieldMovePrompt_Ask
	jr nz, FieldMovePrompt_Close
	; mirrors StartMenu_Pokemon.surf
	farcall IsSurfingAllowed
	ld hl, wStatusFlags1
	bit BIT_SURF_ALLOWED, [hl]
	res BIT_SURF_ALLOWED, [hl]
	jr z, FieldMovePrompt_Close
	ld a, [wCurPartySpecies]
	cp STARTER_PIKACHU
	ld b, $2 ; surfing Pikachu sprite
	jr z, .gotSurfSprite
	cp LAPRAS
	ld b, $3 ; Lapras surf sprite
	jr z, .gotSurfSprite
	ld b, $1 ; Seel surf sprite
.gotSurfSprite
	ld a, b
	ld [wd472], a
	ld a, SURFBOARD
	ld [wCurItem], a
	ld [wPseudoItemID], a
	call UseItem
	ld a, [wActionResultOrTookBattleTurn]
	and a
	jr nz, FieldMovePrompt_Close
	xor a
	ld [wd472], a
	; fallthrough

FieldMovePrompt_Close:
; mirrors CloseTextDisplay, minus the bank juggling (Bankswitch restores it)
	ld a, $90
	ldh [hWY], a
	call DelayFrame
	call LoadGBPal
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wSprite01StateData2OrigFacingDirection
	ld c, $0f
	ld de, $10
.restoreSpriteFacingDirectionLoop
	ld a, [hl]
	dec h
	ld [hl], a
	inc h
	add hl, de
	dec c
	jr nz, .restoreSpriteFacingDirectionLoop
	call InitMapSprites
	ld hl, wFontLoaded
	res BIT_FONT_LOADED, [hl]
	ld a, [wStatusFlags6]
	bit BIT_FLY_WARP, a
	call z, LoadPlayerSpriteGraphics
	call LoadCurrentMapView
	call UpdateSprites
	xor a
	ldh [hTextID], a ; tell the overworld loop nothing is left to display
	ret

; Opens a text box, prints the question at hl and asks yes/no.
; Returns z if the player chose YES.
FieldMovePrompt_Ask:
	push hl
	call SaveScreenTilesToBuffer2 ; UsedCut restores the map view from here
	ld a, 1 ; any nonzero ID: dialogue box rather than the start menu
	ldh [hTextID], a
	xor a
	ld [wAutoTextBoxDrawingControl], a
	farcall DisplayTextIDInit
	pop hl
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret

; d = move. Returns carry if a party mon knows it, with wWhichPokemon,
; wCurPartySpecies and wNameBuffer (its nickname) set up for the field move.
FindPartyMonWithMove:
	ld a, [wPartyCount]
	and a
	ret z
	ld c, a
	ld b, 0 ; party index
	ld hl, wPartyMon1Moves
.monLoop
	push hl
	ld e, NUM_MOVES
.moveLoop
	ld a, [hli]
	cp d
	jr z, .found
	dec e
	jr nz, .moveLoop
	pop hl
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	inc b
	dec c
	jr nz, .monLoop
	and a ; nc
	ret

.found
	pop hl
	ld a, b
	ld [wWhichPokemon], a
	ld e, a
	ld d, 0
	ld hl, wPartySpecies
	add hl, de
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld a, b
	ld hl, wPartyMonNicks
	call GetPartyMonName
	scf
	ret

FieldMovePromptSurfText:
	text "The water is calm."
	line "Want to SURF?"
	done

FieldMovePromptCutText:
	text "This tree can be"
	line "CUT. Use CUT?"
	done

FieldMovePromptStrengthText:
	text "Use STRENGTH to"
	line "move this boulder?"
	done
