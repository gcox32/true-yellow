TrashCanRandom:
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call JumpToAddress
	ld e, a
	ld d, 0
	ret

.Jumptable:
	dw .zero
	dw .one
	dw .two
	dw .three
	dw .four

.zero
.one
	ld a, 0
	ret

.two
	call Random
	and $1
	ret

.three
; Pick one of the 3 candidate pairs. The original code left the result in b
; while the caller reads a, so a held a raw 0-255 value and the second-lock
; can index was sampled far out of bounds. Keep the result in a.
	call Random
	swap a
	ld b, 0
	cp 1 * $ff / 3
	jr c, .threedone
	inc b
	cp 2 * $ff / 3
	jr c, .threedone
	inc b
.threedone
	ld a, b
	ret

.four
	call Random
	and $3
	ret

Yellow_SampleSecondTrashCan:
	ld hl, GymTrashCans3c
	ld a, [wGymTrashCanIndex]
	ld c, a
	ld b, 0
	ld a, 9
	call AddNTimes
	call AddNTimes ; ????
	ld a, [hli]
	ldh [hGymTrashCanRandNumMask], a
	ld e, a
	push hl
	call TrashCanRandom
	pop hl
	add hl, de
	add hl, de
	ld a, [hli]
	ld [wSecondLockTrashCanIndex], a
	ld a, [hl]
	ld [wSecondLockTrashCanIndex + 1], a
	ret

GymTrashCans3c:
; First byte: number of trashcan entries
; Following four byte pairs: indices for the second trash can.
; Rows with 3 trashcan entries pick which third of the range 0-255 a random
; number falls in (see TrashCanRandom.three). The original code returned that
; offset in the wrong register, so it was really a full 0-255 offset and the
; second-lock can was sampled out of bounds; .three has been fixed to return
; an offset in [0,2].
	db 4
	db  1,3,   3,1,   1,-1,  3,-1
	db 3
	db  0,2,   2,4,   4,0,  -1,-1
	db 4
	db  1,5,   5,1,   1,-1,  5,-1
	db 3
	db  0,4,   4,6,   6,0,  -1,-1
	db 4
	db  1,3,   3,1,   5,5,   7,7
	db 3
	db  2,4,   4,8,   8,2,  -1,-1
	db 3
	db  3,7,   7,9,   9,3,  -1,-1
	db 4
	db  4,8,   6,10,  8,4,  10,6
	db 3
	db  5,7,   7,11, 11,5,  -1,-1
	db 3
	db  6,10, 10,12, 12,6,  -1,-1
	db 4
	db  7,9,   9,7,  11,13, 13,11
	db 3
	db  8,10, 10,14, 14,8,  -1,-1
	db 4
	db  9,13, 13,9,   9,-1, 13,-1
	db 3
	db 10,12, 12,14, 14,10, -1,-1
	db 4
	db 11,13, 13,11, 11,-1, 13,-1
