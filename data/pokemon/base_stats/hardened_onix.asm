; PureRGBnote: ADDED: powered up version of onix with better stats and less weaknesses.
	db DEX_ONIX ; pokedex id

	db  80,  85, 180,  80,  75
	;   hp  atk  def  spd  spc

	db CRYSTAL, GROUND ; type
	db 45 ; catch rate
	db 108 ; base exp

	INCBIN "gfx/pokemon/front/onix.pic", 0, 1 ; sprite dimensions
	dw OnixPicFront, OnixPicBackSW

	db TACKLE, HARDEN, GROWL, NO_MOVE ; level 1 learnset
	db GROWTH_FAST ; growth rate

	; tm/hm learnset
	tmhm \
	TOXIC,\
	BODY_SLAM,\
	DOUBLE_EDGE,\
	HYPER_BEAM,\
	DRAGON_RAGE,\
	EARTHQUAKE,\
	DIG,\
	SWORDS_DANCE,\
	BIDE,\
	FIRE_BLAST,\
	ROCK_SLIDE,\
	SUBSTITUTE,\
	CUT,\
	SURF,\
	STRENGTH
	; end

	db BANK(OnixPicFront)
	db BANK(OnixPicFrontAlt)
	db BANK(OnixPicBack)
	db BANK(OnixPicBackSW)

	dw OnixPicFrontAlt, OnixPicBack

