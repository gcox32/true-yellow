	object_const_def
	const_export POWERPLANT_VOLTORB1
	const_export POWERPLANT_VOLTORB2
	const_export POWERPLANT_VOLTORB3
	const_export POWERPLANT_ELECTRODE1
	const_export POWERPLANT_VOLTORB4
	const_export POWERPLANT_VOLTORB5
	const_export POWERPLANT_ELECTRODE2
	const_export POWERPLANT_CARBOS
	const_export POWERPLANT_ZAPDOS
	const_export POWERPLANT_HP_UP
	const_export POWERPLANT_RARE_CANDY
	const_export POWERPLANT_TM_THUNDER

PowerPlant_Object:
	db $2e ; border block

	def_warp_events
	warp_event  4, 35, LAST_MAP, 4
	warp_event  5, 35, LAST_MAP, 4
	warp_event  0, 11, LAST_MAP, 4

	def_bg_events
	; The electromagnet: machine block on the Zapdos room's north wall.
	; A bg_event rather than an object - followers own sprite structs 13-15,
	; so indoor maps get at most 12 objects.
	bg_event  2,  7, TEXT_POWERPLANT_ELECTROMAGNET
	bg_event  3,  7, TEXT_POWERPLANT_ELECTROMAGNET

	def_object_events
	object_event  9, 20, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_VOLTORB1, VOLTORB, 40
	object_event 32, 18, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_VOLTORB2, VOLTORB, 40
	object_event 21, 25, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_VOLTORB3, VOLTORB, 40
	object_event 25, 18, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_ELECTRODE1, ELECTRODE, 43
	object_event 23, 34, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_VOLTORB4, VOLTORB, 40
	object_event 26, 28, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_VOLTORB5, VOLTORB, 40
	object_event 21, 14, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_ELECTRODE2, ELECTRODE, 43
	; CARBOS sits in slot 8 so ZAPDOS stays object 9: its trainer header bit
	; must match EVENT_BEAT_ZAPDOS (see def_trainers 9 in scripts/PowerPlant.asm)
	object_event  7, 25, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_CARBOS, CARBOS
	object_event  4,  9, SPRITE_BIRD, STAY, UP, TEXT_POWERPLANT_ZAPDOS, ZAPDOS, 50
	object_event 28,  3, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_HP_UP, HP_UP
	object_event 34,  3, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_RARE_CANDY, RARE_CANDY
	object_event 26, 32, SPRITE_POKE_BALL, STAY, NONE, TEXT_POWERPLANT_TM_THUNDER, TM_THUNDER

	def_warps_to POWER_PLANT
