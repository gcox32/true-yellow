; Moved out of Battle Core for space; its only caller (init_battle.asm) already uses callfar.
SlidePlayerAndEnemySilhouettesOnScreen:
	ld hl, LoadPlayerBackPic
	ld b, BANK(LoadPlayerBackPic)
	call Bankswitch
	ld a, MESSAGE_BOX ; the usual text box at the bottom of the screen
	ld [wTextBoxID], a
	call DisplayTextBoxID
	hlcoord 1, 5
	lb bc, 3, 7
	call ClearScreenArea
	call DisableLCD
	call LoadFontTilePatterns
	ld hl, LoadHudAndHpBarAndStatusTilePatterns
	ld b, BANK(LoadHudAndHpBarAndStatusTilePatterns)
	call Bankswitch
	ld hl, vBGMap0
	ld bc, TILEMAP_AREA
.clearBackgroundLoop
	ld a, ' '
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .clearBackgroundLoop
; copy the work RAM tile map to VRAM
	hlcoord 0, 0
	ld de, vBGMap0
	ld b, SCREEN_HEIGHT
.copyRowLoop
	ld c, SCREEN_WIDTH
.copyColumnLoop
	ld a, [hli]
	ld [de], a
	inc e
	dec c
	jr nz, .copyColumnLoop
	ld a, 12 ; number of off screen tiles to the right of screen in VRAM
	add e ; skip the off screen tiles
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	dec b
	jr nz, .copyRowLoop
	call EnableLCD
	ld a, $90
	ldh [hWY], a
	ldh [rWY], a
	xor a
	ldh [hTileAnimations], a
	ldh [hSCY], a
	dec a
	ld [wUpdateSpritesEnabled], a
	call Delay3
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld b, $70
	ld c, $90
	ld a, c
	ldh [hSCX], a
	call DelayFrame
; PureRGBnote: FIXED: the normal palette only looks like a silhouette with the black
; SGB/CGB battle palette (wOnSGB is also set on CGB). Plain DMG needs a black one.
	ld a, [wOnSGB]
	and a
	ld a, %11100100 ; inverted palette for silhouette effect
	jr nz, .gotSilhouettePalette
	ld a, %11111100 ; color 0 stays white, everything else black
.gotSilhouettePalette
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call UpdateCGBPal_BGP
	call UpdateCGBPal_OBP0
	call UpdateCGBPal_OBP1
.slideSilhouettesLoop ; slide silhouettes of the player's pic and the enemy's pic onto the screen
	ld h, b
	ld l, $40
	call SetScrollXForSlidingPlayerBodyLeft ; begin background scrolling on line $40
	inc b
	inc b
	ld h, $0
	ld l, $60
	call SetScrollXForSlidingPlayerBodyLeft ; end background scrolling on line $60
	call SlidePlayerHeadLeft
	ld a, c
	ldh [hSCX], a
	dec c
	dec c
	jr nz, .slideSilhouettesLoop
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	ld a, $31
	ldh [hStartTileID], a
	hlcoord 1, 5
	predef CopyUncompressedPicToTilemap
	xor a
	ldh [hWY], a
	ldh [rWY], a
	inc a
	ldh [hAutoBGTransferEnabled], a
	ld a, [wOnSGB]
	and a
	jr nz, .paletteRestored
	ld a, %11100100 ; undo the DMG silhouette palette
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
.paletteRestored
	call Delay3
	ld b, SET_PAL_BATTLE
	call RunPaletteCommand
	call HideSprites
	jpfar PrintBeginningBattleText

; when a battle is starting, silhouettes of the player's pic and the enemy's pic are slid onto the screen
; the lower of the player's pic (his body) is part of the background, but his head is a sprite
; the reason for this is that it shares Y coordinates with the lower part of the enemy pic, so background scrolling wouldn't work for both pics
; instead, the enemy pic is part of the background and uses the scroll register, while the player's head is a sprite and is slid by changing its X coordinates in a loop
SlidePlayerHeadLeft:
	push bc
	ld hl, wShadowOAMSprite00XCoord
	ld c, $15 ; number of OAM entries
	ld de, $4 ; size of OAM entry
.loop
	dec [hl] ; decrement X
	dec [hl] ; decrement X
	add hl, de ; next OAM entry
	dec c
	jr nz, .loop
	pop bc
	ret

SetScrollXForSlidingPlayerBodyLeft:
	ldh a, [rLY]
	cp l
	jr nz, SetScrollXForSlidingPlayerBodyLeft
	ld a, h
	ldh [rSCX], a
.loop
	ldh a, [rLY]
	cp h
	jr z, .loop
	ret
