; Picks and prints what Misty / Brock say when the player talks to them.
; Called (farcall) from TalkToMisty / TalkToBrock in chain_follow.asm,
; after the text box is set up; they handle the button wait and cleanup.
;
; The lines live in data/followers/follower_lines.asm (same section, so the
; table can point straight at the text). See the header there for the format.

; condition values (see data/followers/follower_lines.asm)
DEF ALWAYS       EQU $ffff ; "when" that always holds
DEF NEVER        EQU $ffff ; "unless" that never blocks
DEF HAS_BADGES   EQU $a000 ; + n: at least n badges
DEF DEX_OWNED    EQU $b000 ; + n: at least n #MON owned
DEF BEAT_ELITE_4 EQU $c000 ; wElite4Flags BIT_BEAT_ELITE_4 (survives the Hall of Fame)
; event flags (EVENT_*) are < $a00

DEF ANYWHERE           EQU -1
DEF FOLLOWER_LINES_END EQU $ff
DEF FOLLOWER_POOL      EQU $fc ; first byte of a follower_pool (texts start with TX_START)

; table entry layout (follower_line macro)
DEF FL_FIRST_MAP  EQU 0
DEF FL_LAST_MAP   EQU 1
DEF FL_WHEN       EQU 2 ; dw condition
DEF FL_UNLESS     EQU 4 ; dw condition
DEF FL_CHANCE     EQU 6 ; db 0 = always, else pass if Random < this
DEF FL_LINES      EQU 7 ; dw misty_line, brock_line
DEF FL_ENTRY_SIZE EQU 11

; in: c = FOLLOWER_TALK_MISTY or FOLLOWER_TALK_BROCK
FollowerTalk_PrintLine::
	ld hl, FollowerLines
.loop
	ld a, [hli] ; first map
	cp FOLLOWER_LINES_END
	jr z, .default
	ld b, a
	ld a, [wCurMap]
	cp b
	jr c, .skipFrom1 ; wCurMap < first
	ld b, a
	ld a, [hli] ; last map
	cp b
	jr c, .skipFrom2 ; last < wCurMap

; this follower's line pointer: 0 = no line here, skip the whole entry
	push hl
	ld de, FL_LINES - FL_WHEN
	add hl, de
	ld a, c
	add a
	ld e, a
	add hl, de ; d is still 0
	ld a, [hli]
	or [hl]
	pop hl
	jr z, .skipFrom2

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	call .EvalWhen
	jr nc, .skipFrom4
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	call .EvalUnless
	jr c, .skipFrom6
	ld a, [hli] ; chance
	and a
	jr z, .pick
	ld b, a
	call Random ; preserves bc, de, hl
	cp b
	jr nc, .skipFrom7

.pick ; hl -> dw misty_line, brock_line
	ld a, c
	add a
	add l
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr .printLineOrPool

.skipFrom1
	ld de, FL_ENTRY_SIZE - 1
	jr .skip
.skipFrom2
	ld de, FL_ENTRY_SIZE - 2
	jr .skip
.skipFrom4
	ld de, FL_ENTRY_SIZE - 4
	jr .skip
.skipFrom6
	ld de, FL_ENTRY_SIZE - 6
	jr .skip
.skipFrom7
	ld de, FL_ENTRY_SIZE - 7
.skip
	add hl, de
	jr .loop

.default
	ld hl, FollowerDefaultMistyText
	ld a, c
	and a
	jr z, .printLineOrPool
	ld hl, FollowerDefaultBrockText
	; fallthrough

; hl -> a text, or a follower_pool (db FOLLOWER_POOL, count, dw lines...)
.printLineOrPool
	ld a, [hl]
	cp FOLLOWER_POOL
	jp nz, PrintText
	inc hl
	ld a, [hli]
	ld b, a ; count
	call Random
.mod
	sub b
	jr nc, .mod
	add b ; a = 0..count-1
	add a
	add l
	ld l, a
	jr nc, .noCarry2
	inc h
.noCarry2
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp PrintText

; in: de = condition. out: carry if it holds (ALWAYS holds).
; preserves c, hl
.EvalWhen:
	ld a, d
	and e
	inc a
	scf
	ret z ; ALWAYS ($ffff)
	jr .Eval

; in: de = condition. out: carry if it holds (NEVER doesn't).
; preserves c, hl
.EvalUnless:
	ld a, d
	and e
	inc a
	ret z ; NEVER ($ffff): carry is clear (and e cleared it, inc keeps it)
	; fallthrough

; in: de = condition (an event flag, HAS_BADGES + n, DEX_OWNED + n,
; or BEAT_ELITE_4). out: carry if it holds. preserves c, hl
.Eval:
	ld a, d
	cp HIGH(HAS_BADGES)
	jr c, .evalEventFlag
	cp HIGH(BEAT_ELITE_4)
	jr z, .evalElite4
	push hl
	push bc
	push de
	ld hl, wObtainedBadges
	ld b, 1
	cp HIGH(HAS_BADGES)
	jr z, .count
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
.count
	call CountSetBits
	pop de
	pop bc
	pop hl
	ld a, [wNumSetBits]
	cp e
	ccf ; carry if count >= n
	ret

.evalElite4
	ld a, [wElite4Flags]
	bit BIT_BEAT_ELITE_4, a
	scf
	ret nz
	and a
	ret

.evalEventFlag
	push hl
	call .CheckEventDE
	pop hl
	scf
	ret nz
	and a
	ret

; in: de = event flag index (16-bit; FlagAction only handles 8-bit)
; out: nz if set. preserves c
.CheckEventDE:
	ld a, e
	and 7
	ld b, a
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ld hl, wEventFlags
	add hl, de
	ld a, [hl]
	inc b
.shift
	dec b
	jr z, .gotBit
	rrca
	jr .shift
.gotBit
	and 1
	ret
