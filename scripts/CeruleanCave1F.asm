CeruleanCave1F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CeruleanCave1F_ScriptPointers
	ld a, [wCeruleanCave1FCurScript]
	jp CallFunctionInTable

CeruleanCave1F_ScriptPointers:
	def_script_pointers
	dw_const CeruleanCave1FDefaultScript,         SCRIPT_CERULEANCAVE1F_DEFAULT
	dw_const CeruleanCave1FOakAfterBattleScript,  SCRIPT_CERULEANCAVE1F_OAK_AFTER_BATTLE

CeruleanCave1FDefaultScript:
	ret

; OAK blocks the way in (24,15) while invited (see OaksLabOak1Text); beating him
; hides him again until the next invitation, so the cycle repeats forever
CeruleanCave1FOakAfterBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, .reset ; lost: the player blacked out
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TEXT_CERULEANCAVE1F_OAK_AFTER_BATTLE
	ldh [hTextID], a
	call DisplayTextID
	call GBFadeOutToBlack
	ld a, HS_CERULEAN_CAVE_1F_OAK
	ld [wMissableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromBlack
.reset
	xor a ; SCRIPT_CERULEANCAVE1F_DEFAULT
	ld [wJoyIgnore], a
	ld [wCeruleanCave1FCurScript], a
	ret

CeruleanCave1F_TextPointers:
	def_text_pointers
	dw_const PickUpItemText,                  TEXT_CERULEANCAVE1F_RARE_CANDY
	dw_const PickUpItemText,                  TEXT_CERULEANCAVE1F_MAX_ELIXER
	dw_const PickUpItemText,                  TEXT_CERULEANCAVE1F_MAX_REVIVE
	dw_const PickUpItemText,                  TEXT_CERULEANCAVE1F_ULTRA_BALL
	dw_const CeruleanCave1FOakText,           TEXT_CERULEANCAVE1F_OAK
	dw_const CeruleanCave1FOakAfterBattleText, TEXT_CERULEANCAVE1F_OAK_AFTER_BATTLE

CeruleanCave1FOakText:
	text_asm
	ld a, BANK(Music_MeetProfOak)
	ld c, a
	ld a, MUSIC_MEET_PROF_OAK
	call PlayMusic
	ld hl, .ShallWeText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .DefeatedText
	ld de, .VictoryText
	call SaveEndBattleTextPointers
	ld a, OPP_PROF_OAK
	ld [wCurOpponent], a
	ld a, 1
	ld [wTrainerNo], a
	ld a, SCRIPT_CERULEANCAVE1F_OAK_AFTER_BATTLE
	ld [wCeruleanCave1FCurScript], a
	jp TextScriptEnd

.ShallWeText:
	text_far _CeruleanCave1FOakShallWeText
	text_end

.DefeatedText:
	text_far _CeruleanCave1FOakDefeatedText
	text_end

.VictoryText:
	text_far _CeruleanCave1FOakVictoryText
	text_end

CeruleanCave1FOakAfterBattleText:
	text_far _CeruleanCave1FOakAfterBattleText
	text_end
