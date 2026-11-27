_OaksLabRivalText::
	text "<RIVAL>: Smell"
	line "you later!"
	done

_OaksLabEmptyPokeballText::
	text "This # BALL is"
	line "empty!"
	done

_OaksLabOak1PokemonAroundTheWorldText::
	text "#MON around the"
	line "world wait for"
	cont "you, <PLAYER>!"
	done

_OaksLabOak1HowIsYourPokedexComingText::
	text "OAK: Good to see "
	line "you! How is your "
	cont "#DEX coming? "
	cont "Here, let me take"
	cont "a look!"
	prompt

_OaksLabOak1MeetMeInCeruleanCaveText::
	text "Was there"
	line "something else"
	cont "you wanted to"
	cont "ask?"

	para "..."

	para "I see..."

	para "Not here."
	line "Meet me in"
	cont "CERULEAN CAVE."
	prompt

_OaksLabPokedexText::
	text "It's encyclopedia-"
	line "like, but the"
	cont "pages are blank!"
	done

_OaksLabOak2Text::
	text "?"
	done

_OaksLabGirlText::
	text "PROF.OAK is the"
	line "authority on"
	cont "#MON!"

	para "Many #MON"
	line "trainers hold him"
	cont "in high regard!"
	done

; Episode 1 lines are verbatim from the dub (docs/anime), Ash -> <PLAYER>
_OaksLabOakShowUpAfterAllText::
	text "OAK: So, you've"
	line "decided to show"
	cont "up after all."

	para "You look like"
	line "you're ready for"
	cont "bed, not #MON"
	cont "training."

	para "That # BALL?"
	line "Already taken by"
	cont "someone who was"
	cont "on time."

	para "The early bird"
	line "gets the worm, or"
	cont "in this case, the"
	cont "#MON."

	para "..."

	para "Well there is"
	line "still one left,"
	cont "but I..."

	para "..."

	para "I think I should"
	line "warn you, there"
	cont "is a problem with"
	cont "this last one."

	para "..."

	para "Well in that"
	line "case..."
	done

_OaksLabOakGivesText::
	text "OAK: Its name is"
	line "PIKACHU."
	prompt

_OaksLabReceivedText::
	text "<PLAYER> received"
	line "a @"
	text_ram wNameBuffer
	text "!@"
	text_end

_OaksLabPikachuDislikesPokeballsText1::
	text "OAK: What?"
	done

_OaksLabPikachuDislikesPokeballsText2::
	text "OAK: Would you"
	line "look at that!"

	para "It's odd, but it"
	line "appears that your"
	cont "PIKACHU dislikes"
	cont "# BALLs."

	para "You should just"
	line "keep it with you."

	para "That should make"
	line "it happy!"

	para "You can talk to it"
	line "and see how it"
	cont "feels about you."
	done

_OaksLabOakGotPokedexText::
	text "OAK: Now take"
	line "these!"

	para "<PLAYER> got"
	line "#DEX from OAK!@"
	text_end

_OaksLabOakGotPokeballsText::
	text "<PLAYER> got 5"
	line "# BALLs!@"
	text_end

_OaksLabOakPokedexExplanationText::
	text_start
	para "OAK: The #DEX"
	line "automatically"
	cont "records data on"
	cont "#MON you've"
	cont "seen or caught!"

	para "But you can't get"
	line "detailed data by"
	cont "just seeing them."
	cont "You must catch"
	cont "them!"

	para "When a wild"
	line "#MON appears,"
	cont "it's fair game."

	para "Throw a # BALL"
	line "at it and try to"
	cont "catch it!"

	para "#MON around"
	line "the world wait"
	cont "for you, <PLAYER>!"
	done

_OaksLabPlayerThankText::
	text "<PLAYER> thanked"
	line "PROF.OAK..."
	prompt

_OaksLabOakYoureWelcomeText::
	text "PIKACHU zapped"
	line "<PLAYER> and OAK!"

	para "OAK: YOU'RE"
	line "WELCOMMMME!!"
	done

_OaksLabScientistText::
	text "I study #MON as"
	line "PROF.OAK's AIDE."
	done
