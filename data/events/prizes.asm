PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries, PrizeMenuMon1Cost
	dw PrizeMenuMon2Entries, PrizeMenuMon2Cost
	dw PrizeMenuTMsEntries,  PrizeMenuTMsCost

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
	db TM_BLIZZARD
	db TM_THUNDER
	db TM_FIRE_BLAST
	db "@"

PrizeMenuMon2Cost:
	bcd2 3000
	bcd2 3000
	bcd2 3000
	db "@"

PrizeMenuTMsEntries:
	db TM_DRAGON_RAGE
	db TM_HYPER_BEAM
	db TM_SUBSTITUTE
	db "@"

PrizeMenuTMsCost:
	bcd2 5000
	bcd2 6000
	bcd2 7000
	db "@"
