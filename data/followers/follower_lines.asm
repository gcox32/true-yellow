; What MISTY and BROCK say when you talk to them.
;
; FollowerTalk_PrintLine (engine/followers/follower_talk.asm) walks this table
; top to bottom and uses the FIRST entry that matches, separately for each
; follower. So order = priority: put specific entries (a place + a beat)
; above general ones (just a place, or just a beat), and newer beats above
; older ones.
;
;   follower_line MAP,              BEAT, MistyText, BrockText
;   follower_line FIRST_MAP, LAST_MAP, BEAT, MistyText, BrockText
;
; - MAP: a map constant, or ANYWHERE. FIRST_MAP..LAST_MAP is an inclusive
;   range of map ids (check constants/map_constants.asm - multi-floor places
;   aren't always consecutive, e.g. SILPH_CO_*, SEAFOAM_ISLANDS_*).
; - BEAT: an event flag that must be set (EVENT_BEAT_MISTY, ...), or NO_BEAT.
;   Any EVENT_* from constants/event_constants.asm works, including new ones.
;   BEAT_ELITE_4 = beaten the Elite 4. Don't use EVENT_BEAT_CHAMPION_RIVAL or
;   other Indigo Plateau events: the Hall of Fame resets that whole range.
; - A text label, or 0 to have that follower skip this entry and keep looking.
;
; Nothing matched -> FollowerDefaultMistyText / FollowerDefaultBrockText.
;
; Text box is 18 characters wide. "#" prints as POKé (4 chars), <PLAYER> can be
; up to 7. Lines end with "done" (the caller waits for the button press).
; The table and all the text share one ROM bank (~8 KB free there today); if it
; ever overflows, move text into text/ and point at text_far stubs instead.

DEF ANYWHERE EQU -1
DEF NO_BEAT  EQU -1
DEF BEAT_ELITE_4 EQU -2 ; wElite4Flags BIT_BEAT_ELITE_4 (survives the Hall of Fame)
DEF FOLLOWER_LINES_END EQU $ff

MACRO follower_line
	IF _NARG == 5
		db \1, \2
		SHIFT
	ELIF (\1) == ANYWHERE
		db 0, $ff
	ELSE
		db \1, \1
	ENDC
	dw (\2) & $ffff, \3, \4
ENDM

FollowerLines:
; --- a place + a beat ---
	follower_line CERULEAN_CITY,          EVENT_BEAT_MISTY, .MistyCeruleanAfterGym, 0

; --- places ---
	follower_line CERULEAN_CITY,          NO_BEAT, .MistyCerulean,      .BrockCerulean
	follower_line PEWTER_CITY,            NO_BEAT, .MistyPewter,        .BrockPewter
	follower_line LAVENDER_TOWN,          NO_BEAT, .MistyLavender,      0
	follower_line VIRIDIAN_FOREST,        NO_BEAT, .MistyBugs,          .BrockBugs
	follower_line MT_MOON_1F, MT_MOON_B2F, NO_BEAT, .MistyMtMoon,       .BrockMtMoon
	follower_line ROCK_TUNNEL_1F,         NO_BEAT, .MistyRockTunnel,    .BrockRockTunnel
	follower_line ROCK_TUNNEL_B1F,        NO_BEAT, .MistyRockTunnel,    .BrockRockTunnel
	follower_line POWER_PLANT,            NO_BEAT, .MistyPowerPlant,    .BrockPowerPlant
	follower_line SS_ANNE_1F, SS_ANNE_B1F_ROOMS, NO_BEAT, .MistySSAnne, .BrockSSAnne
	follower_line POKEMON_TOWER_1F, POKEMON_TOWER_7F, NO_BEAT, .MistyTower, .BrockTower
	follower_line GAME_CORNER,            NO_BEAT, .MistyGameCorner,    .BrockGameCorner
	follower_line SILPH_CO_1F,            NO_BEAT, .MistySilph,         .BrockSilph
	follower_line SILPH_CO_2F, SILPH_CO_8F, NO_BEAT, .MistySilph,       .BrockSilph
	follower_line SILPH_CO_9F, SILPH_CO_ELEVATOR, NO_BEAT, .MistySilph, .BrockSilph
	follower_line SAFARI_ZONE_EAST, SAFARI_ZONE_NORTH_REST_HOUSE, NO_BEAT, .MistySafari, .BrockSafari
	follower_line SEAFOAM_ISLANDS_B1F, SEAFOAM_ISLANDS_B4F, NO_BEAT, .MistySeafoam, .BrockSeafoam
	follower_line SEAFOAM_ISLANDS_1F,     NO_BEAT, .MistySeafoam,       .BrockSeafoam
; every #MON CENTER
	follower_line VIRIDIAN_POKECENTER,    NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line PEWTER_POKECENTER,      NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line CERULEAN_POKECENTER,    NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line MT_MOON_POKECENTER,     NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line ROCK_TUNNEL_POKECENTER, NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line VERMILION_POKECENTER,   NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line CELADON_POKECENTER,     NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line LAVENDER_POKECENTER,    NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line FUCHSIA_POKECENTER,     NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line CINNABAR_POKECENTER,    NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy
	follower_line SAFFRON_POKECENTER,     NO_BEAT, .MistyNurseJoy,      .BrockNurseJoy

; --- story beats, newest first ---
	follower_line ANYWHERE, BEAT_ELITE_4,                   .MistyChampion,  .BrockChampion
	follower_line ANYWHERE, EVENT_BEAT_SILPH_CO_GIOVANNI,   .MistySilphDone, .BrockSilphDone
	follower_line ANYWHERE, EVENT_RESCUED_MR_FUJI,          0,               .BrockMrFuji
	follower_line ANYWHERE, EVENT_GOT_BICYCLE,              .MistyBike,      0
	follower_line ANYWHERE, EVENT_BEAT_MISTY,               .MistyLostToYou, .BrockTwoBadges
	follower_line ANYWHERE, EVENT_BEAT_BROCK,               .MistyBrockJoined, .BrockJoined

	db FOLLOWER_LINES_END

; =====================================================================

.MistyCeruleanAfterGym:
	text "MISTY: Back home,"
	line "and I didn't even"
	para "have to see my"
	line "sisters. Win-win!"
	done

.MistyCerulean:
	text "MISTY: My GYM is"
	line "right up ahead!"
	para "Don't expect me"
	line "to go easy on you!"
	done

.BrockCerulean:
	text "BROCK: MISTY's"
	line "home turf, huh?"
	para "Better rest your"
	line "#MON first."
	done

.MistyPewter:
	text "MISTY: PEWTER's"
	line "so dusty..."
	para "Even the GYM is"
	line "full of rocks!"
	done

.BrockPewter:
	text "BROCK: My family"
	line "runs the house"
	para "while I'm away."
	line "I hope they ate!"
	done

.MistyLavender:
	text "MISTY: This town"
	line "gives me chills."
	done

.MistyBugs:
	text "MISTY: Ugh, BUGS!"
	line "Everywhere!"
	para "Hurry up and get"
	line "us out of here!"
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

.BrockMtMoon:
	text "BROCK: They say"
	line "CLEFAIRY dance"
	para "here under the"
	line "full moon."
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

.MistyPowerPlant:
	text "MISTY: My hair's"
	line "standing on end!"
	done

.BrockPowerPlant:
	text "BROCK: GROUND and"
	line "ROCK moves work"
	para "wonders here."
	line "Trust me."
	done

.MistySSAnne:
	text "MISTY: A real"
	line "cruise ship!"
	para "Can we stay for"
	line "the pool? Please?"
	done

.BrockSSAnne:
	text "BROCK: Smell that"
	line "buffet? I have to"
	para "meet this ship's"
	line "chef!"
	done

.MistyTower:
	text "MISTY: D-did you"
	line "hear that?!"
	para "N-not that I'm"
	line "scared or..."
	done

.BrockTower:
	text "BROCK: Show some"
	line "respect, guys."
	para "People come here"
	line "to say goodbye."
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

.MistySilph:
	text "MISTY: These warp"
	line "pads make me"
	para "seasick. And I"
	line "LIKE boats!"
	done

.BrockSilph:
	text "BROCK: TEAM ROCKET"
	line "took the whole"
	para "building? Let's"
	line "clear 'em out!"
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

.MistySeafoam:
	text "MISTY: Brr! The"
	line "water's freezing!"
	para "...I love it!"
	done

.BrockSeafoam:
	text "BROCK: Watch your"
	line "step on the ice."
	done

.MistyNurseJoy:
	text "MISTY: BROCK,"
	line "you're drooling."
	done

.BrockNurseJoy:
	text "BROCK: NURSE JOY!"
	line "My heart...!"
	done

.MistyChampion:
	text "MISTY: CHAMPION"
	line "<PLAYER>! Wow!"
	para "...You still owe"
	line "me a bike, though."
	done

.BrockChampion:
	text "BROCK: You did it!"
	line "I'm so proud."
	para "Let's celebrate."
	line "I'll cook!"
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

.BrockMrFuji:
	text "BROCK: MR.FUJI"
	line "takes care of"
	para "orphaned #MON."
	line "Good man."
	done

.MistyBike:
	text "MISTY: Nice BIKE."
	line "Mine's still"
	para "fried, you know."
	line "PIKACHU did that."
	done

.MistyLostToYou:
	text "MISTY: OK, you"
	line "beat me. Fair and"
	para "square. Don't"
	line "rub it in!"
	done

.BrockTwoBadges:
	text "BROCK: Two BADGEs"
	line "down. Six to go!"
	done

.MistyBrockJoined:
	text "MISTY: So BROCK's"
	line "tagging along now?"
	para "Ugh. Fine."
	done

.BrockJoined:
	text "BROCK: I'll keep"
	line "an eye on you,"
	para "<PLAYER>. That's"
	line "a promise."
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
