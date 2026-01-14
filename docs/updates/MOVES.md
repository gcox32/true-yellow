# Moves

## Moves
A simple table, found in `/data/moves/moves.asm`, defines each move's corresponding animation, effect, power, type, percent accuracy, and pp. We adjust the values in this table to most quickly. Below are all the moves changed and how they were changed.

| Move | Effect | Power | Type | Accuracy | PP | Update
|------|--------|-------|------|----------|----|--------|
| POUND | NO_ADDITIONAL_EFFECT | 40 | NORMAL | 100 | 35 | |
| KARATE_CHOP | NO_ADDITIONAL_EFFECT | 50 | **FIGHTING** | 100 | 25 | type changed from NORMAL to FIGHTING |
| DOUBLESLAP | TWO_TO_FIVE_ATTACKS_EFFECT | 15 | NORMAL | 95 | 10 | accuracy changed from 85 to 95 |
| COMET_PUNCH | TWO_TO_FIVE_ATTACKS_EFFECT | 18 | FIGHTING | 90 | 15 | type changed from NORMAL to FIGHTING, accuracy changed from 85 to 90 |
| MEGA_PUNCH | NO_ADDITIONAL_EFFECT | 80 | NORMAL | 95 | 20 | accuracy changed from 85 to 95 |
| PAY_DAY | PAY_DAY_EFFECT | 40 | NORMAL | 100 | 20 |
| FIRE_PUNCH | BURN_SIDE_EFFECT1 | 65 | FIRE | 100 | 15 | power changed from 75 to 65 |
| ICE_PUNCH | FREEZE_SIDE_EFFECT1 | 65 | ICE | 100 | 15 | power changed from 75 to 65 |
| THUNDERPUNCH | PARALYZE_SIDE_EFFECT1 | 65 | ELECTRIC | 100 | 15 | power changed from 75 to 65 |
| SCRATCH | NO_ADDITIONAL_EFFECT | 40 | NORMAL | 100 | 35 |
| VICEGRIP | NO_ADDITIONAL_EFFECT | 55 | NORMAL | 100 | 30 |
| GUILLOTINE | OHKO_EFFECT | 1 | BUG | 50 | 5 | type changed from NORMAL to BUG, accuracy changed from 30 to 50 |
| RAZOR_WIND | CHARGE_EFFECT | 80 | FLYING | 100 | 10 | type changed from NORMAL to FLYING, accuracy changed from 75 to 100 |
| SWORDS_DANCE | ATTACK_UP2_EFFECT | 0 | NORMAL | 100 | 30 |
| CUT | NO_ADDITIONAL_EFFECT | 50 | BUG | 95 | 30 | type changed from NORMAL to BUG |
| GUST | NO_ADDITIONAL_EFFECT | 40 | FLYING | 100 | 35 | type changed from NORMAL to FLYING |
| WING_ATTACK | NO_ADDITIONAL_EFFECT | 60 | FLYING | 100 | 35 | power changed from 35 to 60 |
| WHIRLWIND | SWITCH_AND_TELEPORT_EFFECT | 0 | FLYING | 85 | 20 | type changed from NORMAL to FLYING |
| FLY | FLY_EFFECT | 70 | FLYING | 95 | 15 |
| BIND | TRAPPING_EFFECT | 15 | NORMAL | 85 | 20 | accuracy changed from 75 to 85 |
| SLAM | FLINCH_SIDE_EFFECT1 | 80 | DRAGON | 95 | 20 | type changed from NORMAL to DRAGON, accuracy changed from 75 to 95; added FLINCH_SIDE_EFFECT1 effect |
| VINE_WHIP | NO_ADDITIONAL_EFFECT | 35 | GRASS | 100 | 20 | pp changed from 10 to 20 |
| STOMP | FLINCH_SIDE_EFFECT2 | 65 | NORMAL | 100 | 20 |
| DOUBLE_KICK | ATTACK_TWICE_EFFECT | 40 | FIGHTING | 100 | 30 | power changed from 30 to 40 |
| MEGA_KICK | NO_ADDITIONAL_EFFECT | 100 | NORMAL | 95 | 10 | power changed from 120 to 100, accuracy changed from 75 to 95, pp changed from 5 to 10 |
| JUMP_KICK | JUMP_KICK_EFFECT | 70 | FIGHTING | 95 | 25 |
| ROLLING_KICK | FLINCH_SIDE_EFFECT2 | 60 | FIGHTING | 95 | 15 | accuracy changed from 85 to 95 |
| SAND_ATTACK | ACCURACY_DOWN1_EFFECT | 0 | GROUND | 100 | 15 | type changed from NORMAL to GROUND |
| HEADBUTT | FLINCH_SIDE_EFFECT2 | 70 | NORMAL | 100 | 15 |
| HORN_ATTACK | NO_ADDITIONAL_EFFECT | 65 | NORMAL | 100 | 25 |
| FURY_ATTACK | TWO_TO_FIVE_ATTACKS_EFFECT | 15 | NORMAL | 95 | 20 | accuracy change from 85 to 95 |
| HORN_DRILL | OHKO_EFFECT | 1 | NORMAL | 50 | 5 | accuracy changed from 30 to 50 |
| TACKLE | NO_ADDITIONAL_EFFECT | 35 | NORMAL | 95 | 35 |
| BODY_SLAM | PARALYZE_SIDE_EFFECT2 | 85 | NORMAL | 100 | 15 |
| WRAP | TRAPPING_EFFECT | 15 | NORMAL | 85 | 20 |
| TAKE_DOWN | RECOIL_EFFECT | 90 | NORMAL | 95 | 20 | accuracy changed from 85 to 95 |
| THRASH | THRASH_PETAL_DANCE_EFFECT | 90 | DRAGON | 100 | 20 | type changed from NORMAL to DRAGON |
| DOUBLE_EDGE | RECOIL_EFFECT | 100 | NORMAL | 100 | 15 |
| TAIL_WHIP | DEFENSE_DOWN1_EFFECT | 0 | NORMAL | 100 | 30 |
| POISON_STING | POISON_SIDE_EFFECT1 | 15 | POISON | 100 | 35 |
| TWINEEDLE | TWINEEDLE_EFFECT | 40 | BUG | 100 | 20 | power changed from 25 to 40 |
| PIN_MISSILE | TWO_TO_FIVE_ATTACKS_EFFECT | 20 | BUG | 95 | 20 | power changed from 14 to 20, accuracy changed from 85 to 95 |
| LEER | DEFENSE_DOWN1_EFFECT | 0 | NORMAL | 100 | 30 |
| BITE | FLINCH_SIDE_EFFECT1 | 50 | NORMAL | 100 | 25 | power changed from 60 to 50 |
| GROWL | ATTACK_DOWN1_EFFECT | 0 | NORMAL | 100 | 40 |
| ROAR | SWITCH_AND_TELEPORT_EFFECT | 0 | NORMAL | 100 | 20 |
| SING | SLEEP_EFFECT | 0 | NORMAL | 55 | 15 |
| SUPERSONIC | CONFUSION_EFFECT | 0 | NORMAL | 55 | 20 |
| SONICBOOM | SPECIAL_DAMAGE_EFFECT | 1 | FLYING | 90 | 20 |
| DISABLE | DISABLE_EFFECT | 0 | NORMAL | 85 | 20 | accuracy changed from 55 to 85 |
| ACID | DEFENSE_DOWN_SIDE_EFFECT | 40 | POISON | 100 | 30 |
| EMBER | BURN_SIDE_EFFECT1 | 40 | FIRE | 100 | 25 |
| FLAMETHROWER | BURN_SIDE_EFFECT1 | 95 | FIRE | 100 | 15 |
| MIST | MIST_EFFECT | 0 | WATER | 100 | 30 | type changed from ICE to WATER |
| WATER_GUN | NO_ADDITIONAL_EFFECT | 40 | WATER | 100 | 25 |
| HYDRO_PUMP | NO_ADDITIONAL_EFFECT | 120 | WATER | 90 | 5 | accuracy changed from 80 to 90 |
| SURF | NO_ADDITIONAL_EFFECT | 95 | WATER | 100 | 15 |
| ICE_BEAM | FREEZE_SIDE_EFFECT1 | 95 | ICE | 100 | 10 |
| BLIZZARD | FREEZE_SIDE_EFFECT1 | 120 | ICE | 90 | 5 |
| PSYBEAM | CONFUSION_SIDE_EFFECT | 65 | PSYCHIC_TYPE | 100 | 20 |
| BUBBLEBEAM | SPEED_DOWN_SIDE_EFFECT | 65 | WATER | 100 | 20 |
| AURORA_BEAM | ATTACK_DOWN_SIDE_EFFECT | 75 | ICE | 100 | 20 | power changed from 65 to 75 |
| HYPER_BEAM | HYPER_BEAM_EFFECT | 150 | NORMAL | 95 | 5 | accuracy changed from 90 to 95 |
| PECK | NO_ADDITIONAL_EFFECT | 35 | FLYING | 100 | 35 |
| DRILL_PECK | NO_ADDITIONAL_EFFECT | 80 | FLYING | 100 | 20 |
| SUBMISSION | RECOIL_EFFECT | 90 | FIGHTING | 95 | 25 | power changed from 80 to 90, accuracy changed from 80 to 95 |
| LOW_KICK | FLINCH_SIDE_EFFECT2 | 50 | FIGHTING | 95 | 20 | accuracy changed from 90 to 95 |
| COUNTER | NO_ADDITIONAL_EFFECT | 1 | FIGHTING | 100 | 20 |
| SEISMIC_TOSS | SPECIAL_DAMAGE_EFFECT | 1 | FIGHTING | 100 | 20 |
| STRENGTH | NO_ADDITIONAL_EFFECT | 80 | NORMAL | 100 | 15 |
| ABSORB | DRAIN_HP_EFFECT | 30 | GRASS | 100 | 25 | power changed from 20 to 30 |
| MEGA_DRAIN | DRAIN_HP_EFFECT | 60 | GRASS | 100 | 20 | power changed from 40 to 60, pp changed from 10 to 20 |
| LEECH_SEED | LEECH_SEED_EFFECT | 0 | GRASS | 90 | 20 | pp changed from 10 to 20 |
| GROWTH | SPECIAL_UP1_EFFECT | 0 | NORMAL | 100 | 30 | pp changed from 40 to 30 |
| RAZOR_LEAF | NO_ADDITIONAL_EFFECT | 55 | GRASS | 95 | 25 |
| SOLARBEAM | CHARGE_EFFECT | 150 | GRASS | 100 | 10 | power changed from 120 to 150 |
| POISONPOWDER | POISON_EFFECT | 0 | POISON | 85 | 20 | accuracy changed from 75 to 85, pp changed from 35 to 20 |
| STUN_SPORE | PARALYZE_EFFECT | 0 | GRASS | 85 | 20 | accuracy changed from 75 to 85, pp changed from 30 to 20 |
| SLEEP_POWDER | SLEEP_EFFECT | 0 | GRASS | 75 | 15 |
| PETAL_DANCE | THRASH_PETAL_DANCE_EFFECT | 90 | GRASS | 100 | 20 | power changed from 70 to 90 |
| STRING_SHOT | SPEED_DOWN1_EFFECT | 0 | BUG | 95 | 25 | pp changed from 40 to 25 |
| DRAGON_RAGE | SPECIAL_DAMAGE_EFFECT | 1 | DRAGON | 100 | 10 |
| FIRE_SPIN | TRAPPING_EFFECT | 15 | FIRE | 85 | 15 | accuracy changed from 70 to 85 |
| THUNDERSHOCK | PARALYZE_SIDE_EFFECT1 | 40 | ELECTRIC | 100 | 30 |
| THUNDERBOLT | PARALYZE_SIDE_EFFECT1 | 95 | ELECTRIC | 100 | 15 |
| THUNDER_WAVE | PARALYZE_EFFECT | 0 | ELECTRIC | 100 | 20 |
| THUNDER | PARALYZE_SIDE_EFFECT1 | 120 | ELECTRIC | 80 | 10 | accuracy changed from 70 to 80 |
| ROCK_THROW | NO_ADDITIONAL_EFFECT | 50 | ROCK | 95 | 15 | accuracy changed from 65 to 95 |
| EARTHQUAKE | NO_ADDITIONAL_EFFECT | 100 | GROUND | 100 | 10 |
| FISSURE | OHKO_EFFECT | 1 | GROUND | 50 | 5 | accuracy changed from 30 to 50 |
| DIG | CHARGE_EFFECT | 60 | GROUND | 100 | 10 | power changed from 100 to 60 |
| TOXIC | POISON_EFFECT | 0 | POISON | 85 | 10 |
| CONFUSION | CONFUSION_SIDE_EFFECT | 50 | PSYCHIC_TYPE | 100 | 25 |
| PSYCHIC_M | SPECIAL_DOWN_SIDE_EFFECT | 90 | PSYCHIC_TYPE | 100 | 10 |
| HYPNOSIS | SLEEP_EFFECT | 0 | PSYCHIC_TYPE | 70 | 20 | accuracy changed from 60 to 70 |
| MEDITATE | ATTACK_UP1_EFFECT | 0 | PSYCHIC_TYPE | 100 | 30 | pp changed from 40 to 30 |
| AGILITY | SPEED_UP2_EFFECT | 0 | PSYCHIC_TYPE | 100 | 20 | pp changed from 30 to 20 |
| QUICK_ATTACK | NO_ADDITIONAL_EFFECT | 40 | NORMAL | 100 | 30 |
| RAGE | RAGE_EFFECT | 20 | NORMAL | 100 | 20 |
| TELEPORT | SWITCH_AND_TELEPORT_EFFECT | 0 | PSYCHIC_TYPE | 100 | 10 |
| NIGHT_SHADE | SPECIAL_DAMAGE_EFFECT | 0 | GHOST | 100 | 15 |
| MIMIC | MIMIC_EFFECT | 0 | NORMAL | 100 | 10 |
| SCREECH | DEFENSE_DOWN2_EFFECT | 0 | NORMAL | 85 | 30 | pp changed from 40 to 30 |
| DOUBLE_TEAM | EVASION_UP1_EFFECT | 0 | NORMAL | 100 | 15 |
| RECOVER | HEAL_EFFECT | 0 | NORMAL | 100 | 20 |
| HARDEN | DEFENSE_UP1_EFFECT | 0 | NORMAL | 100 | 20 | pp changed from 30 to 20 |
| MINIMIZE | EVASION_UP1_EFFECT | 0 | NORMAL | 100 | 20 |
| SMOKESCREEN | ACCURACY_DOWN1_EFFECT | 0 | POISON | 100 | 20 | type changed from NORMAL to POISON |
| CONFUSE_RAY | CONFUSION_EFFECT | 0 | GHOST | 100 | 10 |
| WITHDRAW | DEFENSE_UP1_EFFECT | 0 | WATER | 100 | 30 |
| DEFENSE_CURL | DEFENSE_UP1_EFFECT | 0 | NORMAL | 100 | 30 | pp changed from 40 to 30 |
| BARRIER | DEFENSE_UP2_EFFECT | 0 | PSYCHIC_TYPE | 100 | 30 |
| LIGHT_SCREEN | LIGHT_SCREEN_EFFECT | 0 | PSYCHIC_TYPE | 100 | 30 |
| HAZE | HAZE_EFFECT | 0 | POISON | 100 | 30 | type changed from ICE to POISON |
| REFLECT | REFLECT_EFFECT | 0 | PSYCHIC_TYPE | 100 | 20 |
| FOCUS_ENERGY | FOCUS_ENERGY_EFFECT | 0 | FIGHTING | 100 | 30 | type changed from NORMAL to FIGHTING |
| BIDE | BIDE_EFFECT | 0 | NORMAL | 100 | 10 |
| METRONOME | METRONOME_EFFECT | 0 | NORMAL | 100 | 10 |
| MIRROR_MOVE | MIRROR_MOVE_EFFECT | 0 | FLYING | 100 | 20 |
| SELFDESTRUCT | EXPLODE_EFFECT | 130 | NORMAL | 100 | 5 |
| EGG_BOMB | NO_ADDITIONAL_EFFECT | 100 | FLYING | 90 | 10 | accuracy changed from 75 to 90, type changed from NORMAL to FLYING |
| LICK | PARALYZE_SIDE_EFFECT2 | 30 | GHOST | 100 | 30 | power changed from 20 to 30 |
| SMOG | POISON_SIDE_EFFECT2 | 30 | POISON | 85 | 20 | power changed from 20 to 30, accuracy changed from 70 to 85 |
| SLUDGE | POISON_SIDE_EFFECT2 | 65 | POISON | 100 | 20 |
| BONE_CLUB | FLINCH_SIDE_EFFECT1 | 65 | GROUND | 100 | 20 | accuracy changed from 85 to 100 |
| FIRE_BLAST | BURN_SIDE_EFFECT2 | 120 | FIRE | 85 | 5 |
| WATERFALL | NO_ADDITIONAL_EFFECT | 80 | WATER | 100 | 15 |
| CLAMP | TRAPPING_EFFECT | 35 | WATER | 85 | 10 | accuracy changed from 75 to 85 |
| SWIFT | SWIFT_EFFECT | 60 | NORMAL | 100 | 20 |
| SKULL_BASH | CHARGE_EFFECT | 100 | NORMAL | 100 | 15 |
| SPIKE_CANNON | TWO_TO_FIVE_ATTACKS_EFFECT | 20 | NORMAL | 100 | 15 |
| CONSTRICT | SPEED_DOWN_SIDE_EFFECT | 40 | NORMAL | 100 | 30 | power changed from 10 to 40, pp changed from 35 to 30 |
| AMNESIA | SPECIAL_UP2_EFFECT | 0 | PSYCHIC_TYPE | 100 | 20 |
| KINESIS | ACCURACY_DOWN1_EFFECT | 0 | PSYCHIC_TYPE | 100 | 15 | accuracy changed from 80 to 100 |
| SOFTBOILED | HEAL_EFFECT | 0 | NORMAL | 100 | 10 |
| HI_JUMP_KICK | JUMP_KICK_EFFECT | 85 | FIGHTING | 90 | 20 |
| GLARE | PARALYZE_EFFECT | 0 | NORMAL | 85 | 30 | accuracy changed from 75 to 85 |
| DREAM_EATER | DREAM_EATER_EFFECT | 100 | GHOST | 100 | 15 | type changed from PSYCHIC_TYPE to GHOST |
| POISON_GAS | POISON_EFFECT | 0 | POISON | 85 | 20 | accuracy changed from 55 to 85, pp changed from 40 to 20 |
| BARRAGE | TWO_TO_FIVE_ATTACKS_EFFECT | 20 | GRASS | 85 | 20 | power changed from 15 to 20, type changed from NORMAL to GRASS |
| LEECH_LIFE | DRAIN_HP_EFFECT | 40 | BUG | 100 | 15 | power changed from 20 to 40 |
| LOVELY_KISS | SLEEP_EFFECT | 0 | NORMAL | 85 | 10 | accuracy changed from 75 to 85 |
| SKY_ATTACK | CHARGE_EFFECT | 150 | FLYING | 100 | 5 | power changed from 140 to 150, accuracy changed from 90 to 100 |
| TRANSFORM | TRANSFORM_EFFECT | 0 | NORMAL | 100 | 10 |
| BUBBLE | SPEED_DOWN_SIDE_EFFECT | 20 | WATER | 100 | 30 |
| DIZZY_PUNCH | NO_ADDITIONAL_EFFECT | 70 | NORMAL | 100 | 10 |
| SPORE | SLEEP_EFFECT | 0 | GRASS | 100 | 15 |
| FLASH | ACCURACY_DOWN1_EFFECT | 0 | NORMAL | 100 | 20 | accuracy changed from 70 to 100 |
| PSYWAVE | SPECIAL_DAMAGE_EFFECT | 1 | PSYCHIC_TYPE | 100 | 15 | accuracy changed from 80 to 100 |
| SPLASH | SPLASH_EFFECT | 0 | WATER | 100 | 10 | type changed from NORMAL to WATER, pp changed from 40 to 10 |
| ACID_ARMOR | DEFENSE_UP2_EFFECT | 0 | POISON | 100 | 20 | pp changed from 40 to 20 |
| CRABHAMMER | NO_ADDITIONAL_EFFECT | 90 | WATER | 85 | 10 |
| EXPLOSION | EXPLODE_EFFECT | 170 | NORMAL | 100 | 5 |
| FURY_SWIPES | TWO_TO_FIVE_ATTACKS_EFFECT | 20 | NORMAL | 85 | 15 | power changed from 18 to 20, accuracy changed from 80 to 85 |
| BONEMERANG | ATTACK_TWICE_EFFECT | 50 | GROUND | 90 | 10 |
| REST | HEAL_EFFECT | 0 | NORMAL | 100 | 10 | type changed from PSYCHIC_TYPE to NORMAL |
| ROCK_SLIDE | FLINCH_SIDE_EFFECT2 | 90 | ROCK | 90 | 10 | power changed from 75 to 90 |
| HYPER_FANG | FLINCH_SIDE_EFFECT1 | 80 | NORMAL | 90 | 15 |
| SHARPEN | ATTACK_UP1_EFFECT | 0 | NORMAL | 100 | 30 |
| CONVERSION | CONVERSION_EFFECT | 0 | NORMAL | 100 | 30 |
| TRI_ATTACK | NO_ADDITIONAL_EFFECT | 80 | NORMAL | 100 | 10 | TRIATTACK_EFFECT added |
| SUPER_FANG | SUPER_FANG_EFFECT | 1 | NORMAL | 95 | 10 | accuracy changed from 90 to 95 |
| SLASH | NO_ADDITIONAL_EFFECT | 70 | NORMAL | 100 | 20 |
| SUBSTITUTE | SUBSTITUTE_EFFECT | 0 | NORMAL | 100 | 10 |
| STRUGGLE | RECOIL_EFFECT | 50 | NORMAL | 100 | 10 | type changed from NORMAL to TYPELESS |

## Animations

## Effects
- new dope effect for `TRI_ATTACK`