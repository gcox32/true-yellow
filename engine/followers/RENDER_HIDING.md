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

### Deferred: always-hide modals

Two cases that should hard-hide regardless of position — flags not yet identified:
- **Town Map overlay** — full-screen, need the active-flag
- **Pikachu interaction modal** — special reaction scene, need the active-flag
