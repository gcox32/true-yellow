CinnabarLab_Script:
	call EnableAutoTextBoxDrawing
	ret

CinnabarLab_TextPointers:
	def_text_pointers
	dw_const CinnabarLabFishingGuruText,     TEXT_CINNABARLAB_FISHING_GURU
	dw_const CinnabarLabMewtwoMachineText,   TEXT_CINNABARLAB_MEWTWO_MACHINE
	dw_const CinnabarLabPhotoText,           TEXT_CINNABARLAB_PHOTO
	dw_const CinnabarLabMeetingRoomSignText, TEXT_CINNABARLAB_MEETING_ROOM_SIGN
	dw_const CinnabarLabRAndDSignText,       TEXT_CINNABARLAB_R_AND_D_SIGN
	dw_const CinnabarLabTestingRoomSignText, TEXT_CINNABARLAB_TESTING_ROOM_SIGN

CinnabarLabFishingGuruText:
	text_far _CinnabarLabFishingGuruText
	text_end

CinnabarLabMewtwoMachineText:
	text_asm
	ld hl, CinnabarLabMachineHumText
	call PrintText
	callfar SpeciesChangePartyMenu
	jr c, .done
	call GetPartyMonName2
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Species
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [hl]
	cp MEWTWO
	jr z, .toArmored
	cp ARMORED_MEWTWO
	jr z, .toNormal
	ld hl, CinnabarLabMachineWrongMonText
	jr .print
.toArmored
	ld a, ARMORED_MEWTWO
	jr .transform
.toNormal
	ld a, MEWTWO
.transform
	ld [wCurPartySpecies], a
	callfar ChangePartyPokemonSpecies
	ld a, SFX_BALL_POOF
	call PlaySound
	call WaitForSoundToFinish
	ld a, [wCurPartySpecies]
	call PlayCry
	call WaitForSoundToFinish
	ld hl, CinnabarLabMachineSuccessText
.print
	call PrintText
.done
	jp TextScriptEnd

CinnabarLabMachineHumText:
	text_far _CinnabarLabMachineHumText
	text_end

CinnabarLabMachineWrongMonText:
	text_far _CinnabarLabMachineWrongMonText
	text_end

CinnabarLabMachineSuccessText:
	text_far _CinnabarLabMachineSuccessText
	text_end

CinnabarLabPhotoText:
	text_far _CinnabarLabPhotoText
	text_end

CinnabarLabMeetingRoomSignText:
	text_far _CinnabarLabMeetingRoomSignText
	text_end

CinnabarLabRAndDSignText:
	text_far _CinnabarLabRAndDSignText
	text_end

CinnabarLabTestingRoomSignText:
	text_far _CinnabarLabTestingRoomSignText
	text_end
