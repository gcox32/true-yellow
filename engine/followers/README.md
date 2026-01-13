# Chain Follower System

This directory contains the implementation of the chain follower system, which allows Misty and Brock to follow the player alongside Pikachu. This is the core unique feature of True Yellow.

## Overview

The follower system extends Pokemon Yellow's existing Pikachu follow mechanic to support multiple followers walking in a chain behind the player. The implementation uses a **position trail** approach rather than command buffering, which provides smoother movement and simpler synchronization.

```
[Brock] -> [Misty] -> [Pikachu] -> [Player]
   ^          ^          ^
trail[2]   trail[1]   trail[0]
```

## Architecture

### Position Trail System

Instead of having followers mirror player commands (move up, move down, etc.), we record where the player has been and have each follower walk toward their target position in that history.

**Key insight**: When the player moves, their old position becomes Pikachu's target. Pikachu's old position becomes Misty's target. And so on down the chain.

The position trail is a 4-entry circular buffer stored in WRAM:
- `wPositionTrailY[0-3]` - Y coordinates (map coords + 4)
- `wPositionTrailX[0-3]` - X coordinates (map coords + 4)
- `wMovementTypeTrail[0-3]` - Movement type (0=walk, 1=jump/hop)

When the player completes a step, `RecordPlayerPositionToTrail` shifts the trail and records the player's previous position at trail[0].

```asm
RecordPlayerPositionToTrail::
	; Shift trail entries: [3] <- [2] <- [1] <- [0]
	ld a, [wPositionTrailY + 2]
	ld [wPositionTrailY + 3], a
	ld a, [wPositionTrailX + 2]
	ld [wPositionTrailX + 3], a
	ld a, [wMovementTypeTrail + 2]
	ld [wMovementTypeTrail + 3], a

	ld a, [wPositionTrailY + 1]
	ld [wPositionTrailY + 2], a
	ld a, [wPositionTrailX + 1]
	ld [wPositionTrailX + 2], a
	ld a, [wMovementTypeTrail + 1]
	ld [wMovementTypeTrail + 2], a

	ld a, [wPositionTrailY + 0]
	ld [wPositionTrailY + 1], a
	ld a, [wPositionTrailX + 0]
	ld [wPositionTrailX + 1], a
	ld a, [wMovementTypeTrail + 0]
	ld [wMovementTypeTrail + 1], a

	; Store new position at trail[0]
	ld a, b
	ld [wPositionTrailY + 0], a
	ld a, c
	ld [wPositionTrailX + 0], a

	; Store movement type (0=walk, 1=jump)
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	ld a, 0
	jr z, .notJumping
	ld a, 1
.notJumping
	ld [wMovementTypeTrail + 0], a
	ret
```

This creates a "breadcrumb trail" where each follower can read where they should be from their assigned trail index.

### Follower Targets

Each follower targets a specific trail index:
- **Pikachu**: trail[0] (1 step behind player) - handled by existing `pikachu_follow.asm`
- **Misty**: trail[1] (2 steps behind player)
- **Brock**: trail[2] (3 steps behind player)

### Spawn Conditions

Each follower has specific conditions that must be met to appear:

**Misty** (`ShouldMistySpawn`):
1. Not in exit doorway mode 2 or 3 (delayed spawn after exiting buildings)
2. `wMistyOverworldStateFlags` bits 5 and 7 not set
3. Not in Cerulean Gym before beating Misty (gym leader Misty takes priority)
4. `EVENT_MISTY_FOLLOWING_PLAYER` flag is set
5. Not biking or surfing (`wWalkBikeSurfState` == 0)

**Brock** (`ShouldBrockSpawn`):
1. Not in exit doorway mode 2, 3, or 4
2. `wBrockOverworldStateFlags` bits 5 and 7 not set
3. Has Boulder Badge
4. Pikachu is spawned (movement status != 0)
5. Not biking or surfing (`wWalkBikeSurfState` == 0)

### Movement States

Followers use movement status values to track their current state:
- **Status 0**: Inactive/hidden
- **Status 1**: Idle, ready to move
- **Status 3**: Normal walking (8 frames, 2 pixels/frame = 16 pixels total)
- **Status 5**: Fast walking (4 frames, 4 pixels/frame = 16 pixels total)
- **Status 6**: Hopping/ledge jump (16 frames with arc)

**Speed adaptation**: When a follower falls behind (Manhattan distance >= 2 tiles from target), they switch to fast walking to catch up. This prevents the chain from stretching during rapid movement.

```asm
UpdateMistyIdleState:
	; Get target position from trail[1]
	ld a, [wPositionTrailY + 1]
	ld b, a  ; b = target Y
	ld a, [wPositionTrailX + 1]
	ld c, a  ; c = target X

	; Get Misty's current position
	ld a, [wSpriteMistyStateData2MapY]
	ld d, a  ; d = current Y
	ld a, [wSpriteMistyStateData2MapX]
	ld e, a  ; e = current X

	; Compare Y coordinates
	ld a, d
	cp b
	jr z, .checkX
	jr c, .moveDown   ; current Y < target Y, need to move down
	jr .moveUp        ; current Y > target Y, need to move up

.checkX
	; Y coordinates match, check X
	ld a, e
	cp c
	jr z, .atTarget   ; both match, at target
	jr c, .moveRight  ; current X < target X, need to move right
	jr .moveLeft      ; current X > target X, need to move left

.moveDown
	ld a, SPRITE_FACING_DOWN
	jr .startWalk
.moveUp
	ld a, SPRITE_FACING_UP
	jr .startWalk
.moveLeft
	ld a, SPRITE_FACING_LEFT
	jr .startWalk
.moveRight
	ld a, SPRITE_FACING_RIGHT

.startWalk
	; Set facing direction
	ld [wSpriteMistyStateData1FacingDirection], a

	; Calculate Manhattan distance to decide speed
	; d=current Y, e=current X, b=target Y, c=target X (still in registers)
	push bc
	; |target.Y - current.Y|
	ld a, b
	sub d
	jr nc, .yPosMisty
	cpl
	inc a
.yPosMisty
	ld h, a  ; h = |Y distance|
	; |target.X - current.X|
	ld a, c
	sub e
	jr nc, .xPosMisty
	cpl
	inc a
.xPosMisty
	add h  ; a = Manhattan distance
	pop bc

	; If distance >= 2, use fast walking (status 5, 4 frames)
	cp 2
	jr c, .normalWalkMisty

	; Fast walking
	ld a, 5
	ld [wSpriteMistyStateData1MovementStatus], a
	ld a, 4
	ld [wSpriteMistyStateData2WalkAnimationCounter], a
	jr .doStepMisty

.normalWalkMisty
	; Normal walking (status 3, 8 frames)
	ld a, 3
	ld [wSpriteMistyStateData1MovementStatus], a
	ld a, 8
	ld [wSpriteMistyStateData2WalkAnimationCounter], a
```

This shows how followers continuously check their target position, determine movement direction, and adapt their speed to maintain proper spacing.

## Special Behaviors

### Doorway Transitions

Entering and exiting buildings requires special handling to prevent followers from appearing inside walls or overlapping each other.

**Entering buildings** (`wFollowerDoorwayMode = 1`):
- Position trail is initialized with horizontal positions
- Arrangement: `[Brock] - [Player] - [Pikachu] - [Misty]`
- Followers stand to the sides of the player rather than behind

**Exiting buildings** (`wFollowerDoorwayMode = 2, 3, 4`):
- Followers spawn delayed, one per step taken
- Mode 2: All followers hidden, door position stored
- Mode 3: Pikachu can spawn at door, Misty/Brock still hidden
- Mode 4: Misty can spawn at door, Brock still hidden
- Mode 0: All followers can spawn normally

### Ledge Jumping

When the player jumps a ledge, followers perform synchronized hops:
1. `BIT_LEDGE_OR_FISHING` is set in `wMovementFlags` during the jump
2. `RecordPlayerPositionToTrail` detects this and stores movement type 1 (jump)
3. When a follower reads a jump from their trail position, they enter hop state
4. `FollowerHopArc` table provides Y pixel offsets for smooth arc animation

The hop arc spans 16 frames:
```
Frame:    0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
Y offset: 0 -2 -4 -5 -6 -6 -6 -5 -4 -3 -2 -1  0  0  0  0
```

### Spinning Tiles

When the player hits a spinning tile:
1. `BIT_SPINNING` is set in `wMovementFlags`
2. `UpdateMistyWalkingSprite` and `UpdateBrockWalkingSprite` detect this
3. Instead of using their own facing direction, followers copy the player's sprite animation
4. This creates synchronized spinning for the entire party

### Surfing and Biking

When the player surfs or bikes:
1. `wWalkBikeSurfState` is set to 2 (surfing) or 1 (biking)
2. `ShouldMistySpawn` and `ShouldBrockSpawn` check this value
3. Followers are hidden (ImageIndex = $ff, MovementStatus = 0)
4. When player returns to walking (state = 0), followers respawn via `InitializePositionTrail`

### Fishing

Fishing does NOT hide followers:
- The fishing code temporarily sets `wWalkBikeSurfState` to 0 during the animation
- `BIT_LEDGE_OR_FISHING` is set but followers don't check this for visibility
- Followers remain visible but frozen in place during fishing

## Interaction System

Players can talk to followers by pressing A while facing them.

**Detection** (`IsPlayerTalkingToFollower`):
1. Check if sprite interaction is with follower slot (Misty = $D, Brock = $E)
2. Call appropriate dialogue function
3. Clear interaction state to prevent normal text processing

**Dialogue display**:
1. Make follower face the player (opposite of player's facing direction)
2. Set up text box via `DisplayTextIDInit`
3. Display text from `MistyFollowerText` or `BrockFollowerText`
4. Wait for button press
5. Clean up via `CleanupFollowerTextBox` (restore sprites, reload graphics)

Text content is stored in `text/follower_text.asm` and can be customized based on game progress, current map, etc.

## WRAM Variables

### Position Trail
| Variable | Size | Description |
|----------|------|-------------|
| `wPositionTrailY` | 4 bytes | Y coordinates for trail positions |
| `wPositionTrailX` | 4 bytes | X coordinates for trail positions |
| `wMovementTypeTrail` | 4 bytes | Movement type (0=walk, 1=jump) |

### Doorway Management
| Variable | Size | Description |
|----------|------|-------------|
| `wFollowerDoorwayMode` | 1 byte | Current doorway transition mode (0-4) |
| `wExitDoorwayY` | 1 byte | Stored door Y position for delayed spawn |
| `wExitDoorwayX` | 1 byte | Stored door X position for delayed spawn |

### Follower State Flags
| Variable | Size | Description |
|----------|------|-------------|
| `wMistyOverworldStateFlags` | 1 byte | Bit 5/7: hide Misty |
| `wBrockOverworldStateFlags` | 1 byte | Bit 5/7: hide Brock |

### Sprite State Data
Each follower uses standard sprite state data structures:
- `wSpriteMistyStateData1` / `wSpriteMistyStateData2` (16 bytes each)
- `wSpriteBrockStateData1` / `wSpriteBrockStateData2` (16 bytes each)

Key fields:
- `MovementStatus` - Current movement state (0, 1, 3, 5, 6)
- `ImageIndex` - Sprite tile index ($ff = hidden)
- `FacingDirection` - Current facing (0=down, 4=up, 8=left, $C=right)
- `MapY/MapX` - Position in map coordinates
- `YPixels/XPixels` - Screen pixel position
- `YStepVector/XStepVector` - Movement direction (-1, 0, or 1)
- `WalkAnimationCounter` - Frames remaining in current movement

## Integration Points

### Home Bank (`home/pikachu.asm`)
- `SpawnFollower_` dispatch called during sprite processing
- Routes to appropriate spawn function based on `hCurrentSpriteOffset`

### Sprite Processing (`engine/overworld/update_sprites.asm`)
- Followers are processed as sprites $D (Misty) and $E (Brock)
- Standard sprite update loop calls their spawn functions

### Map Loading
- `InitializePositionTrail` called when entering new maps
- Position trail seeded based on player position and facing direction

### Player Movement (`engine/overworld/player_movement.asm`)
- `RecordPlayerPositionToTrail` called when player completes a step
- Handles doorway mode advancement

The trail is updated from `engine/pikachu/pikachu_follow.asm`:

```asm
Func_fcc08::
	; Record player's current position to trail (for Misty/Brock followers)
	; Must do this before player moves, so their current position becomes trail history
	ld a, [wYCoord]
	add 4
	ld b, a
	ld a, [wXCoord]
	add 4
	ld c, a
	call RecordPlayerPositionToTrail
	; ... rest of Pikachu follow logic ...
```

This ensures the trail is updated every time the player moves, providing fresh position data for all followers.

### Item Effects (`engine/items/item_effects.asm`)
- Surfboard/bicycle code sets `wWalkBikeSurfState`
- Followers automatically hide/show based on this state

## Sprite Set Modifications

Adding two new follower sprites to every map required removing sprites from each sprite set. See `SPRITE_SET_ANALYSIS.md` for the detailed analysis of which sprites were removed and why.

Key constraints:
- Each sprite set has an 11-slot limit
- Slot 0: Pikachu (existing)
- Slot 1: Misty (new)
- Slot 2: Brock (new)
- Slots 3-10: Map-specific NPCs

## Files

| File | Purpose |
|------|---------|
| `chain_follow.asm` | Main follower implementation |
| `README.md` | This documentation |
| `TODO.md` | Development task tracking |
| `SPRITE_SET_ANALYSIS.md` | Sprite set modification analysis |

## Future Enhancements

Potential improvements for future development:
- Followers riding bikes alongside player
- Context-aware dialogue based on current map/game progress
