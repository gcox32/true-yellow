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

Values >= 9 (or >= 10 for X) mean the follower is above/left of the player
(unsigned wrap) or off-screen — safe in both cases.

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
