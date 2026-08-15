CeruleanGym_Script:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_2, [hl]
	res BIT_CUR_MAP_LOADED_2, [hl]
	jr z, .skipMapLoadInit
	call .LoadNames
	call .CheckHideMisty
.skipMapLoadInit
	call EnableAutoTextBoxDrawing
	ld hl, CeruleanGymTrainerHeaders
	ld de, CeruleanGym_ScriptPointers
	ld a, [wCeruleanGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeruleanGymCurScript], a
	ret

.LoadNames:
	ld hl, .CityName
	ld de, .LeaderName
	jp LoadGymLeaderAndCityName

.CityName:
	db "CERULEAN CITY@"

.LeaderName:
	db "MISTY@"

.CheckHideMisty:
	; Hide Misty if she's been defeated (she'll appear as follower instead)
	; CERULEANGYM_MISTY is the first object (object ID 0), which is sprite 1 (offset $10)
	CheckEvent EVENT_BEAT_MISTY
	ret z
	; Clear the sprite's data to prevent it from rendering
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_PICTUREID
	ld [hl], 0 ; clear picture ID (marks sprite slot as unused)
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_MOVEMENTSTATUS
	ld [hl], 0 ; clear movement status
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_IMAGEINDEX
	ld [hl], $ff ; make sprite invisible
	; Also clear sprite state data 2 fields
	ld hl, wSprite01StateData2 + SPRITESTATEDATA2_IMAGEBASEOFFSET
	ld [hl], 0
	ret

CeruleanGymResetScripts:
	xor a ; SCRIPT_CERULEANGYM_DEFAULT
	ld [wJoyIgnore], a
	ld [wCeruleanGymCurScript], a
	ld [wCurMapScript], a
	ret

CeruleanGym_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_CERULEANGYM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_CERULEANGYM_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_CERULEANGYM_END_BATTLE
	dw_const CeruleanGymMistyPostBattleScript,      SCRIPT_CERULEANGYM_MISTY_POST_BATTLE
	dw_const CeruleanGymSpawnMistyFollower,         SCRIPT_CERULEANGYM_MISTY_SPAWN_FOLLOWER

CeruleanGymMistyPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, CeruleanGymResetScripts
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a

CeruleanGymReceiveTM11:
	; Note: EVENT_BEAT_MISTY is NOT set here. ShouldMistySpawn's Cerulean Gym
	; special case (chain_follow.asm) keys directly off it to decide whether
	; to show the follower, and the follower's per-frame update loop runs
	; independently of this script - setting it early would make her follower
	; sprite pop into view immediately (at whatever stale position it last
	; held) while this text is still displaying, alongside her still-visible
	; stationary gym sprite. It's set later, in CeruleanGymSpawnMistyFollower,
	; only once her follower position has actually been corrected.
	ld a, TEXT_CERULEANGYM_MISTY_CASCADE_BADGE_INFO
	ldh [hTextID], a
	call DisplayTextID
	lb bc, TM_BUBBLEBEAM, 1
	call GiveItem
	jr nc, .BagFull
	ld a, TEXT_CERULEANGYM_MISTY_RECEIVED_TM11
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM11
	jr .gymVictory
.BagFull
	ld a, TEXT_CERULEANGYM_MISTY_TM11_NO_ROOM
	ldh [hTextID], a
	call DisplayTextID
.gymVictory
	ld hl, wObtainedBadges
	set BIT_CASCADEBADGE, [hl]
	ld hl, wBeatGymFlags
	set BIT_CASCADEBADGE, [hl]

	; deactivate gym trainers
	SetEvents EVENT_BEAT_CERULEAN_GYM_TRAINER_0, EVENT_BEAT_CERULEAN_GYM_TRAINER_1

	; Remember where Misty is standing, so when her follower sprite is
	; spawned below it appears right where she's standing instead of
	; teleporting into place behind the player. Hardcoded (rather than read
	; from wSprite01StateData2) because she's a STAY-type NPC at a fixed
	; spot - her object_event position (data/maps/objects/CeruleanGym.asm)
	; is X=4, Y=2; MapY/MapX use a +4 coordinate offset (see object_event in
	; macros/scripts/maps.asm), giving MapY=6, MapX=8.
	ld a, 2 + 4
	ld [wExitDoorwayY], a
	ld a, 4 + 4
	ld [wExitDoorwayX], a

	; Hide Misty from the gym (she'll appear as follower instead)
	; CERULEANGYM_MISTY is the first object (object ID 0), which is sprite 1 (offset $10)
	; Clear the sprite's data to prevent it from rendering
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_PICTUREID
	ld [hl], 0 ; clear picture ID (marks sprite slot as unused)
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_MOVEMENTSTATUS
	ld [hl], 0 ; clear movement status
	ld hl, wSprite01StateData1 + SPRITESTATEDATA1_IMAGEINDEX
	ld [hl], $ff ; make sprite invisible
	; Also clear sprite state data 2 fields
	ld hl, wSprite01StateData2 + SPRITESTATEDATA2_IMAGEBASEOFFSET
	ld [hl], 0

	; Don't spawn the follower yet - this text_asm script is still running
	; (control hasn't returned to the player). Switch to a dedicated script
	; state so the spawn happens on the next frame, once this whole script
	; and its dialogue have fully finished. Both wCeruleanGymCurScript and
	; wCurMapScript must be set: ExecuteCurMapScriptInTable re-reads
	; wCurMapScript on return and CeruleanGym_Script copies that into
	; wCeruleanGymCurScript, clobbering a wCeruleanGymCurScript-only write
	; (see CeruleanGymResetScripts, which sets both for the same reason).
	ld a, SCRIPT_CERULEANGYM_MISTY_SPAWN_FOLLOWER
	ld [wCeruleanGymCurScript], a
	ld [wCurMapScript], a
	ret

CeruleanGymSpawnMistyFollower:
	; Initialize Misty's follower state. wExitDoorwayY/X (set above) makes
	; her spawn exactly where she was standing rather than behind the
	; player, so she stands in place and only starts walking to catch up
	; once the player moves away from her current spot.
	farcall InitializeMistyFollower
	; Only now that her follower position is correct is it safe to let
	; ShouldMistySpawn's Cerulean Gym check start showing her as a follower
	; (see the comment in CeruleanGymReceiveTM11).
	SetEvent EVENT_BEAT_MISTY
	; InitializeMistyPosition only clears wExitDoorwayY/X itself when Brock
	; isn't following (it otherwise expects Brock's own fresh-spawn init to
	; clear it - see its comment). Brock isn't fresh-spawning here (he's
	; been following the whole time we were in the gym), so clear it
	; ourselves to avoid a stale gym position leaking into some future
	; unrelated fresh follower spawn.
	xor a
	ld [wExitDoorwayY], a
	ld [wExitDoorwayX], a
	jp CeruleanGymResetScripts

CeruleanGym_TextPointers:
	def_text_pointers
	dw_const CeruleanGymMistyText,                 TEXT_CERULEANGYM_MISTY
	dw_const CeruleanGymCooltrainerFText,          TEXT_CERULEANGYM_COOLTRAINER_F
	dw_const CeruleanGymSwimmerText,               TEXT_CERULEANGYM_SWIMMER
	dw_const CeruleanGymGymGuideText,              TEXT_CERULEANGYM_GYM_GUIDE
	dw_const CeruleanGymMistyCascadeBadgeInfoText, TEXT_CERULEANGYM_MISTY_CASCADE_BADGE_INFO
	dw_const CeruleanGymMistyReceivedTM11Text,     TEXT_CERULEANGYM_MISTY_RECEIVED_TM11
	dw_const CeruleanGymMistyTM11NoRoomText,       TEXT_CERULEANGYM_MISTY_TM11_NO_ROOM

CeruleanGymTrainerHeaders:
	def_trainers 2
CeruleanGymTrainerHeader0:
	trainer EVENT_BEAT_CERULEAN_GYM_TRAINER_0, 3, CeruleanGymBattleText1, CeruleanGymEndBattleText1, CeruleanGymAfterBattleText1
CeruleanGymTrainerHeader1:
	trainer EVENT_BEAT_CERULEAN_GYM_TRAINER_1, 3, CeruleanGymBattleText2, CeruleanGymEndBattleText2, CeruleanGymAfterBattleText2
	db -1 ; end

CeruleanGymMistyText:
	text_asm
	CheckEvent EVENT_BEAT_MISTY
	jr z, .beforeBeat
	CheckEventReuseA EVENT_GOT_TM11
	jr nz, .afterBeat
	call z, CeruleanGymReceiveTM11
	call DisableWaitingAfterTextDisplay
	jr .done
.afterBeat
	ld hl, .TM11ExplanationText
	call PrintText
	jr .done
.beforeBeat
	ld hl, .PreBattleText
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, CeruleanGymMistyReceivedCascadeBadgeText
	ld de, CeruleanGymMistyReceivedCascadeBadgeText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $2
	ld [wGymLeaderNo], a
	xor a
	ldh [hJoyHeld], a
	ld a, SCRIPT_CERULEANGYM_MISTY_POST_BATTLE
	ld [wCeruleanGymCurScript], a
.done
	jp TextScriptEnd

.PreBattleText:
	text_far _CeruleanGymMistyPreBattleText
	text_end

.TM11ExplanationText:
	text_far _CeruleanGymMistyTM11ExplanationText
	text_end

CeruleanGymMistyCascadeBadgeInfoText:
	text_far _CeruleanGymMistyCascadeBadgeInfoText
	text_end

CeruleanGymMistyReceivedTM11Text:
	text_far _CeruleanGymMistyReceivedTM11Text
	sound_get_item_1
	text_end

CeruleanGymMistyTM11NoRoomText:
	text_far _CeruleanGymMistyTM11NoRoomText
	text_end

CeruleanGymMistyReceivedCascadeBadgeText:
	text_far _CeruleanGymMistyReceivedCascadeBadgeText
	text_end

CeruleanGymCooltrainerFText:
	text_asm
	ld hl, CeruleanGymTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

CeruleanGymBattleText1:
	text_far _CeruleanGymBattleText1
	text_end

CeruleanGymEndBattleText1:
	text_far _CeruleanGymEndBattleText1
	text_end

CeruleanGymAfterBattleText1:
	text_far _CeruleanGymAfterBattleText1
	text_end

CeruleanGymSwimmerText:
	text_asm
	ld hl, CeruleanGymTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

CeruleanGymBattleText2:
	text_far _CeruleanGymBattleText2
	text_end

CeruleanGymEndBattleText2:
	text_far _CeruleanGymEndBattleText2
	text_end

CeruleanGymAfterBattleText2:
	text_far _CeruleanGymAfterBattleText2
	text_end

CeruleanGymGymGuideText:
	text_asm
	CheckEvent EVENT_BEAT_MISTY
	jr nz, .afterBeat
	ld hl, .ChampInMakingText
	call PrintText
	jr .done
.afterBeat
	ld hl, .BeatMistyText
	call PrintText
.done
	jp TextScriptEnd

.ChampInMakingText:
	text_far _CeruleanGymGymGuideChampInMakingText
	text_end

.BeatMistyText:
	text_far _CeruleanGymGymGuideBeatMistyText
	text_end
