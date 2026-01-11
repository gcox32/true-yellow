# Chain Follower System Documentation

## Overview

The chain follower system allows multiple NPCs (Misty and Brock) to follow the player in a line, with each follower maintaining a specific distance behind the player. The system uses a **position trail** approach that stores where the player was for the last N steps, allowing followers to target specific positions in the trail.

## Architecture

### Position Trail

The core of the system is a position trail that stores the player's previous positions:

```
wPositionTrailY:: ds 4  ; Y coordinates (map Y + 4)
wPositionTrailX:: ds 4  ; X coordinates (map X + 4)
```

The trail has 4 slots:
- **trail[0]**: 1 step behind player → Pikachu's target
- **trail[1]**: 2 steps behind player → Misty's target
- **trail[2]**: 3 steps behind player → Brock's target
- **trail[3]**: 4 steps behind player (spare, for future use)

### Follower Chain

```
Player → Pikachu → Misty → Brock
         trail[0]  trail[1] trail[2]
```

Each follower targets a specific position in the trail, creating a smooth chain where:
- Pikachu follows the player (using trail[0])
- Misty follows Pikachu (using trail[1])
- Brock follows Misty (using trail[2])

## How It Works

### 1. Trail Initialization

When followers are first initialized (e.g., entering a new map or starting to follow), `InitializePositionTrail` is called:

```asm
InitializePositionTrail::
    ; Gets player's current position and facing direction
    ; Creates a line of positions extending behind the player
    ; Each trail slot is one step further behind
```

The trail is initialized based on the player's facing direction:
- If player faces **DOWN**, positions are above (Y-1, Y-2, Y-3, Y-4)
- If player faces **UP**, positions are below (Y+1, Y+2, Y+3, Y+4)
- If player faces **LEFT**, positions are to the right (X+1, X+2, X+3, X+4)
- If player faces **RIGHT**, positions are to the left (X-1, X-2, X-3, X-4)

### 2. Trail Updates

When the player moves, `RecordPlayerPositionToTrail` is called (should be called from the player movement code):

```asm
RecordPlayerPositionToTrail::
    ; Input: b = old Y position, c = old X position
    ; Shifts trail: [3] <- [2] <- [1] <- [0]
    ; Stores new position at trail[0]
```

The trail acts like a shift register:
1. All entries shift forward: `trail[3] ← trail[2] ← trail[1] ← trail[0]`
2. The player's previous position is stored at `trail[0]`
3. This creates a "breadcrumb trail" of where the player was

**Note**: This function should be called **before** the player's position is updated, or with the old position as input.

### 3. Follower Movement Logic

Each follower checks their target position every frame and moves toward it if needed.

#### Idle State (`UpdateMistyIdleState` / `UpdateBrockIdleState`)

1. **Get target position** from the trail:
   - Misty reads `trail[1]`
   - Brock reads `trail[2]`

2. **Compare current position to target**:
   - If at target: stay idle, update screen position for scrolling
   - If not at target: start walking

3. **Calculate movement direction**:
   - Compare Y coordinates first
   - If Y matches, compare X coordinates
   - Determine which direction to move (up/down/left/right)

4. **Calculate walking speed**:
   - Manhattan distance = |target.Y - current.Y| + |target.X - current.X|
   - If distance ≥ 2: fast walking (status 5, 4 frames, 4 pixels/frame)
   - If distance = 1: normal walking (status 3, 8 frames, 2 pixels/frame)

5. **Start walking**:
   - Set facing direction
   - Set movement status (3 or 5)
   - Set walk animation counter
   - Set step vectors
   - **Update screen position immediately** (critical fix - see below)

#### Walking State (`UpdateMistyWalking` / `UpdateBrockWalking`)

1. **Decrement walk counter** each frame

2. **Update animation frame**:
   - Frames 8-5: walking frame 1
   - Frames 4-1: walking frame 2

3. **Update screen position**:
   - Normal walk: 2 pixels per frame
   - Fast walk: 4 pixels per frame (call update twice)

4. **When walk completes**:
   - Update map position (move to new tile)
   - Clear step vectors
   - Reset animation frame
   - Return to idle state
   - **Immediately check for next movement** (no 1-frame delay)

## Critical Fix: 1-Frame Delay Elimination

### The Problem

Originally, when a follower decided to start walking:
1. Frame N: Set up walk state (status, counter, step vectors) but **don't move**
2. Frame N+1: Start moving (update screen position)

This created a 1-frame delay per step that accumulated, causing followers to lag behind.

### The Solution

When starting a walk, immediately update the screen position on the same frame:

```asm
.doStepMisty
    call SetMistyStepVector
    
    ; Update screen position immediately on first frame
    ; Check if fast or normal walking
    ld a, [wSpriteMistyStateData1MovementStatus]
    and $7f
    cp 5
    jr z, .fastWalkFirstFrame
    call UpdateMistyScreenPosition
    jr .updateSpriteFirstFrame
.fastWalkFirstFrame
    call UpdateMistyScreenPosition
    call UpdateMistyScreenPosition  ; Fast = 4 pixels
.updateSpriteFirstFrame
    call UpdateMistyWalkingSprite
    ret
```

This ensures:
- Movement starts immediately when the decision is made
- No accumulated lag
- Followers stay perfectly in sync with their targets

## Walking Mechanics

### Step Vectors

Step vectors define the direction of movement:
- `YStepVector`: -1 (up), 0 (horizontal), or +1 (down)
- `XStepVector`: -1 (left), 0 (vertical), or +1 (right)

These are set by `SetMistyStepVector` / `SetBrockStepVector` based on facing direction.

### Screen Position Updates

Screen position is updated incrementally during walking:
- **Normal walk**: 2 pixels per frame × 8 frames = 16 pixels (1 tile)
- **Fast walk**: 4 pixels per frame × 4 frames = 16 pixels (1 tile)

Both speeds cover the same distance (1 tile) but at different rates.

### Map Position Updates

Map position is only updated when the walk completes:
- After all animation frames are done
- Sprite has visually moved to the new tile
- Map coordinates are updated to match screen position

## Initialization

### Misty

```asm
InitializeMistyFollower::
    ; 1. Initialize position trail
    call InitializePositionTrail
    
    ; 2. Clear state data
    ; 3. Set sprite picture ID and VRAM slot
    ; 4. Initialize position from trail[1]
    call InitializeMistyPosition
    ; 5. Set up sprite image
```

### Brock

Brock follows the same pattern but:
- Requires both Boulder and Cascade badges
- Requires Misty to be spawned
- Targets `trail[2]`

## Spawn Conditions

### Misty

- `EVENT_MISTY_FOLLOWING_PLAYER` flag is set
- Pikachu is visible/spawned
- Not biking or surfing
- Not hidden by state flags

### Brock

- Has both Boulder and Cascade badges
- Misty is visible/spawned
- Not biking or surfing
- Not hidden by state flags

## Integration Points

### Player Movement

The trail should be updated when the player moves. Add a call to `RecordPlayerPositionToTrail` in the player movement code:

```asm
; When player completes a step:
ld a, [wYCoord]
add 4
ld b, a
ld a, [wXCoord]
add 4
ld c, a
farcall RecordPlayerPositionToTrail
```

### Sprite System

Followers are spawned through the unified dispatcher:
- Sprite slot $f0 → Pikachu
- Sprite slot $e0 → Brock
- Sprite slot $d0 → Misty

Each follower has its own VRAM slot:
- Player: slot 1
- Pikachu: slot 2
- Misty: slot 3
- Brock: slot 4

## Performance Characteristics

- **Smooth following**: No lag, followers stay exactly N steps behind
- **Fast response**: Immediate movement when target changes
- **Efficient**: Simple position comparisons, no complex pathfinding
- **Scalable**: Easy to add more followers (just use trail[3], trail[4], etc.)

## Future Enhancements

Potential improvements:
- Use trail[3] for a fourth follower
- Add diagonal movement support
- Implement collision detection between followers
- Add follower-specific behaviors (e.g., Brock stops at certain tiles)

## Code Locations

- **Main implementation**: `engine/followers/chain_follow.asm`
- **Position trail variables**: `ram/wram.asm` (wPositionTrailY, wPositionTrailX)
- **Sprite constants**: `constants/sprite_constants.asm`
- **Event flags**: `constants/event_constants.asm`

