ResetStatusAndHalveMoneyOnBlackout::
; Reset player status on blackout.
	xor a
	ld [wPikachuCollisionCounter], a
	xor a ; gamefreak copypasting functions (double xor a)
	ld [wBattleResult], a
	ld [wWalkBikeSurfState], a
	ld [wIsInBattle], a
	ld [wMapPalOffset], a
	ld [wNPCMovementScriptFunctionNum], a
	ldh [hJoyHeld], a
	ld [wNPCMovementScriptPointerTableNum], a
	ld [wMiscFlags], a

	ldh [hMoney], a
	ldh [hMoney + 1], a
	ldh [hMoney + 2], a
	call HasEnoughMoney
	jr c, .lostmoney ; never happens

	; Halve the player's money.
	ld a, [wPlayerMoney]
	ldh [hMoney], a
	ld a, [wPlayerMoney + 1]
	ldh [hMoney + 1], a
	ld a, [wPlayerMoney + 2]
	ldh [hMoney + 2], a
	xor a
	ldh [hDivideBCDDivisor], a
	ldh [hDivideBCDDivisor + 1], a
	ld a, 2
	ldh [hDivideBCDDivisor + 2], a
	predef DivideBCDPredef3
	ldh a, [hDivideBCDQuotient]
	ld [wPlayerMoney], a
	ldh a, [hDivideBCDQuotient + 1]
	ld [wPlayerMoney + 1], a
	ldh a, [hDivideBCDQuotient + 2]
	ld [wPlayerMoney + 2], a

.lostmoney
; PureRGBnote: FIXED: blacking out (poison while walking) ended the game without ending
; the Safari Game. The step counter kept running everywhere and later warped you back.
	ResetEvents EVENT_SAFARI_GAME_OVER, EVENT_IN_SAFARI_ZONE
	xor a
	ld [wNumSafariBalls], a
	ld [wSafariSteps], a
	ld [wSafariSteps + 1], a
	ld [wSafariZoneGameOver], a
	ld [wSafariZoneGateCurScript], a ; SCRIPT_SAFARIZONEGATE_DEFAULT
	ld hl, wStatusFlags6
	set BIT_FLY_OR_DUNGEON_WARP, [hl]
	res BIT_FLY_WARP, [hl]
	set BIT_ESCAPE_WARP, [hl]
	set BIT_BLACKOUT_WARP, [hl]
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	predef_jump HealParty
