ReadTrainer:

; don't change any moves in a link battle
	ld a, [wLinkState]
	and a
	ret nz

; Fighting Dojo training hall: once the Dojo is beaten, its Blackbelts
; field the training teams (appended after the vanilla Blackbelt teams).
; The guard keeps this idempotent if ReadTrainer ever runs twice.
	call IsDojoTrainingBout
	jr nc, .notDojoTraining
	ld a, [wTrainerNo]
	cp DOJO_TRAINING_TEAMS_OFFSET + 1
	jr nc, .notDojoTraining
	add DOJO_TRAINING_TEAMS_OFFSET
	ld [wTrainerNo], a
.notDojoTraining

; set [wEnemyPartyCount] to 0, [wEnemyPartySpecies] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl, wEnemyPartyCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a

; get the pointer to trainer data for this class
	ld a, [wTrainerClass] ; get trainer class
	dec a
	add a
	ld hl, TrainerDataPointers
	ld c, a
	ld b, 0
	add hl, bc ; hl points to trainer class
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wTrainerNo]
	ld b, a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.CheckNextTrainer
	dec b
	jr z, .IterateTrainer
.SkipTrainer
	ld a, [hli]
	and a
	jr nz, .SkipTrainer
	jr .CheckNextTrainer

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	call IsDojoTrainingBout
	jr c, .DojoTrainingLevel
	ld a, [hli]
	cp $FF ; is the trainer special?
	jr z, .SpecialTrainer ; if so, check for special moves
	ld [wCurEnemyLevel], a
.LoopTrainerData
	ld a, [hli]
	and a ; have we reached the end of the trainer data?
	jp z, .AddAdditionalMoveData
	ld [wCurPartySpecies], a
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	push hl
	call AddPartyMon
	pop hl
	jr .LoopTrainerData
.SpecialTrainer
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
	ld a, [hli]
	and a ; have we reached the end of the trainer data?
	jr z, .AddAdditionalMoveData
	ld [wCurEnemyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	push hl
	call AddPartyMon
	pop hl
	jr .SpecialTrainer
.DojoTrainingLevel
; the team's level byte is a signed offset from the player's highest level
	ld a, [hli]
	ld c, a
	push hl
	ld hl, wPartyMon1Level
	ld de, wPartyMon2 - wPartyMon1
	ld a, [wPartyCount]
	ld b, a
	xor a
.highestLevelLoop
	cp [hl]
	jr nc, .notHigher
	ld a, [hl]
.notHigher
	add hl, de
	dec b
	jr nz, .highestLevelLoop
	pop hl
	ld b, a
	ld a, c
	bit 7, a
	jr nz, .negativeOffset
	add b
	cp MAX_LEVEL + 1
	jr c, .gotDojoLevel
	ld a, MAX_LEVEL
	jr .gotDojoLevel
.negativeOffset
	add b ; carry set iff level + offset >= 0
	jr nc, .dojoLevelTooLow
	cp 2
	jr nc, .gotDojoLevel
.dojoLevelTooLow
	ld a, 2
.gotDojoLevel
	ld [wCurEnemyLevel], a
	jp .LoopTrainerData
.AddAdditionalMoveData
; does the trainer have additional move data?
	ld a, [wTrainerClass]
	ld b, a
	ld a, [wTrainerNo]
	ld c, a
	ld hl, SpecialTrainerMoves
.loopAdditionalMoveData
	ld a, [hli]
	cp $ff
	jr z, .FinishUp
	cp b
	jr nz, .loopSkipTrainer
	ld a, [hli]
	cp c
	jr nz, .loopSkipTrainer
	ld d, h
	ld e, l
.writeAdditionalMoveDataLoop
	ld a, [de]
	inc de
	and a
	jp z, .FinishUp
	dec a
	ld hl, wEnemyMon1Moves
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld a, [de]
	inc de
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [de]
	inc de
	ld [hl], a
	jr .writeAdditionalMoveDataLoop
.loopSkipTrainer
	ld a, [hli]
	and a
	jr nz, .loopSkipTrainer
	jr .loopAdditionalMoveData
.FinishUp
; clear wAmountMoneyWon addresses
	xor a
	ld de, wAmountMoneyWon
	ld [de], a
	inc de
	ld [de], a
	inc de
	ld [de], a
	ld a, [wCurEnemyLevel]
	ld b, a
; Fighting Dojo training hall pays double (level <= MAX_LEVEL, so b <= 200)
	call IsDojoTrainingBout
	jr nc, .LastLoop
	sla b
.LastLoop
; update wAmountMoneyWon addresses (money to win) based on enemy's level
	ld hl, wTrainerBaseMoney + 1
	ld c, 2 ; wAmountMoneyWon is a 3-byte number
	push bc
	predef AddBCDPredef
	pop bc
	inc de
	inc de
	dec b
	jr nz, .LastLoop ; repeat wCurEnemyLevel times
	ret

; carry set if this battle is a Fighting Dojo training-hall bout:
; a Blackbelt in the Dojo after the Dojo has been beaten
IsDojoTrainingBout:
	ld a, [wCurMap]
	cp FIGHTING_DOJO
	jr nz, .no
	ld a, [wTrainerClass]
	cp BLACKBELT
	jr nz, .no
	CheckEvent EVENT_DEFEATED_FIGHTING_DOJO
	jr z, .no
	scf
	ret
.no
	and a
	ret
