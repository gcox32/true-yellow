PowerPlant_Script:
	call EnableAutoTextBoxDrawing
	ld hl, PowerPlantTrainerHeaders
	ld de, PowerPlant_ScriptPointers
	ld a, [wPowerPlantCurScript]
	call ExecuteCurMapScriptInTable
	ld [wPowerPlantCurScript], a
	ret

PowerPlant_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_POWERPLANT_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_POWERPLANT_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_POWERPLANT_END_BATTLE

PowerPlant_TextPointers:
	def_text_pointers
	dw_const PowerPlantVoltorb1Text,   TEXT_POWERPLANT_VOLTORB1
	dw_const PowerPlantVoltorb2Text,   TEXT_POWERPLANT_VOLTORB2
	dw_const PowerPlantVoltorb3Text,   TEXT_POWERPLANT_VOLTORB3
	dw_const PowerPlantElectrode1Text, TEXT_POWERPLANT_ELECTRODE1
	dw_const PowerPlantVoltorb4Text,   TEXT_POWERPLANT_VOLTORB4
	dw_const PowerPlantVoltorb5Text,   TEXT_POWERPLANT_VOLTORB5
	dw_const PowerPlantElectrode2Text, TEXT_POWERPLANT_ELECTRODE2
	dw_const PowerPlantVoltorb6Text,   TEXT_POWERPLANT_VOLTORB6
	dw_const PowerPlantZapdosText,     TEXT_POWERPLANT_ZAPDOS
	dw_const PickUpItemText,           TEXT_POWERPLANT_CARBOS
	dw_const PickUpItemText,           TEXT_POWERPLANT_HP_UP
	dw_const PickUpItemText,           TEXT_POWERPLANT_RARE_CANDY
	dw_const PickUpItemText,           TEXT_POWERPLANT_TM_THUNDER
	dw_const PickUpItemText,           TEXT_POWERPLANT_TM_REFLECT
	dw_const PowerPlantElectromagnetText, TEXT_POWERPLANT_ELECTROMAGNET

PowerPlantTrainerHeaders:
	def_trainers
Voltorb0TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_0, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb1TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_1, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb2TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_2, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb3TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_3, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb4TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_4, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb5TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_5, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb6TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_6, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
Voltorb7TrainerHeader:
	trainer EVENT_BEAT_POWER_PLANT_VOLTORB_7, 0, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText, PowerPlantVoltorbBattleText
ZapdosTrainerHeader:
	trainer EVENT_BEAT_ZAPDOS, 0, PowerPlantZapdosBattleText, PowerPlantZapdosBattleText, PowerPlantZapdosBattleText
	db -1 ; end

PowerPlantInitBattleScript:
	call TalkToTrainer
	ld a, [wCurMapScript]
	ld [wPowerPlantCurScript], a
	jp TextScriptEnd

PowerPlantVoltorb1Text:
	text_asm
	ld hl, Voltorb0TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorb2Text:
	text_asm
	ld hl, Voltorb1TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorb3Text:
	text_asm
	ld hl, Voltorb2TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantElectrode1Text:
	text_asm
	ld hl, Voltorb3TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorb4Text:
	text_asm
	ld hl, Voltorb4TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorb5Text:
	text_asm
	ld hl, Voltorb5TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantElectrode2Text:
	text_asm
	ld hl, Voltorb6TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorb6Text:
	text_asm
	ld hl, Voltorb7TrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantZapdosText:
	text_asm
	ld hl, ZapdosTrainerHeader
	jr PowerPlantInitBattleScript

PowerPlantVoltorbBattleText:
	text_far _PowerPlantVoltorbBattleText
	text_end

PowerPlantZapdosBattleText:
	text_far _PowerPlantZapdosBattleText
	text_asm
	ld a, ZAPDOS
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

PowerPlantElectromagnetText:
	text_asm
	CheckEvent EVENT_BEAT_ZAPDOS
	jr z, .noCharge
	CheckEvent EVENT_SUPERCHARGED_MAGNETON
	jr nz, .dormant
	ld hl, PowerPlantMagnetHumText
	call PrintText
	callfar SpeciesChangePartyMenu
	jr c, .done
	call GetPartyMonName2
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Species
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [hl]
	cp MAGNETON
	jr z, .convert
	cp MAGNEMITE
	jr z, .notEvolved
	cp FLOATING_MAGNETON
	jr z, .already
	ld hl, PowerPlantMagnetWrongMonText
	jr .print
.notEvolved
	ld hl, PowerPlantMagnetNotEvolvedText
	jr .print
.already
	ld hl, PowerPlantMagnetAlreadyText
	jr .print
.convert
	ld a, FLOATING_MAGNETON
	ld [wCurPartySpecies], a
	callfar ChangePartyPokemonSpecies
	ld a, SFX_BALL_POOF
	call PlaySound
	call WaitForSoundToFinish
	ld a, FLOATING_MAGNETON
	call PlayCry
	call WaitForSoundToFinish
	SetEvent EVENT_SUPERCHARGED_MAGNETON
	ld hl, PowerPlantMagnetSuccessText
.print
	call PrintText
.done
	jp TextScriptEnd
.noCharge
	ld hl, PowerPlantMagnetNoChargeText
	call PrintText
	jp TextScriptEnd
.dormant
	ld hl, PowerPlantMagnetDormantText
	call PrintText
	jp TextScriptEnd

PowerPlantMagnetHumText:
	text_far _PowerPlantMagnetHumText
	text_end

PowerPlantMagnetWrongMonText:
	text_far _PowerPlantMagnetWrongMonText
	text_end

PowerPlantMagnetNotEvolvedText:
	text_far _PowerPlantMagnetNotEvolvedText
	text_end

PowerPlantMagnetAlreadyText:
	text_far _PowerPlantMagnetAlreadyText
	text_end

PowerPlantMagnetSuccessText:
	text_far _PowerPlantMagnetSuccessText
	text_end

PowerPlantMagnetNoChargeText:
	text_far _PowerPlantMagnetNoChargeText
	text_end

PowerPlantMagnetDormantText:
	text_far _PowerPlantMagnetDormantText
	text_end
