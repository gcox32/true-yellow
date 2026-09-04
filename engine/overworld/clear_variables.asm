ClearVariablesOnEnterMap::
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ldh [rWY], a
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld [wStepCounter], a
	ld [wLoneAttackNo], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ldh [hJoyHeld], a
	ld [wActionResultOrTookBattleTurn], a
	ld [wUnusedMapVariable], a
	ld hl, wCardKeyDoorY
	ld [hli], a
	ld [hl], a
	ld hl, wWhichTrade
	ld bc, wStandingOnWarpPadOrHole - wWhichTrade
	call FillMemory
	; Clear the "suppress out-of-battle poison / Pikachu step updates" bit.
	; It's set by the Bill's House, Pewter Pokecenter and Pokemon Fan Club map
	; scripts (which re-set it every frame while you're there) but was only
	; cleared by the Pewter City / Vermilion City / Route 25 scripts, so leaving
	; those rooms by Fly/Dig/Escape Rope/a reworked warp could strand it and
	; freeze wPikachuHappiness / wPikachuMood. Clear it on every map load.
	ld hl, wd492
	res 7, [hl]
	ret
