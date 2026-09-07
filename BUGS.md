# Known Bugs
- [x] Brock "follow you" text doesn't appear after gym battle
- [x] BIDE doesn't work and doesn't look right
- [x] Moves cannot be forgotten, are all treated as HMs
- [x] Girl didn't walk to us on Route before Mt. Moon
- [x] Misty and Brock sit on top of text; should disappear when text boxes or start menu appears
- [x] SHARPEN move breaks the game (ATTACK_ACCURACY_UP1); part of bigger issue with 3 new effects that raise multiple stats: DefenseSpeedUpEffect, AccuracyAttackUpEffect, and AttackDefenseUpEffect
- [x] RIVAL, BLUE, doesn't walk on Cerulean Bridge
- [x] follower spawns after text/menu/TOWNMAP render location based on PLAYER facing direction; previous location isn't saved anywhere
- [x] followers should render one at a time on a ladder WARP tile, like pikachu, resembling exiting the ladder one at a time in succession
- [x] followers disappearing during text and then reappearing is jarring

- [x] Trainers on route 6 perpetually re-challenge after being defeated
- [x] Cerulean map is glitchy: house in the NE has water tile through the middle

- [x] Officer Jenny in Vermilion City doesn't turn to face the player when talked to (she was stuck in still-only sprite slot $0B of the shared SPRITESET_VERMILION; gave Vermilion City its own SPRITESET_VERMILION_CITY)
- [x] Wigglytuff on S.S. Anne 1F Rooms rendered as the player sprite (7 distinct NPC sprites, but indoor maps only have 6 slots after the Pikachu/Misty/Brock follower reservation; reskinned MIDDLE_AGED_MAN -> GENTLEMAN). S.S. Anne 2F Rooms had the same overflow (BEAUTY); reskinned GRAMPS -> GENTLEMAN.
- [x] Celadon Game Corner: ROCKET (poster guard) and GAMBLER rendered as the player sprite (8 distinct NPC sprites > 6-slot indoor limit; reskinned GAMBLER -> MIDDLE_AGED_MAN and MIDDLE_AGED_WOMAN -> BEAUTY)

- [ ] visual bug with menu from badge explainer guy in cerulean