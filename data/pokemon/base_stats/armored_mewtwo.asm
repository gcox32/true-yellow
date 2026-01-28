	db DEX_MEWTWO ; pokedex id

	db 130, 110,  130, 115, 154
	;   hp  atk  def  spd  spc

	db PSYCHIC_TYPE, PSYCHIC_TYPE ; type
	db 25 ; catch rate
	db 220 ; base exp

	INCBIN "gfx/pokemon/front/armored_mewtwo.pic", 0, 1 ; sprite dimensions
	dw ArmoredMewtwoPicFront, ArmoredMewtwoPicBackSW

	db CONFUSION, DISABLE, SWIFT, PSYCHIC_M ; level 1 learnset
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	tmhm \
	TOXIC,\
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
	PSYCHIC_M,\
	REFLECT,\
	BIDE,\
	FIRE_BLAST,\
	THUNDER_WAVE,\
	SUBSTITUTE,\
	CUT,\
	STRENGTH,\
	FLASH
	; end


	db BANK(ArmoredMewtwoPicFront)
	db BANK(ArmoredMewtwoPicFrontAlt)
	db BANK(ArmoredMewtwoPicBack)
	db BANK(ArmoredMewtwoPicBackSW)

	dw ArmoredMewtwoPicFrontAlt, ArmoredMewtwoPicBack

