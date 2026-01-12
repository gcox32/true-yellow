visual bugs:
- [ ] standing on a doorway after just having entered an inside map: currently, pikachu stands to right of the player, but misty and brock stand in their normal spots 2 and 3 tiles back, respectively. we should have misty stand to the right of pikachu and brock to the left of the player, and then fall inline as the player walks forward.
- [ ] standing on a doorway when leaving a building into an outside map: currently, pikachu stands on the door tile and the player stands in front of it; either we A) have brock and misty to stand to the left and right of the player, just outside the building, or B) wait until pikachu has moved forward to reveal misty on the door tile, and then once misty has moved forward reveal brock.
- [ ] jumping ledges behavior for followers doesn't match pikachu: ledge jumps are special overworld movement behavior that produce a "shadow" beneath the overworld sprite as the move over the ledge tile; pikachu matches the player character, misty and brock need to match it as well.
- [ ] spinning tiles behavior for followers should match pikachu: same idea as the ledge behavior
- [ ] followers should disappear when we surf (future feature, get followers surfing behind)
- [ ] followers should disappear when we bike (future feature, get followers on their own bikes)
- [ ] followers should not disappear when we fish (pikachu disappearing is fine but unnecessary)

downstream effects:
- [ ] handle sprites overflow: now that we have 2 more sprites for every map, we need to edit all possible sprites for any particular map. this may mean going through, map by map, and removing sprite objects that do not meaningfully affect gameplay

feature:
- [ ] add standard text to interacting with brock or misty follower (future feature, add text based on game progress, current map etc)
- [x] cerulean gym event logic: if not EVENT_BEAT_MISTY, when inside cerulean gym, MISTY should be at her normal gym leader spot, waiting to engage in a battle