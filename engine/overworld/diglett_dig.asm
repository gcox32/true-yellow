; DIG used by DIGLETT from the party menu: instead of the Escape Rope spin, the
; player is swapped for a DIGLETT that burrows away, then pops back up at the
; destination. StartMenu_Pokemon.dig sets BIT_DIG_WITH_DIGLETT; _LeaveMapAnim
; and EnterMapAnim call in here, and EnterMapAnim clears the bit.
; Ported from PureRGB (engine/menus/dig.asm), graphics included.

DEF DIGLETT_DIG_STAND        EQU  0
DEF DIGLETT_DIG_MOUTH_CLOSED EQU  4
DEF DIGLETT_DIG_HALF_BURIED  EQU  8
DEF DIGLETT_DIG_MOST_BURIED  EQU 12
DEF DIGLETT_DIG_NEARLY_GONE  EQU 16
DEF DIGLETT_DIG_TOP_ONLY     EQU 20
DEF DIGLETT_DIG_DIRT         EQU 24
DEF DIGLETT_DIG_BLINK_TOP    EQU 28

DiglettDigLeaveMapAnim::
	ld a, [wAudioROMBank]
	push af
	ld a, SPRITE_FACING_DOWN
	ld [wSpritePlayerStateData1ImageIndex], a
	ld a, DIGLETT_DIG_STAND
	call DiglettDigLoadFrame
	ld c, 10
	call DelayFrames
	call DiglettDigBlink
	call DiglettDigBlink
	call DiglettDigBlink
	ld c, 24
	call DelayFrames
	call DiglettDigPlaySound
	ld hl, DiglettDigBurrowFrames
	call DiglettDigPlayFrames
	call DiglettDigResetSound
	ld c, 36
	call DelayFrames
	jr DiglettDigRestoreAudioBank

; The player is still parked off-screen (EnterMapAnim moved it there), so load
; the dirt mound before bringing it back into view.
DiglettDigEnterMapAnim::
	ld a, [wAudioROMBank]
	push af
	ld c, 10
	call DelayFrames
	ld a, SPRITE_FACING_DOWN
	ld [wSpritePlayerStateData1ImageIndex], a
	ld a, DIGLETT_DIG_DIRT
	call DiglettDigLoadFrame
	ld a, [wSavedPlayerScreenY]
	ld [wSpritePlayerStateData1YPixels], a
	call DiglettDigPlaySound
	ld hl, DiglettDigEmergeFrames
	call DiglettDigPlayFrames
	ld c, 5
	call DelayFrames
	ld a, DIGLETT_DIG_STAND
	call DiglettDigLoadFrame
	ld c, 20
	call DelayFrames
	call DiglettDigResetSound
	; fallthrough

; the dig sound lives in the battle SFX bank; put back the bank that was
; active before (map or bike music). Jumped to (not called) by both anims, so
; the bank they pushed on entry is on top of the stack.
DiglettDigRestoreAudioBank:
	pop af
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ret

DiglettDigBurrowFrames:
	db DIGLETT_DIG_MOUTH_CLOSED
	db DIGLETT_DIG_HALF_BURIED
	db DIGLETT_DIG_MOST_BURIED
	db DIGLETT_DIG_NEARLY_GONE
	db DIGLETT_DIG_TOP_ONLY
	db DIGLETT_DIG_DIRT
	db -1

DiglettDigEmergeFrames:
	db DIGLETT_DIG_TOP_ONLY
	db DIGLETT_DIG_NEARLY_GONE
	db DIGLETT_DIG_MOST_BURIED
	db DIGLETT_DIG_HALF_BURIED
	db DIGLETT_DIG_MOUTH_CLOSED
	db -1

; hl = -1-terminated list of frame tile offsets, shown 2 frames apart
DiglettDigPlayFrames:
	ld a, [hli]
	cp -1
	ret z
	push hl
	push af
	ld c, 2
	call DelayFrames
	pop af
	call DiglettDigLoadFrame
	pop hl
	jr DiglettDigPlayFrames

DiglettDigBlink:
	ld c, 5
	call DelayFrames
	ld de, DiglettDigSprite tile DIGLETT_DIG_BLINK_TOP
	ld c, 2
	call .loadTop
	ld c, 5
	call DelayFrames
	ld de, DiglettDigSprite tile DIGLETT_DIG_STAND
	ld c, 2
.loadTop
	ld hl, vNPCSprites
	ld b, BANK(DiglettDigSprite)
	jp CopyVideoData

; a = tile offset of a 16x16 frame; copies it over the player's
; facing-down standing tiles
DiglettDigLoadFrame:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ; 16 bytes per tile
	ld de, DiglettDigSprite
	add hl, de
	ld d, h
	ld e, l
	ld hl, vNPCSprites
	lb bc, BANK(DiglettDigSprite), 4
	jp CopyVideoData

; PureRGB's dig sound: the battle "damage" thud, pitched down and slowed
DiglettDigPlaySound:
	ld a, BANK(SFX_Damage)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, $10
	ld [wFrequencyModifier], a
	ld a, $40
	ld [wTempoModifier], a
	ld a, SFX_DAMAGE
	jp PlaySound

DiglettDigResetSound:
	call WaitForSoundToFinish
	xor a
	ld [wFrequencyModifier], a
	ld [wTempoModifier], a
	ret

DiglettDigSprite: INCBIN "gfx/sprites/diglett_dig.2bpp"
