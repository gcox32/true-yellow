_PowerPlantVoltorbBattleText::
	text "Bzzzt!"
	done

_PowerPlantZapdosBattleText::
	text "Gyaoo!@"
	text_end

_PowerPlantMagnetHumText::
	text "A colossal"
	line "electromagnet"
	cont "fills the room. It"
	cont "hums with stored"
	cont "charge."

	para "Expose a #MON"
	line "to the magnetic"
	cont "core?"
	prompt

_PowerPlantMagnetWrongMonText::
	text "The magnetic field"
	line "didn't affect this"
	cont "#MON."
	done

_PowerPlantMagnetNotEvolvedText::
	text "MAGNEMITE rattled"
	line "in the field, but"
	cont "nothing more came"
	cont "of it."
	done

_PowerPlantMagnetAlreadyText::
	text "This #MON is"
	line "already charged"
	cont "and floating."
	done

_PowerPlantMagnetSuccessText::
	text "The core surged"
	line "into @"
	text_ram wNameBuffer
	text "!"

	para "It rose into the"
	line "air on a cushion"
	cont "of magnetism. It"
	cont "learned to float!"
	done

_PowerPlantMagnetNoChargeText::
	text "The electromagnet"
	line "is dead. It would"
	cont "take an immense"
	cont "electric force to"
	cont "wake it."
	done
