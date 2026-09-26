# Parties

Both tables below are generated - run `make docs` (or `tools/gen_parties_doc.py`) after
editing `data/trainers/parties.asm` or `data/trainers/special_moves.asm`. Hand edits to
them will be overwritten; the prose around them is preserved.

## Party Updates
NPC trainer parties are established in `data/trainers/parties.asm`.

**Class** is the constant from `constants/trainer_constants.asm`. It's only half of how a
battle is addressed: a trainer object on a map names a class and a party number, and the
engine walks that class's list counting null terminators until it reaches that party. The
number isn't printed here - one row is one battle regardless - so two trainers in the
same place with the same team are two identical rows.

**Location** comes from the section comments in the asm, and is only as accurate as
those. **Notes** is a comment on that party's own line.

Only parties the game can reach are listed: the ones the asm marks `Unused`, and the two
classes with no party data at all, are left out.

Rows run in the order of `data/maps/town_map_order.asm` - roughly the order the player
reaches each place - rather than by trainer class, so a route's or a building's trainers
are listed together. A party is placed by resolving its location comment to a map and
then to that map's spot on the town map, which is what files every Silph Co. floor under
Saffron City, the Rocket Hideout under Celadon City, and the Elite Four's rooms under
Indigo Plateau.

Inside one place, trainers are grouped by the location they're actually fought at, so a
gym's trainers stay together in front of their leader instead of interleaving with the
rest of the city. Those groups run in map id order, which walks a building floor by
floor - Silph Co. 2F up to 11F, the Mansion 2F down to B1F - and the gym is always the
city's last stop. Within one location the asm's own order is kept, class order rather than
the order you'd walk past them, except that the location's boss is moved to the end of it:
Giovanni closes out both the Rocket Hideout and Silph Co., each gym closes on its leader,
and the table closes on the champion. Two sequences the map ids get wrong are spelled out
in the generator instead - the rival being the last battle on the S.S. Anne, and the
Elite Four in the order you have to beat them.

Town map order is geography, not progress, so four stops are pinned somewhere else to
keep the table in playing order: Route 11 moves up next to Route 6, Vermilion Gym waits
until after the S.S. Anne, Viridian Gym drops back to just before the endgame Rival
battles on Route 22, and the Rival battle on Route 22 that is actually the game's second
fight moves up behind the one in Oak's lab.

**Lv** is one number when every Pokemon on the team shares a level - which is also how
the asm stores it, as a single leading level byte. Teams built from `$FF` level/species
pairs show a range instead, and the **Party** column then carries each Pokemon's own
level.

<!-- generated:parties -->
| Class         | Location                                                                   | Lv    | Party                                                                              | Notes                           |
|---------------|----------------------------------------------------------------------------|-------|------------------------------------------------------------------------------------|---------------------------------|
| RIVAL1        | Oak's Lab                                                                  | 5     | EEVEE                                                                              |                                 |
| RIVAL1        | Route 22                                                                   | 8-9   | SPEAROW 9, EEVEE 8                                                                 |                                 |
| BUG_CATCHER   | Viridian Forest                                                            | 7     | CATERPIE, CATERPIE                                                                 |                                 |
| BUG_CATCHER   | Viridian Forest                                                            | 6     | METAPOD, CATERPIE, METAPOD                                                         |                                 |
| BUG_CATCHER   | Viridian Forest                                                            | 10    | PINSIR, METAPOD                                                                    | samurai                         |
| BUG_CATCHER   | Viridian Forest                                                            | 8     | CATERPIE, METAPOD                                                                  |                                 |
| LASS          | Viridian Forest                                                            | 6     | RATTATA, PIDGEY                                                                    |                                 |
| JR_TRAINER_M  | Pewter Gym                                                                 | 9     | DIGLETT, SANDSHREW                                                                 |                                 |
| BROCK         | Pewter Gym                                                                 | 12-14 | GEODUDE 12, BROCK_ONIX 14                                                          |                                 |
| YOUNGSTER     | Route 3                                                                    | 11    | RATTATA, EKANS                                                                     |                                 |
| YOUNGSTER     | Route 3                                                                    | 14    | SPEAROW                                                                            |                                 |
| BUG_CATCHER   | Route 3                                                                    | 10    | CATERPIE, WEEDLE, KAKUNA                                                           |                                 |
| BUG_CATCHER   | Route 3                                                                    | 9     | WEEDLE, KAKUNA, POLIWAG, VENONAT, METAPOD                                          |                                 |
| BUG_CATCHER   | Route 3                                                                    | 12    | CATERPIE, METAPOD                                                                  |                                 |
| LASS          | Route 3                                                                    | 9     | NIDORAN_F, PIDGEY, MEOWTH                                                          |                                 |
| LASS          | Route 3                                                                    | 10    | SQUIRTLE, NIDORAN_M                                                                |                                 |
| LASS          | Route 3                                                                    | 14    | JIGGLYPUFF                                                                         |                                 |
| YOUNGSTER     | Mt. Moon 1F                                                                | 10    | DIGLETT, SPEAROW, ZUBAT                                                            |                                 |
| BUG_CATCHER   | Mt. Moon 1F                                                                | 11    | PARAS, KAKUNA, PARAS                                                               |                                 |
| BUG_CATCHER   | Mt. Moon 1F                                                                | 10    | KAKUNA, METAPOD, PARAS                                                             |                                 |
| LASS          | Mt. Moon 1F                                                                | 11    | ODDISH, BELLSPROUT, VULPIX                                                         |                                 |
| LASS          | Mt. Moon 1F                                                                | 14    | CLEFAIRY                                                                           |                                 |
| SUPER_NERD    | Mt. Moon 1F                                                                | 11    | MAGNEMITE, VOLTORB                                                                 |                                 |
| HIKER         | Mt. Moon 1F                                                                | 10    | GEODUDE, SHELLDER, ONIX                                                            |                                 |
| SUPER_NERD    | Mt. Moon B2F                                                               | 12    | GRIMER, VOLTORB, KOFFING                                                           |                                 |
| ROCKET        | Mt. Moon B2F                                                               | 13    | NIDORAN_M, ZUBAT                                                                   |                                 |
| ROCKET        | Mt. Moon B2F                                                               | 11    | SANDSHREW, MANKEY, ZUBAT                                                           |                                 |
| ROCKET        | Mt. Moon B2F                                                               | 12    | PSYDUCK, EKANS                                                                     |                                 |
| ROCKET        | Jessie & James                                                             | 16    | EKANS, KOFFING, MEOWTH                                                             | Mt. Moon B2F                    |
| LASS          | Route 4                                                                    | 14    | PARAS, PARAS, CLEFAIRY                                                             |                                 |
| RIVAL1        | Cerulean City                                                              | 15-18 | SPEAROW 18, SANDSHREW 15, RATTATA 15, EEVEE 17                                     |                                 |
| ROCKET        | Cerulean City                                                              | 17    | LICKITUNG, DROWZEE                                                                 |                                 |
| JR_TRAINER_F  | Cerulean Gym                                                               | 19    | GOLDEEN, PSYDUCK                                                                   |                                 |
| SWIMMER       | Cerulean Gym                                                               | 16    | HORSEA, OMANYTE, SHELLDER                                                          |                                 |
| MISTY         | Cerulean Gym                                                               | 22-23 | STARYU 22, STARMIE 23                                                              |                                 |
| YOUNGSTER     | Route 24                                                                   | 14    | RATTATA, EKANS, ZUBAT                                                              |                                 |
| BUG_CATCHER   | Route 24                                                                   | 18    | METAPOD, BEEDRILL                                                                  |                                 |
| LASS          | Route 24                                                                   | 16    | EEVEE, PONYTA                                                                      |                                 |
| LASS          | Route 24                                                                   | 15    | JIGGLYPUFF, NIDORAN_F, BULBASAUR                                                   |                                 |
| JR_TRAINER_M  | Route 24/Route 25                                                          | 14    | RATTATA, EKANS                                                                     |                                 |
| JR_TRAINER_M  | Route 24                                                                   | 18    | MANKEY                                                                             |                                 |
| ROCKET        | Route 24                                                                   | 16    | EKANS, ABRA, ZUBAT, EXEGGCUTE                                                      |                                 |
| YOUNGSTER     | Route 25                                                                   | 15    | RATTATA, SPEAROW                                                                   |                                 |
| YOUNGSTER     | Route 25                                                                   | 17    | SLOWPOKE                                                                           |                                 |
| YOUNGSTER     | Route 25                                                                   | 14    | EKANS, SANDSHREW                                                                   |                                 |
| LASS          | Route 25                                                                   | 17    | NIDORINA, NIDORAN_F                                                                |                                 |
| LASS          | Route 25                                                                   | 16    | ODDISH, JIGGLYPUFF, SEEL                                                           |                                 |
| HIKER         | Route 25                                                                   | 16    | GEODUDE, GEODUDE, DIGLETT                                                          |                                 |
| HIKER         | Route 25                                                                   | 16    | GEODUDE, CUBONE, MACHOP, PSYDUCK                                                   |                                 |
| HIKER         | Route 25                                                                   | 17    | RHYHORN                                                                            |                                 |
| BUG_CATCHER   | Route 6                                                                    | 20    | VENONAT, CATERPIE, WEEDLE                                                          |                                 |
| BUG_CATCHER   | Route 6                                                                    | 20    | BUTTERFREE, PARAS                                                                  |                                 |
| JR_TRAINER_M  | Route 6                                                                    | 16    | SPEAROW, RATICATE                                                                  | Joe from the show               |
| JR_TRAINER_M  | Route 6                                                                    | 16    | WEEPINBELL                                                                         |                                 |
| JR_TRAINER_F  | Route 6                                                                    | 16    | PIDGEY, PIDGEY, PIDGEY                                                             | Giselle from the show           |
| JR_TRAINER_F  | Route 6                                                                    | 20    | CUBONE                                                                             |                                 |
| YOUNGSTER     | Route 11                                                                   | 21    | GRIMER, KRABBY                                                                     |                                 |
| YOUNGSTER     | Route 11                                                                   | 19    | SANDSHREW, BUTTERFREE                                                              |                                 |
| YOUNGSTER     | Route 11                                                                   | 19    | PIDGEOTTO, STARYU, RATICATE                                                        |                                 |
| YOUNGSTER     | Route 11                                                                   | 19    | NIDORINO, PONYTA                                                                   |                                 |
| ENGINEER      | Route 11                                                                   | 21    | PORYGON                                                                            |                                 |
| ENGINEER      | Route 11                                                                   | 18    | MAGNEMITE, DODUO, MAGNETON                                                         |                                 |
| GAMBLER       | Route 11                                                                   | 19    | POLIWAG, VULPIX                                                                    |                                 |
| GAMBLER       | Route 11                                                                   | 18    | BELLSPROUT, MAGNEMITE, GROWLITHE                                                   |                                 |
| GAMBLER       | Route 11                                                                   | 19    | VOLTORB, ODDISH                                                                    |                                 |
| GAMBLER       | Route 11                                                                   | 19    | GROWLITHE, HORSEA                                                                  |                                 |
| SAILOR        | SS Anne Stern                                                              | 22    | SEEL, SHELLDER                                                                     |                                 |
| SAILOR        | SS Anne Stern                                                              | 22    | MACHOP, TENTACOOL                                                                  |                                 |
| YOUNGSTER     | SS Anne 1F Rooms                                                           | 22    | NIDORINO                                                                           |                                 |
| LASS          | SS Anne 1F Rooms                                                           | 21    | PSYDUCK, EEVEE                                                                     |                                 |
| GENTLEMAN     | SS Anne 1F Rooms                                                           | 20    | GROWLITHE, DRATINI                                                                 |                                 |
| GENTLEMAN     | SS Anne 1F Rooms                                                           | 21    | NIDORAN_M, NIDORAN_F, WEEPINBELL                                                   |                                 |
| LASS          | SS Anne 2F Rooms                                                           | 21    | NIDORAN_F, PIKACHU, GOLDEEN                                                        |                                 |
| FISHER        | SS Anne 2F Rooms                                                           | 21    | GOLDEEN, TENTACOOL, MAGIKARP                                                       |                                 |
| GENTLEMAN     | SS Anne 2F Rooms/Vermilion Gym                                             | 22    | JOLTEON                                                                            |                                 |
| GENTLEMAN     | SS Anne 2F Rooms (RATICATE traded for player's BUTTERFREE, and back again) | 25    | RATICATE                                                                           |                                 |
| SAILOR        | SS Anne B1F Rooms                                                          | 21    | SHELLDER, KRABBY                                                                   |                                 |
| SAILOR        | SS Anne B1F Rooms                                                          | 20    | HORSEA, SHELLDER, MACHOP                                                           |                                 |
| SAILOR        | SS Anne B1F Rooms                                                          | 22    | TENTACOOL, STARYU                                                                  |                                 |
| SAILOR        | SS Anne B1F Rooms                                                          | 20    | HORSEA, SANDSHREW, POLIWHIRL                                                       |                                 |
| SAILOR        | SS Anne B1F Rooms                                                          | 21    | MACHOP, SQUIRTLE                                                                   |                                 |
| FISHER        | SS Anne B1F Rooms                                                          | 21    | SHELLDER, STARYU, STARYU                                                           |                                 |
| RIVAL2        | SS Anne 2F                                                                 | 20-24 | SPEAROW 22, EXEGGCUTE 20, PORYGON 21, EEVEE 24                                     |                                 |
| SAILOR        | Vermilion Gym                                                              | 24    | MAGNEMITE                                                                          |                                 |
| ROCKER        | Vermilion Gym                                                              | 22    | VOLTORB, WARTORTLE, CUBONE                                                         |                                 |
| LT_SURGE      | Vermilion Gym                                                              | 30    | RAICHU                                                                             |                                 |
| YOUNGSTER     | Route 9                                                                    | 30    | SANDSHREW                                                                          | Sandshrew kid, AJ from the show |
| BUG_CATCHER   | Route 9                                                                    | 24    | BEEDRILL, BUTTERFREE, SCYTHER                                                      |                                 |
| BUG_CATCHER   | Route 9                                                                    | 24    | KAKUNA, PINSIR, BEEDRILL                                                           |                                 |
| JR_TRAINER_M  | Route 9                                                                    | 25    | RHYHORN, CHARMANDER                                                                |                                 |
| JR_TRAINER_F  | Route 9                                                                    | 23    | ODDISH, BELLSPROUT, DODUO, GLOOM                                                   |                                 |
| JR_TRAINER_F  | Route 9                                                                    | 26    | CHANSEY                                                                            |                                 |
| HIKER         | Route 9                                                                    | 25    | GRAVELER, ONIX                                                                     |                                 |
| HIKER         | Route 9                                                                    | 24    | GEODUDE, DODUO, RHYHORN                                                            |                                 |
| HIKER         | Route 9/Rock Tunnel B1F                                                    | 25    | SANDSLASH, NIDORINO                                                                |                                 |
| JR_TRAINER_F  | Rock Tunnel 1F                                                             | 28    | BELLSPROUT, CLEFAIRY                                                               |                                 |
| JR_TRAINER_F  | Rock Tunnel 1F                                                             | 27    | MEOWTH, ODDISH, ZUBAT                                                              |                                 |
| JR_TRAINER_F  | Rock Tunnel 1F                                                             | 26    | BELLSPROUT, NIDORINA, ABRA, IVYSAUR                                                |                                 |
| POKEMANIAC    | Rock Tunnel 1F                                                             | 27    | CUBONE, SLOWPOKE                                                                   |                                 |
| HIKER         | Rock Tunnel 1F                                                             | 25    | GEODUDE, MACHOP, GRAVELER, POLIWAG                                                 |                                 |
| HIKER         | Rock Tunnel 1F                                                             | 26    | ONIX, KOFFING, GEODUDE                                                             |                                 |
| HIKER         | Rock Tunnel 1F                                                             | 27    | MANKEY, GRAVELER                                                                   |                                 |
| JR_TRAINER_F  | Rock Tunnel B1F                                                            | 27    | JIGGLYPUFF, GOLDEEN, MEOWTH                                                        |                                 |
| JR_TRAINER_F  | Rock Tunnel B1F                                                            | 27    | ODDISH, ABRA, BULBASAUR                                                            |                                 |
| POKEMANIAC    | Rock Tunnel B1F                                                            | 26    | SLOWPOKE, PONYTA, EXEGGCUTE                                                        |                                 |
| POKEMANIAC    | Rock Tunnel B1F                                                            | 26    | CHARMANDER, CUBONE, CHARMELEON                                                     |                                 |
| POKEMANIAC    | Rock Tunnel B1F                                                            | 27    | SLOWPOKE, VENONAT                                                                  |                                 |
| HIKER         | Rock Tunnel B1F                                                            | 26    | SLOWPOKE, DODUO, GRAVELER                                                          |                                 |
| HIKER         | Rock Tunnel B1F                                                            | 28    | HITMONLEE                                                                          |                                 |
| JR_TRAINER_F  | Route 10                                                                   | 27    | PIKACHU, CLEFAIRY, EEVEE                                                           |                                 |
| JR_TRAINER_F  | Route 10                                                                   | 28    | STARYU, PIDGEOTTO                                                                  |                                 |
| POKEMANIAC    | Route 10                                                                   | 45    | POLIWRATH, ELECTABUZZ                                                              |                                 |
| POKEMANIAC    | Route 10                                                                   | 28    | CUBONE, SLOWPOKE                                                                   |                                 |
| HIKER         | Route 10                                                                   | 27    | PSYDUCK, ONIX                                                                      |                                 |
| HIKER         | Route 10                                                                   | 26    | MAROWAK, GRAVELER                                                                  |                                 |
| RIVAL2        | Pokémon Tower 2F                                                           | 34-36 | HITMONCHAN 35, ELECTRODE 35, GYARADOS 34, KADABRA 35, EEVEE 36                     |                                 |
| RIVAL2        | Pokémon Tower 2F                                                           | 34-36 | KABUTOPS 35, KADABRA 35, SANDSLASH 34, ELECTRODE 35, EEVEE 36                      |                                 |
| RIVAL2        | Pokémon Tower 2F                                                           | 34-36 | SCYTHER 35, GYARADOS 35, ARCANINE 34, DODRIO 35, EEVEE 36                          |                                 |
| CHANNELER     | Pokémon Tower 3F                                                           | 32    | GASTLY                                                                             |                                 |
| CHANNELER     | Pokémon Tower 3F                                                           | 32    | GASTLY                                                                             |                                 |
| CHANNELER     | Pokémon Tower 3F                                                           | 30    | GASTLY, DROWZEE                                                                    |                                 |
| CHANNELER     | Pokémon Tower 4F                                                           | 33    | HAUNTER                                                                            |                                 |
| CHANNELER     | Pokémon Tower 4F                                                           | 31    | GASTLY, CUBONE                                                                     |                                 |
| CHANNELER     | Pokémon Tower 4F                                                           | 32    | HYPNO                                                                              |                                 |
| CHANNELER     | Pokémon Tower 5F                                                           | 34    | HAUNTER                                                                            |                                 |
| CHANNELER     | Pokémon Tower 5F                                                           | 31    | GASTLY, MR_MIME                                                                    |                                 |
| CHANNELER     | Pokémon Tower 5F                                                           | 34    | NINETALES                                                                          |                                 |
| CHANNELER     | Pokémon Tower 5F                                                           | 34    | LICKITUNG                                                                          |                                 |
| CHANNELER     | Pokémon Tower 6F                                                           | 32    | GASTLY, VENONAT, GASTLY                                                            |                                 |
| CHANNELER     | Pokémon Tower 6F                                                           | 34    | JYNX                                                                               |                                 |
| CHANNELER     | Pokémon Tower 6F                                                           | 33    | KADABRA                                                                            |                                 |
| ROCKET        | Jessie & James                                                             | 36    | MEOWTH, ARBOK, WEEZING                                                             | Pokémon Tower 7F                |
| BUG_CATCHER   | Route 8                                                                    | 26    | VENONAT, SCYTHER, KABUTO                                                           |                                 |
| LASS          | Route 8                                                                    | 28    | NIDORAN_F, NIDORINA                                                                |                                 |
| LASS          | Route 8                                                                    | 26    | MEOWTH, FARFETCHD, EEVEE                                                           |                                 |
| LASS          | Route 8                                                                    | 25    | ARBOK, SLOWPOKE, VULPIX, MEOWTH, PIKACHU                                           |                                 |
| LASS          | Route 8                                                                    | 28    | CLEFAIRY, CLEFAIRY, CLEFABLE                                                       |                                 |
| SUPER_NERD    | Route 8                                                                    | 27    | VOLTORB, KOFFING, PSYDUCK, MAGNEMITE                                               |                                 |
| SUPER_NERD    | Route 8                                                                    | 27    | GRIMER, MR_MIME, MUK                                                               |                                 |
| SUPER_NERD    | Route 8                                                                    | 29    | KOFFING, DITTO                                                                     |                                 |
| GAMBLER       | Route 8                                                                    | 28    | POLIWAG, GRAVELER, POLIWHIRL                                                       |                                 |
| GAMBLER       | Route 8                                                                    | 28    | DROWZEE, NINETALES                                                                 |                                 |
| ROCKET        | Game Corner                                                                | 31    | BEEDRILL, PERSIAN                                                                  |                                 |
| ROCKET        | Rocket Hideout B1F                                                         | 31    | DROWZEE, KINGLER                                                                   |                                 |
| ROCKET        | Rocket Hideout B1F                                                         | 32    | EXEGGCUTE, RATICATE                                                                |                                 |
| ROCKET        | Rocket Hideout B1F                                                         | 31    | GRIMER, KOFFING, DODRIO                                                            |                                 |
| ROCKET        | Rocket Hideout B1F                                                         | 31    | GEODUDE, MACHOKE, RATICATE, GOLBAT                                                 |                                 |
| ROCKET        | Rocket Hideout B1F                                                         | 32    | KOFFING, ELECTRODE                                                                 |                                 |
| ROCKET        | Rocket Hideout B2F                                                         | 30    | FEAROW, PORYGON, GRIMER, WARTORTLE, RATICATE                                       |                                 |
| ROCKET        | Rocket Hideout B3F                                                         | 31    | DROWZEE, GOLDUCK, HITMONLEE                                                        |                                 |
| ROCKET        | Rocket Hideout B3F                                                         | 32    | MACHOKE, LICKITUNG                                                                 |                                 |
| ROCKET        | Rocket Hideout B4F                                                         | 35    | PARASECT, MAROWAK, ARBOK                                                           |                                 |
| ROCKET        | Jessie & James                                                             | 27    | KOFFING, EKANS, MEOWTH                                                             | Rocket Hideout B4F              |
| GIOVANNI      | Rocket Hideout B4F                                                         | 35-38 | SANDSLASH 37, RHYHORN 35, DODRIO 35, KANGASKHAN 38                                 |                                 |
| LASS          | Celadon Gym                                                                | 31    | NIDORINA, WEEPINBELL                                                               |                                 |
| LASS          | Celadon Gym                                                                | 31    | CHANSEY, GLOOM                                                                     |                                 |
| JR_TRAINER_F  | Celadon Gym                                                                | 30    | BULBASAUR, IVYSAUR, EEVEE                                                          |                                 |
| BEAUTY        | Celadon Gym                                                                | 29    | JIGGLYPUFF, BELLSPROUT, BUTTERFREE, JYNX                                           |                                 |
| BEAUTY        | Celadon Gym                                                                | 31    | ODDISH, TANGELA                                                                    |                                 |
| BEAUTY        | Celadon Gym                                                                | 33    | PARASECT                                                                           |                                 |
| COOLTRAINER_F | Celadon Gym                                                                | 31    | WEEPINBELL, GLOOM, IVYSAUR                                                         |                                 |
| ERIKA         | Celadon Gym                                                                | 37-40 | TANGELA 37, WEEPINBELL 37, GLOOM 40                                                |                                 |
| BLACKBELT     | Fighting Dojo                                                              | 37    | HITMONLEE, HITMONCHAN                                                              |                                 |
| BLACKBELT     | Fighting Dojo                                                              | 32    | MANKEY, MACHOP, PRIMEAPE                                                           |                                 |
| BLACKBELT     | Fighting Dojo                                                              | 34    | MANKEY, MACHOKE                                                                    |                                 |
| BLACKBELT     | Fighting Dojo                                                              | 35    | PRIMEAPE                                                                           |                                 |
| BLACKBELT     | Fighting Dojo                                                              | 32    | MACHOP, MANKEY, ELECTABUZZ                                                         |                                 |
| SCIENTIST     | Silph Co. 2F                                                               | 39    | PARASECT, PORYGON, MAGMAR, WEEZING                                                 |                                 |
| SCIENTIST     | Silph Co. 2F                                                               | 40    | FLAREON, STARMIE, MAGNETON                                                         |                                 |
| ROCKET        | Silph Co. 2F                                                               | 42    | CLOYSTER, DUGTRIO                                                                  |                                 |
| ROCKET        | Silph Co. 2F                                                               | 39    | GOLBAT, SANDSLASH, POLIWRATH, RATICATE, HITMONCHAN                                 |                                 |
| SCIENTIST     | Silph Co. 3F                                                               | 42    | ELECTRODE, WEEZING                                                                 |                                 |
| ROCKET        | Silph Co. 3F                                                               | 41    | RATICATE, HYPNO, CHARMELEON                                                        |                                 |
| SCIENTIST     | Silph Co. 4F                                                               | 44    | DITTO                                                                              |                                 |
| ROCKET        | Silph Co. 4F                                                               | 42    | ARCANINE, GENGAR                                                                   |                                 |
| ROCKET        | Silph Co. 4F                                                               | 40    | GRAVELER, JOLTEON, WARTORTLE                                                       |                                 |
| JUGGLER       | Silph Co. 5F                                                               | 42    | BUTTERFREE, ALAKAZAM                                                               |                                 |
| SCIENTIST     | Silph Co. 5F                                                               | 39    | MAGNETON, TENTACRUEL, EXEGGUTOR, ELECTRODE                                         |                                 |
| ROCKET        | Silph Co. 5F                                                               | 45    | GENGAR                                                                             |                                 |
| ROCKET        | Silph Co. 5F                                                               | 45    | SNORLAX                                                                            |                                 |
| SCIENTIST     | Silph Co. 6F                                                               | 38    | ELECTABUZZ, GOLDUCK, MAGNETON, TANGELA, LICKITUNG                                  |                                 |
| ROCKET        | Silph Co. 6F                                                               | 42    | MACHAMP, VICTREEBEL                                                                |                                 |
| ROCKET        | Silph Co. 6F                                                               | 41    | DUGTRIO, NINETALES, GOLBAT                                                         |                                 |
| SCIENTIST     | Silph Co. 7F                                                               | 42    | ELECTRODE, MUK                                                                     |                                 |
| ROCKET        | Silph Co. 7F                                                               | 40    | SCYTHER, ARBOK, GENGAR, GOLEM                                                      |                                 |
| ROCKET        | Silph Co. 7F                                                               | 42    | EXEGGUTOR, KINGLER                                                                 |                                 |
| ROCKET        | Silph Co. 7F                                                               | 42    | RAICHU, SANDSLASH                                                                  |                                 |
| RIVAL2        | Silph Co. 7F                                                               | 43-47 | GOLBAT 46, GYARADOS 46, TANGELA 45, CHANSEY 43, JOLTEON 47                         |                                 |
| RIVAL2        | Silph Co. 7F                                                               | 43-47 | FEAROW 46, DUGTRIO 46, GOLEM 45, SNORLAX 43, FLAREON 47                            |                                 |
| RIVAL2        | Silph Co. 7F                                                               | 43-47 | PIDGEOT 46, ELECTABUZZ 46, WEEZING 45, ALAKAZAM 43, VAPOREON 47                    |                                 |
| SCIENTIST     | Silph Co. 8F                                                               | 42    | SLOWBRO, ELECTRODE                                                                 |                                 |
| ROCKET        | Silph Co. 8F                                                               | 39    | RATICATE, NIDOKING, PRIMEAPE, RAPIDASH                                             |                                 |
| ROCKET        | Silph Co. 8F                                                               | 41    | HITMONLEE, GOLBAT, GENGAR                                                          |                                 |
| SCIENTIST     | Silph Co. 9F                                                               | 40    | DRAGONAIR, JYNX, MAGNETON                                                          |                                 |
| ROCKET        | Silph Co. 9F                                                               | 41    | VENOMOTH, HITMONCHAN, MAROWAK                                                      |                                 |
| ROCKET        | Silph Co. 9F                                                               | 41    | RHYDON, SLOWBRO, MACHAMP                                                           |                                 |
| SCIENTIST     | Silph Co. 10F                                                              | 42    | MAGNETON, PORYGON                                                                  |                                 |
| ROCKET        | Silph Co. 10F                                                              | 46    | ALAKAZAM                                                                           |                                 |
| ROCKET        | Silph Co. 11F                                                              | 39    | LICKITUNG, CHARIZARD, GOLEM, MAGMAR, GYARADOS                                      |                                 |
| ROCKET        | Jessie & James                                                             | 42    | WEEZING, ARBOK, VICTREEBEL, LICKITUNG, MEOWTH                                      | Silph Co. 11F                   |
| GIOVANNI      | Silph Co. 11F                                                              | 48-51 | NIDOKING 48, KANGASKHAN 49, KINGLER 49, NIDOQUEEN 51                               |                                 |
| PSYCHIC_TR    | Saffron Gym                                                                | 48    | KADABRA, POLIWRATH, MR_MIME, VENOMOTH                                              |                                 |
| PSYCHIC_TR    | Saffron Gym                                                                | 50    | MR_MIME, ALAKAZAM                                                                  |                                 |
| PSYCHIC_TR    | Saffron Gym                                                                | 49    | BUTTERFREE, JOLTEON, SLOWBRO                                                       |                                 |
| PSYCHIC_TR    | Saffron Gym                                                                | 52    | STARMIE                                                                            |                                 |
| CHANNELER     | Saffron Gym                                                                | 50    | MR_MIME, NINETALES                                                                 |                                 |
| CHANNELER     | Saffron Gym                                                                | 51    | GENGAR                                                                             |                                 |
| CHANNELER     | Saffron Gym                                                                | 49    | HYPNO, HAUNTER, GOLDUCK                                                            |                                 |
| SABRINA       | Saffron Gym                                                                | 55    | ABRA, KADABRA, ALAKAZAM                                                            |                                 |
| JR_TRAINER_M  | Route 12                                                                   | 41    | NIDORINO, NIDORINA                                                                 |                                 |
| FISHER        | Route 12                                                                   | 27    | GOLDEEN, POLIWAG, TANGELA                                                          |                                 |
| FISHER        | Route 12                                                                   | 27    | TENTACOOL, TANGELA                                                                 |                                 |
| FISHER        | Route 12                                                                   | 29    | SEADRA                                                                             |                                 |
| FISHER        | Route 12                                                                   | 26    | POLIWAG, SHELLDER, SEAKING, SEAKING                                                |                                 |
| FISHER        | Route 12                                                                   | 41    | VAPOREON, SLOWBRO                                                                  |                                 |
| ROCKER        | Route 12                                                                   | 42    | ELECTABUZZ, GYARADOS                                                               |                                 |
| JR_TRAINER_F  | Route 13                                                                   | 37    | RAICHU, VILEPLUME, BUTTERFREE, WIGGLYTUFF, CLEFABLE                                |                                 |
| JR_TRAINER_F  | Route 13                                                                   | 41    | NIDOQUEEN, WIGGLYTUFF                                                              |                                 |
| JR_TRAINER_F  | Route 13                                                                   | 39    | KANGASKHAN, PERSIAN, CLEFABLE, PIDGEOT                                             |                                 |
| JR_TRAINER_F  | Route 13                                                                   | 40    | STARMIE, NIDOQUEEN, CHANSEY                                                        |                                 |
| BIKER         | Route 13                                                                   | 39    | WEEZING, TAUROS, RAPIDASH                                                          |                                 |
| BEAUTY        | Route 13                                                                   | 40    | WIGGLYTUFF, PIKACHU, RAICHU                                                        |                                 |
| BEAUTY        | Route 13                                                                   | 41    | VILEPLUME, PERSIAN                                                                 |                                 |
| BIRD_KEEPER   | Route 13                                                                   | 41    | GOLBAT, SCYTHER                                                                    |                                 |
| BIRD_KEEPER   | Route 13                                                                   | 37    | FEAROW, NIDOKING, DEWGONG, PIDGEOT, DODRIO                                         |                                 |
| BIRD_KEEPER   | Route 13                                                                   | 38    | FEAROW, FARFETCHD, DUGTRIO, MACHAMP                                                |                                 |
| BIKER         | Route 14                                                                   | 41    | MAGMAR, VICTREEBEL                                                                 |                                 |
| BIKER         | Route 14                                                                   | 39    | HITMONLEE, WARTORTLE, MUK, WEEZING                                                 |                                 |
| BIKER         | Route 14                                                                   | 40    | ELECTRODE, MUK                                                                     |                                 |
| BIKER         | Route 14                                                                   | 41    | GOLDUCK, MUK                                                                       |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 49    | FARFETCHD                                                                          |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 41    | PIDGEOT, SANDSLASH                                                                 |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 39    | JOLTEON, CLOYSTER, DODRIO                                                          |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 38    | PIDGEOT, FEAROW, NIDOKING, PARASECT                                                |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 41    | KINGLER, GOLBAT                                                                    |                                 |
| BIRD_KEEPER   | Route 14                                                                   | 40    | VENOMOTH, SNORLAX, FEAROW                                                          |                                 |
| JR_TRAINER_F  | Route 15                                                                   | 40    | VILEPLUME, CHANSEY, CLEFABLE                                                       |                                 |
| JR_TRAINER_F  | Route 15                                                                   | 42    | TANGELA, RAICHU                                                                    |                                 |
| JR_TRAINER_F  | Route 15                                                                   | 45    | CHANSEY                                                                            |                                 |
| JR_TRAINER_F  | Route 15                                                                   | 40    | NIDOQUEEN, WIGGLYTUFF, DEWGONG                                                     |                                 |
| BIKER         | Route 15                                                                   | 39    | RAPIDASH, WEEPINBELL, HAUNTER, RHYDON                                              |                                 |
| BIKER         | Route 15                                                                   | 41    | BEEDRILL, ONIX, MAROWAK                                                            |                                 |
| BEAUTY        | Route 15                                                                   | 42    | IVYSAUR, JYNX                                                                      |                                 |
| BEAUTY        | Route 15                                                                   | 42    | WIGGLYTUFF, VENUSAUR                                                               |                                 |
| BIRD_KEEPER   | Route 15                                                                   | 40    | EXEGGUTOR, FARFETCHD, DODRIO, PIDGEOT                                              |                                 |
| BIRD_KEEPER   | Route 15                                                                   | 41    | DODRIO, DRAGONAIR, AERODACTYL                                                      |                                 |
| BIKER         | Route 16                                                                   | 39    | MUK, WEEZING                                                                       |                                 |
| BIKER         | Route 16                                                                   | 41    | WEEZING                                                                            |                                 |
| BIKER         | Route 16                                                                   | 38    | HAUNTER, DODRIO, MUK, EXEGGUTOR                                                    |                                 |
| CUE_BALL      | Route 16                                                                   | 39    | MACHOKE, PARASECT, DUGTRIO                                                         |                                 |
| CUE_BALL      | Route 16                                                                   | 40    | PRIMEAPE, VENOMOTH                                                                 |                                 |
| CUE_BALL      | Route 16                                                                   | 42    | GOLEM                                                                              |                                 |
| BIKER         | Route 17                                                                   | 39    | FLAREON, ELECTABUZZ, WEEZING                                                       |                                 |
| BIKER         | Route 17                                                                   | 41    | CLOYSTER                                                                           |                                 |
| BIKER         | Route 17                                                                   | 40    | ELECTRODE, RHYDON                                                                  |                                 |
| BIKER         | Route 17                                                                   | 40    | BEEDRILL, MUK                                                                      |                                 |
| BIKER         | Route 17                                                                   | 37    | VICTREEBEL, PIDGEOT, MAGNETON, WEEZING                                             |                                 |
| CUE_BALL      | Route 17                                                                   | 40    | SNORLAX, PRIMEAPE                                                                  |                                 |
| CUE_BALL      | Route 17                                                                   | 40    | TAUROS, MACHAMP                                                                    |                                 |
| CUE_BALL      | Route 17                                                                   | 52    | POLIWHIRL                                                                          |                                 |
| CUE_BALL      | Route 17                                                                   | 38    | PERSIAN, GOLDUCK, KANGASKHAN, POLIWRATH                                            |                                 |
| CUE_BALL      | Route 17                                                                   | 40    | PRIMEAPE, RAPIDASH                                                                 |                                 |
| BIRD_KEEPER   | Route 18                                                                   | 42    | SCYTHER, FEAROW                                                                    |                                 |
| BIRD_KEEPER   | Route 18                                                                   | 43    | AERODACTYL                                                                         |                                 |
| BIRD_KEEPER   | Route 18                                                                   | 39    | FEAROW, RAICHU, DUGTRIO, DODRIO                                                    |                                 |
| JUGGLER       | Fuchsia Gym                                                                | 46    | DROWZEE, BEEDRILL, KADABRA, GOLBAT                                                 |                                 |
| JUGGLER       | Fuchsia Gym                                                                | 47    | STARMIE, MR_MIME                                                                   |                                 |
| JUGGLER       | Fuchsia Gym                                                                | 50    | EXEGGCUTE                                                                          |                                 |
| JUGGLER       | Fuchsia Gym                                                                | 47    | DRAGONAIR, CLEFABLE                                                                |                                 |
| TAMER         | Fuchsia Gym                                                                | 47    | SANDSLASH, ARBOK                                                                   |                                 |
| TAMER         | Fuchsia Gym                                                                | 46    | VENUSAUR, NIDOQUEEN, ARBOK                                                         |                                 |
| KOGA          | Fuchsia Gym                                                                | 50-54 | TENTACRUEL 50, MUK 51, VENOMOTH 51, GOLBAT 52, FLOATING_WEEZING 54                 |                                 |
| SWIMMER       | Route 19 (beach)                                                           | 43    | CLOYSTER, MACHOKE                                                                  |                                 |
| SWIMMER       | Route 19 (beach)                                                           | 41    | POLIWHIRL, TAUROS, STARMIE                                                         |                                 |
| SWIMMER       | Route 19 (water)                                                           | 51    | RAICHU, POLIWRATH                                                                  |                                 |
| SWIMMER       | Route 19 (water)                                                           | 48    | SEADRA, RHYDON, MUK, BLASTOISE                                                     |                                 |
| SWIMMER       | Route 19 (water)                                                           | 50    | LICKITUNG, DRAGONAIR, SEAKING                                                      |                                 |
| SWIMMER       | Route 19 (water)                                                           | 51    | KABUTOPS, LAPRAS                                                                   |                                 |
| SWIMMER       | Route 19 (water)                                                           | 48    | GYARADOS, KANGASKHAN, MACHAMP, SEADRA, TENTACRUEL                                  |                                 |
| BEAUTY        | Route 19                                                                   | 48    | PERSIAN, WIGGLYTUFF, SEAKING, NIDOQUEEN, DEWGONG                                   |                                 |
| BEAUTY        | Route 19                                                                   | 52    | PIDGEOT, VAPOREON                                                                  |                                 |
| BEAUTY        | Route 19                                                                   | 50    | JYNX, VILEPLUME, LAPRAS                                                            |                                 |
| JR_TRAINER_F  | Route 20                                                                   | 52    | WIGGLYTUFF, SEAKING                                                                |                                 |
| JR_TRAINER_F  | Route 20                                                                   | 50    | CHANSEY, DRAGONAIR, VENUSAUR                                                       |                                 |
| SWIMMER       | Route 20                                                                   | 52    | OMANYTE, CLOYSTER                                                                  |                                 |
| SWIMMER       | Route 20                                                                   | 55    | GYARADOS                                                                           |                                 |
| SWIMMER       | Route 20                                                                   | 49    | BEEDRILL, GOLBAT, PARASECT, PRIMEAPE                                               |                                 |
| BEAUTY        | Route 20                                                                   | 55    | DEWGONG                                                                            |                                 |
| BEAUTY        | Route 20                                                                   | 51    | NIDOQUEEN, FARFETCHD, LAPRAS                                                       |                                 |
| BEAUTY        | Route 20                                                                   | 52    | VAPOREON, SNORLAX                                                                  |                                 |
| BEAUTY        | Route 20                                                                   | 50    | BUTTERFREE, RAICHU, SEADRA                                                         |                                 |
| BIRD_KEEPER   | Route 20                                                                   | 50    | PIDGEOTTO, FEAROW, AERODACTYL                                                      |                                 |
| BURGLAR       | Mansion 2F                                                                 | 53    | SANDSLASH, WEEZING                                                                 |                                 |
| BURGLAR       | Mansion 3F                                                                 | 56    | NINETALES                                                                          |                                 |
| SCIENTIST     | Mansion 3F                                                                 | 52    | ONIX, MAGNETON, EXEGGUTOR                                                          |                                 |
| BURGLAR       | Mansion B1F                                                                | 54    | RATICATE, FEAROW                                                                   |                                 |
| SCIENTIST     | Mansion B1F                                                                | 55    | ALAKAZAM, AERODACTYL                                                               |                                 |
| SUPER_NERD    | Cinnabar Gym                                                               | 48    | PORYGON, GOLEM, NINETALES                                                          |                                 |
| SUPER_NERD    | Cinnabar Gym                                                               | 49    | FLAREON, KINGLER, TANGELA, DITTO                                                   |                                 |
| SUPER_NERD    | Cinnabar Gym                                                               | 51    | RAPIDASH, STARMIE                                                                  |                                 |
| SUPER_NERD    | Cinnabar Gym                                                               | 47    | NINETALES, MAGNETON                                                                |                                 |
| BURGLAR       | Cinnabar Gym                                                               | 53    | PERSIAN, PRIMEAPE, NINETALES                                                       |                                 |
| BURGLAR       | Cinnabar Gym                                                               | 58    | MAGMAR                                                                             |                                 |
| BURGLAR       | Cinnabar Gym                                                               | 55    | CHARMELEON, CHARIZARD                                                              |                                 |
| BLAINE        | Cinnabar Gym                                                               | 59-63 | RHYDON 59, ARCANINE 60, FLAREON 60, RAPIDASH 61, MAGMAR 63                         |                                 |
| FISHER        | Route 21                                                                   | 49    | SEADRA, VICTREEBEL, FEAROW, SEAKING                                                |                                 |
| FISHER        | Route 21                                                                   | 53    | MAROWAK, CLOYSTER                                                                  |                                 |
| FISHER        | Route 21                                                                   | 99    | MAGIKARP, MAGIKARP, MAGIKARP, MAGIKARP, MAGIKARP                                   |                                 |
| FISHER        | Route 21                                                                   | 52    | SEAKING, FARFETCHD                                                                 |                                 |
| SWIMMER       | Route 21                                                                   | 52    | OMASTAR, TENTACRUEL                                                                |                                 |
| SWIMMER       | Route 21                                                                   | 55    | STARMIE                                                                            |                                 |
| SWIMMER       | Route 21                                                                   | 52    | SEADRA, SEADRA                                                                     |                                 |
| SWIMMER       | Route 21                                                                   | 50    | GOLBAT, BEEDRILL, KINGLER                                                          |                                 |
| CUE_BALL      | Route 21                                                                   | 51    | MACHOKE, POLIWRATH, TENTACRUEL                                                     |                                 |
| TAMER         | Viridian Gym                                                               | 61    | RHYDON                                                                             |                                 |
| TAMER         | Viridian Gym                                                               | 58    | ARBOK, TAUROS                                                                      |                                 |
| BLACKBELT     | Viridian Gym                                                               | 59    | HITMONLEE, HITMONCHAN                                                              |                                 |
| BLACKBELT     | Viridian Gym                                                               | 61    | MACHAMP                                                                            |                                 |
| BLACKBELT     | Viridian Gym                                                               | 58    | GRAVELER, MACHOKE, PRIMEAPE                                                        |                                 |
| COOLTRAINER_M | Viridian Gym                                                               | 58    | OMASTAR, NIDOKING                                                                  |                                 |
| COOLTRAINER_M | Viridian Gym                                                               | 58    | SANDSLASH, DUGTRIO                                                                 |                                 |
| COOLTRAINER_M | Viridian Gym                                                               | 61    | SNORLAX                                                                            |                                 |
| GIOVANNI      | Viridian Gym                                                               | 61-70 | KINGLER 62, GOLEM 61, NIDOQUEEN 61, NIDOKING 62, PERSIAN 62, ARMORED_MEWTWO 70     |                                 |
| RIVAL2        | Route 22                                                                   | 62-65 | TENTACRUEL 62, MACHAMP 62, VICTREEBEL 63, GOLEM 63, ALAKAZAM 63, JOLTEON 65        |                                 |
| RIVAL2        | Route 22                                                                   | 62-65 | RAICHU 62, NIDOKING 62, PERSIAN 63, RAPIDASH 63, AERODACTYL 63, FLAREON 65         |                                 |
| RIVAL2        | Route 22                                                                   | 62-65 | FEAROW 62, POLIWRATH 62, MAGNETON 63, WEEZING 63, GENGAR 63, VAPOREON 65           |                                 |
| COOLTRAINER_M | Victory Road 1F                                                            | 54    | BEEDRILL, SANDSLASH, GOLDUCK, CHARIZARD                                            |                                 |
| COOLTRAINER_F | Victory Road 1F                                                            | 57    | PERSIAN, NINETALES                                                                 |                                 |
| POKEMANIAC    | Victory Road 2F                                                            | 56    | EXEGGUTOR, LAPRAS, LICKITUNG                                                       |                                 |
| JUGGLER       | Victory Road 2F                                                            | 55    | SCYTHER, ELECTABUZZ, SEADRA                                                        |                                 |
| JUGGLER       | Victory Road 2F                                                            | 62    | EXEGGUTOR                                                                          |                                 |
| TAMER         | Victory Road 2F                                                            | 57    | DONPHAN, MACHAMP, PINSIR, GOLEM, VENOMOTH                                          | this guy right here             |
| BLACKBELT     | Victory Road 2F                                                            | 57    | PINSIR, HITMONCHAN, MACHOKE                                                        |                                 |
| COOLTRAINER_M | Victory Road 3F                                                            | 56    | EXEGGUTOR, CLOYSTER, ARCANINE                                                      |                                 |
| COOLTRAINER_M | Victory Road 3F                                                            | 56    | KINGLER, HITMONLEE, DRAGONITE                                                      |                                 |
| COOLTRAINER_F | Victory Road 3F                                                            | 55    | WIGGLYTUFF, SEAKING, VICTREEBEL                                                    |                                 |
| COOLTRAINER_F | Victory Road 3F                                                            | 55    | TANGELA, DEWGONG, CHANSEY                                                          |                                 |
| LORELEI       | Lorelei's Room                                                             | 62-66 | DEWGONG 62, CLOYSTER 63, SLOWBRO 63, JYNX 62, VAPOREON 63, LAPRAS 66               |                                 |
| BRUNO         | Bruno's Room                                                               | 63-67 | HITMONCHAN 63, HITMONLEE 63, ONIX 65, ONIX 65, PRIMEAPE 64, MACHAMP 67             |                                 |
| AGATHA        | Agatha's Room                                                              | 63-68 | GENGAR 65, HYPNO 63, NINETALES 64, ARBOK 65, HAUNTER 63, GENGAR 68                 |                                 |
| LANCE         | Lance's Room                                                               | 66-69 | GYARADOS 66, DRAGONAIR 66, AERODACTYL 67, DRAGONITE 68, CHARIZARD 67, DRAGONITE 69 |                                 |
| RIVAL3        | Champion's Room                                                            | 68-82 | ARTICUNO 69, ALAKAZAM 68, GOLEM 68, EXEGGUTOR 68, JOLTEON 75, BLASTOISE 82         |                                 |
| RIVAL3        | Champion's Room                                                            | 68-82 | ZAPDOS 69, ALAKAZAM 68, NIDOQUEEN 68, EXEGGUTOR 68, FLAREON 75, BLASTOISE 82       |                                 |
| RIVAL3        | Champion's Room                                                            | 68-82 | MOLTRES 69, ALAKAZAM 68, NIDOQUEEN 68, MAGMAR 68, VAPOREON 75, BLASTOISE 82        |                                 |
<!-- /generated:parties -->

## Special Moves
Yellow references unique taught moves in `data/trainers/special_moves.asm`.

An entry overwrites one move slot on one party member, by position, after the team has
been built - so it replaces whatever that Pokemon would have learnt by level-up. The asm
only names the positions; **Pokémon** is the join back to the party table, i.e. who
**Slot** actually is. **Move #** is which of the four slots gets replaced.

An entry listed as `(none)` is a trainer the table names and then gives nothing to.

<!-- generated:special-moves -->
| Class       | Party | Slot | Pokémon    | Move # | Move         |
|-------------|-------|------|------------|--------|--------------|
| BUG_CATCHER | 15    | -    | -          | -      | (none)       |
| YOUNGSTER   | 14    | 1    | SANDSHREW  | 1      | SLASH        |
| YOUNGSTER   | 14    | 1    | SANDSHREW  | 2      | DIG          |
| YOUNGSTER   | 14    | 1    | SANDSHREW  | 3      | ROCK_SLIDE   |
| YOUNGSTER   | 14    | 1    | SANDSHREW  | 4      | FISSURE      |
| BROCK       | 1     | 2    | BROCK_ONIX | 3      | BIND         |
| BROCK       | 1     | 2    | BROCK_ONIX | 4      | BIDE         |
| MISTY       | 1     | 2    | STARMIE    | 4      | BUBBLEBEAM   |
| LT_SURGE    | 1     | 1    | RAICHU     | 1      | THUNDERBOLT  |
| LT_SURGE    | 1     | 1    | RAICHU     | 2      | MEGA_PUNCH   |
| LT_SURGE    | 1     | 1    | RAICHU     | 3      | MEGA_KICK    |
| LT_SURGE    | 1     | 1    | RAICHU     | 4      | BODY_SLAM    |
| ERIKA       | 1     | 1    | TANGELA    | 3      | MEGA_DRAIN   |
| ERIKA       | 1     | 2    | WEEPINBELL | 1      | RAZOR_LEAF   |
| ERIKA       | 1     | 3    | GLOOM      | 1      | PETAL_DANCE  |
| KOGA        | 1     | -    | -          | -      | (none)       |
| BLAINE      | 1     | 1    | RHYDON     | 1      | THUNDERBOLT  |
| BLAINE      | 1     | 5    | MAGMAR     | 4      | THUNDERPUNCH |
| SABRINA     | 1     | 1    | ABRA       | 2      | PSYCHIC_M    |
| SABRINA     | 1     | 1    | ABRA       | 3      | REFLECT      |
| GIOVANNI    | 3     | 1    | KINGLER    | 3      | GUILLOTINE   |
| GIOVANNI    | 3     | 2    | GOLEM      | 2      | FISSURE      |
| GIOVANNI    | 3     | 3    | NIDOQUEEN  | 1      | EARTHQUAKE   |
| GIOVANNI    | 3     | 3    | NIDOQUEEN  | 3      | THUNDER      |
| GIOVANNI    | 3     | 4    | NIDOKING   | 1      | EARTHQUAKE   |
| GIOVANNI    | 3     | 4    | NIDOKING   | 2      | HYPER_BEAM   |
| GIOVANNI    | 3     | 4    | NIDOKING   | 3      | THUNDER      |
| LORELEI     | 1     | 1    | DEWGONG    | 1      | BUBBLEBEAM   |
| LORELEI     | 1     | 2    | CLOYSTER   | 3      | ICE_BEAM     |
| LORELEI     | 1     | 3    | SLOWBRO    | 1      | PSYCHIC_M    |
| LORELEI     | 1     | 3    | SLOWBRO    | 2      | SURF         |
| LORELEI     | 1     | 4    | JYNX       | 3      | LOVELY_KISS  |
| LORELEI     | 1     | 5    | VAPOREON   | 3      | BLIZZARD     |
| BRUNO       | 1     | 1    | HITMONCHAN | 1      | DOUBLE_TEAM  |
| BRUNO       | 1     | 2    | HITMONLEE  | 4      | DOUBLE_TEAM  |
| BRUNO       | 1     | 5    | PRIMEAPE   | 3      | HYPER_BEAM   |
| AGATHA      | 1     | 1    | GENGAR     | 2      | SUBSTITUTE   |
| AGATHA      | 1     | 1    | GENGAR     | 3      | LICK         |
| AGATHA      | 1     | 1    | GENGAR     | 4      | MEGA_DRAIN   |
| AGATHA      | 1     | 2    | HYPNO      | 2      | TOXIC        |
| AGATHA      | 1     | 3    | NINETALES  | 2      | HYPNOSIS     |
| AGATHA      | 1     | 4    | ARBOK      | 1      | WRAP         |
| AGATHA      | 1     | 5    | HAUNTER    | 2      | PSYCHIC_M    |
| LANCE       | 1     | 6    | DRAGONITE  | 1      | BLIZZARD     |
| LANCE       | 1     | 6    | DRAGONITE  | 2      | FIRE_BLAST   |
| LANCE       | 1     | 6    | DRAGONITE  | 3      | THUNDER      |
<!-- /generated:special-moves -->
