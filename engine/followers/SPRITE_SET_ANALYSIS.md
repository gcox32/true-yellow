# Sprite Set Analysis for Follower Integration

## Goal
Add SPRITE_MISTY to slot 1 and SPRITE_BROCK to slot 2 of each sprite set.
This requires removing 2 sprites from each set to stay within the 11-slot limit.

The overworld sprite sets can be found in `data/maps/sprite_sets.asm` and each map's object in `data/maps/objects/`. (note: only outdoor maps needed to be handled as indoor maps loaded in NPCs differently)

## Format
- Slot 0: PIKACHU (keep)
- Slot 1: MISTY (new)
- Slot 2: BROCK (new)
- Slots 3-8: 6 walking NPC sprites
- Slots 9-10: 2 still sprites (POKE_BALL, SNORLAX, FOSSIL, etc.)

---

## 1. SPRITESET_PALLET_VIRIDIAN
**Maps:** PalletTown, ViridianCity, CinnabarIsland, Route1, Route21, Route22

**Current set:**
```
PIKACHU, BLUE, YOUNGSTER, BRUNETTE_GIRL, FISHER, COOLTRAINER_M, GAMBLER, OAK, GIRL, POKE_BALL, GAMBLER_ASLEEP
```

**Actually used:** FISHER(6), YOUNGSTER(4), GAMBLER(4), GIRL(3), BLUE(2), OAK(1), GAMBLER_ASLEEP(1)

**NOT used:** BRUNETTE_GIRL, COOLTRAINER_M, POKE_BALL

**WARNING:** SWIMMER(5) and MISTY(1) are used but NOT in set - map may need fixing?

**Maps to audit:** Check where SWIMMER is used (likely Route21?) - need to replace with different sprite or change map

---

## 2. SPRITESET_PEWTER_CERULEAN
**Maps:** PewterCity, CeruleanCity, Route3, Route4, Route9, Route24, Route25

**Current set:**
```
PIKACHU, YOUNGSTER, ROCKET, SUPER_NERD, HIKER, BLUE, OFFICER_JENNY, COOLTRAINER_F, COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2
```

**Actually used:** COOLTRAINER_F(14), YOUNGSTER(13), COOLTRAINER_M(9), SUPER_NERD(6), HIKER(6), POKE_BALL(5), OFFICER_JENNY(2), ROCKET(1), BLUE(1)

**NOT used:** UNUSED_GAMBLER_ASLEEP_2

Note: COOLTRAINER_M moved to still sprite slot since heavily used

**Maps to audit:** Cerulean City

---

## 3. SPRITESET_LAVENDER
**Maps:** LavenderTown (+ Route10 north portion via split)

**Current set:**
```
PIKACHU, LITTLE_GIRL, GIRL, SUPER_NERD, HIKER, GAMBLER, MONSTER, COOLTRAINER_F, COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2
```

**Actually used in LavenderTown:** LITTLE_GIRL(1), COOLTRAINER_M(1), SUPER_NERD(1)

**NOT used (in LavenderTown):** GIRL, HIKER, GAMBLER, MONSTER, COOLTRAINER_F, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2

**Maps to audit:** Check Route10 for GIRL usage before removing

---

## 4. SPRITESET_VERMILION
**Maps:** VermilionCity (+ Route6 south, Route11 west via splits)

**Current set:**
```
PIKACHU, OFFICER_JENNY, SUPER_NERD, YOUNGSTER, GAMBLER, MONSTER, SAILOR, COOLTRAINER_F, COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2
```

**Actually used:** COOLTRAINER_F(1), GAMBLER(2), MONSTER(1), OFFICER_JENNY(1), SAILOR(2)

**NOT used:** SUPER_NERD, YOUNGSTER, COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2

**Maps to audit:** Check Route6, Route11 for SUPER_NERD usage

---

## 5. SPRITESET_CELADON
**Maps:** CeladonCity (+ Route7 west, Route16 east via splits)

**Current set:**
```
PIKACHU, LITTLE_GIRL, LITTLE_BOY, GIRL, FISHER, MIDDLE_AGED_MAN, GRAMPS, MONSTER, ROCKET, POKE_BALL, SNORLAX
```

**Actually used:** FISHER(1), GIRL(1), GRAMPS(3), LITTLE_GIRL(1), MONSTER(1), ROCKET(2)

**NOT used:** LITTLE_BOY, MIDDLE_AGED_MAN, POKE_BALL, SNORLAX

**Maps to audit:** Check Route7, Route16 for LITTLE_BOY/MIDDLE_AGED_MAN usage

---

## 6. SPRITESET_SAFFRON
**Maps:** SaffronCity (+ Route5 south, Route7 east, Route8 west via splits)

**Current set:**
```
PIKACHU, ROCKET, SCIENTIST, SILPH_WORKER_M, SILPH_WORKER_F, GENTLEMAN, BIRD, ROCKER, COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2
```

**Actually used:** BIRD(1), GENTLEMAN(1), ROCKER(1), ROCKET(8), SCIENTIST(1), SILPH_WORKER_F(1), SILPH_WORKER_M(1)

**NOT used:** COOLTRAINER_M, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2

**Maps to audit:** Check Route5, Route7, Route8 for COOLTRAINER_M usage

---

## 7. SPRITESET_INDIGO
**Maps:** IndigoPlateau, Route23

**Current set:**
```
PIKACHU, GYM_GUIDE, MONSTER, BLUE, COOLTRAINER_F, COOLTRAINER_M, SWIMMER, GUARD, GAMBLER, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2
```

**Actually used:** GUARD(5), SWIMMER(2)

**NOT used:** GYM_GUIDE, MONSTER, BLUE, COOLTRAINER_F, COOLTRAINER_M, GAMBLER, POKE_BALL, UNUSED_GAMBLER_ASLEEP_2

**Maps to audit:** Minimal - very few sprites used

---

## 8. SPRITESET_FUCHSIA
**Maps:** FuchsiaCity, Route19

**Current set:**
```
PIKACHU, COOLTRAINER_M, CHANSEY, FISHER, GAMBLER, MONSTER, SEEL, SWIMMER, YOUNGSTER, POKE_BALL, FOSSIL
```

**Actually used:** ALL sprites are used! CHANSEY(1), COOLTRAINER_M(2), FISHER(1), FOSSIL(1), GAMBLER(1), MONSTER(2), POKE_BALL(1), SEEL(1), SWIMMER(8), YOUNGSTER(2)

**PROBLEM:** This set is FULL. Must remove 2 actually-used sprites.

Note: unfortunately, Fuchsia City is full of unique sprites because of the area in front of the Safari Zone, and there's no clean way to keep that feel _and_ add two followers. Unless I come up with a novel solution, two of the Pokemon enclosures had to get cut.

Second note: we should be sure to come back and edit the text on a sign or something to pay homage to the removed Lapras and Chansey (they were set free?)

**Maps to audit:** Find and replace the SEEL and CHANSEY NPCs in FuchsiaCity

---

## 9. SPRITESET_SILENCE_BRIDGE
**Maps:** Route13, Route14 (+ Route12 south, Route15 east via splits)

**Current set:**
```
PIKACHU, BIKER, SUPER_NERD, MIDDLE_AGED_MAN, COOLTRAINER_F, COOLTRAINER_M, BEAUTY, FISHER, ROCKER, POKE_BALL, SNORLAX
```

**Actually used:** BEAUTY(2), BIKER(5), COOLTRAINER_F(4), COOLTRAINER_M(9)

**NOT used:** SUPER_NERD, MIDDLE_AGED_MAN, FISHER, ROCKER, POKE_BALL, SNORLAX

**Maps to audit:** Check Route12, Route15 for SUPER_NERD/MIDDLE_AGED_MAN usage

---

## 10. SPRITESET_CYCLING_ROAD
**Maps:** Route17 (+ Route16 west, Route18 west via splits)

**Current set:**
```
PIKACHU, BIKER, COOLTRAINER_M, SILPH_WORKER_M, FISHER, ROCKER, HIKER, GAMBLER, MIDDLE_AGED_MAN, POKE_BALL, SNORLAX
```

**Actually used in Route17:** BIKER(10) - that's it!

Note: because there are so few unique overworld sprites in this set, there's some cool potential here to add misty and brock bike sprites, specifically for cycling road.

**NOT used:** COOLTRAINER_M, SILPH_WORKER_M, FISHER, ROCKER, HIKER, GAMBLER, MIDDLE_AGED_MAN, POKE_BALL, SNORLAX

**Maps to audit:** Check Route16, Route18 for removed sprite usage

---

## FINAL Summary of Sprites to Remove

| Sprite Set | Remove #1 | Remove #2 | Maps to Check |
|------------|-----------|-----------|---------------|
| PALLET_VIRIDIAN | BRUNETTE_GIRL | COOLTRAINER_M | Route20, Route21 (SWIMMER issue!) |
| PEWTER_CERULEAN | UNUSED_GAMBLER_ASLEEP_2 | BLUE | Find 1 BLUE usage |
| LAVENDER | UNUSED_GAMBLER_ASLEEP_2 | MONSTER | (check Route8,10,12 for MONSTER) |
| VERMILION | UNUSED_GAMBLER_ASLEEP_2 | COOLTRAINER_M | Route6 uses COOLTRAINER_M! |
| CELADON | LITTLE_BOY | MIDDLE_AGED_MAN | Route16 |
| SAFFRON | UNUSED_GAMBLER_ASLEEP_2 | COOLTRAINER_M | Route6 (shared set issue) |
| INDIGO | UNUSED_GAMBLER_ASLEEP_2 | GYM_GUIDE | (minimal) |
| FUCHSIA | SEEL | CHANSEY | FuchsiaCity - replace NPCs |
| SILENCE_BRIDGE | ROCKER | MIDDLE_AGED_MAN | Route11, Route12 |
| CYCLING_ROAD | SILPH_WORKER_M | MIDDLE_AGED_MAN | Route16, Route18 |

**Note:** Route6 uses COOLTRAINER_M but is split between SAFFRON and VERMILION sets.
If COOLTRAINER_M is removed from both, Route6 NPCs need sprite changes.

## Split Route Usage (Additional Data)

| Route | Sprites Used | Sprite Set(s) |
|-------|--------------|---------------|
| Route2 | POKE_BALL | PEWTER_CERULEAN / PALLET_VIRIDIAN |
| Route5 | (none) | PEWTER_CERULEAN / SAFFRON |
| Route6 | COOLTRAINER_F, COOLTRAINER_M, YOUNGSTER | SAFFRON / VERMILION |
| Route7 | (none) | CELADON / SAFFRON |
| Route8 | COOLTRAINER_F, GAMBLER, SUPER_NERD | SAFFRON / LAVENDER |
| Route10 | COOLTRAINER_F, HIKER, SUPER_NERD | PEWTER_CERULEAN / LAVENDER |
| Route11 | GAMBLER, SUPER_NERD, YOUNGSTER | VERMILION / SILENCE_BRIDGE |
| Route12 | COOLTRAINER_M, FISHER, POKE_BALL, SNORLAX, SUPER_NERD | LAVENDER / SILENCE_BRIDGE |
| Route15 | BEAUTY, BIKER, COOLTRAINER_F, COOLTRAINER_M, POKE_BALL | FUCHSIA / SILENCE_BRIDGE |
| Route16 | BIKER, SNORLAX | CYCLING_ROAD / CELADON |
| Route18 | COOLTRAINER_M | CYCLING_ROAD / FUCHSIA |
| Route20 | COOLTRAINER_M, SWIMMER | PALLET_VIRIDIAN / FUCHSIA |

---

## Known Issues to Fix

1. **SPRITESET_PALLET_VIRIDIAN**: Uses SWIMMER(5) which is NOT in the set - these maps are already broken or using wrong sprites