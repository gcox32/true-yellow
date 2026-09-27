_PokemonMansionB1FBurglarBattleText::
	text "Uh-oh. Where am"
	line "I now?"
	done

_PokemonMansionB1FBurglarEndBattleText::
	text "Awooh!"
	prompt

_PokemonMansionB1FBurglarAfterBattleText::
	text "You can find stuff"
	line "lying around."
	done

_PokemonMansionB1FScientistBattleText::
	text "This place is"
	line "ideal for a lab."
	done

_PokemonMansionB1FScientistEndBattleText::
	text "What"
	line "was that for?"
	prompt

_PokemonMansionB1FScientistAfterBattleText::
	text "I like it here!"
	line "It's conducive to"
	cont "my studies!"
	done

_PokemonMansionB1FDiaryText::
	text "Diary; Sept. 1"
	line "MEWTWO is far too"
	cont "powerful."

	para "We have failed to"
	line "curb its vicious"
	cont "tendencies..."
	done

_PokemonMansionB1FGasPipeText::
	text "A rusted vent set"
	line "into the floor."

	para "A steady hiss of"
	line "helium rises from"
	cont "the grate."

	para "Hold a #MON"
	line "over the vent?"
	prompt

_PokemonMansionB1FGasWrongMonText::
	text "The helium had no"
	line "effect on this"
	cont "#MON."
	done

_PokemonMansionB1FGasNotEvolvedText::
	text "KOFFING wobbled,"
	line "but it isn't"
	cont "developed enough"
	cont "to hold the gas."
	done

_PokemonMansionB1FGasAlreadyText::
	text "This #MON is"
	line "already floating."
	done

_PokemonMansionB1FGasSuccessText::
	text "The helium filled"
	line "@"
	text_ram wNameBuffer
	text "!"

	para "It swelled up and"
	line "drifted off the"
	cont "floor. It learned"
	cont "to float!"
	done
