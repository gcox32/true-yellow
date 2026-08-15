# Chain Follower Conditional Hiding

## Problem

The blanket `BIT_FONT_LOADED` hide works for Pikachu (always 1 tile behind, never
overlaps UI) but is too aggressive for Misty (2 tiles) and Brock (3 tiles), who are
often on-screen in a safe region while text or a menu is open.

## Solution

Only hide a follower when their screen tile position would overlap the active UI element.

### Screen coordinate math

The GB overworld screen is 10×9 tiles (160×144px ÷ 16px/tile).  
The player sits at approximately screen tile (4, 4).

All positions are already in 16px map-coordinate units, and the +4 border offset
cancels out, so:

```
screen_tile_Y = follower_mapY - wYCoord
screen_tile_X = follower_mapX - wXCoord
```

### Hide thresholds

| UI element         | Condition                  | Constant         |
|--------------------|---------------------------|------------------|
| Text box (bottom)  | screen_tile_Y >= 7        | TEXT_BOX_TILE_ROW |
| Menu (right side)  | screen_tile_X >= 7        | MENU_TILE_COL    |
| Yes/No box (upper-right, e.g. `YesNoChoice`, can appear alongside a text box) | screen_tile_X >= 9 | YESNO_BOX_TILE_COL |

Values >= 9 (or >= 10 for X) mean the follower is above/left of the player
(unsigned wrap) or off-screen — safe in both cases.

The yes/no case is checked as an *extra* X-axis check layered onto the
text-box (`hTextID != 0`) branch once the Y-axis check alone says "safe" -
`YesNoChoice` (`home/yes_no.asm`) sets `wTextBoxID = TWO_OPTION_MENU` while
its box is up, alongside whatever bottom text box triggered it. This is
generic engine plumbing used by ~27 scripts, not a one-off, so the fix
covers all of them.

### Always-hide modals

Cases that hard-hide regardless of position:
- **Pikachu interaction modal** — the overworld reaction sequence (text/emote
  bubble/pikapic) driven by `DoStarterPikachuEmotions`. Tracked by
  `wPikachuReactionActive` (set/cleared around the call in
  `engine/pikachu/pikachu_emotions.asm`), checked in `ShouldMistySpawn`/
  `ShouldBrockSpawn`. Not needed for Pikachu itself - it has its own,
  separate spawn gate in `engine/pikachu/pikachu_follow.asm`.
- **Start Menu session** — the pause menu (POKeDEX/POKEMON/ITEM/etc.) and all
  of its submenus (party list, item bag, trainer card, save/options). Its
  submenus don't fit the text-box/menu shapes above, and closing one back to
  the still-open parent Start menu would otherwise let a follower reappear
  on top of it. Tracked by `hStartMenuModalActive` (set every time
  `DrawStartMenu` (re)draws the box - `engine/menus/draw_start_menu.asm` -
  which happens on open and again whenever a submenu returns to it), checked
  in `ShouldMistySpawn`/`ShouldBrockSpawn`. Home bank (ROM0) is size-locked,
  so the flag is set from `DrawStartMenu` (ROMX) rather than
  `DisplayStartMenu` (home/start_menu.asm, ROM0) even though the latter
  reads more naturally as "the" entry point.

### Deferred: always-hide modals

One case that should hard-hide regardless of position — flag not yet identified:
- **Town Map overlay** — full-screen, need the active-flag

## Different bug class: frozen mid-catch-up, not overlapping anything

The cases above are all about a follower's own render decision (hide vs
show). There's a second, unrelated failure mode with a completely different
fix shape, first found in Pewter City's "It's right here! You have to pay"
script (`PewterCitySuperNerd1ShowsPlayerMuseumScript`,
`scripts/PewterCity.asm`):

**Symptom:** an NPC leads the player on a long scripted walk
(`StartSimulatingJoypadStates`/`RunNPCMovementScript`) that runs directly
into a blocking `call DisplayTextID` the instant it ends. `DisplayTextID`'s
wait loop (`WaitForTextScrollButtonPress`/`HoldTextDisplayOpen`,
`home/text_script.asm`) only polls `Joypad` - it never calls `UpdateSprites`
again until the player dismisses the box. Whichever follower hadn't fully
closed their trailing distance by the exact instant the walk ended gets
captured mid-stride and stays visibly frozen there, mid-animation, for as
long as the text is up. Because they're usually off in the upper part of
the screen (not overlapping the bottom text box), the normal row/column
overlap checks above correctly find nothing to hide and don't help - this
isn't a detection gap, it's that nothing re-evaluates them at all while the
text blocks.

**Fix shape** (see `scripts/PewterCity.asm`, the "It's right here" case):
1. Hard-hide via the usual bit 6 (`wMistyOverworldStateFlags`/
   `wBrockOverworldStateFlags`), set right before the text opens.
2. Manually `set BIT_FONT_LOADED, [hl]` on `wFontLoaded` *before* forcing a
   sprite update, since it's still false at that point (no text is open
   yet) and `ShouldMistySpawn`/`ShouldBrockSpawn` treat that as "nothing
   active" and self-clear bit 6 as stale before it ever gets to hide
   anything. `DisplayTextID` sets the real bit moments later anyway, which
   is harmless.
3. **Do not** call a plain `UpdateSprites` to apply the hide. It reprocesses
   *every* sprite slot, not just the followers - including whatever NPC
   just finished driving the scripted walk. That NPC's own `MOVEMENTSTATUS`
   is typically still mid-transition right after `_EndNPCMovementScript`
   (`engine/overworld/auto_movement.asm`), which never resets it, so
   running it through the generic per-frame NPC update
   (`UpdateNPCSprite`/`CheckSpriteAvailability`,
   `engine/overworld/movement.asm`) a second time that frame can drive its
   `ImageIndex` to `$ff` (invisible), clobbering whatever positioning the
   script just did. This is exactly what `BIT_NO_SPRITE_UPDATES`
   (`wMiscFlags`) exists to prevent for `DisplayTextIDInit`'s own internal
   `UpdateSprites` call - don't reintroduce the same problem via a manual
   call.
4. Instead, call `SpawnMisty`/`SpawnBrock` (`home/pikachu.asm`) directly for
   just the two follower slots, replicating the setup `_UpdateSprites`'s
   loop would normally do for them (`engine/overworld/sprite_collisions.asm`):
   `hCurrentSpriteOffset` = `$d0` (Misty) / `$e0` (Brock), `hl` pointing at
   that follower's `...StateData2ImageBaseOffset` byte. This touches only
   the two follower sprites and never processes the guide NPC's slot at
   all.

**Other site with the same code shape, checked and NOT affected:**
`PewterCityYoungsterShowsPlayerGymScript` (`scripts/PewterCity.asm:161`,
the "go take on Brock" youngster who leads the player to the gym) has the
identical code shape - scripted walk, `BIT_NO_SPRITE_UPDATES`, then a
blocking `DisplayTextID` call (`TEXT_PEWTERCITY_YOUNGSTER_GO_TAKE_ON_BROCK`)
- but doesn't need the fix. The bug is only *visible* when a follower is
still mid-catch-up (visibly walking) the instant the text opens; that
depends on the specific movement route, not the code shape. This
youngster's route leaves the followers to the player's left rather than
strung out behind in a walking column, so they're already settled by the
time the text opens. Don't assume every `BIT_NO_SPRITE_UPDATES` +
scripted-walk site needs this fix without checking the actual route first.
