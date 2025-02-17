ShouldMistySpawn::
    ld a, [wMistyOverworldStateFlags]
    bit 5, a
    jr nz, .hide
    scf
    ret
.hide
    and a
    ret



ClearMistyFollowCommandBuffer::
    xor a
    ld [wMistyFollowCommandBufferSize], a
    ld hl, wMistyFollowCommandBuffer
    ld bc, 16  ; buffer size
    call FillMemory
    ret



ComputeMistyFollowCommand::
    call IsMistyRightNextToPikachu
    jr c, .already_there
    
    ; Get movement direction based on relative position
    call GetMistyFacingDirectionAndReturnToE
    ld a, e
    cp $ff
    jr z, .already_there
    
    ; Convert facing direction to movement command
    add a
    add a  ; multiply by 4
    ld e, a
    ld d, 0
    ld hl, MistyMovementCommands
    add hl, de
    ld a, [hl]
    ret

.already_there
    scf
    ret

MistyMovementCommands:
    db MOVEMENT_DOWN    ; SPRITE_FACING_DOWN
    db MOVEMENT_UP      ; SPRITE_FACING_UP
    db MOVEMENT_LEFT    ; SPRITE_FACING_LEFT
    db MOVEMENT_RIGHT   ; SPRITE_FACING_RIGHT

GetMistyFollowCommand::
    ld hl, wMistyFollowCommandBufferSize
    ld a, [hl]
    cp $ff
    jr z, .default
    ld e, a
    ld d, 0
    ld hl, wMistyFollowCommandBuffer
    add hl, de
    ld a, [hl]
    ret
.default
    xor a
    ret

AddMistyMovementCommand::
    push bc
    ld hl, wMistyFollowCommandBufferSize
    ld a, [hl]
    cp $ff
    jr z, .done
    cp 16  ; max buffer size
    jr nc, .done
    inc [hl]
    ld c, a
    ld b, 0
    ld hl, wMistyFollowCommandBuffer
    add hl, bc
    ld [hl], a
.done
    pop bc
    ret

UpdateMistySprite::
    ; First check if we need to update sprite state
    ld a, [wMistyMovementStatus]
    and a
    ret z
    
    ; Get next movement command
    call GetMistyFollowCommand
    and a
    ret z
    
    ; Update sprite facing direction based on movement
    cp SPRITE_FACING_DOWN
    jr z, .face_down
    cp SPRITE_FACING_UP
    jr z, .face_up
    cp SPRITE_FACING_LEFT
    jr z, .face_left
    cp SPRITE_FACING_RIGHT
    jr z, .face_right
    ret

.face_down
    ld a, SPRITE_FACING_DOWN
    jr .set_facing

.face_up
    ld a, SPRITE_FACING_UP
    jr .set_facing

.face_left
    ld a, SPRITE_FACING_LEFT
    jr .set_facing

.face_right
    ld a, SPRITE_FACING_RIGHT

.set_facing
    ld [wMistyFacingDirection], a
    ld [wSpriteMistyStateData1FacingDirection], a
    ret

ClearMistySpriteStateData::
    ld bc, $10
    xor a
    call FillMemory
    ret

CheckMistyCollision::
    ld a, [wMistyOverworldStateFlags]
    bit 1, a
    ret nz  ; return if following is disabled
    
    ; Get Misty's current position
    ld a, [wSpriteMistyStateData2MapY]
    add $4
    ld d, a  ; d = Misty's Y + 4
    ld a, [wSpriteMistyStateData2MapX]
    add $4
    ld e, a  ; e = Misty's X + 4
    
    ; Check collision with other sprites
    ld h, HIGH(wSpriteStateData1)
    ld a, SPRITESTATEDATA1_PICTUREID
.checkNextSprite
    ld l, a
    ld a, [hl]
    and a
    jr z, .nextSprite
    push hl
    push de
    call CheckSpriteCollision
    pop de
    pop hl
    jr c, .collision
.nextSprite
    ld a, l
    add $10
    cp $f0  ; changed from $100 to $f0
    jr nz, .checkNextSprite
    and a     ; clear carry flag - no collision
    ret

.collision
    scf       ; set carry flag - collision detected
    ret

CheckSpriteCollision:
    ; Compare Y coordinates
    ld hl, SPRITESTATEDATA2_MAPY - SPRITESTATEDATA1_PICTUREID
    add hl, de
    ld a, [hl]
    sub d
    jr z, .checkX
    cp -1
    jr z, .possibleCollision
    cp 1
    ret nz
.possibleCollision
    ; Compare X coordinates
    ld hl, SPRITESTATEDATA2_MAPX - SPRITESTATEDATA1_PICTUREID
    add hl, de
    ld a, [hl]
    sub e
    jr z, .collision
    cp -1
    jr z, .collision
    cp 1
    ret nz
.collision
    scf
    ret
.checkX
    ld hl, SPRITESTATEDATA2_MAPX - SPRITESTATEDATA1_PICTUREID
    add hl, de
    ld a, [hl]
    sub e
    jr z, .collision
    cp -1
    jr z, .collision
    cp 1
    jr z, .collision
    and a
    ret

SetMistyOverworldStateFlag2::
    push hl
    ld hl, wMistyOverworldStateFlags
    set 2, [hl]
    pop hl
    ret

ResetMistyOverworldStateFlag2::
    push hl
    ld hl, wMistyOverworldStateFlags
    res 2, [hl]
    pop hl
    ret

IsMistyRightNextToPikachu::
    push bc
    push de
    push hl
    
    ; Get Pikachu's position
    ld a, [wSpritePikachuStateData2MapX]
    add $4
    ld d, a
    ld a, [wSpritePikachuStateData2MapY]
    add $4
    ld e, a
    
    ; Compare with Misty's position
    ld a, [wSpriteMistyStateData2MapY]
    sub e
    and a
    jr z, .check_x
    cp $ff
    jr z, .one_away
    cp $1
    jr z, .one_away
    jr .too_far

.one_away
    ld a, [wSpriteMistyStateData2MapX]
    sub d
    jr z, .good
    jr .too_far

.check_x
    ld a, [wSpriteMistyStateData2MapX]
    sub d
    cp $ff
    jr z, .good
    cp $1
    jr z, .good
    
.too_far
    pop hl
    pop de
    pop bc
    xor a
    ret

.good
    pop hl
    pop de
    pop bc
    scf
    ret



