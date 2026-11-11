DisplayPokemonCenterDialogue_::
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a ; wait for a button press afterwards unless TEXT: SHORT says otherwise
	ld a, [wCurMap]
	cp PEWTER_POKECENTER
	jr nz, .regularCenter
	call CheckPikachuFollowingPlayer
	jr z, .regularCenter
	ld hl, LooksContentText ; if pikachu is sleeping, don't heal
	call PrintText
	ret
.regularCenter
	call SaveScreenTilesToBuffer1 ; save screen
	ld a, [wLetterPrintingDelayFlags]
	bit BIT_SHORT_TEXT, a
	jr nz, .shortIntro
	ld hl, PokemonCenterWelcomeText
	call PrintText
	ld hl, wStatusFlags4
	bit BIT_USED_POKECENTER, [hl]
	set BIT_UNKNOWN_4_1, [hl]
	set BIT_USED_POKECENTER, [hl]
	jr nz, .skipShallWeHealYourPokemon
	ld hl, ShallWeHealYourPokemonText
	jr .printShallWeHeal
.shortIntro
; TEXT: SHORT - straight to "Shall we heal your #MON?"
	ld hl, wStatusFlags4
	set BIT_UNKNOWN_4_1, [hl]
	set BIT_USED_POKECENTER, [hl]
	ld hl, ShallWeHealYourPokemonShortText
.printShallWeHeal
	call PrintText
.skipShallWeHealYourPokemon
	call YesNoChoicePokeCenter ; yes/no menu
	call UpdateSprites
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .declinedHealing ; if the player chose No
	call SetLastBlackoutMap
	callfar IsStarterPikachuAliveInOurParty
	jr nc, .notHealingPlayerPikachu
	call CheckPikachuFollowingPlayer
	jr nz, .notHealingPlayerPikachu
	call LoadCurrentMapView
	call Delay3
	call UpdateSprites
	callfar PikachuWalksToNurseJoy
.notHealingPlayerPikachu
	ld a, [wLetterPrintingDelayFlags]
	bit BIT_SHORT_TEXT, a
	jr nz, .skipNeedYourPokemon
	ld hl, NeedYourPokemonText
	call PrintText
	ld c, 64
	call DelayFrames
.skipNeedYourPokemon
	call CheckPikachuFollowingPlayer
	jr nz, .playerPikachuNotOnScreen
	call DisablePikachuOverworldSpriteDrawing
	callfar IsStarterPikachuAliveInOurParty
	call c, Func_6eaa
.playerPikachuNotOnScreen
	lb bc, 1, 8
	call Func_6ebb
	ld c, 30
	call DelayFrames
	farcall AnimateHealingMachine ; do the healing machine animation
	predef HealParty
	xor a
	ld [wAudioFadeOutControl], a
	ld a, [wAudioSavedROMBank]
	ld [wAudioROMBank], a
	ld a, [wMapMusicSoundID]
	ld [wLastMusicSoundID], a
	ld [wNewSoundID], a
	call PlaySound
	call CheckPikachuFollowingPlayer
	jr nz, .doNotReturnPikachu
	callfar IsStarterPikachuAliveInOurParty
	call c, Func_6eaa
	ld a, $5
	ld [wPikachuSpawnState], a
	call EnablePikachuOverworldSpriteDrawing
.doNotReturnPikachu
	lb bc, 1, 0
	call Func_6ebb
	ld a, [wLetterPrintingDelayFlags]
	bit BIT_SHORT_TEXT, a
	ld hl, PokemonFightingFitText
	jr z, .printFightingFit
	ld hl, PokemonFightingFitShortText
.printFightingFit
	call PrintText
	callfar IsStarterPikachuAliveInOurParty
	jr nc, .notInParty
	lb bc, 15, 0
	call Func_6ebb
.notInParty
	call LoadCurrentMapView
	call Delay3
	call UpdateSprites
	callfar ReloadWalkingTilePatterns
	ld a, $1
	ldh [hSpriteIndex], a
	ld a, $1
	ldh [hSpriteImageIndex], a
	call SpriteFunc_34a1
	ld c, 40
	call DelayFrames
	call UpdateSprites
	call LoadFontTilePatterns
	jr .done
.declinedHealing
	call LoadScreenTilesFromBuffer1 ; restore screen
.done
; TEXT: SHORT has no farewell line, so tell DisplayPokemonCenterDialogue not to
; wait for a button press afterwards (nothing would be on screen to dismiss)
	ld a, [wLetterPrintingDelayFlags]
	and 1 << BIT_SHORT_TEXT
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jr nz, .skipFarewell
	ld hl, PokemonCenterFarewellText
	call PrintText
.skipFarewell
	call UpdateSprites
	ret

Func_6eaa:
	ld a, $1
	ldh [hSpriteIndex], a
	ld a, $4
	ldh [hSpriteImageIndex], a
	call SpriteFunc_34a1
	ld c, 64
	call DelayFrames
	ret

Func_6ebb:
	ld a, b
	ldh [hSpriteIndex], a
	ld a, c
	ldh [hSpriteImageIndex], a
	push bc
	call SetSpriteFacingDirectionAndDelay
	pop bc
	ld a, b
	ldh [hSpriteIndex], a
	ld a, c
	ldh [hSpriteImageIndex], a
	call SpriteFunc_34a1
	ret

PokemonCenterWelcomeText:
	text_far _PokemonCenterWelcomeText
	text_end

ShallWeHealYourPokemonText:
	text_pause
	text_far _ShallWeHealYourPokemonText
	text_end

ShallWeHealYourPokemonShortText:
	text_far _ShallWeHealYourPokemonText
	text_end

PokemonFightingFitShortText:
	text_far _PokemonFightingFitShortText
	text_end

NeedYourPokemonText:
	text_far _NeedYourPokemonText
	text_end

PokemonFightingFitText:
	text_far _PokemonFightingFitText
	text_end

PokemonCenterFarewellText:
	text_pause
	text_far _PokemonCenterFarewellText
	text_end

LooksContentText:
	text_far _LooksContentText
	text_end
