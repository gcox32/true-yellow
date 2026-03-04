	db DEX_MISSINGNO ; pokedex id

	db  255, 150, 150,  5,  5
	;   hp  atk  def  spd  spc

	db GHOST, NORMAL ; type
	db 25 ; catch rate
	db 255 ; base exp

	INCBIN "gfx/pokemon/front/missingno.pic", 0, 1 ; sprite dimensions
	dw MissingnoPicFront, MissingnoPicBackSW

	db SKY_ATTACK, WATER_GUN, WATER_GUN, NO_MOVE ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm \
	RAZOR_WIND,\ ; ROOST
	TOXIC,\
	HORN_DRILL,\
	BODY_SLAM,\
	DOUBLE_EDGE,\
	BUBBLEBEAM,\
	ICE_BEAM,\
	BLIZZARD,\
	HYPER_BEAM,\
	SOLARBEAM,\
	THUNDERBOLT,\
	THUNDER,\
	EARTHQUAKE,\
	DIG,\
	PSYCHIC_M,\
	MEGA_DRAIN,\
	SWORDS_DANCE,\
	REFLECT,\
	BIDE,\
	FIRE_BLAST,\
	SKY_ATTACK,\
	THUNDER_WAVE,\
	ROCK_SLIDE,\
	SUBSTITUTE,\
	CUT,\
	FLY,\
	SURF,\
	STRENGTH,\
	FLASH
	; end


	db BANK(MissingnoPicFront)
	db 0
	db BANK(MissingnoPicBack)
	db BANK(MissingnoPicBackSW)

	dw 0, MissingnoPicBack

