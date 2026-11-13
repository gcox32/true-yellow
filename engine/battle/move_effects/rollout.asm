; ROLLOUT (repurposes Gen 1 Rage's lock-in): runs before damage calc every turn
; the user is locked in. USING_RAGE = "rolling"; it stops the battle menu / AI
; from picking a move, makes .RageCheck re-use ROLLOUT, and skips DecrementPP
; after the first turn. wPlayer/EnemyNumAttacksLeft counts hits (free while
; locked: Thrash, multi-hit and trapping moves can't run at the same time).
; The lock ends after the 5th hit, on a miss (core.asm), or when the user is
; fully paralyzed / hurts itself in confusion (core.asm).
; Power doubles if the user has used Defense Curl since it was sent out (as in
; Gen 2): 60/120/180/240, then 255 (the power byte's cap) instead of 300.
DEF ROLLOUT_MAX_HITS EQU 5
DEF ROLLOUT_POWER_STEP EQU 30 ; power = 30 x hit number: 30/60/90/120/150

RolloutEffect_:
	ld hl, wPlayerBattleStatus2
	ld de, wPlayerNumAttacksLeft
	ld bc, wPlayerMovePower
	ldh a, [hWhoseTurn]
	and a
	jr z, .gotPointers
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyNumAttacksLeft
	ld bc, wEnemyMovePower
.gotPointers
	bit USING_RAGE, [hl]
	jr nz, .rolling
	set USING_RAGE, [hl] ; first hit: lock in
	xor a
	ld [de], a
.rolling
	ld a, [de]
	inc a
	ld [de], a
	cp ROLLOUT_MAX_HITS
	jr c, .setPower
	res USING_RAGE, [hl] ; last hit: free next turn
.setPower
	ld e, a ; hit number (the counter is already saved)
	xor a
.powerLoop
	add ROLLOUT_POWER_STEP
	dec e
	jr nz, .powerLoop
	bit DEFENSE_CURLED, [hl]
	jr z, .gotPower
	add a ; Defense Curl doubles it
	jr nc, .gotPower
	ld a, $ff ; cap
.gotPower
	ld [bc], a
	ret
