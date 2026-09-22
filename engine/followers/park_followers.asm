; ParkFollowers and its tables live together in their own section so the linker
; can place them in whichever bank has room. They MUST share a bank: farcall
; maps this bank before the routine reads a table through `de`, so a table left
; behind in a caller's bank would be read as whatever sits at the same address
; here. The park_followers macro asserts it at link time; keeping the routine
; and every table in one section is what makes that assertion hold no matter
; where the linker puts them.
ParkFollowers::
; Walk Misty and/or Brock out of a scripted NPC's way before that NPC moves.
;
; de -> a table of park_follower entries, terminated by park_followers_end.
; (de, not hl: the `farcall` that gets here clobbers hl and b.)
;
; An entry fires only when that follower is spawned AND its trail entry is
; exactly the danger tile, so a follower who isn't in the way is never moved -
; which matters, because "nudge everyone by a constant delta" has no safe delta
; on some maps and shoves the innocent follower into a wall.
;
; The override is transient: the player's next couple of real steps cascade
; fresh trail values back in (Misty after 1 step, Brock after 2), exactly as
; the normal follow logic self-corrects.
;
; Destinations are absolute and verified at build time - walkable, off the NPC's
; path, and reachable by the follower's greedy Y-then-X walk before the NPC
; arrives. See engine/followers/CUTSCENE_COLLISIONS.md and
; tools/cutscene_check.py.
.entryLoop
	ld a, [de]
	inc a
	ret z                    ; park_followers_end
	call ParkFollowerEntry
	jr .entryLoop

ParkFollowerEntry:
; de -> one entry; always returns with de past it, whether or not it fired.
	ld a, [de]
	inc de
	ld c, a
	ld b, 0                  ; bc = trail slot
	call IsFollowerSpawned
	jr z, .skipDanger

	ld a, [de]               ; danger Y, or $ff for park-always
	inc de
	inc a
	jr z, .parkAlways
	dec a
	ld hl, wPositionTrailY
	add hl, bc
	cp [hl]
	jr nz, .skipDangerX

	ld a, [de]               ; danger X
	inc de
	ld hl, wPositionTrailX
	add hl, bc
	cp [hl]
	jr nz, .skipDest
	jr .writeDestination

.parkAlways
	inc de                   ; the danger X byte is unused in this form

.writeDestination
	ld hl, wPositionTrailY
	add hl, bc
	ld a, [de]               ; destination Y
	inc de
	ld [hl], a

	ld hl, wPositionTrailX
	add hl, bc
	ld a, [de]               ; destination X
	inc de
	ld [hl], a

	ld hl, wMovementTypeTrail
	add hl, bc
	ld [hl], 0               ; walk to it, don't hop
	ret

; Step de over whatever is left of the entry. Fallthrough, so each label skips
; one more byte than the one below it.
.skipDanger
	inc de                   ; danger Y
.skipDangerX
	inc de                   ; danger X
.skipDest
	inc de                   ; destination Y
	inc de                   ; destination X
	ret

IsFollowerSpawned:
; c = trail slot. Returns z when that follower is not currently on the map.
	ld a, c
	cp MISTY_TRAIL_SLOT
	jr nz, .brock
	ld a, [wSpriteMistyStateData1MovementStatus]
	and a
	ret
.brock
	ld a, [wSpriteBrockStateData1MovementStatus]
	and a
	ret

; --- Park tables --------------------------------------------------------
; These MUST live in this bank, not in the calling script's: `farcall`
; maps this bank before ParkFollowers runs its `ld a, [de]`, so a table in
; the script's bank would read whatever happens to sit at the same address
; here. The park_followers macro asserts the bank at link time.

MtMoonB2FRocketsParkTable::
	;              slot              danger  destination
	park_follower BROCK_TRAIL_SLOT,   3, 3,    3, 2
	park_follower BROCK_TRAIL_SLOT,   4, 4,    4, 2
	park_followers_end

; Rival on the left, player on the right at (15,5); he exits down-then-right.
PokemonTower2FRivalOnLeftParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT, 14, 6,   16, 6
	park_follower MISTY_TRAIL_SLOT, 15, 7,   16, 6
	park_follower BROCK_TRAIL_SLOT, 14, 7,   13, 7
	park_follower BROCK_TRAIL_SLOT, 16, 7,   16, 8
	park_followers_end

; Player below the rival at (14,6); he exits right-then-down.
PokemonTower2FRivalBelowParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT, 15, 5,   14, 4
	park_follower MISTY_TRAIL_SLOT, 15, 7,   13, 7
	park_follower BROCK_TRAIL_SLOT, 15, 6,   14, 7
	park_follower BROCK_TRAIL_SLOT, 16, 7,   17, 7
	park_followers_end


; Silph Co 7F - the rival's exit. Two routes, picked by wSavedCoordIndex.
;
; The two trigger tiles (3,2) and (3,3) seal the room: every path from the 3F
; teleport pad at (5,3) to the rest of the floor crosses one of them, so before
; the scene fires the player can only ever have been on (5,3), (4,3), (5,2) or
; (4,2). That leaves 4 possible follower arrangements per branch instead of 20,
; and means the rival's walk UP to meet the player can never reach them - only
; his exit needs a table.
;
; Brock on (4,3) is deliberately absent: he's safe there, and he's boxed in
; anyway (every neighbour is on the rival's route, the player, or wall).

SilphCo7FRivalExitRightParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,   4, 3,    5, 2
	park_follower BROCK_TRAIL_SLOT,   5, 3,    4, 2
	park_followers_end

SilphCo7FRivalWalkAroundParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,   5, 3,    1, 2
	park_follower MISTY_TRAIL_SLOT,   4, 2,    1, 2
	park_follower BROCK_TRAIL_SLOT,   5, 2,    4, 3
	park_followers_end

; Game Corner - the Rocket guarding the hideout poster. He has no trainer
; header, so he never walks up: you talk to him at (9,5) from (8,5), (9,6) or
; (10,5) ((9,4) is wall), and the script picks his exit route from the player's
; own coords. Talking from (8,5) is already clear - the player would have had
; to walk through him to leave a follower on his route - so only the other two
; positions need entries.

GameCornerRocketDirectParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  10, 5,   10, 7
	park_follower BROCK_TRAIL_SLOT,  11, 5,   10, 6
	park_followers_end

GameCornerRocketWalkAroundParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  12, 5,   12, 7
	park_follower MISTY_TRAIL_SLOT,   9, 6,    7, 6
	park_follower MISTY_TRAIL_SLOT,  11, 6,   10, 7
	park_follower BROCK_TRAIL_SLOT,  13, 5,   13, 6
	park_follower BROCK_TRAIL_SLOT,  10, 6,    8, 6
	park_follower BROCK_TRAIL_SLOT,  12, 6,   13, 6
	park_followers_end

; Route 22 - the rival's exit after the FIRST battle. Misty only: beating
; Pewter Gym is what makes Brock follow (Boulder Badge) and the same script
; resets EVENT_1ST_ROUTE22_RIVAL_BATTLE (scripts/PewterGym.asm), so Brock and
; this scene are mutually exclusive. The second Route 22 battle, which does
; have both followers, needs no table - that rival exits back the way he came,
; westward, while the followers trail east of the player.

Route22Rival1Exit1ParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  30, 5,   30, 4
	park_followers_end

Route22Rival1Exit2ParkTable::
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  30, 4,   30, 5
	park_follower MISTY_TRAIL_SLOT,  31, 5,   30, 5
	park_followers_end

; SS Anne 2F - the rival's exit. He and the player are in a two-wide corridor
; (cols 36-37), and he leaves down whichever column the player isn't in.
;
; The obvious fix - step each follower across to the other column - does NOT
; work: in a two-wide corridor the followers occupy both columns, so moving one
; across lands it on the other. They have to spread out instead, one dropping
; to the wider stretch at row 10 (cols 34-37).
;
; His walk DOWN to meet the player needs no table. The triggers (36,8)/(37,8)
; span the corridor, so the player can never have been north of them and the
; followers are always below him on the approach.

SSAnne2FRivalDownParkTable::
	; player on (37,8); he exits straight down column 36
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  36, 9,   37,10
	park_follower BROCK_TRAIL_SLOT,  36,10,   35,10
	park_followers_end

SSAnne2FRivalWalkAroundParkTable::
	; player on (36,8); he steps right and exits down column 37
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  37, 9,   36,10
	park_follower BROCK_TRAIL_SLOT,  37,10,   35,10
	park_followers_end

; Cerulean City - the rival's exit after the Nugget Bridge battle. Same shape as
; SS Anne: a two-wide corridor (the bridge, cols 20-21) with the triggers
; (20,6)/(21,6) spanning it, and he leaves down whichever column the player
; isn't in.
;
; His walk DOWN to meet the player needs no table - the triggers seal the
; bridge, so the player can never have been north of them and the followers are
; always below him.
;
; As on SS Anne, the followers cannot simply step across: they occupy both
; columns, so they swap ROWS as well, which keeps them off each other.

CeruleanCityRivalExitEastParkTable::
	; player on (20,6); he steps right and exits down column 21
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  21, 7,   20, 8
	park_follower BROCK_TRAIL_SLOT,  21, 8,   20, 7
	park_followers_end

CeruleanCityRivalExitWestParkTable::
	; player on (21,6); he steps left and exits down column 20
	;              slot              danger  destination
	park_follower MISTY_TRAIL_SLOT,  20, 7,   21, 8
	park_follower BROCK_TRAIL_SLOT,  20, 8,   21, 7
	park_followers_end

; Bill's House - Bill's Pokemon walks into the teleporter machine, and later
; Bill himself walks across the room. Three separate walks in an 8x8 room, and
; every tile the player can talk from leaves a follower on one of them.
;
; Rather than dodge three paths, send both followers to the doorway and leave
; them there: (1,7) and (4,7) flank the double-wide entrance at (2,7)/(3,7),
; and neither is on any of the three walks. Unconditional, because there is no
; arrangement where standing put is safe.
;
; Parking once here covers Bill's later walk too: the player doesn't move for
; the rest of the sequence, so the trail - and therefore the followers - stay
; where this puts them.
;
; Note (6,2) is the machine, a wall tile Bill's Pokemon steps into on purpose;
; a path check flagging it is a false positive, not a bug.

BillsHouseDoorwayParkTable::
	;                     slot              dest x, y
	park_follower_always MISTY_TRAIL_SLOT,    1, 7
	park_follower_always BROCK_TRAIL_SLOT,    4, 7
	park_followers_end
