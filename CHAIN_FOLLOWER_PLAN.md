 Chain Follower System: Misty and Brock

 Overview

 Add Misty and Brock as chain followers behind Pikachu: Player → Pikachu → Misty → Brock

 - Misty follows Pikachu when a story event flag is set
 - Brock follows Misty when player has both Boulder AND Cascade badges

 Sprite Slot Allocation

 Use reserved sprite slots (reducing max map NPCs from 16 to 13):
 - Slot 15: Pikachu (existing)
 - Slot 14: Brock (new)
 - Slot 13: Misty (new)

 Existing overworld sprites to reuse:
 - Misty: SPRITE_BRUNETTE_GIRL ($1d)
 - Brock: SPRITE_SUPER_NERD ($0c)

 ---
 Implementation Steps

 Phase 1: Constants and WRAM

 1.1 Add sprite slot constants

 File: constants/sprite_data_constants.asm
```
 DEF MISTY_FOLLOWER_SPRITE_INDEX EQU 13
 DEF BROCK_FOLLOWER_SPRITE_INDEX EQU 14
 ; PIKACHU_SPRITE_INDEX is already 15
```
 1.2 Reduce MAX_OBJECT_EVENTS

 File: constants/map_data_constants.asm (line 26)
 ```
 DEF MAX_OBJECT_EVENTS EQU 13  ; was 16, reserving 13-15 for followers
```
 1.3 Add event flag for Misty

 File: constants/event_constants.asm (before NUM_EVENTS)
 ```
 const EVENT_MISTY_FOLLOWING_PLAYER
```
 1.4 Add WRAM variables

 File: ram/wram.asm (after line 2071, before wSurfingMinigameHiScore)
 ```
 ; Chain Follower - Misty (follows Pikachu)
 wMistyOverworldStateFlags:: db
 wMistySpawnState:: db
 wMistyFollowCommandBufferSize:: db
 wMistyFollowCommandBuffer:: ds 16  ; 19 bytes total

 ; Chain Follower - Brock (follows Misty)
 wBrockOverworldStateFlags:: db
 wBrockSpawnState:: db
 wBrockFollowCommandBufferSize:: db
 wBrockFollowCommandBuffer:: ds 16  ; 19 bytes total
```
 ---
 Phase 2: Core Follower Logic

 2.1 Create new follower engine file

 File: engine/followers/chain_follow.asm (NEW)

 Key functions to implement:
 - ShouldMistySpawn - Check EVENT_MISTY_FOLLOWING_PLAYER flag + Pikachu visible + not biking/surfing
 - ShouldBrockSpawn - Check both badges + Misty visible + not biking/surfing
 - SpawnMisty_ - Main update handler (adapted from SpawnPikachu_)
 - SpawnBrock_ - Main update handler (adapted from SpawnPikachu_)
 - ComputeMistyFollowCommand - Direction from Misty toward Pikachu
 - ComputeBrockFollowCommand - Direction from Brock toward Misty
 - AppendMistyFollowCommand - Buffer management
 - AppendBrockFollowCommand - Buffer management

```
 Badge check for Brock (from constants/ram_constants.asm):
 ld a, [wObtainedBadges]
 and (1 << BIT_BOULDERBADGE) | (1 << BIT_CASCADEBADGE)
 cp (1 << BIT_BOULDERBADGE) | (1 << BIT_CASCADEBADGE)
```
 ---
 Phase 3: Sprite System Integration

 3.1 Add sprite dispatch

 File: engine/overworld/sprite_collisions.asm (lines 29-31)
```
 Current code:
 cp $f0 ; pikachu
 jp z, SpawnPikachu

 Add after:
 cp $e0 ; brock (slot 14)
 jp z, SpawnBrock
 cp $d0 ; misty (slot 13)
 jp z, SpawnMisty
```
 3.2 Add bank-0 wrappers

 File: home/pikachu.asm (after SpawnPikachu)
 ```
 SpawnMisty::
     ld a, [hl]
     dec a
     swap a
     ldh [hTilePlayerStandingOn], a
     homecall SpawnMisty_
     ret

 SpawnBrock::
     ld a, [hl]
     dec a
     swap a
     ldh [hTilePlayerStandingOn], a
     homecall SpawnBrock_
     ret
```
 ---
 Phase 4: Movement Integration

 4.1 Append follower commands on player movement

 File: home/overworld.asm (find where Func_fcc08 is called for Pikachu)

 After the Pikachu command append, add:
```
 callfar AppendMistyFollowCommand
 callfar AppendBrockFollowCommand
```
 4.2 Handle collision pass-through

 Ensure player can walk through followers (like Pikachu). Modify collision checks to skip slots 13 and 14 when followers are active.

 ---
 Phase 5: Graphics Loading

 5.1 Ensure follower sprites always loaded

 File: engine/overworld/map_sprites.asm

 Modify sprite set loading to reserve slots for follower sprites when they're active. The sprites SPRITE_BRUNETTE_GIRL and SPRITE_SUPER_NERD are common, but we need to guarantee VRAM allocation.

 ---
 Phase 6: Include new files

 6.1 Add to main.asm

 File: main.asm (in "Overworld Pikachu" section)
 ```
 INCLUDE "engine/followers/chain_follow.asm"
```
 ---
 Key Files to Modify

 | File                                   | Changes                               |
 |----------------------------------------|---------------------------------------|
 | constants/sprite_data_constants.asm    | Add MISTY/BROCK_FOLLOWER_SPRITE_INDEX |
 | constants/map_data_constants.asm       | Reduce MAX_OBJECT_EVENTS to 13        |
 | constants/event_constants.asm          | Add EVENT_MISTY_FOLLOWING_PLAYER      |
 | ram/wram.asm                           | Add ~38 bytes for follower state      |
 | engine/overworld/sprite_collisions.asm | Add dispatch for slots 13, 14         |
 | home/pikachu.asm                       | Add SpawnMisty/SpawnBrock wrappers    |
 | home/overworld.asm                     | Add follower command appends          |
 | engine/overworld/map_sprites.asm       | Ensure follower sprite VRAM           |
 | main.asm                               | Include new follower file             |

 New Files to Create

 | File                              | Purpose                           |
 |-----------------------------------|-----------------------------------|
 | engine/followers/chain_follow.asm | All follower spawn/movement logic |

 ---
 Chain Following Logic

 When player moves:
 1. Pikachu computes direction toward player's OLD position → appends to buffer
 2. Misty computes direction toward Pikachu's OLD position → appends to buffer
 3. Brock computes direction toward Misty's OLD position → appends to buffer

 Each frame:
 1. Each follower checks spawn conditions
 2. If spawned, processes command buffer to move
 3. If target despawns, follower also despawns

 ---
 Testing Checklist

 - Misty only appears when EVENT_MISTY_FOLLOWING_PLAYER is set
 - Brock only appears with both badges AND Misty visible
 - Chain maintains proper spacing (1 tile apart)
 - All despawn when biking/surfing
 - Misty despawns when Pikachu goes into Pokeball → Brock also despawns
 - Map transitions preserve chain positions
 - No sprite overlap or flickering
 - Maps with 13+ NPCs identified and fixed (compile will fail on these)