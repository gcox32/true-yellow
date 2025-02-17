SpawnMisty_::
    call ShouldMistySpawn
    ret nc          ; return if Misty shouldn't spawn
    
    ld a, [wMistyOverworldStateFlags]
    bit 3, a       ; check if sprite drawing is disabled
    ret nz
    
    ; Calculate new position based on Pikachu's location
    call CalculateMistyPlacementCoords
    
    ; Set Misty's sprite data
    ld a, SPRITE_BRUNETTE_GIRL
    ld [wSpriteMistyStateData1PictureID], a
    
    ; Copy Pikachu's facing direction by default
    ld a, [wSpritePikachuStateData1FacingDirection]
    ld [wMistyFacingDirection], a
    
    ; Set Misty's coordinates
    ld a, [wMistyMapY]
    ld [wSpriteMistyStateData2MapY], a
    ld a, [wMistyMapX]
    ld [wSpriteMistyStateData2MapX], a
    
    ; Initialize movement status
    xor a
    ld [wMistyMovementStatus], a
    
    ; Clear any pending movement commands
    call ClearMistyFollowCommandBuffer
    
    ; Initialize sprite state data
    ld hl, wSpriteMistyStateData1
    call ClearMistySpriteStateData
    ld hl, wSpriteMistyStateData2
    call ClearMistySpriteStateData
    ret

CalculateMistyPlacementCoords::
    ; First get Pikachu's position
    ld a, [wSpritePikachuStateData2MapY]
    ld e, a  ; e = Pikachu's Y
    ld a, [wSpritePikachuStateData2MapX]
    ld d, a  ; d = Pikachu's X
    
    ; Get Pikachu's facing direction to determine where Misty should be
    ld a, [wSpritePikachuStateData1FacingDirection]
    cp SPRITE_FACING_DOWN
    jr z, .below_pikachu
    cp SPRITE_FACING_UP
    jr z, .above_pikachu
    cp SPRITE_FACING_LEFT
    jr z, .left_of_pikachu
    ; must be facing right
    jr .right_of_pikachu

.below_pikachu
    inc e  ; one tile below Pikachu
    jr .load_coords

.above_pikachu
    dec e  ; one tile above Pikachu
    jr .load_coords

.left_of_pikachu
    dec d  ; one tile left of Pikachu
    jr .load_coords

.right_of_pikachu
    inc d  ; one tile right of Pikachu
    ; fallthrough to load_coords

.load_coords
    ld a, e
    ld [wMistyMapY], a
    ld a, d
    ld [wMistyMapX], a
    ret