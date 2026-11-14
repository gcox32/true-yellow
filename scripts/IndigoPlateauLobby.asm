IndigoPlateauLobby_Script:
	call Serial_TryEstablishingExternallyClockedConnection
	call EnableAutoTextBoxDrawing
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_2, [hl]
	res BIT_CUR_MAP_LOADED_2, [hl]
	ret z
	ResetEvent EVENT_VICTORY_ROAD_1_BOULDER_ON_SWITCH
	; Reset Elite Four events if the player started challenging them before
	ld hl, wElite4Flags
	bit BIT_STARTED_ELITE_4, [hl]
	res BIT_STARTED_ELITE_4, [hl]
	ret z
	ResetEventRange INDIGO_PLATEAU_EVENTS_START, EVENT_LANCES_ROOM_LOCK_DOOR
	ret

IndigoPlateauLobby_TextPointers:
	def_text_pointers
	dw_const IndigoPlateauLobbyNurseText,            TEXT_INDIGOPLATEAULOBBY_NURSE
	dw_const IndigoPlateauLobbyGymGuideText,         TEXT_INDIGOPLATEAULOBBY_GYM_GUIDE
	dw_const IndigoPlateauLobbyCooltrainerFText,     TEXT_INDIGOPLATEAULOBBY_COOLTRAINER_F
	dw_const IndigoPlateauLobbyClerkText,            TEXT_INDIGOPLATEAULOBBY_CLERK
	dw_const IndigoPlateauLobbyLinkReceptionistText, TEXT_INDIGOPLATEAULOBBY_LINK_RECEPTIONIST
	dw_const IndigoPlateauLobbyChanseyText,          TEXT_INDIGOPLATEAULOBBY_CHANSEY

IndigoPlateauLobbyNurseText:
	script_pokecenter_nurse

IndigoPlateauLobbyGymGuideText:
	; His usual pep talk, then he hands out any GYM LEADER's TM for free,
	; as many times as the player likes. Same list-menu setup as the
	; CERULEAN badge house, including the follower force-hide (self-clears
	; once this text closes, see DisplayPokemartDialogue_/chain_follow.asm).
	text_asm
	ld hl, wMistyOverworldStateFlags
	set 6, [hl]
	ld hl, wBrockOverworldStateFlags
	set 6, [hl]
	ld hl, .PepTalkText
	call PrintText
	xor a
	ld [wCurrentMenuItem], a
	ld [wListScrollOffset], a
.loop
	ld hl, .WhichTMText
	call PrintText
	ld hl, .GymTMList
	call LoadItemList
	ld hl, wItemList
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	xor a
	ld [wPrintItemPrices], a
	ld [wMenuItemToSwap], a
	ld a, SPECIALLISTMENU
	ld [wListMenuID], a
	call DisplayListMenuID
	jr c, .done
	ld a, [wCurItem]
	ld b, a
	ld c, 1
	call GiveItem
	jr nc, .bag_full
	ld hl, .ReceivedTMText
	call PrintText
	jr .loop
.bag_full
	ld hl, .NoRoomText
	call PrintText
.done
	xor a
	ld [wListScrollOffset], a
	ld hl, .GoForItText
	call PrintText
	jp TextScriptEnd

.GymTMList:
	item_list TM_BIDE, TM_BUBBLEBEAM, TM_THUNDERBOLT, TM_MEGA_DRAIN, TM_TOXIC, TM_PSYWAVE, TM_FIRE_BLAST, TM_FISSURE

.PepTalkText:
	text_far _IndigoPlateauLobbyGymGuideText
	text_end

.WhichTMText:
	text_far _IndigoPlateauLobbyGymGuideWhichTMText
	text_end

.ReceivedTMText:
	text_far _IndigoPlateauLobbyGymGuideReceivedTMText
	sound_get_item_1
	text_promptbutton
	text_end

.NoRoomText:
	text_far _IndigoPlateauLobbyGymGuideNoRoomText
	text_end

.GoForItText:
	text_far _IndigoPlateauLobbyGymGuideGoForItText
	text_end

IndigoPlateauLobbyCooltrainerFText:
	text_far _IndigoPlateauLobbyCooltrainerFText
	text_end

IndigoPlateauLobbyLinkReceptionistText:
	script_cable_club_receptionist

IndigoPlateauLobbyChanseyText:
	text_asm
	callfar PokecenterChanseyText
	jp TextScriptEnd
