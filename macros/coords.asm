MACRO? validate_coords
	IF _NARG >= 4
		IF \1 >= \3
			fail "x coord out of range"
		ENDC
		IF \2 >= \4
			fail "y coord out of range"
		ENDC
	ELSE
		validate_coords \1, \2, SCREEN_WIDTH, SCREEN_HEIGHT
	ENDC
ENDM

MACRO? hlcoord
	coord hl, \#
ENDM

MACRO? bccoord
	coord bc, \#
ENDM

MACRO? decoord
	coord de, \#
ENDM

MACRO? coord
; register, x, y[, origin]
	validate_coords \2, \3
	IF _NARG >= 4
		ld \1, (\3) * SCREEN_WIDTH + (\2) + \4
	ELSE
		ld \1, (\3) * SCREEN_WIDTH + (\2) + wTileMap
	ENDC
ENDM

MACRO? hlbgcoord
	bgcoord hl, \#
ENDM

MACRO? bcbgcoord
	bgcoord bc, \#
ENDM

MACRO? debgcoord
	bgcoord de, \#
ENDM

MACRO? bgcoord
; register, x, y[, origin]
	validate_coords \2, \3, TILEMAP_WIDTH, TILEMAP_HEIGHT
	IF _NARG >= 4
		ld \1, (\3) * TILEMAP_WIDTH + (\2) + \4
	ELSE
		ld \1, (\3) * TILEMAP_WIDTH + (\2) + vBGMap0
	ENDC
ENDM

MACRO? hlowcoord
	owcoord hl, \#
ENDM

MACRO? bcowcoord
	owcoord bc, \#
ENDM

MACRO? deowcoord
	owcoord de, \#
ENDM

MACRO? owcoord
; register, x, y, map width
	ld \1, wOverworldMap + ((\2) + 3) + (((\3) + 3) * ((\4) + (3 * 2)))
ENDM

MACRO? event_displacement
; map width, x blocks, y blocks
	dw (wOverworldMap + 7 + (\1) + ((\1) + 6) * ((\3) >> 1) + ((\2) >> 1))
	db \3, \2
ENDM

MACRO? dwcoord
; x, y
	validate_coords \1, \2
	IF _NARG >= 3
		dw (\2) * SCREEN_WIDTH + (\1) + \3
	ELSE
		dw (\2) * SCREEN_WIDTH + (\1) + wTileMap
	ENDC
ENDM

MACRO? ldcoord_a
; x, y[, origin]
	validate_coords \1, \2
	IF _NARG >= 3
		ld [(\2) * SCREEN_WIDTH + (\1) + \3], a
	ELSE
		ld [(\2) * SCREEN_WIDTH + (\1) + wTileMap], a
	ENDC
ENDM

MACRO? lda_coord
; x, y[, origin]
	validate_coords \1, \2
	IF _NARG >= 3
		ld a, [(\2) * SCREEN_WIDTH + (\1) + \3]
	ELSE
		ld a, [(\2) * SCREEN_WIDTH + (\1) + wTileMap]
	ENDC
ENDM

MACRO? dbmapcoord
; x, y
	db \2, \1
ENDM

; One entry of a ParkFollowers table (engine/followers/chain_follow.asm): if
; that follower is standing on the danger tile when a cutscene NPC is about to
; walk through it, send them to the destination instead.
;\1 trail slot (MISTY_TRAIL_SLOT / BROCK_TRAIL_SLOT)
;\2,\3 danger x, y   \4,\5 destination x, y   (both in map coords)
; Position trail entries are stored as map coord + 4 (see wram.asm), which the
; +4s here fold in at assembly time so the table reads in plain map coords.
MACRO park_follower
	db \1, \3 + 4, \2 + 4, \5 + 4, \4 + 4
ENDM

; Unconditional form: park that follower wherever they happen to be standing.
; Use this when the follower's position at scene time is fixed rather than
; dependent on how the player walked in - after a battle, for instance, the
; trail is rebuilt from the player's facing, so there is only one arrangement
; to handle and no danger tile worth matching.
;\1 trail slot   \2,\3 destination x, y (map coords)
; $ff in the danger-Y byte is the wildcard ParkFollowers looks for.
MACRO park_follower_always
	db \1, -1, -1, \3 + 4, \2 + 4
ENDM

DEF PARK_FOLLOWER_ENTRY_SIZE EQU 5

MACRO park_followers_end
	db -1
ENDM
