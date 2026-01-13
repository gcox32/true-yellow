MACRO move
	db \1 ; animation (interchangeable with move id)
	db \2 ; effect
	db \3 ; power
	db \4 ; type
	db \5 percent ; accuracy
	db \6 ; pp
	ASSERT \6 <= 40, "PP must be 40 or less"
ENDM

Moves:
; Characteristics of each move.
	table_width MOVE_LENGTH
	move POUND,        NO_ADDITIONAL_EFFECT,        40, NORMAL,       100, 35
	move KARATE_CHOP,  NO_ADDITIONAL_EFFECT,        50, FIGHTING,     100, 25 ; type changed from NORMAL to FIGHTING
	move DOUBLESLAP,   TWO_TO_FIVE_ATTACKS_EFFECT,  15, NORMAL,        95, 10 ; accuracy changed from 85 to 95
	move COMET_PUNCH,  TWO_TO_FIVE_ATTACKS_EFFECT,  18, FIGHTING,      90, 15 ; type changed from NORMAL to FIGHTING, accuracy changed from 85 to 90
	move MEGA_PUNCH,   NO_ADDITIONAL_EFFECT,        80, NORMAL,        95, 20 ; accuracy changed from 85 to 95
	move PAY_DAY,      PAY_DAY_EFFECT,              40, NORMAL,       100, 20
	move FIRE_PUNCH,   BURN_SIDE_EFFECT1,           65, FIRE,         100, 15 ; power changed from 75 to 65
	move ICE_PUNCH,    FREEZE_SIDE_EFFECT1,         65, ICE,          100, 15 ; power changed from 75 to 65
	move THUNDERPUNCH, PARALYZE_SIDE_EFFECT1,       65, ELECTRIC,     100, 15 ; power changed from 75 to 65
	move SCRATCH,      NO_ADDITIONAL_EFFECT,        40, NORMAL,       100, 35
	move VICEGRIP,     NO_ADDITIONAL_EFFECT,        55, NORMAL,       100, 30
	move GUILLOTINE,   OHKO_EFFECT,                  1, BUG,           50,  5 ; type changed from NORMAL to BUG, accuracy changed from 30 to 50
	move RAZOR_WIND,   CHARGE_EFFECT,               80, FLYING,       100, 10 ; type changed from NORMAL to FLYING, accuracy changed from 75 to 100
	move SWORDS_DANCE, ATTACK_UP2_EFFECT,            0, NORMAL,       100, 30
	move CUT,          NO_ADDITIONAL_EFFECT,        50, BUG,           95, 30 ; type changed from NORMAL to BUG
	move GUST,         NO_ADDITIONAL_EFFECT,        40, FLYING,       100, 35 ; type changed from NORMAL to FLYING
	move WING_ATTACK,  NO_ADDITIONAL_EFFECT,        60, FLYING,       100, 35 ; power changed from 35 to 60
	move WHIRLWIND,    SWITCH_AND_TELEPORT_EFFECT,   0, FLYING,        85, 20 ; type changed from NORMAL to FLYING
	move FLY,          FLY_EFFECT,                  70, FLYING,        95, 15
	move BIND,         TRAPPING_EFFECT,             15, NORMAL,        85, 20 ; accuracy changed from 75 to 85
	move SLAM,         FLINCH_SIDE_EFFECT1,         80, DRAGON,        95, 20 ; type changed from NORMAL to DRAGON, accuracy changed from 75 to 95; added FLINCH_SIDE_EFFECT1 effect
	move VINE_WHIP,    NO_ADDITIONAL_EFFECT,        35, GRASS,        100, 20 ; pp changed from 10 to 20
	move STOMP,        FLINCH_SIDE_EFFECT2,         65, NORMAL,       100, 20
	move DOUBLE_KICK,  ATTACK_TWICE_EFFECT,         40, FIGHTING,     100, 30 ; power changed from 30 to 40
	move MEGA_KICK,    NO_ADDITIONAL_EFFECT,       100, NORMAL,        95, 10 ; power changed from 120 to 100, accuracy changed from 75 to 95, pp changed from 5 to 10
	move JUMP_KICK,    JUMP_KICK_EFFECT,            70, FIGHTING,      95, 25
	move ROLLING_KICK, FLINCH_SIDE_EFFECT2,         60, FIGHTING,      95, 15 ; accuracy changed from 85 to 95
	move SAND_ATTACK,  ACCURACY_DOWN1_EFFECT,        0, GROUND,       100, 15 ; type changed from NORMAL to GROUND
	move HEADBUTT,     FLINCH_SIDE_EFFECT2,         70, NORMAL,       100, 15
	move HORN_ATTACK,  NO_ADDITIONAL_EFFECT,        65, NORMAL,       100, 25
	move FURY_ATTACK,  TWO_TO_FIVE_ATTACKS_EFFECT,  15, NORMAL,        95, 20 ; accuracy change from 85 to 95
	move HORN_DRILL,   OHKO_EFFECT,                  1, NORMAL,        50,  5 ; accuracy changed from 30 to 50
	move TACKLE,       NO_ADDITIONAL_EFFECT,        35, NORMAL,        95, 35
	move BODY_SLAM,    PARALYZE_SIDE_EFFECT2,       85, NORMAL,       100, 15
	move WRAP,         TRAPPING_EFFECT,             15, NORMAL,        85, 20
	move TAKE_DOWN,    RECOIL_EFFECT,               90, NORMAL,        95, 20 ; accuracy changed from 85 to 95
	move THRASH,       THRASH_PETAL_DANCE_EFFECT,   90, DRAGON,       100, 20 ; type changed from NORMAL to DRAGON
	move DOUBLE_EDGE,  RECOIL_EFFECT,              100, NORMAL,       100, 15
	move TAIL_WHIP,    DEFENSE_DOWN1_EFFECT,         0, NORMAL,       100, 30
	move POISON_STING, POISON_SIDE_EFFECT1,         15, POISON,       100, 35
	move TWINEEDLE,    TWINEEDLE_EFFECT,            40, BUG,          100, 20 ; power changed from 25 to 40
	move PIN_MISSILE,  TWO_TO_FIVE_ATTACKS_EFFECT,  20, BUG,           95, 20 ; power changed from 14 to 20, accuracy changed from 85 to 95
	move LEER,         DEFENSE_DOWN1_EFFECT,         0, NORMAL,       100, 30
	move BITE,         FLINCH_SIDE_EFFECT1,         50, NORMAL,       100, 25 ; power changed from 60 to 50
	move GROWL,        ATTACK_DOWN1_EFFECT,          0, NORMAL,       100, 40
	move ROAR,         SWITCH_AND_TELEPORT_EFFECT,   0, NORMAL,       100, 20
	move SING,         SLEEP_EFFECT,                 0, NORMAL,        55, 15
	move SUPERSONIC,   CONFUSION_EFFECT,             0, NORMAL,        55, 20
	move SONICBOOM,    SPECIAL_DAMAGE_EFFECT,        1, FLYING,        90, 20
	move DISABLE,      DISABLE_EFFECT,               0, NORMAL,        85, 20 ; accuracy changed from 55 to 85
	move ACID,         DEFENSE_DOWN_SIDE_EFFECT,    40, POISON,       100, 30
	move EMBER,        BURN_SIDE_EFFECT1,           40, FIRE,         100, 25
	move FLAMETHROWER, BURN_SIDE_EFFECT1,           95, FIRE,         100, 15
	move MIST,         MIST_EFFECT,                  0, WATER,        100, 30 ; type changed from ICE to WATER
	move WATER_GUN,    NO_ADDITIONAL_EFFECT,        40, WATER,        100, 25
	move HYDRO_PUMP,   NO_ADDITIONAL_EFFECT,       120, WATER,         90,  5 ; accuracy changed from 80 to 90
	move SURF,         NO_ADDITIONAL_EFFECT,        95, WATER,        100, 15
	move ICE_BEAM,     FREEZE_SIDE_EFFECT1,         95, ICE,          100, 10
	move BLIZZARD,     FREEZE_SIDE_EFFECT1,        120, ICE,           90,  5
	move PSYBEAM,      CONFUSION_SIDE_EFFECT,       65, PSYCHIC_TYPE, 100, 20
	move BUBBLEBEAM,   SPEED_DOWN_SIDE_EFFECT,      65, WATER,        100, 20
	move AURORA_BEAM,  ATTACK_DOWN_SIDE_EFFECT,     75, ICE,          100, 20 ; power changed from 65 to 75
	move HYPER_BEAM,   HYPER_BEAM_EFFECT,          150, NORMAL,        95,  5 ; accuracy changed from 90 to 95
	move PECK,         NO_ADDITIONAL_EFFECT,        35, FLYING,       100, 35
	move DRILL_PECK,   NO_ADDITIONAL_EFFECT,        80, FLYING,       100, 20
	move SUBMISSION,   RECOIL_EFFECT,               90, FIGHTING,      95, 25 ; power changed from 80 to 90, accuracy changed from 80 to 95
	move LOW_KICK,     FLINCH_SIDE_EFFECT2,         50, FIGHTING,      95, 20 ; accuracy changed from 90 to 95
	move COUNTER,      NO_ADDITIONAL_EFFECT,         1, FIGHTING,     100, 20
	move SEISMIC_TOSS, SPECIAL_DAMAGE_EFFECT,        1, FIGHTING,     100, 20
	move STRENGTH,     NO_ADDITIONAL_EFFECT,        80, NORMAL,       100, 15
	move ABSORB,       DRAIN_HP_EFFECT,             30, GRASS,        100, 25 ; power changed from 20 to 30
	move MEGA_DRAIN,   DRAIN_HP_EFFECT,             60, GRASS,        100, 20 ; power changed from 40 to 60, pp changed from 10 to 20
	move LEECH_SEED,   LEECH_SEED_EFFECT,            0, GRASS,         90, 20 ; pp changed from 10 to 20
	move GROWTH,       SPECIAL_UP1_EFFECT,           0, NORMAL,       100, 30 ; pp changed from 40 to 30
	move RAZOR_LEAF,   NO_ADDITIONAL_EFFECT,        55, GRASS,         95, 25
	move SOLARBEAM,    CHARGE_EFFECT,              150, GRASS,        100, 10 ; power changed from 120 to 150
	move POISONPOWDER, POISON_EFFECT,                0, POISON,        85, 20 ; accuracy changed from 75 to 85, pp changed from 35 to 20
	move STUN_SPORE,   PARALYZE_EFFECT,              0, GRASS,         85, 20 ; accuracy changed from 75 to 85, pp changed from 30 to 20
	move SLEEP_POWDER, SLEEP_EFFECT,                 0, GRASS,         75, 15
	move PETAL_DANCE,  THRASH_PETAL_DANCE_EFFECT,   90, GRASS,        100, 20 ; power changed from 70 to 90
	move STRING_SHOT,  SPEED_DOWN1_EFFECT,           0, BUG,           95, 25 ; pp changed from 40 to 25
	move DRAGON_RAGE,  SPECIAL_DAMAGE_EFFECT,        1, DRAGON,       100, 10
	move FIRE_SPIN,    TRAPPING_EFFECT,             15, FIRE,          85, 15 ; accuracy changed from 70 to 85
	move THUNDERSHOCK, PARALYZE_SIDE_EFFECT1,       40, ELECTRIC,     100, 30
	move THUNDERBOLT,  PARALYZE_SIDE_EFFECT1,       95, ELECTRIC,     100, 15
	move THUNDER_WAVE, PARALYZE_EFFECT,              0, ELECTRIC,     100, 20
	move THUNDER,      PARALYZE_SIDE_EFFECT1,      120, ELECTRIC,      80, 10 ; accuracy changed from 70 to 80
	move ROCK_THROW,   NO_ADDITIONAL_EFFECT,        50, ROCK,          95, 15 ; accuracy changed from 65 to 95
	move EARTHQUAKE,   NO_ADDITIONAL_EFFECT,       100, GROUND,       100, 10
	move FISSURE,      OHKO_EFFECT,                  1, GROUND,        50,  5 ; accuracy changed from 30 to 50
	move DIG,          CHARGE_EFFECT,               60, GROUND,       100, 10 ; power changed from 100 to 60
	move TOXIC,        POISON_EFFECT,                0, POISON,        85, 10
	move CONFUSION,    CONFUSION_SIDE_EFFECT,       50, PSYCHIC_TYPE, 100, 25
	move PSYCHIC_M,    SPECIAL_DOWN_SIDE_EFFECT,    90, PSYCHIC_TYPE, 100, 10
	move HYPNOSIS,     SLEEP_EFFECT,                 0, PSYCHIC_TYPE,  70, 20 ; accuracy changed from 60 to 70
	move MEDITATE,     ATTACK_UP1_EFFECT,            0, PSYCHIC_TYPE, 100, 30 ; pp changed from 40 to 30
	move AGILITY,      SPEED_UP2_EFFECT,             0, PSYCHIC_TYPE, 100, 20 ; pp changed from 30 to 20
	move QUICK_ATTACK, NO_ADDITIONAL_EFFECT,        40, NORMAL,       100, 30
	move RAGE,         RAGE_EFFECT,                 20, NORMAL,       100, 20
	move TELEPORT,     SWITCH_AND_TELEPORT_EFFECT,   0, PSYCHIC_TYPE, 100, 10
	move NIGHT_SHADE,  SPECIAL_DAMAGE_EFFECT,        0, GHOST,        100, 15
	move MIMIC,        MIMIC_EFFECT,                 0, NORMAL,       100, 10
	move SCREECH,      DEFENSE_DOWN2_EFFECT,         0, NORMAL,        85, 30 ; pp changed from 40 to 30
	move DOUBLE_TEAM,  EVASION_UP1_EFFECT,           0, NORMAL,       100, 15
	move RECOVER,      HEAL_EFFECT,                  0, NORMAL,       100, 20
	move HARDEN,       DEFENSE_UP1_EFFECT,           0, NORMAL,       100, 20 ; pp changed from 30 to 20
	move MINIMIZE,     EVASION_UP1_EFFECT,           0, NORMAL,       100, 20
	move SMOKESCREEN,  ACCURACY_DOWN1_EFFECT,        0, POISON,       100, 20 ; type changed from NORMAL to POISON
	move CONFUSE_RAY,  CONFUSION_EFFECT,             0, GHOST,        100, 10
	move WITHDRAW,     DEFENSE_UP1_EFFECT,           0, WATER,        100, 30
	move DEFENSE_CURL, DEFENSE_UP1_EFFECT,           0, NORMAL,       100, 30 ; pp changed from 40 to 30
	move BARRIER,      DEFENSE_UP2_EFFECT,           0, PSYCHIC_TYPE, 100, 30
	move LIGHT_SCREEN, LIGHT_SCREEN_EFFECT,          0, PSYCHIC_TYPE, 100, 30
	move HAZE,         HAZE_EFFECT,                  0, POISON,       100, 30 ; type changed from ICE to POISON
	move REFLECT,      REFLECT_EFFECT,               0, PSYCHIC_TYPE, 100, 20
	move FOCUS_ENERGY, FOCUS_ENERGY_EFFECT,          0, FIGHTING,     100, 30 ; type changed from NORMAL to FIGHTING
	move BIDE,         BIDE_EFFECT,                  0, NORMAL,       100, 10
	move METRONOME,    METRONOME_EFFECT,             0, NORMAL,       100, 10
	move MIRROR_MOVE,  MIRROR_MOVE_EFFECT,           0, FLYING,       100, 20
	move SELFDESTRUCT, EXPLODE_EFFECT,             130, NORMAL,       100,  5
	move EGG_BOMB,     NO_ADDITIONAL_EFFECT,       100, FLYING,        90, 10 ; accuracy changed from 75 to 90, type changed from NORMAL to FLYING
	move LICK,         PARALYZE_SIDE_EFFECT2,       30, GHOST,        100, 30 ; power changed from 20 to 30
	move SMOG,         POISON_SIDE_EFFECT2,         30, POISON,        85, 20 ; power changed from 20 to 30, accuracy changed from 70 to 85
	move SLUDGE,       POISON_SIDE_EFFECT2,         65, POISON,       100, 20
	move BONE_CLUB,    FLINCH_SIDE_EFFECT1,         65, GROUND,       100, 20 ; accuracy changed from 85 to 100
	move FIRE_BLAST,   BURN_SIDE_EFFECT2,          120, FIRE,          85,  5
	move WATERFALL,    NO_ADDITIONAL_EFFECT,        80, WATER,        100, 15
	move CLAMP,        TRAPPING_EFFECT,             35, WATER,         85, 10 ; accuracy changed from 75 to 85
	move SWIFT,        SWIFT_EFFECT,                60, NORMAL,       100, 20
	move SKULL_BASH,   CHARGE_EFFECT,              100, NORMAL,       100, 15
	move SPIKE_CANNON, TWO_TO_FIVE_ATTACKS_EFFECT,  20, NORMAL,       100, 15
	move CONSTRICT,    SPEED_DOWN_SIDE_EFFECT,      40, NORMAL,       100, 30 ; power changed from 10 to 40, pp changed from 35 to 30
	move AMNESIA,      SPECIAL_UP2_EFFECT,           0, PSYCHIC_TYPE, 100, 20
	move KINESIS,      ACCURACY_DOWN1_EFFECT,        0, PSYCHIC_TYPE, 100, 15 ; accuracy changed from 80 to 100
	move SOFTBOILED,   HEAL_EFFECT,                  0, NORMAL,       100, 10
	move HI_JUMP_KICK, JUMP_KICK_EFFECT,            85, FIGHTING,      90, 20
	move GLARE,        PARALYZE_EFFECT,              0, NORMAL,        85, 30 ; accuracy changed from 75 to 85
	move DREAM_EATER,  DREAM_EATER_EFFECT,         100, GHOST,        100, 15 ; type changed from PSYCHIC_TYPE to GHOST
	move POISON_GAS,   POISON_EFFECT,                0, POISON,        85, 20 ; accuracy changed from 55 to 85, pp changed from 40 to 20
	move BARRAGE,      TWO_TO_FIVE_ATTACKS_EFFECT,  20, GRASS,         85, 20 ; power changed from 15 to 20, type changed from NORMAL to GRASS
	move LEECH_LIFE,   DRAIN_HP_EFFECT,             40, BUG,          100, 15 ; power changed from 20 to 40
	move LOVELY_KISS,  SLEEP_EFFECT,                 0, NORMAL,        85, 10 ; accuracy changed from 75 to 85
	move SKY_ATTACK,   CHARGE_EFFECT,              150, FLYING,       100,  5 ; power changed from 140 to 150, accuracy changed from 90 to 100
	move TRANSFORM,    TRANSFORM_EFFECT,             0, NORMAL,       100, 10
	move BUBBLE,       SPEED_DOWN_SIDE_EFFECT,      20, WATER,        100, 30
	move DIZZY_PUNCH,  NO_ADDITIONAL_EFFECT,        70, NORMAL,       100, 10
	move SPORE,        SLEEP_EFFECT,                 0, GRASS,        100, 15
	move FLASH,        ACCURACY_DOWN1_EFFECT,        0, NORMAL,       100, 20 ; accuracy changed from 70 to 100
	move PSYWAVE,      SPECIAL_DAMAGE_EFFECT,        1, PSYCHIC_TYPE, 100, 15 ; accuracy changed from 80 to 100
	move SPLASH,       SPLASH_EFFECT,                0, WATER,        100, 10 ; type changed from NORMAL to WATER, pp changed from 40 to 10
	move ACID_ARMOR,   DEFENSE_UP2_EFFECT,           0, POISON,       100, 20 ; pp changed from 40 to 20
	move CRABHAMMER,   NO_ADDITIONAL_EFFECT,        90, WATER,         85, 10
	move EXPLOSION,    EXPLODE_EFFECT,             170, NORMAL,       100,  5
	move FURY_SWIPES,  TWO_TO_FIVE_ATTACKS_EFFECT,  20, NORMAL,        85, 15 ; power changed from 18 to 20, accuracy changed from 80 to 85
	move BONEMERANG,   ATTACK_TWICE_EFFECT,         50, GROUND,        90, 10
	move REST,         HEAL_EFFECT,                  0, NORMAL,       100, 10 ; type changed from PSYCHIC_TYPE to NORMAL
	move ROCK_SLIDE,   NO_ADDITIONAL_EFFECT,        90, ROCK,          90, 10 ; power changed from 75 to 90
	move HYPER_FANG,   FLINCH_SIDE_EFFECT1,         80, NORMAL,        90, 15
	move SHARPEN,      ATTACK_UP1_EFFECT,            0, NORMAL,       100, 30
	move CONVERSION,   CONVERSION_EFFECT,            0, NORMAL,       100, 30
	move TRI_ATTACK,   NO_ADDITIONAL_EFFECT,        80, NORMAL,       100, 10
	move SUPER_FANG,   SUPER_FANG_EFFECT,            1, NORMAL,        95, 10 ; accuracy changed from 90 to 95
	move SLASH,        NO_ADDITIONAL_EFFECT,        70, NORMAL,       100, 20
	move SUBSTITUTE,   SUBSTITUTE_EFFECT,            0, NORMAL,       100, 10
	move STRUGGLE,     RECOIL_EFFECT,               50, NORMAL,       100, 10
	assert_table_length NUM_ATTACKS
