; What MISTY and BROCK say when you talk to them.
;
; FollowerTalk_PrintLine (engine/followers/follower_talk.asm) walks this table
; top to bottom, separately for each follower, and uses the FIRST entry that
; passes. So order = priority: specific (a place + a beat) above general.
;
;   follower_line MAP,                 WHEN, UNLESS, CHANCE, MistyLine, BrockLine
;   follower_line FIRST_MAP, LAST_MAP, WHEN, UNLESS, CHANCE, MistyLine, BrockLine
;
; - MAP: a map constant, or ANYWHERE. FIRST_MAP..LAST_MAP is an inclusive
;   range of map ids (check constants/map_constants.asm - multi-floor places
;   aren't always consecutive, e.g. SILPH_CO_*, SEAFOAM_ISLANDS_*).
; - WHEN must hold, UNLESS must not. Each is one of:
;     an EVENT_* flag          (set)
;     HAS_BADGES + n           (at least n badges, any order)
;     DEX_OWNED + n            (at least n #MON owned)
;     BEAT_ELITE_4             (wElite4Flags; survives the Hall of Fame)
;     ALWAYS / NEVER           (no check)
;   Don't use EVENT_BEAT_CHAMPION_RIVAL or other Indigo Plateau events: the
;   Hall of Fame resets that whole range.
;   Lines about a beat should look FORWARD ("next stop: X") and use UNLESS
;   to expire once X is done, so they never go stale.
; - CHANCE: percent (100 = always). On a miss the search carries on down the
;   table, which is how places, story, #DEX and anime lines all get airtime.
; - Lines: a text label, a follower_pool (one picked at random), or 0 to have
;   that follower skip this entry.
; - Misty lines that mention BROCK need WHEN EVENT_BEAT_BROCK (he joins then).
;
; The ANYWHERE / ALWAYS pools at the bottom catch everything, so the defaults
; only show if those are removed.
;
; Text box is 18 characters wide. "#" prints as POKé (4 chars), <PLAYER> can be
; up to 7. Lines end with "done" (the caller waits for the button press).
; No "--" in dialogue.
;
; Anime quotes (marked ; EPxx) are exact English-dub lines from the Indigo
; League, from docs/anime/ (gitignored; docs/anime/fetch.py rebuilds it). Only
; recased to the game's style, "Ash" -> <PLAYER>, and typos fixed. Keep it that
; way: anything that isn't a real quote is written as an original line.

MACRO follower_line
	IF _NARG == 7
		db \1, \2
		SHIFT 2
	ELIF (\1) == ANYWHERE
		db 0, $ff
		SHIFT
	ELSE
		db \1, \1
		SHIFT
	ENDC
	dw (\1) & $ffff, (\2) & $ffff
	IF (\3) >= 100
		db 0
	ELSE
		db (\3) * 256 / 100
	ENDC
	dw \4, \5
ENDM

; follower_pool Line1, Line2, ...: one is picked at random
MACRO follower_pool
	db FOLLOWER_POOL, _NARG
	REPT _NARG
		dw \1
		SHIFT
	ENDR
ENDM

; the same entry for every #MON CENTER
MACRO pokecenter_lines ; WHEN, UNLESS, CHANCE, MistyLine, BrockLine
	FOR _PC, 11
		IF _PC == 0
			DEF _PC_MAP = VIRIDIAN_POKECENTER
		ELIF _PC == 1
			DEF _PC_MAP = PEWTER_POKECENTER
		ELIF _PC == 2
			DEF _PC_MAP = CERULEAN_POKECENTER
		ELIF _PC == 3
			DEF _PC_MAP = MT_MOON_POKECENTER
		ELIF _PC == 4
			DEF _PC_MAP = ROCK_TUNNEL_POKECENTER
		ELIF _PC == 5
			DEF _PC_MAP = VERMILION_POKECENTER
		ELIF _PC == 6
			DEF _PC_MAP = CELADON_POKECENTER
		ELIF _PC == 7
			DEF _PC_MAP = LAVENDER_POKECENTER
		ELIF _PC == 8
			DEF _PC_MAP = FUCHSIA_POKECENTER
		ELIF _PC == 9
			DEF _PC_MAP = CINNABAR_POKECENTER
		ELSE
			DEF _PC_MAP = SAFFRON_POKECENTER
		ENDC
		follower_line _PC_MAP, \1, \2, \3, \4, \5
	ENDR
ENDM

FollowerLines:
; ===================== places =====================

; --- gyms and their towns ---
	follower_line PEWTER_CITY,       ALWAYS, EVENT_BEAT_BROCK, 100, .MistyPewterBeforeGym, 0
	follower_line PEWTER_CITY,       ALWAYS, NEVER, 60, .MistyPewter, .BrockPewterPool
	follower_line CERULEAN_CITY,     HAS_BADGES + 5, NEVER, 60, .MistyCeruleanBackAgain, 0
	follower_line CERULEAN_CITY,     ALWAYS, EVENT_BEAT_MISTY, 100, .MistyCeruleanPool, .BrockCeruleanPool
	follower_line CERULEAN_CITY,     ALWAYS, NEVER, 60, .MistyCeruleanAfterGymPool, .BrockCeruleanPool
	follower_line VERMILION_GYM,     ALWAYS, EVENT_BEAT_LT_SURGE, 100, .MistySurgePool, .BrockSurge
	follower_line CELADON_GYM,       ALWAYS, EVENT_BEAT_ERIKA, 100, .MistyErika, .BrockErika
	follower_line FUCHSIA_GYM,       ALWAYS, NEVER, 100, .MistyFuchsiaGymPool, .BrockFuchsiaGym
	follower_line SAFFRON_GYM,       EVENT_BEAT_SABRINA, NEVER, 100, .MistySabrinaDone, .BrockMarshBadge
	follower_line SAFFRON_GYM,       ALWAYS, NEVER, 100, .MistySaffronGym, .BrockSaffronGym
	follower_line CINNABAR_ISLAND,   ALWAYS, EVENT_BEAT_BLAINE, 70, .MistyBlaine, .BrockCinnabar
	follower_line CINNABAR_GYM,      ALWAYS, EVENT_BEAT_BLAINE, 100, .MistyCinnabarGym, .BrockCinnabarGym
	follower_line VIRIDIAN_GYM,      ALWAYS, EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI, 100, .MistyViridianGym, .BrockViridianGym

; --- the road ---
	follower_line VIRIDIAN_FOREST,   ALWAYS, NEVER, 100, .MistyBugsPool, .BrockBugs
	follower_line MT_MOON_1F, MT_MOON_B2F, ALWAYS, NEVER, 100, .MistyMtMoonPool, .BrockMtMoon
	follower_line ROUTE_24, ROUTE_25, ALWAYS, NEVER, 50, .MistyRoute25, .BrockRoute25
	follower_line ROUTE_5, ROUTE_6,  ALWAYS, EVENT_BEAT_LT_SURGE, 50, .MistyRoute5Pool, 0
	follower_line VERMILION_DOCK,    ALWAYS, NEVER, 100, .MistyStAnne, .BrockStAnne
	follower_line SS_ANNE_1F, SS_ANNE_B1F_ROOMS, ALWAYS, NEVER, 100, .MistySSAnnePool, .BrockSSAnnePool
	follower_line ROCK_TUNNEL_1F,    ALWAYS, NEVER, 100, .MistyRockTunnel, .BrockRockTunnel
	follower_line ROCK_TUNNEL_B1F,   ALWAYS, NEVER, 100, .MistyRockTunnel, .BrockRockTunnel
	follower_line LAVENDER_TOWN,     ALWAYS, NEVER, 60, .MistyLavender, .BrockLavender
	follower_line POKEMON_TOWER_1F, POKEMON_TOWER_7F, ALWAYS, NEVER, 100, .MistyTowerPool, .BrockTowerPool
	follower_line POWER_PLANT,       ALWAYS, NEVER, 100, .MistyPowerPlantPool, .BrockPowerPlantPool
	follower_line CELADON_DINER,     ALWAYS, NEVER, 100, .MistyDiner, .BrockDiner
	follower_line GAME_CORNER,       ALWAYS, NEVER, 100, .MistyGameCorner, .BrockGameCorner
	follower_line ROCKET_HIDEOUT_B1F, ROCKET_HIDEOUT_ELEVATOR, ALWAYS, NEVER, 100, .MistyHideout, .BrockHideout
	follower_line ROUTE_12,          ALWAYS, EVENT_BEAT_ROUTE12_SNORLAX, 100, .MistySnorlax, .BrockSnorlaxPool
	follower_line ROUTE_16,          ALWAYS, EVENT_BEAT_ROUTE16_SNORLAX, 100, .MistySnorlax, .BrockSnorlaxPool
	follower_line ROUTE_13, ROUTE_15, ALWAYS, EVENT_BEAT_KOGA, 50, 0, .BrockFuchsiaNear
	follower_line ROUTE_18,          ALWAYS, EVENT_BEAT_KOGA, 50, 0, .BrockFuchsiaNear
	follower_line SAFARI_ZONE_EAST, SAFARI_ZONE_NORTH_REST_HOUSE, ALWAYS, NEVER, 100, .MistySafari, .BrockSafari
	follower_line DAYCARE,           ALWAYS, NEVER, 100, .MistyDaycare, .BrockBreeder
	follower_line FIGHTING_DOJO,     ALWAYS, NEVER, 100, .MistyDojo, .BrockDojo
	follower_line COPYCATS_HOUSE_1F, COPYCATS_HOUSE_2F, ALWAYS, NEVER, 100, .MistyCopycat, .BrockCopycat
	follower_line SILPH_CO_1F,       ALWAYS, EVENT_BEAT_SILPH_CO_GIOVANNI, 100, .MistySilphPool, .BrockSilphPool
	follower_line SILPH_CO_2F, SILPH_CO_8F, ALWAYS, EVENT_BEAT_SILPH_CO_GIOVANNI, 100, .MistySilphPool, .BrockSilphPool
	follower_line SILPH_CO_9F, SILPH_CO_ELEVATOR, ALWAYS, EVENT_BEAT_SILPH_CO_GIOVANNI, 100, .MistySilphPool, .BrockSilphPool
	follower_line ROUTE_19, ROUTE_21, ALWAYS, EVENT_BEAT_BLAINE, 50, .MistyCinnabarAhead, 0
	follower_line SEAFOAM_ISLANDS_B1F, SEAFOAM_ISLANDS_B4F, ALWAYS, NEVER, 100, .MistySeafoamPool, .BrockSeafoam
	follower_line SEAFOAM_ISLANDS_1F, ALWAYS, NEVER, 100, .MistySeafoamPool, .BrockSeafoam
	follower_line POKEMON_MANSION_1F, ALWAYS, NEVER, 100, .MistyMansionPool, .BrockMansion
	follower_line POKEMON_MANSION_2F, POKEMON_MANSION_B1F, ALWAYS, NEVER, 100, .MistyMansionPool, .BrockMansion
	follower_line VICTORY_ROAD_1F,   ALWAYS, NEVER, 100, .MistyVictoryRoad, .BrockVictoryRoad
	follower_line VICTORY_ROAD_2F,   ALWAYS, NEVER, 100, .MistyVictoryRoad, .BrockVictoryRoad
	follower_line VICTORY_ROAD_3F,   ALWAYS, NEVER, 100, .MistyVictoryRoad, .BrockVictoryRoad
	follower_line CERULEAN_CAVE_2F, CERULEAN_CAVE_1F, ALWAYS, NEVER, 100, .MistyCeruleanCaveInside, .BrockCeruleanCaveInside

; --- every #MON CENTER ---
	pokecenter_lines EVENT_BEAT_BROCK, NEVER, 70, .MistyNurseJoyPool, .BrockNurseJoyPool
	pokecenter_lines ALWAYS, NEVER, 50, .MistyTiredOfWalking, 0

; ===================== story, newest first =====================
; Each line looks ahead to the next goal and expires (UNLESS) once it's done.
; Brock at 100% so his "visit OAK" line below never shows while OAK's waiting
	follower_line ANYWHERE, EVENT_OAK_WAITING_IN_CERULEAN_CAVE, NEVER, 70, .MistyOakWaiting, 0
	follower_line ANYWHERE, EVENT_OAK_WAITING_IN_CERULEAN_CAVE, NEVER, 100, 0, .BrockOakWaiting
	follower_line ANYWHERE, BEAT_ELITE_4, EVENT_BEAT_MEWTWO, 50, .MistyCeruleanNudge, 0
	follower_line ANYWHERE, BEAT_ELITE_4, EVENT_BEAT_PROF_OAK, 50, 0, .BrockVisitOak
	follower_line ANYWHERE, BEAT_ELITE_4, NEVER, 100, .MistyChampionPool, .BrockChampionPool
	follower_line ANYWHERE, HAS_BADGES + 8, NEVER, 70, .MistyEightBadges, .BrockEightBadges
	follower_line ANYWHERE, HAS_BADGES + 7, EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI, 70, .MistyLastGym, .BrockLastGym
	follower_line ANYWHERE, EVENT_BEAT_SILPH_CO_GIOVANNI, EVENT_BEAT_SABRINA, 70, .MistySilphDone, .BrockSabrinaNextPool
	follower_line ANYWHERE, EVENT_BEAT_KOGA, EVENT_BEAT_BLAINE, 40, .MistyCinnabarNext, 0
	follower_line ANYWHERE, EVENT_RESCUED_MR_FUJI, EVENT_BEAT_SILPH_CO_GIOVANNI, 60, .MistySaffronTakenOver, .BrockMrFujiPool
	follower_line ANYWHERE, HAS_BADGES + 6, HAS_BADGES + 7, 60, .MistySixBadges, .BrockSixBadges
	follower_line ANYWHERE, HAS_BADGES + 5, HAS_BADGES + 6, 60, .MistyFiveBadges, .BrockFiveBadges
	follower_line ANYWHERE, EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI, EVENT_RESCUED_MR_FUJI, 70, .MistySilphScope, .BrockSilphScope
	follower_line ANYWHERE, EVENT_BEAT_ERIKA, EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI, 70, .MistyGameCornerShady, .BrockLavenderTrouble
	follower_line ANYWHERE, EVENT_BEAT_LT_SURGE, EVENT_BEAT_ERIKA, 70, .MistyCeladonNext, .BrockCeladonNext
	follower_line ANYWHERE, EVENT_GOT_SS_TICKET, EVENT_BEAT_LT_SURGE, 70, .MistyCruise, .BrockSurgeNext
	follower_line ANYWHERE, EVENT_BEAT_MISTY, EVENT_GOT_SS_TICKET, 70, .MistyLostToYouPool, .BrockBillNext
	follower_line ANYWHERE, EVENT_BEAT_BROCK, EVENT_BEAT_MISTY, 70, .MistyBrockJoinedPool, .BrockJustJoinedPool
	follower_line ANYWHERE, ALWAYS, EVENT_BEAT_BROCK, 70, .MistyBikeEarlyPool, 0
	follower_line ANYWHERE, EVENT_GOT_BICYCLE, NEVER, 15, .MistyBike, 0

; ===================== #DEX progress (like PROF.OAK's rating) =====================
	follower_line ANYWHERE, DEX_OWNED + 150, NEVER, 35, .MistyDex150, .BrockDex150
	follower_line ANYWHERE, DEX_OWNED + 120, DEX_OWNED + 150, 35, .MistyDex120, .BrockDex120
	follower_line ANYWHERE, DEX_OWNED + 80, DEX_OWNED + 120, 35, .MistyDex80, .BrockDex80
	follower_line ANYWHERE, DEX_OWNED + 50, DEX_OWNED + 80, 35, .MistyDex50, .BrockDex50
	follower_line ANYWHERE, DEX_OWNED + 20, DEX_OWNED + 50, 35, .MistyDex20, .BrockDex20
	follower_line ANYWHERE, ALWAYS, DEX_OWNED + 20, 35, .MistyDexLow, .BrockDexLow

; ===================== anytime (catches everything) =====================
	follower_line ANYWHERE, EVENT_BEAT_BROCK, NEVER, 30, .MistyAboutBrockPool, 0
	follower_line ANYWHERE, ALWAYS, NEVER, 100, .MistyAnytimePool, .BrockAnytimePool

	db FOLLOWER_LINES_END

; =====================================================================
; pools

.BrockPewterPool:      follower_pool .BrockPewter, .BrockLostToYou
.BrockCeruleanPool:    follower_pool .BrockCerulean, .BrockMistyHome
.MistyCeruleanPool:    follower_pool .MistyCerulean
.MistyCeruleanAfterGymPool: follower_pool .MistyCeruleanAfterGym, .MistyFourthSister
.MistyRoute5Pool:      follower_pool .MistyTenDays, .MistyNicerThanCerulean
.MistySurgePool:       follower_pool .MistyPikachuRaichu, .MistySurgeLeader
.MistyFuchsiaGymPool:  follower_pool .MistyInvisibleWall, .MistyWeirdRoom, .MistyNinja
.MistyBugsPool:        follower_pool .MistyBugs, .MistyBugOff, .MistyAnotherBug, .MistyBugsDisgusting
.MistyMtMoonPool:      follower_pool .MistyMtMoon, .MistyMtMoonRomantic
.MistySSAnnePool:      follower_pool .MistySSAnne, .MistyBuiltStAnne
.BrockSSAnnePool:      follower_pool .BrockSSAnne, .BrockStAnne
.MistyTowerPool:       follower_pool .MistyTower, .MistyGhostGotMe, .MistyOmen
.BrockTowerPool:       follower_pool .BrockTower, .BrockGhostHangout, .BrockAllergicGhosts
.MistyPowerPlantPool:  follower_pool .MistyPowerPlant, .MistyMagnemiteBlushing
.BrockPowerPlantPool:  follower_pool .BrockPowerPlant, .BrockMagnemiteLove
.BrockSnorlaxPool:     follower_pool .BrockPokeFlute, .BrockSnorlax
.MistySilphPool:       follower_pool .MistySilph, .MistyTrap
.BrockSilphPool:       follower_pool .BrockSilph, .BrockNoDoors
.MistySeafoamPool:     follower_pool .MistySeafoam, .MistyWaterSpecialty
.MistyMansionPool:     follower_pool .MistyMansionHuge, .MistyHundredRooms
.MistyNurseJoyPool:    follower_pool .MistyNurseJoy, .MistyPrettyGirl, .MistyAllTheJoys, .MistyTiredOfWalking
.BrockNurseJoyPool:    follower_pool .BrockNurseJoy, .BrockHelloJoy, .BrockSolidAsARock
.MistyChampionPool:    follower_pool .MistyChampion, .MistyStillOweBike
.BrockChampionPool:    follower_pool .BrockChampion, .BrockChampionBreeder
.BrockSabrinaNextPool: follower_pool .BrockSilphDone, .BrockSabrinaNext
.BrockMrFujiPool:      follower_pool .BrockMrFuji, .BrockSaffronTakenOver
.MistyLostToYouPool:   follower_pool .MistyLostToYou, .MistyJustADraw, .MistyIfTeamRocket, .MistyWarmingUp
.MistyBrockJoinedPool: follower_pool .MistyBrockJoined, .MistyMtMoonNext
.BrockJustJoinedPool:  follower_pool .BrockJoined, .BrockOkayToCome, .BrockThatGirl, .BrockLostToYou
.MistyBikeEarlyPool:   follower_pool .MistyFollowTillPay, .MistyHoldingResponsible, .MistyLameExcuses, .MistyPewterNext
.MistyAboutBrockPool:  follower_pool .MistyPrettyGirl, .MistyBrockCooking
.MistyAnytimePool:     follower_pool FollowerDefaultMistyText, .MistyFollowTillPay, .MistyNotLettingYouGo, .MistyStillOweBike, .MistyPsyduck, .MistyWaterSpecialty, .MistyCallItADay
.BrockAnytimePool:     follower_pool FollowerDefaultBrockText, .BrockBreeder, .BrockGreatCook, .BrockDonut

; =====================================================================
; places

.MistyPewterBeforeGym: ; EP005
	text "MISTY: Huh? Is"
	line "that so? Fine"
	cont "with me."
	para "There's no way"
	line "you'll beat BROCK"
	cont "in the PEWTER"
	cont "CITY GYM. Huh!"
	done

.MistyPewter: ; EP005
	text "MISTY: Yay,"
	line "PEWTER CITY!"
	done

.BrockPewter:
	text "BROCK: My family"
	line "runs the house"
	para "while I'm away."
	line "I hope they ate!"
	done

.BrockLostToYou: ; EP005
	text "BROCK: Nah. I lost"
	line "to you."
	para "You beat me in"
	line "battle and in"
	cont "being kind to all"
	cont "#MON."
	done

.MistyCeruleanBackAgain: ; EP052
	text "MISTY: Right back"
	line "to the CERULEAN"
	cont "GYM!"
	para "I'd like to see"
	line "the look on my"
	cont "sisters' faces!"
	done

.MistyCeruleanAfterGym:
	text "MISTY: Back home,"
	line "and I didn't even"
	para "have to see my"
	line "sisters. Win-win!"
	done

.MistyCerulean:
	text "MISTY: CERULEAN,"
	line "huh? Let's not"
	para "stay long, OK?"
	line "...No reason."
	done

.MistyNicerThanCerulean: ; EP007
	text "MISTY: It's much"
	line "nicer than that"
	cont "old CERULEAN CITY,"
	para "so let's get"
	line "going!"
	done

.MistyFourthSister: ; EP007
	text "MISTY: I'm a"
	line "CERULEAN CITY"
	cont "trainer too."
	para "I'm the fourth"
	line "Sensational"
	cont "Sister."
	done

.BrockCerulean:
	text "BROCK: MISTY's"
	line "home turf, huh?"
	para "Better rest your"
	line "#MON first."
	done

.BrockMistyHome: ; EP007
	text "BROCK: She really"
	line "didn't want to"
	cont "come to CERULEAN"
	cont "CITY, did she?"
	done

.MistyPikachuRaichu: ; EP014
	text "MISTY: Can"
	line "PIKACHU beat"
	cont "RAICHU?"
	done

.MistySurgeLeader: ; EP014
	text "MISTY: Is he the"
	line "GYM LEADER you"
	cont "have to beat?"
	done

.BrockSurge: ; EP014
	text "BROCK: From the"
	line "looks of things"
	cont "here, you'll have"
	para "to be tough to"
	line "battle with this"
	cont "LIEUTENANT SURGE."
	done

.MistyErika:
	text "MISTY: Mmm, it"
	line "smells like"
	cont "flowers in here!"
	para "Try not to insult"
	line "the perfume, OK?"
	done

.BrockErika:
	text "BROCK: ERIKA..."
	line "Beautiful, AND a"
	cont "GRASS expert."
	para "...Focus, BROCK."
	line "Focus."
	done

.MistyInvisibleWall: ; EP032
	text "MISTY: An"
	line "invisible wall?"
	para "BROCK this place"
	line "is really giving"
	cont "me the creeps."
	done

.MistyWeirdRoom: ; EP032
	text "MISTY: Hey, BROCK."
	line "Do you notice"
	cont "anything weird"
	cont "about this room?"
	done

.MistyNinja: ; EP032
	text "MISTY: But don't"
	line "you think that"
	cont "color's a little"
	cont "bright for a"
	cont "ninja?"
	done

.BrockFuchsiaGym: ; EP032
	text "BROCK: There must"
	line "be another way"
	cont "out."
	done

.MistySabrinaDone:
	text "MISTY: Is she"
	line "gone? Good. That"
	para "lady gives me the"
	line "creeps."
	done

.BrockMarshBadge: ; EP024
	text "BROCK: And that"
	line "MARSHBADGE puts"
	cont "you one step"
	para "further along the"
	line "road to the"
	cont "#MON LEAGUE."
	done

.MistySaffronGym: ; EP022
	text "MISTY: SABRINA"
	line "must've teleported"
	para "us from the"
	line "#MON GYM."
	done

.BrockSaffronGym:
	text "BROCK: These warp"
	line "tiles are a maze."
	para "Try the corners,"
	line "<PLAYER>."
	done

.MistyBlaine: ; EP058
	text "MISTY: I heard"
	line "that the GYM"
	cont "LEADER was a guy"
	cont "named BLAINE."
	done

.BrockCinnabar:
	text "BROCK: A volcano"
	line "island? This GYM"
	para "is gonna be HOT."
	line "Bring WATER types."
	done

.MistyCinnabarGym:
	text "MISTY: FIRE types?"
	line "Ha! Just leave"
	cont "this one to me."
	done

.BrockCinnabarGym:
	text "BROCK: Quiz"
	line "machines? I hope"
	cont "you studied."
	done

.MistyViridianGym:
	text "MISTY: This GYM's"
	line "been shut all this"
	para "time. Who's the"
	line "LEADER, anyway?"
	done

.BrockViridianGym:
	text "BROCK: GROUND"
	line "types, I bet."
	para "Keep PIKACHU on"
	line "the bench!"
	done

.MistyBugs:
	text "MISTY: Ugh, BUGS!"
	line "Everywhere!"
	para "Hurry up and get"
	line "us out of here!"
	done

.MistyBugOff: ; EP004
	text "MISTY: This whole"
	line "forest is crawling"
	cont "with slimy,"
	cont "disgusting"
	cont "#MON."
	para "I wish they'd all"
	line "just bug off."
	done

.MistyAnotherBug: ; EP004
	text "MISTY: I think I"
	line "see another bug."
	cont "Gross!"
	done

.MistyBugsDisgusting: ; EP002
	text "MISTY: Even if it"
	line "is a #MON, bugs"
	cont "are disgusting and"
	cont "I don't like them."
	para "Do something."
	done

.BrockBugs:
	text "BROCK: Relax!"
	line "A CATERPIE can't"
	para "hurt you, MISTY."
	done

.MistyMtMoon:
	text "MISTY: It's so"
	line "dark in here..."
	para "Stay close, OK?"
	done

.MistyMtMoonRomantic: ; EP006
	text "MISTY: MT.MOON!"
	line "Ah. Doesn't the"
	para "name sound"
	line "romantic?"
	done

.BrockMtMoon:
	text "BROCK: They say"
	line "CLEFAIRY dance"
	para "here under the"
	line "full moon."
	done

.MistyRoute25: ; EP039
	text "MISTY: The air's"
	line "so fresh, and the"
	cont "water's beautiful."
	para "What a great place"
	line "this is for a"
	cont "rest."
	done

.BrockRoute25:
	text "BROCK: A guy who"
	line "lives out here"
	para "collects rare"
	line "#MON. Worth a"
	cont "visit."
	done

.MistyTenDays: ; EP011
	text "MISTY: I just"
	line "can't go one step"
	cont "further."
	para "We've been looking"
	line "for VERMILION CITY"
	cont "for ten whole"
	cont "days!"
	done

.MistyStAnne:
	text "MISTY: A real"
	line "cruise ship!"
	para "Can we stay for"
	line "the pool? Please?"
	done

.BrockStAnne: ; EP015
	text "BROCK: The"
	line "ST. ANNE. Wow!"
	done

.MistySSAnne:
	text "MISTY: Look at all"
	line "these rich folks."
	para "Did anyone bring"
	line "a nice dress?"
	cont "...No? Figures."
	done

.MistyBuiltStAnne: ; EP016
	text "MISTY: Leave it"
	line "to me. I forgot"
	cont "to mention I"
	para "built my own"
	line "ST. ANNE once."
	done

.BrockSSAnne:
	text "BROCK: Smell that"
	line "buffet? I have to"
	para "meet this ship's"
	line "chef!"
	done

.MistyRockTunnel:
	text "MISTY: I can't"
	line "see a thing!"
	para "Did you bring"
	line "FLASH or not?!"
	done

.BrockRockTunnel:
	text "BROCK: Now THIS"
	line "is my element!"
	done

.MistyLavender:
	text "MISTY: This town"
	line "gives me chills."
	done

.BrockLavender:
	text "BROCK: It's so"
	line "quiet here. Even"
	para "the #MON keep"
	line "their voices low."
	done

.MistyTower:
	text "MISTY: D-did you"
	line "hear that?!"
	para "N-not that I'm"
	line "scared or..."
	done

.MistyGhostGotMe: ; EP023
	text "MISTY: Help! The"
	line "ghost has got me!"
	done

.MistyOmen: ; EP023
	text "MISTY: Maybe this"
	line "is an omen."
	para "Maybe we should"
	line "forget about"
	cont "catching a ghost"
	cont "#MON."
	done

.BrockTower:
	text "BROCK: Show some"
	line "respect, guys."
	para "People come here"
	line "to say goodbye."
	done

.BrockGhostHangout: ; EP023
	text "BROCK: This is"
	line "the #MON TOWER"
	cont "where ghost"
	cont "#MON hang out."
	done

.BrockAllergicGhosts: ; EP024
	text "BROCK: I think"
	line "maybe I'm allergic"
	cont "to ghosts."
	para "Kind of feel sort"
	line "of dizzy."
	done

.MistyPowerPlant:
	text "MISTY: My hair's"
	line "standing on end!"
	done

.MistyMagnemiteBlushing: ; EP030
	text "MISTY: This"
	line "MAGNEMITE is"
	cont "blushing, like"
	para "it's in love or"
	line "something."
	done

.BrockPowerPlant:
	text "BROCK: GROUND and"
	line "ROCK moves work"
	para "wonders here."
	line "Trust me."
	done

.BrockMagnemiteLove: ; EP030
	text "BROCK: Maybe"
	line "MAGNEMITE fall in"
	cont "and out of love"
	para "just like humans"
	line "do."
	done

.MistyDiner: ; EP041
	text "MISTY: We haven't"
	line "had anything to"
	cont "eat since"
	cont "yesterday."
	done

.BrockDiner: ; EP014
	text "BROCK: We haven't"
	line "eaten anything"
	cont "decent for three"
	cont "days now."
	done

.MistyGameCorner:
	text "MISTY: Gambling?"
	line "Really, <PLAYER>?"
	done

.BrockGameCorner:
	text "BROCK: I've got a"
	line "system! ...Lend me"
	para "some coins?"
	done

.MistyHideout: ; EP026
	text "MISTY: It's TEAM"
	line "ROCKET!"
	done

.BrockHideout:
	text "BROCK: A secret"
	line "base under a GAME"
	para "CORNER. Classic"
	line "TEAM ROCKET."
	done

.MistySnorlax: ; EP041
	text "MISTY: Hey,"
	line "SNORLAX, wake up."
	done

.BrockPokeFlute: ; EP041
	text "BROCK: That's"
	line "right. Now I"
	cont "remember."
	para "I heard once that"
	line "you play a"
	cont "# FLUTE to wake"
	cont "up a SNORLAX."
	done

.BrockSnorlax:
	text "BROCK: Nothing's"
	line "getting past that"
	cont "belly."
	done

.BrockFuchsiaNear: ; EP031
	text "BROCK: Well,"
	line "FUCHSIA GYM isn't"
	cont "far from here."
	done

.MistySafari:
	text "MISTY: Don't"
	line "waste all your"
	cont "SAFARI BALLs!"
	done

.BrockSafari:
	text "BROCK: Toss a ROCK"
	line "first to keep it"
	para "from running."
	line "...Or BAIT. Hmm."
	done

.MistyDaycare:
	text "MISTY: BROCK, you"
	line "look right at home"
	cont "here."
	done

.BrockBreeder: ; EP042
	text "BROCK: I'm BROCK,"
	line "and I want to"
	cont "become the world's"
	para "best #MON"
	line "breeder."
	done

.MistyDojo:
	text "MISTY: All this"
	line "yelling... These"
	para "guys need a nice"
	line "swim to relax."
	done

.BrockDojo: ; EP029
	text "BROCK: And I've got"
	line "GEODUDE."
	para "We'll both enter"
	line "the tournament and"
	cont "defeat that"
	cont "HITMONCHAN."
	done

.MistyCopycat: ; EP037
	text "MISTY: Great"
	line "imitations."
	done

.BrockCopycat: ; EP037
	text "BROCK: Very good,"
	line "but she doesn't"
	cont "capture the more"
	para "adult charm of the"
	line "real JOY and"
	cont "JENNY."
	done

.MistySilph:
	text "MISTY: These warp"
	line "pads make me"
	para "seasick. And I"
	line "LIKE boats!"
	done

.MistyTrap: ; EP022
	text "MISTY: Can't you"
	line "put two and two"
	cont "together?!"
	para "The only thing"
	line "we've won is this"
	cont "trap!"
	done

.BrockSilph:
	text "BROCK: TEAM ROCKET"
	line "took the whole"
	para "building? Let's"
	line "clear 'em out!"
	done

.BrockNoDoors: ; EP022
	text "BROCK: There"
	line "aren't any doors"
	cont "or windows in this"
	cont "room."
	done

.MistyCinnabarAhead: ; EP058
	text "MISTY: I can't"
	line "wait until we get"
	cont "to CINNABAR."
	para "It's supposed to"
	line "be beautiful."
	done

.MistySeafoam:
	text "MISTY: Brr! The"
	line "water's freezing!"
	para "...I love it!"
	done

.MistyWaterSpecialty: ; EP016
	text "MISTY: Water's my"
	line "specialty."
	done

.BrockSeafoam:
	text "BROCK: Watch your"
	line "step on the ice."
	done

.MistyMansionHuge: ; EP048
	text "MISTY: It's huge."
	done

.MistyHundredRooms: ; EP048
	text "MISTY: It must"
	line "have 100 rooms."
	done

.BrockMansion: ; EP048
	text "BROCK: Mm-hm. I've"
	line "seen shopping"
	cont "malls smaller than"
	cont "this place."
	done

.MistyCeruleanCaveInside:
	text "MISTY: This cave"
	line "was off-limits"
	cont "my whole life."
	para "It gives me the"
	line "creeps!"
	done

.BrockCeruleanCaveInside:
	text "BROCK: The #MON"
	line "in here are way"
	cont "tougher. Stay"
	cont "sharp!"
	done

.MistyVictoryRoad:
	text "MISTY: The LEAGUE"
	line "is right past"
	para "this cave. My"
	line "palms are sweaty!"
	done

.BrockVictoryRoad:
	text "BROCK: Use"
	line "STRENGTH on those"
	para "boulders. Slow"
	line "and steady."
	done

.MistyNurseJoy:
	text "MISTY: BROCK,"
	line "you're drooling."
	done

.MistyPrettyGirl: ; EP042
	text "MISTY: BROCK just"
	line "can't say no to a"
	cont "pretty girl."
	done

.MistyAllTheJoys: ; EP011
	text "MISTY: What are"
	line "you talking about?"
	para "She looks just"
	line "like all the other"
	cont "JOYs."
	done

.MistyTiredOfWalking: ; EP058
	text "MISTY: I'm too"
	line "tired to eat."
	para "I just want a"
	line "nice, soft bed."
	done

.BrockNurseJoy:
	text "BROCK: NURSE JOY!"
	line "My heart...!"
	done

.BrockHelloJoy: ; EP047
	text "BROCK: Ah, hello,"
	line "NURSE JOY."
	done

.BrockSolidAsARock: ; EP029
	text "BROCK: Don't"
	line "worry, you'll be"
	cont "as solid as a"
	cont "rock again soon."
	done

; =====================================================================
; story

.MistyChampion:
	text "MISTY: CHAMPION"
	line "<PLAYER>! Wow!"
	para "...You still owe"
	line "me a bike, though."
	done

.MistyStillOweBike: ; EP046
	text "MISTY: Don't"
	line "forget you still"
	cont "owe me a new bike."
	done

.BrockChampion:
	text "BROCK: You did it!"
	line "I'm so proud."
	para "Let's celebrate."
	line "I'll cook!"
	done

.BrockChampionBreeder:
	text "BROCK: A CHAMPION"
	line "trainer, and soon"
	para "a world-class"
	line "breeder. That's"
	cont "us!"
	done

.MistyCeruleanNudge:
	text "MISTY: Let's go"
	line "back to CERULEAN"
	cont "CITY sometime."
	para "I've got a funny"
	line "feeling about it."
	done

.BrockVisitOak:
	text "BROCK: We should"
	line "check in with"
	cont "PROF.OAK in"
	cont "PALLET TOWN."
	para "He'll want to hear"
	line "all about this!"
	done

.MistyOakWaiting:
	text "MISTY: PROF.OAK"
	line "in CERULEAN CAVE?"
	para "What's he doing"
	line "in a place like"
	cont "that?"
	done

.BrockOakWaiting:
	text "BROCK: PROF.OAK"
	line "said to meet him"
	cont "in CERULEAN CAVE."
	para "Something tells me"
	line "it's not about"
	cont "your #DEX."
	done

.MistyEightBadges:
	text "MISTY: All eight"
	line "BADGEs! INDIGO"
	para "PLATEAU, here we"
	line "come!"
	done

.BrockEightBadges:
	text "BROCK: Rest up"
	line "first. The ELITE"
	para "FOUR won't go easy"
	line "on anyone."
	done

.MistyLastGym:
	text "MISTY: Seven down!"
	line "Just VIRIDIAN's"
	para "GYM left. Back"
	line "where we started!"
	done

.BrockLastGym:
	text "BROCK: The"
	line "VIRIDIAN GYM's"
	para "open now. I've got"
	line "a bad feeling."
	done

.MistySilphDone:
	text "MISTY: TEAM ROCKET"
	line "is finished!"
	para "...Right? RIGHT?"
	done

.BrockSilphDone:
	text "BROCK: SAFFRON's"
	line "safe again."
	para "Your #MON were"
	line "amazing in there."
	done

.BrockSabrinaNext: ; EP022
	text "BROCK: SABRINA's"
	line "the GYM LEADER of"
	cont "the SAFFRON CITY"
	cont "GYM."
	para "You defeat her,"
	line "you win a"
	cont "MARSHBADGE."
	done

.MistyCinnabarNext: ; EP050
	text "MISTY: We could"
	line "head to CINNABAR"
	cont "ISLAND and the"
	cont "CINNABAR GYM."
	done

.MistySaffronTakenOver:
	text "MISTY: TEAM ROCKET"
	line "took over all of"
	para "SAFFRON? Somebody"
	line "has to stop them!"
	done

.BrockMrFuji:
	text "BROCK: MR.FUJI"
	line "takes care of"
	para "orphaned #MON."
	line "Good man."
	done

.BrockSaffronTakenOver:
	text "BROCK: The guards"
	line "won't let anyone"
	para "into SAFFRON. We"
	line "need a way in."
	done

.MistySixBadges:
	text "MISTY: Six BADGEs!"
	line "Two more and it's"
	cont "the LEAGUE!"
	done

.BrockSixBadges:
	text "BROCK: Six! Your"
	line "team's come a long"
	cont "way since PEWTER."
	done

.MistyFiveBadges:
	text "MISTY: Five BADGEs"
	line "already? Don't let"
	cont "it go to your"
	cont "head."
	done

.BrockFiveBadges:
	text "BROCK: Five down."
	line "Keep training,"
	para "and don't forget"
	line "to rest them."
	done

.MistySilphScope:
	text "MISTY: That SILPH"
	line "SCOPE better work"
	para "on ghosts, or I'm"
	line "not going in!"
	done

.BrockSilphScope:
	text "BROCK: With that"
	line "SILPH SCOPE, we"
	para "can climb the"
	line "TOWER in LAVENDER."
	done

.MistyGameCornerShady:
	text "MISTY: That GAME"
	line "CORNER is shady."
	para "TEAM ROCKET's"
	line "behind it, I bet."
	done

.BrockLavenderTrouble:
	text "BROCK: Something's"
	line "wrong at the TOWER"
	para "in LAVENDER, and"
	line "TEAM ROCKET's in"
	cont "on it."
	done

.MistyCeladonNext:
	text "MISTY: CELADON's"
	line "got the biggest"
	para "store in KANTO!"
	line "Shopping time!"
	done

.BrockCeladonNext:
	text "BROCK: Three down."
	line "CELADON's GYM"
	para "uses GRASS types."
	line "Plan ahead."
	done

.MistyCruise:
	text "MISTY: A cruise on"
	line "the ST. ANNE?"
	para "...With you two?"
	line "Fine."
	done

.BrockSurgeNext:
	text "BROCK: VERMILION's"
	line "GYM uses ELECTRIC"
	para "types. My GEODUDE"
	line "can't wait."
	done

.MistyLostToYou:
	text "MISTY: OK, you"
	line "beat me. Fair and"
	para "square. Don't"
	line "rub it in!"
	done

.MistyJustADraw: ; EP007
	text "MISTY: I didn't"
	line "lose anything."
	para "It was a draw."
	done

.MistyIfTeamRocket: ; EP007
	text "MISTY: If TEAM"
	line "ROCKET hadn't"
	cont "busted in, I would"
	cont "have destroyed"
	cont "you."
	done

.MistyWarmingUp: ; EP002
	text "MISTY: You know as"
	line "well as I do that"
	cont "a water #MON"
	cont "can't battle on"
	cont "land."
	para "I was just warming"
	line "up."
	done

.BrockBillNext:
	text "BROCK: Two BADGEs"
	line "down. Six to go!"
	para "Let's see if BILL"
	line "up north can help."
	done

.MistyBrockJoined:
	text "MISTY: So BROCK's"
	line "tagging along now?"
	para "Ugh. Fine."
	done

.MistyMtMoonNext:
	text "MISTY: MT.MOON,"
	line "then CERULEAN."
	para "...Yes, that's my"
	line "hometown. So what?"
	done

.BrockJoined:
	text "BROCK: I'll keep"
	line "an eye on you,"
	para "<PLAYER>. That's"
	line "a promise."
	done

.BrockOkayToCome: ; EP005
	text "BROCK: Hey"
	line "<PLAYER>, are you"
	cont "sure it's okay if"
	para "I go with you on"
	line "your #MON"
	cont "journey?"
	done

.BrockThatGirl: ; EP005
	text "BROCK: Well, what"
	line "about that girl"
	cont "who keeps"
	cont "following you?"
	done

.MistyFollowTillPay: ; EP005
	text "MISTY: Don't"
	line "forget about my"
	cont "bike, <PLAYER>!"
	para "I'm going to"
	line "follow you till"
	cont "you pay me back!"
	done

.MistyHoldingResponsible: ; EP003
	text "MISTY: I'm"
	line "holding you"
	para "responsible for"
	line "my bike."
	done

.MistyLameExcuses: ; EP002
	text "MISTY: I don't"
	line "want any of your"
	cont "lame excuses, kid."
	para "I just want a new"
	line "bike right now!"
	done

.MistyPewterNext:
	text "MISTY: PEWTER's"
	line "GYM uses ROCK"
	para "types. PIKACHU's"
	line "gonna hate that."
	done

.MistyBike:
	text "MISTY: Nice BIKE."
	line "Mine's still"
	para "fried, you know."
	line "PIKACHU did that."
	done

; =====================================================================
; #DEX

.MistyDex150:
	text "MISTY: Every"
	line "#MON?! Even"
	para "PROF.OAK will be"
	line "speechless!"
	done

.BrockDex150:
	text "BROCK: A complete"
	line "#DEX. That's a"
	para "lifetime's work,"
	line "<PLAYER>."
	done

.MistyDex120:
	text "MISTY: Over 120"
	line "kinds? You're"
	para "turning into a"
	line "real researcher."
	done

.BrockDex120:
	text "BROCK: Only a few"
	line "left. The rare"
	para "ones always hide"
	line "the best."
	done

.MistyDex80:
	text "MISTY: Over half"
	line "the #DEX! Not"
	para "bad... for a kid."
	done

.BrockDex80:
	text "BROCK: 80 kinds!"
	line "Some only show up"
	para "by trading, you"
	line "know."
	done

.MistyDex50:
	text "MISTY: 50 kinds!"
	line "How many WATER"
	para "types, though?"
	line "Not enough!"
	done

.BrockDex50:
	text "BROCK: 50 kinds!"
	line "A breeder has to"
	para "know them all"
	line "too, you know."
	done

.MistyDex20:
	text "MISTY: Your"
	line "#DEX is filling"
	cont "up!"
	para "Don't skip the"
	line "WATER types!"
	done

.BrockDex20:
	text "BROCK: Try fishing"
	line "or new grass. Each"
	para "spot has its own"
	line "#MON."
	done

.MistyDexLow:
	text "MISTY: That"
	line "#DEX is looking"
	cont "pretty empty,"
	cont "<PLAYER>."
	done

.BrockDexLow:
	text "BROCK: Weaken them"
	line "first, then throw"
	para "the BALL. That's"
	line "the trick."
	done

; =====================================================================
; anytime

.MistyBrockCooking:
	text "MISTY: Say what"
	line "you want about"
	para "BROCK, but his"
	line "stew is amazing."
	done

.MistyNotLettingYouGo: ; EP009
	text "MISTY: I'm not"
	line "letting you out of"
	cont "my sight,"
	cont "<PLAYER>,"
	para "until you pay for"
	line "my broken bike."
	done

.MistyPsyduck: ; EP032
	text "MISTY: Sometimes I"
	line "just look at that"
	cont "PSYDUCK face and"
	cont "I get a headache."
	done

.MistyCallItADay: ; EP058
	text "MISTY: We should"
	line "call it a day."
	para "Why don't we check"
	line "out the #MON"
	cont "CENTER?"
	done

.BrockGreatCook: ; EP039
	text "BROCK: What can I"
	line "say? I'm a great"
	cont "cook."
	done

.BrockDonut: ; EP025
	text "BROCK: These"
	line "donuts are great."
	para "Jelly-filled are"
	line "my favorite."
	para "Nothing beats a"
	line "jelly-filled"
	cont "donut."
	done

; --- defaults (nothing above matched) ---

FollowerDefaultMistyText:
	text "MISTY: This is"
	line "so exciting!"
	para "I can't wait to"
	line "see what's next!"
	done

FollowerDefaultBrockText:
	text "BROCK: Stay alert,"
	line "<PLAYER>."
	para "I've got your"
	line "back!"
	done
