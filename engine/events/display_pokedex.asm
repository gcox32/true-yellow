_DisplayPokedex::
	; The dex entry is full-screen, but the positional follower hiding only
	; covers the bottom text box rows, so a follower higher up stays drawn on
	; top of it. Force-hide (bit 6; self-clears once wFontLoaded goes false -
	; see ShouldMistySpawn in chain_follow.asm). ShowPokedexData's own
	; UpdateSprites call applies it.
	ld hl, wMistyOverworldStateFlags
	set 6, [hl]
	ld hl, wBrockOverworldStateFlags
	set 6, [hl]
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	predef ShowPokedexData
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	call ReloadMapData
	ld c, 10
	call DelayFrames
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld c, a
	ld b, FLAG_SET
	ld hl, wPokedexSeen
	predef FlagActionPredef
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret
