visual bugs:
- [ ] standing on a doorway when entering an inside map
- [ ] standing on a doorway when leaving a building into an outside map
- [ ] jumping ledges behavior for followers doesn't match pikachu
- [ ] spinning tiles behavior for followers should match pikachu
- [ ] followers should disappear when we surf (future feature, get followers surfing behind)
- [ ] follwoers should disappear when we bike (future feature, get followers on their own bikes)
- [ ] followers should not disappear when we fish

downstream effects:
- [ ] handle sprites overflow: now that we have 2 more sprites for every map, we need to edit all possible sprites for any particular map. this may mean going through, map by map, and removing sprite objects that do not meaningfully affect gameplay

feature:
- [ ] add standard text to interacting with brock or misty follower (future feature, add text based on game progress, current map etc)
- [ ] cerulean gym event logic: if not EVENT_BEAT_MISTY, when inside cerulean gym, MISTY should be at her normal gym leader spot, waiting to engage in a battle