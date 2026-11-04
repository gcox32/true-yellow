; does nothing since no stats are ever selected (barring glitches)
DoubleSelectedStats:
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerStatsToDouble]
	ld hl, wBattleMonAttack + 1
	jr z, .notEnemyTurn
	ld a, [wEnemyStatsToDouble]
	ld hl, wEnemyMonAttack + 1
.notEnemyTurn
	ld c, 4
	ld b, a
.loop
	srl b
	call c, .doubleStat
	inc hl
	inc hl
	dec c
	ret z
	jr .loop

.doubleStat
	ld a, [hl]
	add a
	ld [hld], a
	ld a, [hl]
	rl a
	ld [hli], a
	ret

; does nothing since no stats are ever selected (barring glitches)
HalveSelectedStats:
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerStatsToHalve]
	ld hl, wBattleMonAttack
	jr z, .notEnemyTurn
	ld a, [wEnemyStatsToHalve]
	ld hl, wEnemyMonAttack
.notEnemyTurn
	ld c, 4
	ld b, a
.loop
	srl b
	call c, .halveStat
	inc hl
	inc hl
	dec c
	ret z
	jr .loop

.halveStat
	ld a, [hl]
	srl a
	ld [hli], a
	rr [hl]
	or [hl]
	jr nz, .nonzeroStat
	ld [hl], 1
.nonzeroStat
	dec hl
	ret

; PureRGBnote: FIXED: restores the stat lost to the burn or paralysis of the mon whose
; turn it is. Call this BEFORE clearing the status, it reads which one to undo.
UndoBurnParStats:
	ld hl, wBattleMonStatus
	ld de, wPlayerStatsToDouble
	ldh a, [hWhoseTurn]
	and a
	jr z, .gotPointers
	ld hl, wEnemyMonStatus
	ld de, wEnemyStatsToDouble
.gotPointers
	ld a, [hl]
	bit BRN, a
	jr nz, .burned
	bit PAR, a
	ret z
	ld a, 1 << 2 ; speed, quartered so double it twice
	ld [de], a
	push de
	call DoubleSelectedStats
	call DoubleSelectedStats
	jr .done
.burned
	ld a, 1 << 0 ; attack
	ld [de], a
	push de
	call DoubleSelectedStats
.done
	pop de
	xor a
	ld [de], a
	ret
