RedsHouse2F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, RedsHouse2F_ScriptPointers
	ld a, [wRedsHouse2FCurScript]
	jp CallFunctionInTable

RedsHouse2F_ScriptPointers:
	def_script_pointers
	dw_const RedsHouse2FWakeUpScript, SCRIPT_REDSHOUSE2F_WAKE_UP
	dw_const RedsHouse2FNoopScript,   SCRIPT_REDSHOUSE2F_NOOP

; Episode 1: the player oversleeps on the morning of the big day.
RedsHouse2FWakeUpScript:
	ld a, SCRIPT_REDSHOUSE2F_NOOP
	ld [wRedsHouse2FCurScript], a
	; older saves never wrote this byte, so only dream before the lab
	ld a, [wStatusFlags4]
	bit BIT_GOT_STARTER, a
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld a, TEXT_REDSHOUSE2F_WAKE_UP
	ldh [hTextID], a
	jp DisplayTextID

RedsHouse2FNoopScript:
	ret

RedsHouse2F_TextPointers:
	def_text_pointers
	dw_const RedsHouse2FWakeUpText, TEXT_REDSHOUSE2F_WAKE_UP

RedsHouse2FWakeUpText:
	text_far _RedsHouse2FWakeUpText
	text_end
