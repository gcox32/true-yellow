OaksLab_Script:
	CheckEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS_2
	call nz, OaksLabLoadTextPointers2Script
	ld a, 1 << BIT_NO_AUTO_TEXT_BOX
	ld [wAutoTextBoxDrawingControl], a
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	; The opening scene is over once OAK has handed over the #DEX. Checking the
	; event rather than the script index also keeps saves made under the old,
	; longer script table (whose NOOP was index 22) out of the table below.
	CheckEvent EVENT_GOT_POKEDEX
	ret nz
	; A save from mid-parcel-errand under the old table can hold an index past
	; the end of this one: hand that player the #DEX and balls instead.
	ld a, [wOaksLabCurScript]
	cp SCRIPT_OAKSLAB_NOOP + 1
	jr c, .runScript
	ld a, SCRIPT_OAKSLAB_OAK_GIVES_POKEDEX
	ld [wOaksLabCurScript], a
.runScript
	ld hl, OaksLab_ScriptPointers
	jp CallFunctionInTable

; Episode 1: the player overslept. <RIVAL> already took his #MON and left, so
; OAK is waiting alone at his desk with the "last one". There is no rival
; battle; Route 22 now decides how the rival's EEVEE evolves.
OaksLab_ScriptPointers:
	def_script_pointers
	dw_const OaksLabDefaultScript,                  SCRIPT_OAKSLAB_DEFAULT
	dw_const OaksLabPlayerWalksToOakScript,         SCRIPT_OAKSLAB_PLAYER_WALKS_TO_OAK
	dw_const OaksLabPikachuEscapesPokeballScript,   SCRIPT_OAKSLAB_PIKACHU_ESCAPES_POKEBALL
	dw_const OaksLabPikachuDislikesPokeballsScript, SCRIPT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS
	dw_const OaksLabOakGivesPokedexScript,          SCRIPT_OAKSLAB_OAK_GIVES_POKEDEX
	dw_const OaksLabNoopScript,                     SCRIPT_OAKSLAB_NOOP

OaksLabDefaultScript:
	CheckEvent EVENT_FOLLOWED_OAK_INTO_LAB
	ret nz
	; door mat: only reachable by walking in (see the map-entry gotcha in
	; BIT_CUR_MAP_LOADED_*, which also fires after battles)
	ld a, [wYCoord]
	cp 11
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	call Delay3
	ld hl, wSimulatedJoypadStatesEnd
	ld de, PlayerEntryMovementRLE
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_OAKSLAB_PLAYER_WALKS_TO_OAK
	ld [wOaksLabCurScript], a
	ret

PlayerEntryMovementRLE:
	db PAD_UP, 8 ; (5,11) -> (5,3), right below OAK at his desk
	db -1 ; end

OaksLabPlayerWalksToOakScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	SetEvent EVENT_FOLLOWED_OAK_INTO_LAB
	SetEvent EVENT_FOLLOWED_OAK_INTO_LAB_2
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, OAKSLAB_OAK1
	ldh [hSpriteIndex], a
	xor a ; SPRITE_FACING_DOWN
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	; OaksLab_Script turns the auto text box off every frame; plain text_far
	; texts need it back on (text_asm ones draw their own via PrintText)
	call EnableAutoTextBoxDrawing
	ld a, TEXT_OAKSLAB_OAK_SHOW_UP_AFTER_ALL
	ldh [hTextID], a
	call DisplayTextID
	call Delay3
	ld a, TEXT_OAKSLAB_PLAYER_RECEIVED_MON
	ldh [hTextID], a
	call DisplayTextID
	ld a, SCRIPT_OAKSLAB_PIKACHU_ESCAPES_POKEBALL
	ld [wOaksLabCurScript], a
	ret

OaksLabPikachuEscapesPokeballScript:
; Pikachu comes out
	ld a, SPRITE_FACING_UP
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, $2
	ld [wPikachuSpawnState], a
	farcall SchedulePikachuSpawnForAfterText
	call EnablePikachuOverworldSpriteDrawing
	ld a, TEXT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS1
	ldh [hTextID], a
	call DisplayTextID
	ld a, SCRIPT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS
	ld [wOaksLabCurScript], a
	ret

OaksLabPikachuDislikesPokeballsScript:
	ld a, TEXT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS2
	ldh [hTextID], a
	call DisplayTextID
	ld a, SCRIPT_OAKSLAB_OAK_GIVES_POKEDEX
	ld [wOaksLabCurScript], a
	ret

OaksLabOakGivesPokedexScript:
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	call EnableAutoTextBoxDrawing ; see OaksLabPlayerWalksToOakScript
	ld a, TEXT_OAKSLAB_OAK_GOT_POKEDEX
	ldh [hTextID], a
	call DisplayTextID
	ld a, HS_POKEDEX_1
	ld [wMissableObjectIndex], a
	predef HideObject
	call Delay3
	lb bc, POKE_BALL, 5
	call GiveItem
	ld a, TEXT_OAKSLAB_OAK_GOT_POKEBALLS
	ldh [hTextID], a
	call DisplayTextID
	call Delay3
	ld a, TEXT_OAKSLAB_PIKACHU_SHOCKS_EVERYONE
	ldh [hTextID], a
	call DisplayTextID

	SetEvent EVENT_GOT_POKEDEX
	SetEvent EVENT_GOT_POKEBALLS_FROM_OAK
	; there is no parcel errand any more: Viridian's mart opens as a normal shop
	SetEvent EVENT_OAK_GOT_PARCEL
	ld a, SCRIPT_VIRIDIANMART_SCRIPT2
	ld [wViridianMartCurScript], a
	; Viridian's sleeping old man keeps the road north shut until Misty joins
	; at the #MON CENTER (scripts/ViridianPokecenter.asm)

	; <RIVAL> is already on his way: he waits for the player on Route 22.
	; His EEVEE's evolution defaults to FLAREON (Route 22 skipped); that
	; battle overrides it (scripts/Route22.asm).
	ld a, RIVAL_STARTER_FLAREON
	ld [wRivalStarter], a
	SetEvent EVENT_1ST_ROUTE22_RIVAL_BATTLE
	ResetEventReuseHL EVENT_2ND_ROUTE22_RIVAL_BATTLE
	SetEventReuseHL EVENT_ROUTE22_RIVAL_WANTS_BATTLE
	ld a, HS_ROUTE_22_RIVAL_1
	ld [wMissableObjectIndex], a
	predef ShowObject

	ld hl, wStatusFlags4
	res BIT_NO_BATTLES, [hl]
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_OAKSLAB_NOOP
	ld [wOaksLabCurScript], a
	ret

OaksLabNoopScript:
	ret

OaksLabLoadTextPointers2Script:
	ld hl, OaksLab_TextPointers2
	ld a, l
	ld [wCurMapTextPtr], a
	ld a, h
	ld [wCurMapTextPtr + 1], a
	ret

OaksLab_TextPointers:
	def_text_pointers
	dw_const OaksLabRivalText,                     TEXT_OAKSLAB_RIVAL
	dw_const OaksLabEeveePokeBallText,             TEXT_OAKSLAB_EEVEE_POKE_BALL
	dw_const OaksLabOak1Text,                      TEXT_OAKSLAB_OAK1
	dw_const OaksLabPokedexText,                   TEXT_OAKSLAB_POKEDEX1
	dw_const OaksLabPokedexText,                   TEXT_OAKSLAB_POKEDEX2
	dw_const OaksLabOak2Text,                      TEXT_OAKSLAB_OAK2
	dw_const OaksLabGirlText,                      TEXT_OAKSLAB_GIRL
	dw_const OaksLabScientistText,                 TEXT_OAKSLAB_SCIENTIST1
	dw_const OaksLabScientistText,                 TEXT_OAKSLAB_SCIENTIST2
	dw_const OaksLabOakShowUpAfterAllText,         TEXT_OAKSLAB_OAK_SHOW_UP_AFTER_ALL
	dw_const OaksLabPlayerReceivedMonText,         TEXT_OAKSLAB_PLAYER_RECEIVED_MON
	dw_const OaksLabPikachuDislikesPokeballsText1, TEXT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS1
	dw_const OaksLabPikachuDislikesPokeballsText2, TEXT_OAKSLAB_PIKACHU_DISLIKES_POKEBALLS2
	dw_const OaksLabOakGotPokedexText,             TEXT_OAKSLAB_OAK_GOT_POKEDEX
	dw_const OaksLabOakGotPokeballsText,           TEXT_OAKSLAB_OAK_GOT_POKEBALLS
	dw_const OaksLabPikachuShocksEveryoneText,     TEXT_OAKSLAB_PIKACHU_SHOCKS_EVERYONE

OaksLab_TextPointers2:
	dw OaksLabRivalText
	dw OaksLabEeveePokeBallText
	dw OaksLabOak1Text
	dw OaksLabPokedexText
	dw OaksLabPokedexText
	dw OaksLabOak2Text
	dw OaksLabGirlText
	dw OaksLabScientistText
	dw OaksLabScientistText

; <RIVAL> left before the player got here; his lab object stays hidden
OaksLabRivalText:
	text_asm ; PrintText draws the box: OaksLab_Script turns the auto one off
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalText
	text_end

; the ball <RIVAL> took his EEVEE from
OaksLabEeveePokeBallText:
	text_asm ; PrintText draws the box: OaksLab_Script turns the auto one off
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabEmptyPokeballText
	text_end

OaksLabOak1Text:
	text_asm
	CheckEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS
	jr nz, .rate_pokedex
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	cp 2
	jr nc, .rate_pokedex
	ld hl, .PokemonAroundTheWorldText
	call PrintText
	jp .done
.rate_pokedex
	ld hl, .HowIsYourPokedexComingText
	call PrintText
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	predef DisplayDexRating
; EVENT_BEAT_CHAMPION_RIVAL is no good here: the Hall of Fame resets the whole
; Indigo Plateau event range. BIT_BEAT_ELITE_4 is set there and persists.
	ld a, [wElite4Flags]
	bit BIT_BEAT_ELITE_4, a
	jr z, .done
; invite the player to battle: OAK waits in Cerulean Cave 1F until beaten
	ld hl, .MeetMeInCeruleanCaveText
	call PrintText
	SetEvent EVENT_OAK_WAITING_IN_CERULEAN_CAVE
	ld a, HS_CERULEAN_CAVE_1F_OAK
	ld [wMissableObjectIndex], a
	predef ShowObject
.done
	jp TextScriptEnd

.PokemonAroundTheWorldText:
	text_far _OaksLabOak1PokemonAroundTheWorldText
	text_end

.HowIsYourPokedexComingText:
	text_far _OaksLabOak1HowIsYourPokedexComingText
	text_end

.MeetMeInCeruleanCaveText:
	text_far _OaksLabOak1MeetMeInCeruleanCaveText
	text_end

OaksLabPokedexText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabPokedexText
	text_end

OaksLabOak2Text:
	text_far _OaksLabOak2Text
	text_end

OaksLabGirlText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabGirlText
	text_end

OaksLabOakShowUpAfterAllText:
	text_far _OaksLabOakShowUpAfterAllText
	text_end

OaksLabPlayerReceivedMonText:
	text_asm
	ld a, STARTER_PIKACHU
	ld [wPlayerStarter], a
	ld [wNamedObjectIndex], a
	call GetMonName
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, OaksLabOakGivesText
	call PrintText
	ld hl, OaksLabReceivedText
	call PrintText
	xor a
	ld [wMonDataLocation], a
	ld a, 5
	ld [wCurEnemyLevel], a
	ld a, STARTER_PIKACHU
	ld [wPokedexNum], a
	ld [wCurPartySpecies], a
	call AddPartyMon
	ld a, LIGHT_BALL_GSC
	ld [wPartyMon1CatchRate], a
	call DisablePikachuOverworldSpriteDrawing
	SetEvent EVENT_GOT_STARTER
	ld hl, wStatusFlags4
	set BIT_GOT_STARTER, [hl]
	jp TextScriptEnd

OaksLabOakGivesText:
	text_far _OaksLabOakGivesText
	text_end

OaksLabReceivedText:
	text_far _OaksLabReceivedText
	sound_get_key_item
	text_end

OaksLabPikachuDislikesPokeballsText1:
	text_asm
	ldpikacry e, PikachuCry2
	callfar PlayPikachuSoundClip
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabPikachuDislikesPokeballsText1
	text_end

OaksLabPikachuDislikesPokeballsText2:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabPikachuDislikesPokeballsText2
	text_end

OaksLabOakGotPokedexText:
	text_far _OaksLabOakGotPokedexText
	sound_get_key_item
	text_end

OaksLabOakGotPokeballsText:
	text_far _OaksLabOakGotPokeballsText
	sound_get_key_item
	text_far _OaksLabOakPokedexExplanationText
	text_end

OaksLabPikachuShocksEveryoneText:
	text_asm
	ld hl, .ThankText
	call PrintText
	ldpikacry e, PikachuCry2
	callfar PlayPikachuSoundClip
	ld hl, .YoureWelcomeText
	call PrintText
	jp TextScriptEnd

.ThankText:
	text_far _OaksLabPlayerThankText
	text_end

.YoureWelcomeText:
	text_far _OaksLabOakYoureWelcomeText
	text_end

OaksLabScientistText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabScientistText
	text_end
