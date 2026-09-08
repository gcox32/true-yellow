; PureRGBnote: ADDED: used with explosion/selfdestruct.
; On a hit, the user recoils 100% of the damage dealt.
; On a miss, the user still recoils 1/2 of its max HP.
ExplodeRecoilEffect_:
	ld a, [wMoveMissed]
	and a
	jr nz, .missed
	; PureRGBnote: CHANGED: on a hit, selfdestruct/explosion recoil 100% of the damage dealt
	ld hl, wDamage
	call GetMaxHPIntoDE ; de = user's max HP pointer (also clobbers a)
	ld a, [hli]
	ld b, a
	ld c, [hl] ; bc = full damage dealt
	ld h, d
	ld l, e ; hl = user's max HP pointer
	jr GotRecoilDamage
.missed
	; if explosion/selfdestruct missed, the recoil will be 1/2 the max health of the user
	call GetMaxHPIntoDE
	ld h, d
	ld l, e
	call CalculateRecoilDamage ; 1/2 of max HP
	jr GotRecoilDamage

; PureRGBnote: ADDED: big recoil effect does 50% of the damage inflicted, used with struggle.
BigRecoilEffect_: 
	call RecoilEffect_
	jr GotRecoilDamage

DefaultRecoilEffect_:
	call RecoilEffect_
	srl b ; PureRGBnote: CHANGED: recoil effect does 50% by default, so divide that by 2 here to get the original 25% of damage done.
	rr c
	jr GotRecoilDamage

GetMaxHPIntoDE:
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveNum]
	ld de, wBattleMonMaxHP
	ret z
	ld a, [wEnemyMoveNum]
	ld de, wEnemyMonMaxHP
	ret

RecoilEffect_:
	ld hl, wDamage 
CalculateRecoilDamage:
	call GetMaxHPIntoDE
.recoilEffect
	push af
	ld a, [hli]
	ld b, a
	ld c, [hl]
	ld h, d
	ld l, e
	pop af
	ld d, a
	srl b
	rr c
	ret

GotRecoilDamage:
	ld a, b
	or c
	jr nz, .updateHP
	inc c ; minimum recoil damage is 1
.updateHP
; subtract HP from user due to the recoil damage
	ld a, [hli]
	ld [wHPBarMaxHP+1], a
	ld a, [hl]
	ld [wHPBarMaxHP], a
	push bc
	ld bc, wBattleMonHP - wBattleMonMaxHP
	add hl, bc
	pop bc
	ld a, [hl]
	ld [wHPBarOldHP], a
	sub c
	ld [hld], a
	ld [wHPBarNewHP], a
	ld a, [hl]
	ld [wHPBarOldHP+1], a
	sbc b
	ld [hl], a
	ld [wHPBarNewHP+1], a
	jr nc, .getHPBarCoords
; if recoil damage is higher than the Pokemon's HP, set its HP to 0
	xor a
	ld [hli], a
	ld [hl], a
	ld hl, wHPBarNewHP
	ld [hli], a
	ld [hl], a
.getHPBarCoords
	hlcoord 10, 9
	ldh a, [hWhoseTurn]
	and a
	ld a, $1
	jr z, .updateHPBar
	hlcoord 2, 2
	xor a
.updateHPBar
	ld [wHPBarType], a
	predef UpdateHPBar2
	ld hl, HitWithRecoilText
	jp PrintText
HitWithRecoilText:
	text_far _HitWithRecoilText
	text_end
