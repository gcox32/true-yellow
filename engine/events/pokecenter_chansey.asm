PokecenterChanseyText::
	ld hl, NurseChanseyText
	call PrintText
	ld c, CHANSEY
	predef MarkMonSeenAndCry
	call WaitForSoundToFinish
	ret

NurseChanseyText:
	text_far _NurseChanseyText
	text_end
