; PureRGBnote: CHANGED: Priority moves are now stored in a list instead of hardcoded Quick Attack only.

PriorityMoves:
	db QUICK_ATTACK
	db COMET_PUNCH
	db WING_ATTACK
	db FLASH
	db SWIFT
	db TRANSFORM
	db MIRROR_MOVE
	db SONICBOOM
	db -1 ; end

FarCheckPriority:
	ld c, d
; returns with c set if move in c is a priority move
CheckPriority:
	push hl
	ld hl, PriorityMoves         ; table of high priority moves
.priorityLoop
	ld a, [hli]                  ; read move from move table
	cp -1                        ; did we reach the end of the list
	jr z, .noPriority            ; if so, not a priority move
	cp c                         ; does it match the move about to be used?
	jr nz, .priorityLoop         ; continue as a normal move if not
	; if so, the move about to be used is a priority move
.foundPriority
	scf
.noPriority
	pop hl
	ret

; Moves that always move last, regardless of Speed (negative priority).
; Counter is designed to strike back after taking the opponent's hit.
LastPriorityMoves:
	db COUNTER
	db -1 ; end

; returns with carry set if move in c is a "moves last" move
CheckLastPriority:
	push hl
	ld hl, LastPriorityMoves
.loop
	ld a, [hli]
	cp -1
	jr z, .notLast
	cp c
	jr nz, .loop
	scf
.notLast
	pop hl
	ret
