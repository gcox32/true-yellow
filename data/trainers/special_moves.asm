; Yellow entry format:
;	db trainerclass, trainerid
;	repeat { db partymon location, partymon move, move id }
;	db 0

SpecialTrainerMoves:
	db BUG_CATCHER, 15
	db 0

	db YOUNGSTER, 14 ; Sandshrew kid
	db 1, 1, SLASH
	db 1, 2, DIG
	db 1, 3, ROCK_SLIDE
	db 1, 4, FISSURE
	db 0

	db BROCK, 1
	db 2, 3, BIND
	db 2, 4, BIDE
	db 0

	db MISTY, 1
	db 2, 4, BUBBLEBEAM
	db 0

	db LT_SURGE, 1
	db 1, 1, THUNDERBOLT
	db 1, 2, MEGA_PUNCH
	db 1, 3, MEGA_KICK
	db 1, 4, BODY_SLAM
	db 0

	db ERIKA, 1
	db 1, 3, MEGA_DRAIN
	db 2, 1, RAZOR_LEAF
	db 3, 1, PETAL_DANCE
	db 0

	db KOGA, 1
	db 0

	db BLAINE, 1
	db 1, 1, THUNDERBOLT
	db 5, 4, THUNDERPUNCH
	db 0

	db SABRINA, 1
	db 1, 2, PSYCHIC_M
	db 1, 3, REFLECT
	db 0

	db GIOVANNI, 3
	db 1, 3, GUILLOTINE
	db 2, 2, FISSURE
	db 3, 1, EARTHQUAKE
	db 3, 3, THUNDER
	db 4, 1, EARTHQUAKE
	db 4, 2, HYPER_BEAM
	db 4, 3, THUNDER
	db 0

	db LORELEI, 1
	db 1, 1, BUBBLEBEAM
	db 2, 3, ICE_BEAM
	db 3, 1, PSYCHIC_M
	db 3, 2, SURF
	db 4, 3, LOVELY_KISS
	db 5, 3, BLIZZARD
	db 0

	db BRUNO, 1
	db 1, 1, DOUBLE_TEAM
	db 2, 4, DOUBLE_TEAM
	db 5, 3, HYPER_BEAM
	db 0

	db AGATHA, 1
	db 1, 2, SUBSTITUTE
	db 1, 3, LICK
	db 1, 4, MEGA_DRAIN
	db 2, 2, TOXIC
	db 3, 2, HYPNOSIS
	db 4, 1, WRAP
	db 5, 2, PSYCHIC_M
	db 0

	db LANCE, 1
	db 6, 1, BLIZZARD
	db 6, 2, FIRE_BLAST
	db 6, 3, THUNDER
	db 0

	db -1 ; end
