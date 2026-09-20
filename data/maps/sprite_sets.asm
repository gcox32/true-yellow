; Valid sprite IDs for each outdoor map.

MapSpriteSets:
	table_width 1
	db SPRITESET_PALLET_VIRIDIAN ; PALLET_TOWN
	db SPRITESET_PALLET_VIRIDIAN ; VIRIDIAN_CITY
	db SPRITESET_PEWTER_CERULEAN ; PEWTER_CITY
	db SPRITESET_CERULEAN_CITY   ; CERULEAN_CITY
	db SPRITESET_LAVENDER        ; LAVENDER_TOWN
	db SPRITESET_VERMILION_CITY  ; VERMILION_CITY
	db SPRITESET_CELADON         ; CELADON_CITY
	db SPRITESET_FUCHSIA         ; FUCHSIA_CITY
	db SPRITESET_PALLET_VIRIDIAN ; CINNABAR_ISLAND
	db SPRITESET_INDIGO          ; INDIGO_PLATEAU
	db SPRITESET_SAFFRON         ; SAFFRON_CITY
	db SPRITESET_PALLET_VIRIDIAN ; UNUSED_MAP_0B
	db SPRITESET_PALLET_VIRIDIAN ; ROUTE_1
	db SPLITSET_ROUTE_2          ; ROUTE_2
	db SPRITESET_PEWTER_CERULEAN ; ROUTE_3
	db SPRITESET_PEWTER_CERULEAN ; ROUTE_4
	db SPLITSET_ROUTE_5          ; ROUTE_5
	db SPLITSET_ROUTE_6          ; ROUTE_6
	db SPLITSET_ROUTE_7          ; ROUTE_7
	db SPLITSET_ROUTE_8          ; ROUTE_8
	db SPRITESET_PEWTER_CERULEAN ; ROUTE_9
	db SPLITSET_ROUTE_10         ; ROUTE_10
	db SPLITSET_ROUTE_11         ; ROUTE_11
	db SPLITSET_ROUTE_12         ; ROUTE_12
	db SPRITESET_SILENCE_BRIDGE  ; ROUTE_13
	db SPRITESET_SILENCE_BRIDGE  ; ROUTE_14
	db SPLITSET_ROUTE_15         ; ROUTE_15
	db SPLITSET_ROUTE_16         ; ROUTE_16
	db SPRITESET_CYCLING_ROAD    ; ROUTE_17
	db SPLITSET_ROUTE_18         ; ROUTE_18
	db SPRITESET_FUCHSIA         ; ROUTE_19
	db SPLITSET_ROUTE_20         ; ROUTE_20
	db SPRITESET_SEA_ROUTES      ; ROUTE_21
	db SPRITESET_PALLET_VIRIDIAN ; ROUTE_22
	db SPRITESET_INDIGO          ; ROUTE_23
	db SPRITESET_PEWTER_CERULEAN ; ROUTE_24
	db SPRITESET_PEWTER_CERULEAN ; ROUTE_25
	assert_table_length FIRST_INDOOR_MAP

; Format:
; #1: whether the map is split EAST_WEST or NORTH_SOUTH
; #2: coordinate of dividing line
; #3: sprite set ID if on the west or north side
; #4: sprite set ID if on the east or south side
SplitMapSpriteSets:
	table_width 4
	db NORTH_SOUTH, 37, SPRITESET_PEWTER_CERULEAN, SPRITESET_PALLET_VIRIDIAN ; SPLITSET_ROUTE_2
	db NORTH_SOUTH, 50, SPRITESET_PEWTER_CERULEAN, SPRITESET_LAVENDER        ; SPLITSET_ROUTE_10
	db EAST_WEST,   57, SPRITESET_VERMILION,       SPRITESET_SILENCE_BRIDGE  ; SPLITSET_ROUTE_11
	db NORTH_SOUTH, 21, SPRITESET_LAVENDER,        SPRITESET_SILENCE_BRIDGE  ; SPLITSET_ROUTE_12
	db EAST_WEST,    8, SPRITESET_FUCHSIA,         SPRITESET_SILENCE_BRIDGE  ; SPLITSET_ROUTE_15
	db EAST_WEST,   24, SPRITESET_CYCLING_ROAD,    SPRITESET_CELADON         ; SPLITSET_ROUTE_16
	db EAST_WEST,   34, SPRITESET_CYCLING_ROAD,    SPRITESET_FUCHSIA         ; SPLITSET_ROUTE_18
	db EAST_WEST,   53, SPRITESET_PALLET_VIRIDIAN, SPRITESET_FUCHSIA         ; SPLITSET_ROUTE_20
	db NORTH_SOUTH, 33, SPRITESET_PEWTER_CERULEAN, SPRITESET_SAFFRON         ; SPLITSET_ROUTE_5
	db NORTH_SOUTH,  2, SPRITESET_SAFFRON,         SPRITESET_VERMILION       ; SPLITSET_ROUTE_6
	db EAST_WEST,   17, SPRITESET_CELADON,         SPRITESET_SAFFRON         ; SPLITSET_ROUTE_7
	db EAST_WEST,    3, SPRITESET_SAFFRON,         SPRITESET_LAVENDER        ; SPLITSET_ROUTE_8
	assert_table_length NUM_SPLIT_SETS

SpriteSets:
	table_width SPRITE_SET_LENGTH

; SPRITESET_PALLET_VIRIDIAN
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_BLUE
	db SPRITE_YOUNGSTER
	; db SPRITE_BRUNETTE_GIRL
	db SPRITE_FISHER
	; db SPRITE_COOLTRAINER_M
	db SPRITE_GAMBLER
	db SPRITE_GIRL          ; swapped with OAK: WALK/STAY RIGHT in this region (needs non-DOWN facing)
	db SPRITE_OAK           ; slot $0A: STAY NONE in this region (safe)
	db SPRITE_POKE_BALL
	db SPRITE_GAMBLER_ASLEEP

; SPRITESET_PEWTER_CERULEAN
; Pewter City and Routes 3/4/9/24/25 only - Cerulean City has its own set now
; (SPRITESET_CERULEAN_CITY). Officer Jenny is a full 12-tile sprite and can
; never safely occupy a still (4-tile) slot even STAY DOWN-only: the tile
; loader copies her full graphic regardless of slot size, overflowing past
; the end of vChars0 into the player's own walking-frame tiles in vChars1.
; That's what was corrupting the player's sprite while walking near
; Cerulean/Pewter/Routes 3-4/9/24-25 - fixed by dropping her from this
; shared set entirely (she's unused outside Cerulean City anyway).
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_YOUNGSTER
	db SPRITE_ROCKET
	db SPRITE_SUPER_NERD
	db SPRITE_HIKER
	db SPRITE_COOLTRAINER_F ; slot $09 (facing), needs non-DOWN facing
	db SPRITE_BLUE          ; slot $0A: needs to walk on Cerulean bridge (must be in walking slot)
	db SPRITE_FOSSIL        ; slot $0B: unused here (still slot; must be a genuine 4-tile sprite)
	; db SPRITE_COOLTRAINER_M
	db SPRITE_POKE_BALL
	; db SPRITE_UNUSED_GAMBLER_ASLEEP_2

; SPRITESET_LAVENDER
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_LITTLE_GIRL
	db SPRITE_COOLTRAINER_F ; swapped: trainer on Route 10/13 (needs non-DOWN facing)
	db SPRITE_SUPER_NERD
	db SPRITE_HIKER
	db SPRITE_COOLTRAINER_M ; swapped: trainer on Route 13/14 (needs non-DOWN facing)
	; db SPRITE_MONSTER
	db SPRITE_GAMBLER       ; slot $0A: not used in this region (safe)
; slot $0B is a 4-tile still slot: SPRITE_GIRL was here, and although nothing
; in this region references her, the tile loader copies every slot's full
; declared graphic regardless - her 12 tiles overflowed the end of vChars0
; into the player's own walking frames. Replaced with a genuine 4-tile
; sprite; nothing visible changes, since neither is used here.
	db SPRITE_FOSSIL        ; slot $0B: not used in this region (still slot)
	db SPRITE_POKE_BALL
	; db SPRITE_UNUSED_GAMBLER_ASLEEP_2

; SPRITESET_VERMILION
; Route 6 (south half) and Route 11 (west half) only - Vermilion City has its
; own set now (SPRITESET_VERMILION_CITY). Only 4 walking NPCs are used here
; (COOLTRAINER_F, SUPER_NERD, YOUNGSTER, GAMBLER), all in full-facing slots.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_COOLTRAINER_F ; trainer on Route 6 (needs non-DOWN facing)
	db SPRITE_SUPER_NERD    ; trainer on Route 6/11 (needs non-DOWN facing)
	db SPRITE_YOUNGSTER     ; trainer on Route 11 (needs non-DOWN facing)
	db SPRITE_GAMBLER       ; trainer on Route 11 (needs non-DOWN facing)
	db SPRITE_MONSTER       ; unused here
	db SPRITE_SAILOR        ; unused here
	db SPRITE_FOSSIL        ; slot $0B: unused here (still slot; must be a genuine 4-tile sprite - see below)
	; db SPRITE_COOLTRAINER_M
	db SPRITE_POKE_BALL
	; db SPRITE_UNUSED_GAMBLER_ASLEEP_2

; SPRITESET_CELADON
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_ROCKET        ; moved to front: walking trainer in Celadon (needs non-DOWN facing)
	; db SPRITE_LITTLE_BOY
	db SPRITE_LITTLE_GIRL
	db SPRITE_GIRL
	db SPRITE_FISHER
	; db SPRITE_MIDDLE_AGED_MAN
	db SPRITE_GRAMPS
	db SPRITE_MONSTER       ; slot $0A: STAY RIGHT in Celadon (broken, unavoidable - no safe candidates remain)
	db SPRITE_POKE_BALL
	db SPRITE_SNORLAX

; SPRITESET_INDIGO
; Route 23 and Indigo Plateau. Between them they use exactly two sprites -
; the badge checkers (GUARD) and the swimmers on Route 23; Indigo Plateau has
; no object events at all - so every other slot here is free filler.
;
; Two things follow from that. SPRITE_GAMBLER used to sit in still slot $0B
; (index 9), which is a 4-tile slot: a 12-tile person sprite there overflows
; past the end of vChars0 into the player's own walking frames, corrupting
; the player sprite around Route 23 (the same bug Officer Jenny caused in
; SPRITESET_PEWTER_CERULEAN). And Route 23's only outside connection is to
; Route 22, which is SPRITESET_PALLET_VIRIDIAN - a different set, so crossing
; there reloaded all 11 VRAM slots, ~38 frames of frozen overworld.
;
; Both are fixed by filling the free slots with whatever
; SPRITESET_PALLET_VIRIDIAN has in them: the still slots end up holding
; genuine 4-tile sprites, and only the two slots Route 23 actually needs
; differ, so the Route 22 <-> 23 crossing reloads 2 slots instead of 11.
; Keep this aligned if either set is ever reordered.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_BLUE           ; unused here; matches SPRITESET_PALLET_VIRIDIAN
	db SPRITE_YOUNGSTER      ; unused here; matches
	db SPRITE_FISHER         ; unused here; matches
	db SPRITE_GAMBLER        ; unused here; matches
	db SPRITE_SWIMMER        ; Route 23 - differs from PALLET_VIRIDIAN's GIRL
	db SPRITE_GUARD          ; Route 23 badge checkers - differs from its OAK
	db SPRITE_POKE_BALL      ; slot $0B: still slot, genuine 4-tile sprite
	db SPRITE_GAMBLER_ASLEEP ; slot $0C: still slot (4 tiles); matches

; SPRITESET_SAFFRON
; Saffron City, plus the halves of Routes 5/6/7/8 that border it (those halves
; reference none of these themselves). Saffron needs six 12-tile NPC sprites
; and there are exactly six walking slots, so slots $0B/$0C must both hold
; genuine 4-tile sprites. SPRITE_GENTLEMAN used to sit in $0B, marked "STAY
; DOWN (safe)" - it is not safe: the tile loader copies a sprite's full
; declared graphic whatever the slot's size, so his 12 tiles overflowed the
; end of vChars0 into the player's own walking frames, corrupting the player
; sprite here and along those route halves.
;
; It only fits because the seventh sprite, SPRITE_ROCKER, is gone: the rocker
; at (18,8) was reskinned to SILPH_WORKER_M, which suits his line about
; watching the ROCKET BOSS flee the SILPH building. He cost the least of the
; seven - he is also object #13, the struct Misty takes over whenever she is
; following, so he was already being replaced by her in practice.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_ROCKET         ; 8 of them pre-Silph (missable objects)
	db SPRITE_SCIENTIST
	db SPRITE_SILPH_WORKER_M ; also the reskinned rocker
	db SPRITE_SILPH_WORKER_F
	db SPRITE_GENTLEMAN      ; the Pidgeot's owner - needs a real walking slot
	db SPRITE_BIRD           ; slot $0A: his Pidgeot, STAY DOWN
	; db SPRITE_COOLTRAINER_M
	db SPRITE_FOSSIL         ; slot $0B: unused here (still slot, 4 tiles)
	db SPRITE_POKE_BALL      ; slot $0C: unused here (still slot, 4 tiles)
	; db SPRITE_UNUSED_GAMBLER_ASLEEP_2

; SPRITESET_SILENCE_BRIDGE
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_BIKER
	db SPRITE_SUPER_NERD
	; db SPRITE_MIDDLE_AGED_MAN
	db SPRITE_COOLTRAINER_F
	db SPRITE_COOLTRAINER_M
	db SPRITE_BEAUTY
	db SPRITE_FISHER
	; db SPRITE_ROCKER
	db SPRITE_POKE_BALL
	db SPRITE_SNORLAX

; SPRITESET_CYCLING_ROAD
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_BIKER
	db SPRITE_COOLTRAINER_M
	; db SPRITE_SILPH_WORKER_M
	db SPRITE_FISHER
	db SPRITE_ROCKER
	db SPRITE_HIKER
	db SPRITE_GAMBLER
	; db SPRITE_MIDDLE_AGED_MAN
	db SPRITE_POKE_BALL
	db SPRITE_SNORLAX

; SPRITESET_FUCHSIA
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_COOLTRAINER_M
	; db SPRITE_CHANSEY
	db SPRITE_YOUNGSTER     ; swapped: WALK/STAY UP in Fuchsia (needs non-DOWN facing)
	db SPRITE_GAMBLER
	db SPRITE_MONSTER
	; db SPRITE_SEEL
	db SPRITE_SWIMMER
	db SPRITE_FISHER        ; slot $0A: STAY DOWN in Fuchsia City (safe)
	db SPRITE_POKE_BALL
	db SPRITE_FOSSIL

; SPRITESET_VERMILION_CITY
; Vermilion City only (Routes 6 & 11 use SPRITESET_VERMILION). Only 5 walking
; NPCs spawn here, so each one gets a full-facing slot ($05-$09) - in
; particular Officer Jenny can now turn to face the player, and the dock
; sailor can face UP toward the gangway.
;
; Kept slot-for-slot identical to SPRITESET_VERMILION except for the one
; entry that genuinely has to change (Officer Jenny replacing the routes'
; Super Nerd). Walking in from Route 6 or Route 11 changes the sprite set
; mid-step with the player in control, and InitOutsideMapSprites reloads
; sprite tile patterns a vblank-paced 8 tiles at a time - reloading all 11
; slots costs ~38 frames of frozen overworld. With the sets aligned,
; LoadChangedMapSpriteTilePatterns (engine/overworld/map_sprites.asm) only
; has to redo the single slot that differs, so keep the shared entries in
; the same positions in both sets. The unused slots are deliberately filled
; with whatever SPRITESET_VERMILION has there for the same reason.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_COOLTRAINER_F ; beauty: WALK LEFT_RIGHT
	db SPRITE_OFFICER_JENNY ; STAY NONE (turns to face player) - the one slot
	                        ; that differs from SPRITESET_VERMILION
	db SPRITE_YOUNGSTER     ; unused here; matches SPRITESET_VERMILION
	db SPRITE_GAMBLER       ; STAY NONE x2 (turns to face player)
	db SPRITE_MONSTER       ; machop: WALK UP_DOWN
	db SPRITE_SAILOR        ; STAY UP + WALK LEFT_RIGHT
	db SPRITE_FOSSIL        ; slot $0B: unused here (still slot)
	db SPRITE_POKE_BALL     ; slot $0C: unused here (still slot)

; SPRITESET_CERULEAN_CITY
; Cerulean City only (Pewter City and Routes 3/4/9/24/25 use
; SPRITESET_PEWTER_CERULEAN). Only 5 walking NPCs spawn here, so each one
; gets a full-facing slot - in particular Officer Jenny is no longer a
; 12-tile sprite jammed into a 4-tile still slot, which was overflowing into
; the player's own walking-frame tiles in vChars1.
;
; Kept slot-for-slot identical to SPRITESET_PEWTER_CERULEAN except for the
; one entry that genuinely has to change (Officer Jenny replacing the
; routes' Hiker), so that walking in from Route 4/5/9/24 only reloads that
; one slot's tile patterns - see the matching note on
; SPRITESET_VERMILION_CITY above.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_YOUNGSTER     ; unused here; matches SPRITESET_PEWTER_CERULEAN
	db SPRITE_ROCKET        ; STAY NONE (turns to face player)
	db SPRITE_SUPER_NERD    ; WALK UP_DOWN / WALK LEFT_RIGHT / STAY DOWN (must be in walking slot)
	db SPRITE_OFFICER_JENNY ; STAY DOWN x2 (now safe: full slot, no VRAM
	                        ; overflow) - the one slot that differs from
	                        ; SPRITESET_PEWTER_CERULEAN
	db SPRITE_COOLTRAINER_F ; STAY LEFT (needs non-DOWN facing)
	db SPRITE_BLUE          ; rival: STAY DOWN (12-tile, needs a walking slot)
	db SPRITE_FOSSIL        ; slot $0B: unused here (still slot)
	db SPRITE_POKE_BALL     ; slot $0C: electrode item ball (still slot)

; SPRITESET_SEA_ROUTES
; The open water south and west of the mainland: Route 21 (Pallet <-> Cinnabar)
; and the Seafoam-side portion of Route 20, which GetSplitMapSpriteSetID's
; .route20 special case picks out by coordinate.
;
; Both were carved off SPRITESET_PALLET_VIRIDIAN / SPRITESET_FUCHSIA because
; those two sets were full. Route 20's swimmers and cooltrainer had been
; dropped from SPRITESET_PALLET_VIRIDIAN for lack of room, which left six of
; them rendering as clones of the player (GetSpriteImageBaseOffset falls back
; to the player's own VRAM slot for a picture ID that isn't in the set), and
; Route 21 sitting in SPRITESET_FUCHSIA made both of its crossings change the
; sprite set, reloading all 11 VRAM slots.
;
; Only three of these are actually referenced - FISHER and SWIMMER on Route
; 21, SWIMMER and COOLTRAINER_M on Route 20 - so every other slot is filled
; to match SPRITESET_PALLET_VIRIDIAN, leaving just two slots differing across
; the Pallet/Cinnabar borders. Keep them aligned if either set is reordered.
	db SPRITE_PIKACHU
	db SPRITE_MISTY
	db SPRITE_BROCK
	db SPRITE_BLUE           ; unused here; matches SPRITESET_PALLET_VIRIDIAN
	db SPRITE_YOUNGSTER      ; unused here; matches
	db SPRITE_FISHER         ; Route 21 fishers; matches
	db SPRITE_GAMBLER        ; unused here; matches
	db SPRITE_SWIMMER        ; Route 20 + 21 - differs from PALLET_VIRIDIAN's GIRL
	db SPRITE_COOLTRAINER_M  ; Route 20 - differs from its OAK
	db SPRITE_POKE_BALL      ; slot $0B: unused here (still slot); matches
	db SPRITE_GAMBLER_ASLEEP ; slot $0C: unused here (still slot); matches

	assert_table_length NUM_SPRITE_SETS
