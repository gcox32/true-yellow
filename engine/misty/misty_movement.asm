UpdateMistyMovementState::
    ld a, [wMistyOverworldStateFlags]
    bit 1, a
    ret nz          ; return if following is disabled
    
    ; Check if we need to process movement
    ld a, [wMistyMovementStatus]
    and a
    jr z, .compute_new_movement
    
    ; We're in the middle of moving, update animation
    call UpdateMistyAnimationFrame
    ret

.compute_new_movement
    call ComputeMistyFollowCommand
    ret c           ; return if we're already at destination
    
    ; Store new movement command
    push af
    call ComputeMistyFacingDirection
    pop af
    
    ; Convert movement command to direction
    cp $1
    jr z, .move_down
    cp $2
    jr z, .move_up
    cp $3
    jr z, .move_right
    cp $4
    jr z, .move_left
    ret             ; invalid movement command

.move_down
    ld a, SPRITE_FACING_DOWN
    jr .set_movement

.move_up
    ld a, SPRITE_FACING_UP
    jr .set_movement

.move_right
    ld a, SPRITE_FACING_RIGHT
    jr .set_movement

.move_left
    ld a, SPRITE_FACING_LEFT

.set_movement
    ; Store facing direction
    ld [wMistyFacingDirection], a
    
    ; Check for collisions before moving
    call CheckMistyCollision
    ret c           ; return if collision detected
    
    ; Update movement status
    ld a, $1
    ld [wMistyMovementStatus], a
    
    ; Update sprite coordinates based on direction
    ld a, [wMistyFacingDirection]
    cp SPRITE_FACING_DOWN
    jr z, .update_y_plus
    cp SPRITE_FACING_UP
    jr z, .update_y_minus
    cp SPRITE_FACING_RIGHT
    jr z, .update_x_plus
    cp SPRITE_FACING_LEFT
    jr z, .update_x_minus
    ret

.update_y_plus
    ld a, [wSpriteMistyStateData2MapY]
    inc a
    ld [wSpriteMistyStateData2MapY], a
    ret

.update_y_minus
    ld a, [wSpriteMistyStateData2MapY]
    dec a
    ld [wSpriteMistyStateData2MapY], a
    ret

.update_x_plus
    ld a, [wSpriteMistyStateData2MapX]
    inc a
    ld [wSpriteMistyStateData2MapX], a
    ret

.update_x_minus
    ld a, [wSpriteMistyStateData2MapX]
    dec a
    ld [wSpriteMistyStateData2MapX], a
    ret

UpdateMistyAnimation::
    ld a, [wMistyMovementStatus]
    and a
    ret z        ; return if not moving
    
    ld a, [wSpriteMistyStateData1ImageIndex]
    inc a
    cp $4       ; we have 4 animation frames
    jr nz, .storeNewFrame
    xor a       ; reset to frame 0
.storeNewFrame
    ld [wSpriteMistyStateData1ImageIndex], a
    
    ; Update sprite facing based on movement direction
    ld a, [wMistyFacingDirection]
    ld b, a
    add a       ; multiply by 4 to get base frame
    add a
    ld c, a
    ld a, [wSpriteMistyStateData1ImageIndex]
    add c       ; add animation frame offset
    ld [wSpriteMistyStateData1ImageIndex], a
    ret
    
ComputeMistyFacingDirection::
    ; Get Pikachu's position relative to Misty
    ld a, [wSpritePikachuStateData2MapY]
    ld b, a
    ld a, [wSpriteMistyStateData2MapY]
    sub b
    jr z, .check_x
    jr nc, .face_up
    
    ; Misty is below Pikachu
    ld a, SPRITE_FACING_DOWN
    jr .load

.face_up
    ld a, SPRITE_FACING_UP
    jr .load

.check_x
    ld a, [wSpritePikachuStateData2MapX]
    ld b, a
    ld a, [wSpriteMistyStateData2MapX]
    sub b
    jr z, .copy_pikachu_facing
    jr nc, .face_left
    
    ld a, SPRITE_FACING_RIGHT
    jr .load

.face_left
    ld a, SPRITE_FACING_LEFT
    jr .load

.copy_pikachu_facing
    ld a, [wSpritePikachuStateData1FacingDirection]
.load
    ld [wSpriteMistyStateData1FacingDirection], a
    ret

UpdateMistyAnimationFrame::
    ; Only animate if we're moving
    ld a, [wMistyMovementStatus]
    and a
    ret z
    
    ; Update animation frame counter
    ld a, [wSpriteMistyStateData1ImageIndex]
    inc a
    and %00000011  ; Keep within 4 frames (0-3)
    ld [wSpriteMistyStateData1ImageIndex], a
    
    ; Calculate final frame based on facing direction
    ld b, a  ; save frame number
    ld a, [wMistyFacingDirection]
    add a    ; multiply by 4 for frame offset
    add a
    add b    ; add animation frame
    ld [wSpriteMistyStateData1ImageIndex], a
    ret
