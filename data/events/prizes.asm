PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries, PrizeMenuMon1Cost
	dw PrizeMenuMon2Entries, PrizeMenuMon2Cost
	dw PrizeMenuTMs2Entries, PrizeMenuTMs2Cost

; whether each prize window (indexed by wWhichPrizeWindow) hands out items (TRUE)
; or Pokémon (FALSE). Keep this in sync with PrizeDifferentMenuPtrs above.
PrizeMenuIsItemWindow:
	db FALSE 
	db FALSE  
	db TRUE 

PrizeMenuMon1Entries:
	db ABRA
	db EEVEE
	db DRATINI
	db "@"

PrizeMenuMon1Cost:
	bcd2 250
	bcd2 1000
	bcd2 3000
	db "@"

PrizeMenuMon2Entries:
	db OMANYTE
	db KABUTO
	db AERODACTYL
	db "@"

PrizeMenuMon2Cost:
	bcd2 3000
	bcd2 3000
	bcd2 3000
	db "@"

PrizeMenuTMs2Entries:
	db TM_DRAGON_RAGE
	db TM_HYPER_BEAM
	db TM_SUBSTITUTE
	db "@"

PrizeMenuTMs2Cost:
	bcd2 5000
	bcd2 6000
	bcd2 7000
	db "@"
