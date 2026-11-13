# TODO
- [x] Make Pokemon Center at Rock Tunnel Entrance, Route 10, a FLYable desination (also Mt. Moon Pokemon Center, Seafoam Islands NW entrance, Route 12 fishing house, Sea Cottage; flags are wTownVisitedFlag bits 11-15 (full), menu order in FlyLocationsOrder. NEEDS IN-GAME TEST for the two new ones.)
- [x] Set SET (vs SWITCH) as default OPTION in OPTIONS (InitOptions in engine/menus/main_menu.asm; existing saves keep their stored setting)
- [x] More LAPRAS-y overworld sprite for surfing _if_ it's LAPRAS surfing (Gen 2 surf sprite from pokecrystal as gfx/sprites/lapras.png; wd472 mode 3; selector moved to ROMX in engine/overworld/surf_sprite.asm, freeing 18 ROM0 bytes. NEEDS IN-GAME TEST.)
- [x] OPTION to reduce text (first obvious place is interacting with the NURSE in the POKEMON CENTER) (OPTIONS "TEXT : FULL/SHORT", stored in wLetterPrintingDelayFlags bit 7 = BIT_SHORT_TEXT. SHORT nurse: ask -> heal -> "Your #MON are fighting fit!". Other places can check the same bit. Tested in-game.)
- [x] instant SAVE after confirm (as opposed to delay with "Saving...") (SaveMenu in engine/menus/save.asm: with OPTIONS TEXT: SHORT, skips "Saving..." + its 128-frame wait and the 10-frame pause after YES; FULL keeps the original. Always keeps "saved the game!" + jingle. NEEDS IN-GAME TEST.)
- [x] More diversity to Saffron Gym trainers
- [x] Review diversity in Cerulean Cave
- [x] Better Rival teams
- [x] Move armor mewtwo event into silph co building somewhere
- [x] Location table for brock and misty responses if memory allows (data/followers/follower_lines.asm: map/range + event-flag table, first match wins; engine in engine/followers/follower_talk.asm. Placeholder lines in - WRITE REAL LINES. NEEDS IN-GAME TEST.)
- [x] Fighting Dojo as rechallengable training hall (after the Dojo is beaten: standing on the door mat re-arms the Master + 4 Blackbelts, but only once the Master has been beaten, so stepping out to heal mid-gauntlet keeps progress; ReadTrainer swaps in Fighting-themed teams at BLACKBELT 10-14 (DOJO_TRAINING_TEAMS_OFFSET) whose level byte is an offset from the player's highest party level: Blackbelts -5..-2, Master +2, clamped 2-100. Money/moves scale with level. New Master lines in text/FightingDojo.asm. Fighting-only restriction dropped. Tested in-game.)
- [x] Gen 2 dragon overworld sprite when FLYing with CHARIZARD or DRAGONITE
- [x] "A" at water's edge prompts SURF?, at BOULDER prompts STRENGTH?, at CUT tree prompts CUT?
- [x] confirm VICTORY ROAD is completable
- [x] POISON_GAS should be a never miss move, like SWIFT (MoveHitTest in engine/battle/core.asm returns early on move POISON_GAS, same early return as SWIFT_EFFECT, now placed after the INVULNERABLE test: both skip accuracy and accuracy/evasion stages but miss a target mid-Fly/Dig/trainer-battle Teleport. NEEDS IN-GAME TEST.)
- [x] Increase the payouts in the training hall (doubled: ReadTrainer .FinishUp runs the base-money × level loop twice when IsDojoTrainingBout, i.e. ¥50 × last mon's level instead of ¥25. Teams unchanged. NEEDS IN-GAME TEST.)
- [x] Hide the FLOAT type from the summary screen if WEEZING or MAGNETON has the secondary FLOAT type (PrintMonType in engine/battle/print_type.asm treats Type2 FLOATING like MAGMA: erases the TYPE2/ row. Status screen + Hall of Fame. Battle math unchanged. NEEDS IN-GAME TEST.)
- [x] Add chance to poison to HYPER_FANG and SUPER_FANG (20%, on top of their own flinch / halve-HP effects: FangPoisonEffect in core.asm runs after the normal side effects, borrowing POISON_SIDE_EFFECT1 for one PoisonEffect call. Usual rules: no SUBSTITUTE, POISON types or already-statused targets. Made room by moving SlidePlayerAndEnemySilhouettesOnScreen to engine/battle/silhouette_slide.asm (Battle Engine 1); Battle Core now has $cd free. NEEDS IN-GAME TEST.)
- [ ] Investigate EXEGGUTOR usage across trainer parties--use this as the first inspection of any oddities across trainer parties
- [ ] Better idea for move MIST
- [ ] Beter idea for move HAZE
- [x] Better idea for DRAGON_RAGE (now an Outrage: THRASH_PETAL_DANCE_EFFECT, 100 power, 100 acc, PP 15; locks in 2-3 turns then confuses the user. Data-only. NEEDS IN-GAME TEST.)
- [ ] Better idea for RAGE (repurpose this mechanic for replacement move ROLLOUT?)


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
- [x] JUMP KICK and HI-JUMP KICK crash damage need to be higher (now 1/2 of the damage it would have dealt, Gen 3/4 rule; was 1/4. NEEDS IN-GAME TEST.)
- [x] possible overworld sprite overflow on certain maps (3 maps had 13 objects; object 13 is Misty's sprite struct, so it never appeared.
      Mt Moon 1F's second POTION and Victory Road 2F GUARD_SPEC balls are now hidden items at the same tile (which brings
      VR2F BOULDER3, the one dropped from 3F, back to object 12). SS Anne 2F Rooms BEAUTY removed. Distinct-sprite limits
      re-audited: clean. Shifts hide/show flags, so old saves may show/hide items wrongly. NEEDS IN-GAME TEST.)
- [x] WHIRLWIND needs to reset the position of the affected pokemon (WhirlwindAnim still ended on SE_SLIDE_ENEMY_MON_OFF from when it ended the battle;
      now delays and re-shows the target's pic via SE_SHOW_ENEMY_MON_PIC. NEEDS IN-GAME TEST.)
- [x] LORELEI's SLOWBRO tried to HORNDRILL me... where did that come from? (SlowbroEvosMoves had no learnset terminator, so it read
      into Ivysaur's `EVOLVE_LEVEL, 32` as "L1: move $20 = HORN_DRILL". Any Slowbro above L54 got it. Added the `db 0`; Rhydon was
      also unterminated, harmless only because Kangaskhan's evo `db 0` follows, and is fixed too. NEEDS IN-GAME TEST.)

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

