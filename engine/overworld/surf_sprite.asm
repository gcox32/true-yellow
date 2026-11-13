; Picks the player's surfing sprite from wd472, which the Surf field move sets
; from the species that used it (see StartMenu_Pokemon.surf):
;   1 = Seel, 2 = surfing Pikachu, 3 = Lapras
;   0 = unknown (old save / other entry): surfing Pikachu if one in the party knows Surf, else Seel
; Lives in ROMX; the home-bank LoadSurfingPlayerSpriteGraphics2 just farjps here.
LoadSurfingPlayerSpriteGraphics_::
	ld a, [wd472]
	and a
	jr z, .checkParty
	dec a
	jr z, .seel
	dec a
	jr z, .pikachu
	dec a
	jr z, .lapras
.checkParty
	ld a, [wPikachuPartyFlags]
	bit BIT_SURFING_PIKACHU_IN_PARTY, a
	jr z, .seel
.pikachu
	ld b, BANK(SurfingPikachuSprite)
	ld de, SurfingPikachuSprite
	jp LoadPlayerSpriteGraphicsCommon
.seel
	ld b, BANK(SeelSprite)
	ld de, SeelSprite
	jp LoadPlayerSpriteGraphicsCommon
.lapras
	ld b, BANK(LaprasSprite)
	ld de, LaprasSprite
	jp LoadPlayerSpriteGraphicsCommon
