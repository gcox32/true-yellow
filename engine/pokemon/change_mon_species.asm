; Permanently converts a party Pokémon into an "alternate form" species.
; The form keeps the base form's Pokédex number (via PokedexOrder) but has its
; own base stats, types, sprite, cry and name.
;
; input:
;   [wCurPartySpecies] = target species index (the form)
;   [wWhichPokemon]    = party slot (0-5)
;
; Recalculates stats from the mon's existing level / EXP / DVs, refills HP to
; the new maximum and copies the form's types. Moves, EXP, DVs, status and the
; nickname string are left untouched.
ChangePartyPokemonSpecies::
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	call GetMonHeader ; load the form's base stats into wMonHeader

; hl = wPartyMon<slot>
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	push hl

; write the form's species index into the party struct
	ld a, [wCurPartySpecies]
	ld [hl], a

; keep the parallel wPartySpecies array in sync
	ld a, [wWhichPokemon]
	ld e, a
	ld d, 0
	ld hl, wPartySpecies
	add hl, de
	ld a, [wCurPartySpecies]
	ld [hl], a

; level -> wCurEnemyLevel (CalcStats reads it as the level input)
	pop hl
	push hl
	ld bc, wPartyMon1Level - wPartyMon1
	add hl, bc
	ld a, [hl]
	ld [wCurEnemyLevel], a

; recalculate all five stats into the party struct's stat block
	pop hl
	push hl
	push hl
	ld bc, wPartyMon1Stats - wPartyMon1
	add hl, bc
	ld d, h
	ld e, l ; de = &wPartyMon<slot>MaxHP
	pop hl
	ld bc, wPartyMon1HPExp - 1 - wPartyMon1
	add hl, bc ; hl = &wPartyMon<slot>HPExp - 1
	ld b, 1 ; consider stat exp
	call CalcStats

; current HP = new max HP
	pop hl
	push hl
	push hl
	ld bc, wPartyMon1MaxHP - wPartyMon1
	add hl, bc
	ld a, [hli]
	ld b, a
	ld c, [hl] ; bc = new max HP
	pop hl
	ld de, wPartyMon1HP - wPartyMon1
	add hl, de
	ld [hl], b
	inc hl
	ld [hl], c

; copy the form's types out of the mon header
	pop hl
	ld bc, wPartyMon1Type1 - wPartyMon1
	add hl, bc
	ld a, [wMonHType1]
	ld [hli], a
	ld a, [wMonHType2]
	ld [hl], a
	ret

; Opens the party menu for an alternate-form conversion, saving and restoring
; the overworld screen around it (the trigger scripts run from a text box).
; Returns carry set if the player backed out; otherwise [wWhichPokemon] holds
; the chosen party slot.
SpeciesChangePartyMenu::
	call SaveScreenTilesToBuffer2
	xor a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wUpdateSpritesEnabled], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	push af
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	pop af
	ret
