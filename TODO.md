# TODO
- [x] Fix double animation for two stat buff moves (e.g. DEFENSE_CURL)
- [x] Butterfree for Raticate trade and trade back on SS Anne
- [x] Swap "Hardened Onix" for "Brock Onix" that is only _resistant_ not immune to Electric
- [x] Mark overworld Pokemon as seen in Pokedex when you interact with them (e.g. Slowbro in Cerulean)
- [x] Bill's Lighthouse instead of Cottage?
- [x] Donphan for sure
- [x] Better burned animation (instead of reusing poisoned animation)
- [x] mt.moon fossil nerd walks on top of misty (fixed by letting the player take both fossils instead)
- [x] mt.moon
    - team rocket walks on top of misty and brock
    - emerging from ladders looks bad 
- [x] hide new followers on pikachu emotion check
- [x] change sleep to attack on-wake-up turn

## QOL
- [ ] the "Grey pokemon" palette needs to be more grey than brown

## Bugfixes from PureRGB
- [ ] High Jump Kick / Jump Kick crash damage on missing does more damage instead of 1 damage always now. (1/4 the damage of what it would have done to the opponent)
- [ ] Focus Energy actually works as intended now (multiplies critical hit rate by 4 instead of dividing it by 4)
- [ ] Badge boosts aren't repeatedly applied to every stat when you use or are afflicted by a stat modifier move.
- [ ] Speed decrease / Attack decrease caused by paralysis and burn statuses aren't repeatedly applied on being hit by or using a stat modifier move.
- [ ] After healing Paralysis/Burn with an item, speed or attack stats will be correctly reset to their original values
- [ ] Nidorino's cry plays correctly in Oak's introduction instead of nidorina's
- [ ] Healing moves like Recover won't fail incorrectly when restoring exactly 255 HP.
- [ ] The evolution stone item bypass glitch was removed - you must use evolution stones to evolve stone evolution pokemon.
- [ ] Skipping a level due to gaining a lot of experience won't skip the move you could have learned on the skipped level anymore
- [ ] Learning moves after evolution works correctly now.
- [ ] Eevee will always learn a type-specific move on evolution regardless of the level it is evolved at
- [ ] Cap light screen / reflect stat boosts to 999 to prevent overflows
- [ ] LT Surge says the Thunderbadge boosts speed, but in the code it actually boosted defence. Now it boosts speed as text indicated.
- [ ] Koga says the Soulbadge boosts defense, but in the code it actually boosted speed. Now it boosts defense as the text indicated.
- [ ] When learning a new move in battle, the "Poof!" sound effect didn't work correctly and would play a random sound instead. Now it works.
- [ ] While transformed into another pokemon via TRANSFORM, you cannot swap your move positions anymore - allowing this caused glitches that end with the game crashing
- [ ] NPCs won't rarely disobey their facing behavioural assignments (facing forward, left, etc.)
- [ ] Double Edge animation appearance when opponent uses it fixed
- [ ] Blacking out in the Safari Zone won't glitch the game out
- [ ] Trying to switch to the current pokemon or a fainted one won't trigger a small visual glitch
- [ ] A small collision detection bug in cerulean cave was fixed
- [ ] Lagginess caused by tile block replacements when loading a map was reduced greatly
- [ ] Sound effects during text will play properly now when you have instant text setting turned on
- [ ] You won't occasionally see a tile block being replaced visually on loading a map anymore
- [ ] Using substitute with exactly the right health to use substitute won't cause your pokemon to faint. Instead you will have 1HP left.
- [ ] The screen won't flash white for 1 frame on entering a battle or a building on original gameboy or on GBC.
- [ ] Pokeflute will correctly detect sleeping wild pokemon when used in battle.
- [ ] On original gameboy, while scrolling the trainer pics across at the start of the battle, they will be silhouettes like on SGB or GBC.
- [ ] Route 17 sign can now be read from below.
- [ ] Can't get blocked by the burglar on Pokemon Mansion 3F
- [ ] If all your pokemon are fainted except for the current one, SHIFT mode won't ask you if you want to switch pokemon before the opponent sends out their next pokemon.
- [ ] The LAPRAS npc in the fuchsia city zoo can now swim around its enclosure like it was coded to be able to.
- [ ] Trapping moves won't erroneously still do ongoing damage to pokemon who are immune. Example: Wrap on a ghost pokemon.
- [ ] In the original game if you or your opponent hurts theirself in confusion or is fully paralyzed while digging or flying, the pokemon will be stuck in an invulnerable state, making all attacks miss. This was fixed so it doesn't happen in link battles, and in normal gameplay, doesn't happen to enemy pokemon. But since it's a funny bug, it can still happen to the player - you will become invulnerable if this bug happens to you.
- [ ] In the original game, if your opponent used minimize or substitute, you opened your FIGHT menu, exited, went to PARTY, looked at a pokemon's status menu, then returned to the fight, the opponent's sprite would be all messed up. Now it's fixed and doesn't do that.
- [ ] Doing the same thing as the above on unidentified GHOSTS would reveal what pokemon they are. Now it doesn't.
- [ ] After saving in rock tunnel, going title screen -> continue screen -> title screen -> continue screen will cause the continue screen to take on darker colors. Now it stays normal colors.

## 