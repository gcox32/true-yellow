_IndigoPlateauLobbyGymGuideText::
	text "Yo! Champ in"
	line "making!"

	para "At #MON LEAGUE,"
	line "you have to face"
	cont "the ELITE FOUR in"
	cont "succession."

	para "If you lose, you"
	line "have to start all"
	cont "over again! This"
	cont "is it! Go for it!"


	para "I've cheered you"
	line "on since your"
	cont "very first GYM."

	para "So here, take any"
	line "GYM LEADER's TM"
	cont "you like. My"
	cont "treat!"
	prompt

_IndigoPlateauLobbyGymGuideWhichTMText::
	text "Which TM do you"
	line "want?"
	done

_IndigoPlateauLobbyGymGuideReceivedTMText::
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end

_IndigoPlateauLobbyGymGuideNoRoomText::
	text "Whoa, your bag's"
	line "full! Make some"
	cont "room first."
	prompt

_IndigoPlateauLobbyGymGuideGoForItText::
	text "Good luck, champ!"
	done

_IndigoPlateauLobbyCooltrainerFText::
	text "From here on, you"
	line "face the ELITE"
	cont "FOUR one by one!"

	para "If you win, a"
	line "door opens to the"
	cont "next trainer!"
	cont "Good luck!"
	done
