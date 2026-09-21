; Syntactic sugar macros

MACRO? lb ; r, hi, lo
	ld \1, ((\2) & $ff) << 8 + ((\3) & $ff)
ENDM

MACRO? ldpal
	ld \1, \2 << 6 | \3 << 4 | \4 << 2 | \5
ENDM

; Design patterns

MACRO dict
	IF \1 == 0
		and a
	ELSE
		cp \1
	ENDC
	jp z, \2
ENDM

; Call ParkFollowers (engine/followers/chain_follow.asm) on a park table.
;
; The table has to live in ParkFollowers' own bank: farcall maps that bank
; before the routine runs, so a table in the caller's bank would be read from
; whatever sits at the same address in the follower bank instead. That failure
; is silent and corrupts WRAM (a garbage slot byte indexes off the end of the
; position trail), so assert the bank rather than trusting a comment.
MACRO park_followers
	ASSERT BANK(\1) == BANK(ParkFollowers), \
		"\1 must live in ParkFollowers' bank - see engine/followers/CUTSCENE_COLLISIONS.md"
	ld de, \1
	farcall ParkFollowers
ENDM

; Same, for callers that pick between tables and already have one in de.
MACRO park_followers_de
	farcall ParkFollowers
ENDM
