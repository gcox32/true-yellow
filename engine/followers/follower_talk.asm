; Picks and prints what Misty / Brock say when the player talks to them.
; Called (farcall) from TalkToMisty / TalkToBrock in chain_follow.asm,
; after the text box is set up; they handle the button wait and cleanup.
;
; The lines live in data/followers/follower_lines.asm (same section, so the
; table can point straight at the text). See the header there for the format.

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
	ld a, [hli] ; last map (ld leaves flags alone)
	jr c, .skip6 ; wCurMap < first
	ld b, a
	ld a, [wCurMap]
	cp b
	jr z, .mapOk
	jr nc, .skip6 ; wCurMap > last
.mapOk
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; de = event flag (or NO_BEAT)
	inc a ; NO_BEAT is $ffff; real flags are < $a00
	jr z, .flagOk
	push hl
	call .CheckEventDE
	pop hl
	jr z, .skip4 ; flag not set
.flagOk
; hl -> dw misty_line, brock_line
	push hl
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
	or h
	jr nz, .print
	pop hl ; no line for this follower here: keep looking
.skip4
	ld de, 4
	add hl, de
	jr .loop
.skip6
	ld de, 6
	add hl, de
	jr .loop

.print
	pop de ; discard saved table pointer
	jp PrintText

.default
	ld hl, FollowerDefaultMistyText
	ld a, c
	and a
	jp z, PrintText
	ld hl, FollowerDefaultBrockText
	jp PrintText

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
