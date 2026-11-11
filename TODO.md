# TODO
- [x] Make Pokemon Center at Rock Tunnel Entrance, Route 10, a FLYable desination (also Mt. Moon Pokemon Center, Seafoam Islands NW entrance, Route 12 fishing house, Sea Cottage; flags are wTownVisitedFlag bits 11-15 (full), menu order in FlyLocationsOrder. NEEDS IN-GAME TEST for the two new ones.)
- [x] Set SET (vs SWITCH) as default OPTION in OPTIONS (InitOptions in engine/menus/main_menu.asm; existing saves keep their stored setting)
- [x] More LAPRAS-y overworld sprite for surfing _if_ it's LAPRAS surfing (Gen 2 surf sprite from pokecrystal as gfx/sprites/lapras.png; wd472 mode 3; selector moved to ROMX in engine/overworld/surf_sprite.asm, freeing 18 ROM0 bytes. NEEDS IN-GAME TEST.)
- [x] OPTION to reduce text (first obvious place is interacting with the NURSE in the POKEMON CENTER) (OPTIONS "TEXT : FULL/SHORT", stored in wLetterPrintingDelayFlags bit 7 = BIT_SHORT_TEXT. SHORT nurse: ask -> heal -> "Your #MON are fighting fit!". Other places can check the same bit. Tested in-game.)
- [x] instant SAVE after confirm (as opposed to delay with "Saving...") (SaveMenu in engine/menus/save.asm: with OPTIONS TEXT: SHORT, skips "Saving..." + its 128-frame wait and the 10-frame pause after YES; FULL keeps the original. Always keeps "saved the game!" + jingle. NEEDS IN-GAME TEST.)
- [ ] More diversity to Saffron Gym trainers
- [ ] Move diversity in Seafoam Islands wild
- [x] Better Rival teams
- [x] Move armor mewtwo event into silph co building somewhere
- [x] Location table for brock and misty responses if memory allows (data/followers/follower_lines.asm: map/range + event-flag table, first match wins; engine in engine/followers/follower_talk.asm. Placeholder lines in - WRITE REAL LINES. NEEDS IN-GAME TEST.)
- [ ] Fighting Dojo as rechallengable (i.e. as a place to "train"?); only FIGHTING type pokemon allowed in?


## Bugs
- [x] Investigate recoil effects--not sure they're working (RECOIL_EFFECT dispatched to calc-only helper; now points at DefaultRecoilEffect_)
- [x] Investigate SONICBOOM--does not need to be fixed damage (already a normal 30 BP FLYING priority move; removed dead SPECIAL_DAMAGE_EFFECT special-casing)
- [x] Investigate attack selection while asleep (menu was still skipped when asleep; cc8a8d03 only did the wake-up half. Now the move menu / enemy AI runs while asleep so the chosen move fires on the wake-up turn. Freeze still skips selection.)
- [x] Pokemon who are "fully paralyzed" on the second turn of Dig or Fly remain untargetable until they Dig or Fly successfully later (MonHurtItselfOrFullyParalysed cleared CHARGING_UP but not INVULNERABLE; now clears both + redraws the hidden pic, player & enemy)
- [x] Followers after overworld dig/fly/teleport don't init position correctly (special warps skip WarpFound2/SetPikachuSpawn*, so wFollowerDoorwayMode / wExitDoorway* / Misty+Brock MovementStatus carried over from the previous map -> stale trail coords. PrepareForSpecialWarp now resets them. NEEDS IN-GAME TEST.)
- [x] upon blackout followers need to be purposefully init'd, to the left and right of the player
      (blackout clears BIT_FLY_WARP so EnterMap skips EnterMapAnim, the only thing that seeds
      wPikachuSpawnState/wFollowerDoorwayMode for a special-warp landing -> followers fell back to
      .normalPositioning, 2 and 3 tiles behind. SpecialEnterMap's blackout branch now seeds mode 1
      (Brock - Player - Pikachu - Misty) and clears Pikachu's MovementStatus, which survives the
      warp because his sprite struct is 15 and ZeroSpriteStateData only reaches 14. NEEDS IN-GAME TEST.)
- [x] upon exiting the SURFing, specifically on a ramp/ladder tile, followers reveal too early (i.e. in line in the water)
      (not tile-dependent after all: neither .stopSurfing path sets wFollowerDoorwayMode, and they clear
      wWalkBikeSurfState before the step off the water, so followers resolved on whatever mode the LAST WARP
      left - mode 1 never self-clears, so a gate gave left/right and a building door gave .normalPositioning,
      2 and 3 tiles back into the water. RecordPlayerPositionToTrail now detects the step off the water via
      wPikachuOverworldStateFlags bit 5 - set only by the two .stopSurfing routines - and starts the door-exit
      cascade anchored on the landing tile, so they emerge from it one per step. Zero ROM0 bytes. NEEDS IN-GAME TEST.)
- [x] exiting surf throws off follower positions
- [x] HAZE is curing POISON status

## Bugfixes from PureRGB
- [x] High Jump Kick / Jump Kick crash damage on missing does more damage instead of 1 damage always now. (1/4 the damage of what it would have done to the opponent)
- [x] Focus Energy actually works as intended now (multiplies critical hit rate by 4 instead of dividing it by 4)
- [x] Badge boosts aren't repeatedly applied to every stat when you use or are afflicted by a stat modifier move.
- [x] Speed decrease / Attack decrease caused by paralysis and burn statuses aren't repeatedly applied on being hit by or using a stat modifier move.
- [x] After healing Paralysis/Burn with an item, speed or attack stats will be correctly reset to their original values
- [x] Nidorino's cry plays correctly in Oak's introduction instead of nidorina's (N/A in Yellow: Oak's intro shows Pikachu, no Nidorino)
- [x] Healing moves like Recover won't fail incorrectly when restoring exactly 255 HP.
- [x] The evolution stone item bypass glitch was removed - you must use evolution stones to evolve stone evolution pokemon. (N/A in Yellow: already has the same wIsInBattle check)
- [x] Skipping a level due to gaining a lot of experience won't skip the move you could have learned on the skipped level anymore
- [x] Learning moves after evolution works correctly now.
- [x] Eevee will always learn a type-specific move on evolution regardless of the level it is evolved at (Ember / ThunderShock / Water Gun)
- [x] Cap light screen / reflect stat boosts to 999 to prevent overflows
- [x] LT Surge says the Thunderbadge boosts speed, but in the code it actually boosted defence. Now it boosts speed as text indicated.
- [x] Koga says the Soulbadge boosts defense, but in the code it actually boosted speed. Now it boosts defense as the text indicated.
- [x] When learning a new move in battle, the "Poof!" sound effect didn't work correctly and would play a random sound instead. Now it works. (N/A in Yellow: already switches to the correct audio bank)
- [x] While transformed into another pokemon via TRANSFORM, you cannot swap your move positions anymore - allowing this caused glitches that end with the game crashing (N/A in Yellow: SwapMovesInMenu already checks TRANSFORMED)
- [x] NPCs won't rarely disobey their facing behavioural assignments (facing forward, left, etc.) (N/A here: wMapSpriteData doesn't cross a page; ASSERT in movement.asm keeps it that way)
- [ ] Double Edge animation appearance when opponent uses it fixed
- [x] Blacking out in the Safari Zone won't glitch the game out
- [ ] Trying to switch to the current pokemon or a fainted one won't trigger a small visual glitch
- [x] A small collision detection bug in cerulean cave was fixed
- [ ] Lagginess caused by tile block replacements when loading a map was reduced greatly
- [x] Sound effects during text will play properly now when you have instant text setting turned on (N/A: no 0-delay text option here)
- [ ] You won't occasionally see a tile block being replaced visually on loading a map anymore
- [x] Using substitute with exactly the right health to use substitute won't cause your pokemon to faint. Instead you will have 1HP left.
- [ ] The screen won't flash white for 1 frame on entering a battle or a building on original gameboy or on GBC.
      (Skipped for now, not worth the overhead: building half needs ROM0 space; battle half reorders every battle start.)
- [x] Pokeflute will correctly detect sleeping wild pokemon when used in battle. (N/A in Yellow: already detects sleeping enemy)
- [ ] On original gameboy, while scrolling the trainer pics across at the start of the battle, they will be silhouettes like on SGB or GBC.
- [x] Route 17 sign can now be read from below.
- [x] Can't get blocked by the burglar on Pokemon Mansion 3F
- [x] If all your pokemon are fainted except for the current one, SHIFT mode won't ask you if you want to switch pokemon before the opponent sends out their next pokemon.
- [x] The LAPRAS npc in the fuchsia city zoo can now swim around its enclosure like it was coded to be able to. (N/A: zoo Lapras is commented out of the map)
- [x] Trapping moves won't erroneously still do ongoing damage to pokemon who are immune. Example: Wrap on a ghost pokemon.
- [x] In the original game if you or your opponent hurts theirself in confusion or is fully paralyzed while digging or flying, the pokemon will be stuck in an invulnerable state, making all attacks miss. This was fixed so it doesn't happen in link battles, and in normal gameplay, doesn't happen to enemy pokemon. But since it's a funny bug, it can still happen to the player - you will become invulnerable if this bug happens to you. (already fixed above for player and enemy, see Bugs)
- [x] In the original game, if your opponent used minimize or substitute, you opened your FIGHT menu, exited, went to PARTY, looked at a pokemon's status menu, then returned to the fight, the opponent's sprite would be all messed up. Now it's fixed and doesn't do that. (N/A in Yellow: already sets hWhoseTurn before reloading the pic)
- [x] Doing the same thing as the above on unidentified GHOSTS would reveal what pokemon they are. Now it doesn't.
- [x] After saving in rock tunnel, going title screen -> continue screen -> title screen -> continue screen will cause the continue screen to take on darker colors. Now it stays normal colors.

