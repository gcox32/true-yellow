_CeruleanCave1FOakShallWeText::
	text "OAK: Ah, <PLAYER>."

	para "I've been coming"
	line "here for a long"
	cont "time..."

	para "Shall we?"
	done

; the end-battle engine prefixes "PROF.OAK: " (10 chars) to line 1
_CeruleanCave1FOakDefeatedText::
	text_start
	line "Remarkable..."
	cont "Truly remarkable!"
	prompt

_CeruleanCave1FOakVictoryText::
	text "Did you"
	line "think the rules"
	cont "applied to me?"
	prompt

_CeruleanCave1FOakAfterBattleText::
	text "OAK: I've waited"
	line "a long time for"
	cont "that battle."

	para "The rest of this"
	line "cave is yours,"
	cont "<PLAYER>."
	done
