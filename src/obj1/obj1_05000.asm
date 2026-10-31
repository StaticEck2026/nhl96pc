; The end-of-game screens: the team stats screen (DrawTeamStats in a panel that scrolls with two arrows) and
; the three stars screen, a card for each of the game's three stars with animated stars and sparkles, and its
; buttons: team stats, another choice, done, and chat in a modem game. ThreeStarsMenu runs it until done.
;
; Both screens run their buttons through one menu routine and end in the same tail (GameStatsScreen.exit),
; which goes on into DrawTeamStats' own tail. Each jump table sits just before the routine that uses it.

unk_1571B3_off	equ	unk_1571B3-obj4_base	; the player records as the code stores them; an equate
									; because NASM swaps base and index for [edx+eax+label-base]

; The team stats screen: background, banner with both teams, the stats panel (DrawTeamStats from row
; 0) and its up and down arrows, a Done button and, in a modem game, Chat. Up and down scroll the
; panel (statsfirstrow 0-10, the ball marks the row); Done leaves.
GameStatsScreen:					; the end-of-game team stats
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	enter	0x244,0
	sub	ebp,0x82					; locals above ebp too
	mov	eax,3
	call	sub_69A94
	call	sub_68AB1
	call	sub_DD6C4
	push	0
	call	sub_ADA50
	add	esp,4
	mov	eax,0xFE
	xor	edx,edx
	call	sub_1E7F6
	push	strict dword str_BKGD-obj4_base	; the background
	push	eax
	mov	esi,eax
	call	sub_E04E0
	add	esp,8
	push	eax
	call	sub_AADA4
	add	esp,4
	push	esi
	call	sub_ABF4C
	add	esp,4
	push	0
	push	strict dword 0xFE50
	push	strict dword str_BANNER-obj4_base	; the banner, FE50h bytes
	call	sub_AB758
	mov	esi,[unk_152F58-obj4_base]
	mov	edi,eax
	movsd
	movsd
	movsd
	movsd
	movsb
	mov	word [eax+4],0xC0
	mov	word [eax+6],0x153
	mov	[ebp+0x7E],eax
	mov	eax,[dword_17C9A0-obj4_base]
	add	esp,0xC
	mov	edi,[eax+1]
	mov	eax,2
	shl	edi,0xF
	call	sub_69A94
	shr	edi,0x1B
	call	sub_68AB1
	mov	eax,edi
	mov	esi,7
	cdq
	idiv	esi
	add	eax,strict dword 0x100
	xor	edx,edx
	call	sub_1E7F6
	push	edi
	push	strict dword str_fmt04d-obj4_base	; "%04d": a team's shape name
	mov	esi,eax
	lea	eax,[ebp+0x56]
	push	eax
	call	sub_ADC18
	add	esp,0xC
	lea	eax,[ebp+0x56]
	push	eax
	push	esi
	mov	dword [ebp+0x6E],0xFFFFFFFF
	call	sub_E04E0
	mov	edi,eax
	add	esp,8
	push	0x10
	push	dword [ebp+0x7E]
	push	eax
	call	sub_E0520
	mov	eax,[ebp+0x7E]
	add	esp,0xC
	add	eax,0x10
	push	eax
	add	edi,0x10
	push	edi
	mov	[ebp+0x66],eax
	call	sub_AFCD0
	add	esp,8
	push	0x46
	push	0x24
	mov	eax,[ebp+0x7E]
	push	eax
	and	dword [eax],0xFF
	call	sub_AAA40
	add	esp,0xC
	push	esi
	call	sub_ABF4C
	mov	eax,[dword_17C9A0-obj4_base]
	add	esp,4
	mov	esi,[eax+1]
	mov	eax,2
	shl	esi,0xA
	call	sub_69A94
	shr	esi,0x1B
	call	sub_68AB1
	mov	eax,esi
	mov	edi,7
	cdq
	idiv	edi
	add	eax,strict dword 0x100
	xor	edx,edx
	call	sub_1E7F6
	push	esi
	push	strict dword str_fmt04d-obj4_base
	mov	edi,eax
	lea	eax,[ebp+0x56]
	push	eax
	call	sub_ADC18
	add	esp,0xC
	lea	eax,[ebp+0x56]
	push	eax
	push	edi
	call	sub_E04E0
	add	esp,8
	push	0x10
	push	dword [ebp+0x7E]
	push	eax
	mov	esi,eax
	call	sub_E0520
	add	esp,0xC
	push	dword [ebp+0x66]
	add	esi,0x10
	push	esi
	call	sub_AFCD0
	add	esp,8
	push	0x46
	push	strict dword 0x19D
	mov	eax,[ebp+0x7E]
	push	eax
	and	dword [eax],0xFF
	call	sub_AAA40
	add	esp,0xC
	push	edi
	call	sub_ABF4C
	add	esp,4
	push	dword [ebp+0x7E]
	call	sub_ABF4C
	add	esp,4
	call	sub_63968
	mov	eax,2
	mov	edx,0x20
	call	sub_69A94
	call	sub_68AB1
	mov	eax,0x2F
	call	sub_1E7F6
	push	eax
	mov	[ebp+0x76],eax
	call	sub_B0284
	add	esp,4
	mov	edx,0xFE
	mov	eax,0xFC
	call	sub_63F79
	mov	eax,0xFF
	xor	edx,edx
	call	sub_1E7F6
	push	strict dword str_pal2-obj4_base	; the palette
	push	eax
	mov	[ebp+0x66],eax
	mov	[ebp+0x7A],eax
	call	sub_E04E0
	add	eax,0x10
	add	esp,8
	mov	[ebp+0x62],eax
	call	sub_62F90
	movsx	eax,word [unk_114DE4-obj4_base]
	movzx	edx,byte [byte_11FA2F-obj4_base]
	add	eax,edx
	movsx	edx,word [statsrowtop+4-obj4_base]
	inc	eax
	inc	eax
	sub	eax,edx
	mov	edx,[mousewidth-obj4_base]
	sub	edx,0xA
	imul	eax,edx
	push	0
	add	eax,0x10
	push	eax
	push	strict dword str_SBACK-obj4_base	; the stats panel
	call	sub_AB758
	mov	esi,[unk_152F58-obj4_base]
	mov	edi,eax
	movsd
	movsd
	movsd
	movsd
	movsb
	mov	word [eax+0xC],0
	mov	dx,[statsrowtop+4-obj4_base]
	dec	edx
	mov	[eax+0xE],dx
	mov	dx,[mousewidth-obj4_base]
	sub	edx,0xA
	mov	[ebp+0x6A],eax
	mov	[eax+4],dx
	mov	[ebp+0x72],eax
	movzx	ax,[byte_11FA2F-obj4_base]
	add	ax,[unk_114DE4-obj4_base]
	mov	si,[statsrowtop+4-obj4_base]
	inc	eax
	inc	eax
	mov	edx,[ebp+0x6A]
	sub	eax,esi
	add	esp,0xC
	mov	[edx+6],ax
	call	sub_DD6C4
	push	dword [ebp+0x6A]
	call	sub_AA988
	mov	word [statsfirstrow-obj4_base],0	; from the first row
	add	esp,4
	mov	eax,[ebp+0x6A]
	lea	edx,[ebp-0x1C2]
	call	DrawTeamStats
	mov	eax,3
	call	sub_64721
	push	strict dword str_AR00-obj4_base	; the up arrow shapes
	push	dword [ebp+0x66]
	call	sub_E04E0
	add	esp,8
	push	strict dword str_AR01-obj4_base
	push	dword [ebp+0x66]
	mov	[ebp-0x1A8],eax
	call	sub_E04E0
	mov	[ebp-0x1A4],eax
	mov	eax,[ebp-0x1A8]
	mov	dword [ebp-0x1B2],4
	movsx	eax,word [eax+0xC]
	mov	[ebp-0x2A],eax
	mov	eax,[ebp-0x1A8]
	movsx	eax,word [eax+0xE]
	mov	[ebp-0x26],eax
	mov	eax,[ebp-0x1A8]
	mov	edx,[ebp-0x2A]
	movsx	eax,word [eax+4]
	add	edx,eax
	mov	eax,[ebp-0x26]
	mov	[ebp-0x22],edx
	mov	[ebp-0x1E],eax
	mov	eax,[ebp-0x1A8]
	mov	[ebp-0x1A],edx
	mov	edx,[ebp-0x26]
	movsx	eax,word [eax+6]
	add	edx,eax
	mov	eax,[ebp-0x2A]
	mov	[ebp-0x12],eax
	lea	eax,[ebp-0x2A]
	mov	[ebp-0x1AE],eax
	mov	eax,[ebp-0x1A8]
	mov	[ebp-0x16],edx
	mov	[ebp-0xE],edx
	movsx	eax,word [eax+0xC]
	mov	[ebp-0x19C],eax
	mov	eax,[ebp-0x1A8]
	movsx	eax,word [eax+0xE]
	mov	[ebp-0x198],eax
	mov	eax,[ebp-0x1A8]
	movsx	eax,word [eax+4]
	mov	edx,[ebp-0x19C]
	sar	eax,1
	add	esp,8
	add	edx,eax
	mov	eax,[ebp-0x1A8]
	mov	[ebp-0x188],edx
	push	strict dword str_AR10-obj4_base	; the down arrow shapes
	movsx	eax,word [eax+6]
	mov	edx,[ebp-0x198]
	sar	eax,1
	push	dword [ebp+0x66]
	add	edx,eax
	mov	byte [ebp-0x17F],1
	mov	[ebp-0x184],edx
	call	sub_E04E0
	add	esp,8
	push	strict dword str_AR11-obj4_base
	push	dword [ebp+0x66]
	mov	[ebp-0x142],eax
	call	sub_E04E0
	mov	[ebp-0x13E],eax
	mov	eax,[ebp-0x142]
	mov	dword [ebp-0x14C],4
	movsx	eax,word [eax+0xC]
	mov	[ebp+0x16],eax
	mov	eax,[ebp-0x142]
	movsx	eax,word [eax+0xE]
	mov	[ebp+0x1A],eax
	mov	eax,[ebp-0x142]
	mov	edx,[ebp+0x16]
	movsx	eax,word [eax+4]
	add	edx,eax
	mov	eax,[ebp+0x1A]
	mov	[ebp+0x1E],edx
	mov	[ebp+0x22],eax
	mov	eax,[ebp-0x142]
	mov	[ebp+0x26],edx
	mov	edx,[ebp+0x1A]
	movsx	eax,word [eax+6]
	add	edx,eax
	mov	eax,[ebp+0x16]
	mov	[ebp+0x2E],eax
	lea	eax,[ebp+0x16]
	mov	[ebp-0x148],eax
	mov	eax,[ebp-0x142]
	mov	[ebp+0x2A],edx
	mov	[ebp+0x32],edx
	movsx	eax,word [eax+0xC]
	mov	[ebp-0x136],eax
	mov	eax,[ebp-0x142]
	movsx	eax,word [eax+0xE]
	mov	[ebp-0x132],eax
	mov	eax,[ebp-0x142]
	lea	edi,[ebp-0xF6]
	movsx	eax,word [eax+4]
	mov	edx,[ebp-0x136]
	sar	eax,1
	mov	esi,unk_17BD48-obj4_base	; the Done button
	add	edx,eax
	mov	eax,[ebp-0x142]
	mov	[ebp-0x122],edx
	mov	ecx,0x66
	movsx	eax,word [eax+6]
	mov	edx,[ebp-0x132]
	sar	eax,1
	mov	byte [ebp-0x11A],0
	add	edx,eax
	mov	byte [ebp-0x119],2
	mov	[ebp-0x11E],edx
	rep	movsb
	add	esp,8
	mov	ax,[linkgame-obj4_base]		; modem game?
	mov	byte [ebp-0xB4],1
	xor	ah,ah
	mov	byte [ebp-0xB2],2
	and	al,1
	mov	byte [ebp-0xB1],2
	cwde
	mov	byte [ebp-0xB3],2
	test	eax,eax
	jz	.buttons
	mov	ecx,0x66
	lea	edi,[ebp-0x90]
	mov	esi,unk_17BCE2-obj4_base	; the Chat button
	rep	movsb
	mov	byte [ebp-0x4E],3
	mov	byte [ebp-0x4C],3
	mov	byte [ebp-0x4B],3
	mov	byte [ebp-0x4D],0
	mov	byte [ebp-0x180],3
.buttons:							; modem game: Chat button added
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	or	al,2
	cwde
	call	sub_62AF7
	mov	edx,[ebp-0xB8]
	mov	eax,[ebp-0xBC]
	call	sub_66373
	mov	dword [ebp+0x5E],2
	call	sub_68C8F
	test	eax,eax
	jnz	.2
	call	sub_68BFA
.2:									; faded in
	mov	ebx,3
	mov	edx,[ebp+0x62]
	xor	eax,eax
	call	sub_63998
	mov	eax,1
	call	LinkSyncWait			; sync, wait sprite
	push	strict dword 0xA0
	push	strict dword 0x264
	push	strict dword str_BALL-obj4_base	; the ball at the first row
	push	dword [ebp+0x7A]
	call	sub_E04E0
	add	esp,8
	push	eax
	call	sub_AAA40
	add	esp,0xC
.loop:								; until Done
	call	sub_69A9B
	cmp	dword [ebp+0x5E],0
	jl	.menu
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	cwde
	add	eax,3
	cmp	eax,[ebp+0x5E]
	jng	.menu
	imul	eax,[ebp+0x5E],0x66
	mov	edx,[mousex-obj4_base]
	cmp	edx,[eax+ebp-0x188]
	jnz	.1
	mov	edx,[mousey-obj4_base]
	cmp	edx,[eax+ebp-0x184]
	jz	.menu
.1:									; the pointer moved off the last button
	mov	dword [ebp+0x5E],0xFFFFFFFF
.menu:								; run the buttons
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	mov	edx,eax
	or	dl,2
	movsx	edx,dx
	push	edx
	mov	ebx,0xFFFFFFFF
	xor	ecx,ecx
	push	2
	lea	edx,[ebp+0x5E]
	cwde
	push	edx
	add	eax,3
	lea	edx,[ebp-0x1C2]
	call	sub_64F59				; eax the button chosen
	cmp	dword [ebp+0x5E],2
	jc	.up
	jna	near .done
	cmp	dword [ebp+0x5E],3
	jz	near .chat
	jmp	.next
.up:								; button 0 or 1
	cmp	dword [ebp+0x5E],0
	jnz	.down
	cmp	word [statsfirstrow-obj4_base],0	; up: unless at the top
	jng	.down
	dec	word [statsfirstrow-obj4_base]
	jmp	.redraw
.down:								; not up, or already at the top
	cmp	dword [ebp+0x5E],1
	jnz	.redraw
	movsx	eax,word [statsfirstrow-obj4_base]	; down: up to row 10
	cmp	eax,10
	jnl	.redraw
	inc	word [statsfirstrow-obj4_base]
.redraw:							; scrolled or not
	mov	eax,[ebp+0x72]
	call	DrawTeamStats			; redraw the panel
	movsx	eax,word [statsfirstrow-obj4_base]
	imul	eax,eax,0xF
	add	eax,strict dword 0xA0
	push	eax
	push	strict dword 0x264
	push	strict dword str_BALL-obj4_base	; the ball at the row
	push	dword [ebp+0x7A]
	call	sub_E04E0
	add	esp,8
	push	eax
	call	sub_AAA40
	add	esp,0xC
	jmp	.next
.done:								; button 2: Done
	call	sub_62D9B
	mov	dword [ebp+0x6E],1			; leave
	jmp	.next
.chat:								; button 3: Chat
	call	sub_62E72
	push	dword [unk_17BC78-obj4_base]
	call	sub_B0284
	add	esp,4
	mov	ecx,0xFC
	mov	ebx,0xFA
	push	strict dword 0xFE
	mov	edx,0xF7
	mov	eax,1
	call	LinkChat				; chat
	push	dword [ebp+0x76]
	call	sub_B0284
	add	esp,4
.next:								; done yet?
	cmp	dword [ebp+0x6E],0
	jl	.loop
	push	dword [ebp+0x72]
	call	sub_ABF4C
	add	esp,4
	push	dword [ebp+0x7A]
	call	sub_ABF4C
	add	esp,4
	push	dword [ebp+0x76]
	call	sub_ABF4C
	add	esp,4
	mov	eax,3
	call	sub_63A5B
.exit:								; shared tail: ThreeStarsScreen ends here too
	lea	esp,[ebp+0x82]
	pop	ebp
	jmp	DrawTeamStats.tail			; pops and returns
ThreeStarsTick.table:				; ThreeStarsTick: the code for each sparkle step
	dd	ThreeStarsTick.case0-obj1_base	; step 0
	dd	ThreeStarsTick.case0-obj1_base	; step 1
	dd	ThreeStarsTick.case2-obj1_base	; step 2
	dd	ThreeStarsTick.case3-obj1_base	; step 3
	dd	ThreeStarsTick.case4-obj1_base	; step 4
	dd	ThreeStarsTick.case3-obj1_base	; step 5
	dd	ThreeStarsTick.case2-obj1_base	; step 6

; Animates the three stars screen, at most every 4 ticks: steps the star shapes (24 frames), and at
; random times puts a sparkle (6 steps) somewhere on one of three areas and runs two other effects.
; The menu routine calls it while ThreeStarsScreen waits for a button.
ThreeStarsTick:						; the menu callback
	push	ebx
	push	ecx
	push	edx
	push	esi
	call	GetTicks				; time yet?
	cmp	eax,[unk_114EF4-obj4_base]
	jng	.exit
	cmp	word [unk_114EFE-obj4_base],0	; star frame due?
	jnz	.3
	movsx	eax,word [unk_114F00-obj4_base]
	inc	eax							; next of 24 frames
	mov	ebx,0x18
	cdq
	idiv	ebx
	movsx	ebx,dx
	mov	eax,ebx
	mov	[unk_114F00-obj4_base],dx
	cdq
	shl	edx,3
	db	0x1B, 0xC2					; sbb eax,edx in its 1Bh form (NASM writes 19h)
.1:									; eax the frame / 8
	sar	eax,3
	mov	ecx,eax
	mov	eax,ebx
	mov	esi,8
	cdq
	idiv	esi
	shl	ecx,5
	mov	eax,edx
	push	dword [ecx+eax*4+unk_151AEC-obj4_base]	; show it
	call	sub_AADA4
	movsx	eax,word [unk_114F00-obj4_base]
	cdq
	idiv	esi
	mov	word [unk_114EFE-obj4_base],2
	add	esp,4
	cmp	edx,7
	jnz	.sparkle
	mov	word [unk_114EFE-obj4_base],0x20
	jmp	.sparkle
.3:									; star frame not due
	dec	word [unk_114EFE-obj4_base]
.sparkle:							; a sparkle under way?
	cmp	word [unk_114EF8-obj4_base],0
	jz	.newsparkle
	push	dword [unk_151B4C-obj4_base]
	call	sub_DD708
	add	esp,4
	push	0
	push	0
	push	dword [unk_151B64-obj4_base]
	call	sub_AAB40
	mov	ax,[unk_114EF8-obj4_base]
	add	esp,0xC
	cmp	ax,strict word 6			; the sparkle step
	ja	.case0
	movzx	eax,ax
	jmp	[cs:eax*4+ThreeStarsTick.table-obj1_base]
.case2:								; steps 2 and 6
	mov	eax,0xFD70					; a fraction of the size
	mov	edx,[unk_151B7C-obj4_base]
.5:									; edx the shape, eax the scale
	xor	ecx,ecx
	xor	ebx,ebx
	call	sub_64296
.case0:								; steps 0, 1 and the step done
	call	sub_DD6C4
	push	dword [unk_151AE8-obj4_base]
	mov	eax,[unk_151B4C-obj4_base]
	push	dword [unk_151AE4-obj4_base]
	push	dword [eax+0x2C]
	call	sub_AAB40
	dec	word [unk_114EF8-obj4_base]
	add	esp,0xC
	jmp	.next
.case3:								; steps 3 and 5
	mov	eax,0xFD70
	mov	edx,[unk_151B78-obj4_base]
	jmp	.5
.case4:								; step 4
	mov	eax,0xFD70
	mov	edx,[unk_151B74-obj4_base]
	jmp	.5
.newsparkle:						; no sparkle: time for one?
	call	GetTicks
	cmp	eax,[unk_114EE8-obj4_base]
	jng	.streak
	cmp	word [unk_114EFC-obj4_base],0
	jnz	.streak
	cmp	word [unk_114EFA-obj4_base],0
	jnz	.streak
	call	rand_					; one of three areas, at random
	mov	ebx,3
	cdq
	idiv	ebx
	mov	ebx,edx
	shl	ebx,6
	mov	esi,[ebx+unk_114DF0-obj4_base]
	sub	esi,[ebx+unk_114DE8-obj4_base]
	call	rand_					; a random x in it
	inc	esi
	cdq
	idiv	esi
	mov	eax,[ebx+unk_114DE8-obj4_base]
	add	eax,edx
	mov	edx,[ebx+unk_114DFC-obj4_base]
	sub	edx,[ebx+unk_114DF4-obj4_base]
	mov	[unk_151AE4-obj4_base],eax
	lea	esi,[edx+1]
	call	rand_					; a random y
	cdq
	idiv	esi
	mov	eax,[ebx+unk_114DF4-obj4_base]
	add	eax,edx
	mov	[unk_151AE8-obj4_base],eax
	mov	eax,[unk_151B4C-obj4_base]
	mov	eax,[eax+0x2C]
	mov	dx,[unk_151AE4-obj4_base]
	mov	[eax+0xC],dx
	mov	eax,[unk_151B4C-obj4_base]
	mov	eax,[eax+0x2C]
	mov	dx,[unk_151AE8-obj4_base]
	mov	[eax+0xE],dx
	mov	eax,[unk_151B4C-obj4_base]
	push	dword [eax+0x2C]
	call	sub_AA988
	add	esp,4
	push	dword [unk_151B64-obj4_base]
	call	sub_ABF4C
	mov	eax,[unk_151B4C-obj4_base]
	add	esp,4
	mov	edx,0x20
	mov	eax,[eax+0x2C]
	call	sub_63B0C
	mov	word [unk_114EF8-obj4_base],6	; six steps
	mov	[unk_151B64-obj4_base],eax
	call	GetTicks				; next in 30-99 ticks
	mov	ecx,0x46
	mov	ebx,eax
	call	rand_
	cdq
	idiv	ecx
	add	ebx,0x1E
	add	ebx,edx
	mov	[unk_114EE8-obj4_base],ebx
	jmp	.next
.streak:							; a streak under way?
	cmp	word [unk_114EFA-obj4_base],0
	jz	.newstreak
	movsx	eax,word [unk_114EFA-obj4_base]
	cmp	eax,5
	jnl	.8
	push	dword [unk_151B68-obj4_base]
	call	sub_AADA4
	add	esp,4
	push	dword [unk_151B68-obj4_base]
	call	sub_ABF4C
	mov	dword [unk_151B68-obj4_base],0
	add	esp,4
.8:									; streak step
	mov	esi,5
	movsx	eax,word [unk_114EFA-obj4_base]
	sub	esi,eax
	cmp	eax,1
	jz	.9
	mov	edx,0x20
	mov	eax,[nosplit esi*4+unk_151B50-obj4_base]
	call	sub_63B0C
	mov	[unk_151B68-obj4_base],eax
	call	sub_DD6C4
	push	dword [unk_151B68-obj4_base]
	call	sub_AA988
	add	esp,4
	push	dword [nosplit esi*4+unk_151B50-obj4_base]
	call	sub_AADA4
	add	esp,4
.9:									; step done
	dec	word [unk_114EFA-obj4_base]
	jmp	.next
.newstreak:							; time for a streak?
	cmp	word [unk_114EFC-obj4_base],0
	jnz	.effect
	call	GetTicks
	cmp	eax,[unk_114EF0-obj4_base]
	jng	.effect
	mov	word [unk_114EFA-obj4_base],5	; five steps
	mov	esi,0x190
	call	GetTicks				; next in 500-899 ticks
	mov	ebx,eax
	call	rand_
	cdq
	idiv	esi
	add	ebx,0x1F4
	add	ebx,edx
	mov	[unk_114EF0-obj4_base],ebx
	jmp	.next
.effect:							; the third effect
	cmp	word [unk_114EFC-obj4_base],0
	jz	.neweffect
	movsx	eax,word [unk_114EFC-obj4_base]
	cmp	eax,2
	jnz	.12
	call	rand_
	mov	ebx,2
	cdq
	idiv	ebx
	mov	esi,edx
	shl	esi,3
	mov	eax,[unk_151B70-obj4_base]
	mov	dx,[esi+unk_114EA8-obj4_base]
	mov	[eax+0xC],dx
	mov	eax,[unk_151B70-obj4_base]
	mov	dx,[esi+unk_114EAC-obj4_base]
	mov	[eax+0xE],dx
	call	sub_DD6C4
	push	dword [unk_151B70-obj4_base]
	call	sub_AA988
	add	esp,4
	push	dword [esi+unk_114EAC-obj4_base]
	push	dword [esi+unk_114EA8-obj4_base]
	push	dword [unk_151B6C-obj4_base]
	call	sub_AAA40
	add	esp,0xC
	jmp	.13
.12:								; its second step
	push	dword [unk_151B70-obj4_base]
	call	sub_AADA4
	add	esp,4
.13:								; step done
	dec	word [unk_114EFC-obj4_base]
	jmp	.next
.neweffect:							; time for it?
	call	GetTicks
	cmp	eax,[unk_114EEC-obj4_base]
	jng	.next
	mov	word [unk_114EFC-obj4_base],2
	call	GetTicks
	mov	ecx,0x1F4
	mov	ebx,eax
	call	rand_
	cdq
	idiv	ecx
	add	ebx,0xC8
	add	ebx,edx
	mov	[unk_114EEC-obj4_base],ebx
.next:								; next call in 4 ticks
	call	GetTicks
	add	eax,4
	mov	[unk_114EF4-obj4_base],eax
.exit:								; done
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret
ThreeStarsScreen.table:				; ThreeStarsScreen: the code for each button
	dd	ThreeStarsScreen.sel0-obj1_base	; button 0
	dd	ThreeStarsScreen.sel1-obj1_base	; button 1
	dd	ThreeStarsScreen.sel2-obj1_base	; button 2
	dd	ThreeStarsScreen.sel3-obj1_base	; button 3: Chat

; The three stars screen: a card for each star (startm, starpl) with the player's photo, name and the
; star, strength and meter shapes, then three buttons (four in a modem game, the fourth Chat).
; Returns 2 for the first button (in a modem game it shows a message instead), 1 for the second, 0
; for the third.
ThreeStarsScreen:					; returns eax 0-2
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	enter	0x2E4,0
	push	eax
	sub	ebp,0x82
	lea	edi,[ebp+0x26]
	mov	esi,word_144BD-obj1_base	; copy the data table into locals
	movsd
	movsw
	lea	edi,[ebp+0x2E]
	mov	esi,word_144C3-obj1_base
	movsd
	movsw
	lea	edi,[ebp+0x1A]
	mov	esi,dword_144C9-obj1_base
	movsd
	movsd
	movsd
	lea	edi,[ebp-0xA]
	mov	esi,dword_144D5-obj1_base
	movsd
	movsd
	movsd
	movsd
	movsd
	movsd
	mov	ecx,0x20
	lea	edi,[ebp-0xCA]
	mov	esi,dword_144ED-obj1_base
	mov	dword [ebp+0x76],0xFFFFFFFF
	mov	eax,2
	rep	movsd
	call	sub_69A94
	call	sub_68AB1
	xor	edi,edi
	xor	esi,esi
.cards:								; for each of the three stars
	movsx	edx,word [esi+startm-obj4_base]	; the star's player record
	imul	edx,edx,dword 0x4B4
	movsx	eax,word [esi+starpl-obj4_base]
	imul	eax,eax,0x2B
	mov	eax,[edx+eax+unk_1571B3_off]
	call	sub_1F15E
	mov	[esi+ebp+0xE],eax
	mov	edx,[unk_1174E0-obj4_base]
	mov	eax,[eax+0x2C]
	inc	edi
	inc	edi
	add	eax,edx
	add	esi,4
	inc	word [edi+eax+0x26]
	cmp	edi,6
	jnz	.cards
	mov	eax,0xFFFFFFF8
	call	sub_1E643
	push	0x20
	push	strict dword 0x900
	mov	dword [ebp+0x6A],0
	push	strict dword str_PALS-obj4_base	; "PALS"
	mov	dword [ebp+0x7A],0
	mov	dword [ebp+0x56],0
	call	sub_AB758
	add	esp,0xC
	mov	[ebp-0x1E],eax
.photos:							; a palette block each
	mov	eax,[ebp-0x1E]
	mov	edx,[ebp+0x7A]
	add	eax,[ebp+0x56]
	push	strict dword str_starsFSH-obj4_base	; "****.FSH": the photo file
	mov	[edx+ebp-0x1E],eax
	lea	eax,[ebp-0x4A]
	push	eax
	mov	esi,[ebp+0x6A]
	mov	ecx,4
	call	sub_ADC18
	add	esp,8
	mov	esi,[esi+ebp+0xE]
	lea	edi,[ebp-0x4A]
	add	esi,0x30
	rep	movsb
	lea	eax,[ebp-0x4A]
	push	eax
	call	sub_B0430
	add	esp,4
	test	eax,eax
	jnz	.3
	push	eax
	push	strict dword str_profilefsh-obj4_base	; no photo: "profile.fsh"
	call	sub_B0494
	add	esp,8
	push	strict dword str_ard-obj4_base
	mov	edi,[ebp+0x7A]
	push	eax
	mov	[ebp+0x4E],eax
	mov	[ebp+0x52],eax
	call	sub_E04E0
	mov	ecx,0x300
	add	esp,8
	lea	esi,[eax+0x10]
	mov	edi,[edi+ebp-0x1E]
	rep	movsb
	push	strict dword str_card-obj4_base
	jmp	.4
.3:									; no photo: the profile shapes
	push	0
	lea	eax,[ebp-0x4A]
	push	eax
	call	sub_B0494
	add	esp,8
	push	strict dword str_pal2-obj4_base
	mov	edi,[ebp+0x7A]
	push	eax
	mov	[ebp+0x4E],eax
	mov	[ebp+0x52],eax
	call	sub_E04E0
	mov	ecx,0x300
	add	esp,8
	lea	esi,[eax+0x10]
	mov	edi,[edi+ebp-0x1E]
	rep	movsb
	push	strict dword str_plyr-obj4_base
.4:									; eax the shape name
	push	dword [ebp+0x4E]
	call	sub_E04E0
	add	esp,8
	xor	edx,edx
	call	sub_63B0C
	mov	edx,[ebp+0x7A]
	mov	[edx+ebp-0x22],eax
	push	dword [ebp+0x52]
	add	dword [ebp+0x6A],4
	add	dword [ebp+0x7A],8
	add	dword [ebp+0x56],0x300
	call	sub_ABF4C
	add	esp,4
	cmp	dword [ebp+0x6A],0xC
	jnz	.photos
	xor	eax,eax
	call	sub_1E643
	mov	eax,4
	xor	edx,edx
	call	sub_69A94
	call	sub_68AB1
	mov	eax,0xB7
	call	sub_1E7F6
	push	0
	mov	esi,eax
	mov	[ebp+0x7E],eax
	call	sub_ADA50
	add	esp,4
	call	sub_63968
	push	strict dword str_pal2-obj4_base
	push	esi
	call	sub_E04E0
	add	eax,0x10
	add	esp,8
	mov	[ebp+0x62],eax
	call	sub_62F90
	mov	eax,4
	call	sub_69A94
	call	sub_68AB1
	push	dword [ebp-0xE]
	push	dword [ebp-0x12]
	push	dword [ebp-0x16]
	push	dword [ebp-0x1A]
	push	dword [ebp-0x1E]
	push	dword [ebp-0x22]
	push	3
	push	0x14
	push	strict dword 0xE5
	push	0x7E
	push	dword [ebp+0x62]
	call	sub_6448D
	add	esp,0x2C
	push	dword [ebp-0x1E]
	call	sub_ABF4C
	add	esp,4
	mov	eax,[ebp+0x62]
	call	sub_6423E
	call	sub_DD6C4
	push	strict dword str_BKGD-obj4_base	; the background
	push	esi
	call	sub_E04E0
	add	esp,8
	push	eax
	mov	dword [ebp+0x66],0
	call	sub_AADA4
	mov	edx,0xFE
	add	esp,4
	mov	eax,0xFC
	xor	edi,edi
	call	sub_63F79
	push	dword [unk_17BC74-obj4_base]
	xor	esi,esi
	call	sub_B0284
	add	esp,4
.5:									; screen set up
	push	0
	movsx	eax,word [edi+ebp+0x2E]
	push	eax
	movsx	eax,word [edi+ebp+0x26]
	push	eax
	call	sub_AD35C
	add	esp,0xC
	push	eax
	mov	[ebp+0x4E],eax
	call	sub_DD708
	add	esp,4
	push	0x74
	call	sub_E0584
	mov	eax,[ebp+0x66]
	add	esp,4
	mov	edx,[esi+ebp-0x22]
	xor	ecx,ecx
	xor	ebx,ebx
	mov	eax,[eax+ebp+0x1A]
	call	sub_64296
	push	dword [esi+ebp-0x22]
	call	sub_ABF4C
	add	esp,4
	call	sub_DD6C4
	push	dword [esi+ebp-6]
	mov	eax,[ebp+0x4E]
	push	dword [esi+ebp-0xA]
	push	dword [eax+0x2C]
	call	sub_AAB40
	add	esp,0xC
	push	dword [ebp+0x4E]
	call	sub_ADBEC
	mov	eax,[ebp+0x66]
	mov	eax,[eax+ebp+0xE]
	add	esp,4
	lea	edx,[eax+0x13]
	push	edx
	add	eax,3
	push	eax
	push	strict dword str_fmtss-obj4_base	; "%s %s": the player's names
	lea	eax,[ebp-0x4A]
	push	eax
	add	esi,8
	inc	edi
	inc	edi
	call	sub_ADC18
	lea	eax,[ebp-0x4A]
	add	esp,0x10
	mov	ebx,[esi+unk_114EB4-obj4_base]
	mov	edx,[esi+unk_114EB0-obj4_base]
	add	dword [ebp+0x66],4
	call	sub_64054
	cmp	edi,6
	jnz	.5
	push	strict dword str_ST10-obj4_base
	push	dword [ebp+0x7E]
	call	sub_E04E0
	add	esp,8
	mov	[ebp+0x72],eax
	movsx	edx,word [eax+6]
	push	0x20
	lea	edx,[edx+edx*2]
	movsx	eax,word [eax+4]
	sar	edx,2
	lea	eax,[eax+eax*2]
	push	edx
	sar	eax,2
	mov	dword [ebp+0x4A],0
	push	eax
	mov	dword [ebp+0x5E],0
	mov	dword [ebp+0x5A],0
	call	sub_AD35C
	add	esp,0xC
	mov	[ebp+0x42],eax
.6:									; name drawn
	mov	eax,[ebp+0x72]
	movsx	eax,word [eax+4]
	mov	edx,[ebp+0x5A]
	lea	eax,[eax+eax*2]
	mov	edx,[edx+unk_114ED0-obj4_base]
	sar	eax,3
	sub	edx,eax
	mov	eax,[ebp+0x42]
	mov	eax,[eax+0x2C]
	mov	[eax+0xC],dx
	mov	eax,[ebp+0x72]
	movsx	eax,word [eax+6]
	mov	edx,[ebp+0x5A]
	lea	eax,[eax+eax*2]
	mov	edx,[edx+unk_114ED4-obj4_base]
	sar	eax,3
	sub	edx,eax
	mov	eax,[ebp+0x42]
	mov	eax,[eax+0x2C]
	mov	[eax+0xE],dx
	call	sub_DD6C4
	mov	eax,[ebp+0x42]
	push	dword [eax+0x2C]
	call	sub_AA988
	mov	eax,[ebp+0x42]
	add	esp,4
	mov	edx,0x20
	mov	eax,[eax+0x2C]
	call	sub_63B0C
	push	dword [ebp+0x42]
	mov	[ebp+0x72],eax
	call	sub_DD708
	mov	edx,[ebp+0x4A]
	inc	edx
	add	esp,4
	mov	[ebp+0x3E],edx
	mov	edx,[ebp+0x5E]
	xor	eax,eax
	mov	[ebp+0x3A],edx
	mov	[ebp+0x6E],edx
.stars:								; the star shapes
	inc	eax
	mov	ebx,8
	mov	[ebp+0x4E],eax
	cdq
	idiv	ebx
	push	edx
	push	dword [ebp+0x3E]
	push	strict dword str_STdd-obj4_base
	lea	eax,[ebp-0x4A]
	push	eax
	call	sub_ADC18
	add	esp,0x10
	lea	eax,[ebp-0x4A]
	push	eax
	push	dword [ebp+0x7E]
	call	sub_E04E0
	add	esp,8
	push	0
	push	0
	mov	edx,[ebp+0x6E]
	push	dword [ebp+0x72]
	mov	[edx+unk_151AEC-obj4_base],eax
	call	sub_AAB40
	mov	edx,[ebp+0x6E]
	mov	eax,0xC000
	add	esp,0xC
	xor	ecx,ecx
	xor	ebx,ebx
	mov	edx,[edx+unk_151AEC-obj4_base]
	mov	esi,[ebp+0x42]
	call	sub_64296
	mov	esi,[esi+0x2C]
	movsx	edx,word [esi+4]
	movsx	eax,word [esi+6]
	imul	eax,edx
	mov	edi,[ebp+0x6E]
	mov	edi,[edi+unk_151AEC-obj4_base]
	lea	ecx,[eax+0x10]
	rep	movsb
	mov	eax,[ebp+0x4E]
	add	dword [ebp+0x6E],4
	cmp	eax,8
	jl	.stars
	push	dword [ebp+0x72]
	call	sub_ABF4C
	add	esp,4
	call	sub_DD6C4
	mov	eax,[ebp+0x3A]
	add	dword [ebp+0x5E],0x20
	add	dword [ebp+0x5A],8
	push	dword [eax+unk_151B08-obj4_base]
	inc	dword [ebp+0x4A]
	call	sub_AADA4
	add	esp,4
	cmp	dword [ebp+0x4A],3
	jl	.6
	mov	word [unk_114EFE-obj4_base],8
	push	dword [ebp+0x42]
	mov	word [unk_114F00-obj4_base],0
	call	sub_ADBEC
	xor	edi,edi
	xor	esi,esi
	add	esp,4
.8:									; strength shapes
	push	edi
	push	strict dword str_STRd-obj4_base
	lea	eax,[ebp-0x4A]
	push	eax
	call	sub_ADC18
	add	esp,0xC
	lea	eax,[ebp-0x4A]
	push	eax
	add	esi,4
	push	dword [ebp+0x7E]
	inc	edi
	call	sub_E04E0
	add	esp,8
	mov	[esi+unk_151B70-obj4_base],eax
	cmp	edi,3
	jl	.8
	mov	eax,[unk_151B74-obj4_base]
	push	0x20
	movsx	edx,word [eax+6]
	push	edx
	movsx	eax,word [eax+4]
	push	eax
	xor	edi,edi
	call	sub_AD35C
	mov	edx,0x20
	mov	[unk_151B4C-obj4_base],eax
	add	esp,0xC
	mov	eax,[eax+0x2C]
	xor	esi,esi
	call	sub_63B0C
	mov	[unk_151B64-obj4_base],eax
.9:									; meter shapes
	push	edi
	push	strict dword str_METd-obj4_base
	lea	eax,[ebp-0x4A]
	push	eax
	call	sub_ADC18
	add	esp,0xC
	lea	eax,[ebp-0x4A]
	push	eax
	add	esi,4
	push	dword [ebp+0x7E]
	inc	edi
	call	sub_E04E0
	add	esp,8
	mov	[esi+unk_151B4C-obj4_base],eax
	cmp	edi,4
	jl	.9
	push	strict dword str_STRK-obj4_base
	push	dword [ebp+0x7E]
	mov	dword [unk_151B68-obj4_base],0
	call	sub_E04E0
	add	esp,8
	mov	edx,0x20
	mov	[unk_151B6C-obj4_base],eax
	call	sub_63B0C
	mov	[unk_151B70-obj4_base],eax
	call	GetTicks
	mov	[unk_114EF4-obj4_base],eax
	mov	[unk_114EEC-obj4_base],eax
	mov	[unk_114EE8-obj4_base],eax
	call	GetTicks
	mov	ebx,0x190
	mov	esi,eax
	call	rand_
	cdq
	idiv	ebx
	mov	word [unk_114EFC-obj4_base],0
	mov	word [unk_114EFA-obj4_base],0
	mov	word [unk_114EF8-obj4_base],0
	add	esi,0x1F4
	mov	eax,4
	add	esi,edx
	lea	edx,[ebp-0x262]
	mov	[unk_114EF0-obj4_base],esi
	call	sub_64721
	push	strict dword str_BT00-obj4_base
	push	dword [ebp+0x7E]
	call	sub_E04E0
	add	esp,8
	push	strict dword str_BT01-obj4_base
	push	dword [ebp+0x7E]
	mov	[ebp-0x248],eax
	call	sub_E04E0
	add	esp,8
	push	strict dword str_BT02-obj4_base
	push	dword [ebp+0x7E]
	mov	[ebp-0x244],eax
	call	sub_E04E0
	mov	[ebp-0x240],eax
	lea	eax,[ebp-0xCA]
	mov	[ebp-0x24E],eax
	mov	eax,[ebp-0x248]
	mov	dword [ebp-0x252],8
	add	esp,8
	movsx	eax,word [eax+0xC]
	push	strict dword str_BT10-obj4_base
	mov	[ebp-0x23C],eax
	mov	eax,[ebp-0x248]
	push	dword [ebp+0x7E]
	movsx	eax,word [eax+0xE]
	mov	dword [ebp-0x228],0x159
	mov	dword [ebp-0x224],0x168
	mov	byte [ebp-0x21D],2
	mov	byte [ebp-0x21F],1
	mov	[ebp-0x238],eax
	call	sub_E04E0
	add	esp,8
	push	strict dword str_BT11-obj4_base
	push	dword [ebp+0x7E]
	mov	[ebp-0x1E2],eax
	call	sub_E04E0
	add	esp,8
	mov	[ebp-0x1DE],eax
	push	strict dword str_BT12-obj4_base
	push	dword [ebp+0x7E]
	call	sub_E04E0
	mov	[ebp-0x1DA],eax
	lea	eax,[ebp-0x8A]
	mov	[ebp-0x1E8],eax
	mov	eax,[ebp-0x1E2]
	mov	dword [ebp-0x1EC],8
	movsx	eax,word [eax+0xC]
	mov	[ebp-0x1D6],eax
	mov	eax,[ebp-0x1E2]
	lea	edi,[ebp-0x196]
	mov	esi,unk_17BD48-obj4_base
	movsx	eax,word [eax+0xE]
	mov	ecx,0x66
	mov	[ebp-0x1D2],eax
	mov	ax,[linkgame-obj4_base]		; modem game?
	add	esp,8
	xor	ah,ah
	mov	dword [ebp-0x1C2],0x159
	and	al,1
	mov	dword [ebp-0x1BE],0x197
	or	al,2
	mov	byte [ebp-0x1BA],0
	cwde
	mov	byte [ebp-0x1B7],2
	call	sub_62AF7
	rep	movsb
	mov	ax,[linkgame-obj4_base]
	mov	byte [ebp-0x154],2
	xor	ah,ah
	mov	byte [ebp-0x152],1
	and	al,1
	mov	byte [ebp-0x151],2
	cwde
	mov	byte [ebp-0x153],2
	test	eax,eax
	jz	.10
	mov	ecx,0x66
	lea	edi,[ebp-0x130]
	mov	esi,unk_17BCE2-obj4_base
	rep	movsb
	mov	byte [ebp-0xEE],3
	mov	byte [ebp-0xEC],3
	mov	byte [ebp-0xEB],3
	mov	byte [ebp-0xED],2
	mov	byte [ebp-0x154],3
.10:								; buttons set up
	mov	edx,[ebp-0x158]
	mov	eax,[ebp-0x15C]
	mov	ebx,3
	call	sub_66373
	mov	edx,[ebp+0x62]
	xor	eax,eax
	mov	dword [ebp+0x46],2
	call	sub_63998
	mov	eax,1
	call	LinkSyncWait			; sync, wait sprite
	cmp	dword [ebp-0x266],0
	jz	.loop
	push	strict dword 0x80
	call	sub_67A63
	add	esp,4
.loop:								; until a button that leaves
	call	sub_69A9B
	cmp	dword [ebp+0x46],0
	jl	.menu
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	cwde
	add	eax,3
	cmp	eax,[ebp+0x46]
	jng	.menu
	imul	eax,[ebp+0x46],0x66
	mov	edx,[mousex-obj4_base]
	cmp	edx,[eax+ebp-0x228]
	jnz	.12
	mov	edx,[mousey-obj4_base]
	cmp	edx,[eax+ebp-0x224]
	jz	.menu
.12:								; the pointer moved off
	mov	dword [ebp+0x46],0xFFFFFFFF
.menu:								; run the buttons, ThreeStarsTick animating
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	mov	edx,eax
	or	dl,2
	movsx	edx,dx
	push	edx
	mov	ecx,ThreeStarsTick-obj1_base	; ThreeStarsTick runs meanwhile
	mov	ebx,0xFFFFFFFF
	push	2
	lea	edx,[ebp+0x46]
	cwde
	push	edx
	add	eax,3
	lea	edx,[ebp-0x262]
	call	sub_64F59
	cmp	dword [ebp+0x46],3
	ja	.next
	mov	eax,[ebp+0x46]
	jmp	[cs:eax*4+ThreeStarsScreen.table-obj1_base]
.sel0:								; button 0
	mov	ax,[linkgame-obj4_base]
	xor	ah,ah
	and	al,1
	cwde
	test	eax,eax
	jz	.14							; modem game: message 266h
	xor	eax,eax
	call	sub_77355
	push	3
	push	0
	push	strict dword 0xF0
	mov	ecx,byte_17BDAE-obj4_base
	push	strict dword 0x140
	lea	ebx,[ebp+0x36]
	mov	[ebp+0x36],eax
	push	0
	mov	eax,0x266
	mov	edx,1
	call	sub_77355
	call	sub_1A109
	jmp	.next
.14:								; not a modem game: result 2
	mov	dword [ebp+0x76],2
	jmp	.next
.sel1:								; button 1: result 1
	mov	dword [ebp+0x76],1
	jmp	.next
.sel2:								; button 2: result 0
	call	sub_62D9B
	mov	dword [ebp+0x76],0
	jmp	.next
.sel3:								; button 3: Chat
	call	sub_62E72
	push	dword [unk_17BC78-obj4_base]
	call	sub_B0284
	add	esp,4
	mov	ecx,0xFC
	mov	ebx,0xFA
	push	strict dword 0xFE
	mov	edx,0xF7
	mov	eax,1
	call	LinkChat				; chat
.next:								; a result yet?
	cmp	dword [ebp+0x76],0
	jl	.loop
	cmp	dword [unk_151B68-obj4_base],0
	jz	.16
	push	dword [unk_151B68-obj4_base]
	call	sub_ABF4C
	add	esp,4
.16:								; no streak sprite
	push	dword [unk_151B70-obj4_base]
	call	sub_ABF4C
	add	esp,4
	push	dword [unk_151B64-obj4_base]
	call	sub_ABF4C
	add	esp,4
	push	dword [unk_151B4C-obj4_base]
	call	sub_ADBEC
	add	esp,4
	push	dword [ebp+0x7E]
	call	sub_ABF4C
	add	esp,4
	mov	eax,3
	call	sub_63A5B
	call	sub_686DF
	push	dword [unk_17BC78-obj4_base]
	call	sub_B0284
	mov	eax,[ebp+0x76]
	add	esp,4
	jmp	GameStatsScreen.exit		; pops and returns

; Runs the three stars screen until it returns 0: 1 opens the team stats screen, 2 waits on a routine
; until it returns A410h; then the end-of-screen calls.
ThreeStarsMenu:						; the three stars, until done
	push	ebx
	push	ecx
	push	edx
	mov	ebx,1						; first time: eax 1
.loop:								; until the screen returns 0
	mov	eax,ebx
	call	ThreeStarsScreen
	mov	ecx,eax
	xor	ebx,ebx
	cmp	eax,1
	jnz	.2
	call	GameStatsScreen			; 1: the team stats
	jmp	.next
.2:									; not the team stats
	cmp	eax,2
	jnz	.next
	mov	eax,[dword_17C9A0-obj4_base]	; 2:
	mov	eax,[eax+1]
	shl	eax,0xF
	mov	byte [unk_1820F1-obj4_base],0
	shr	eax,0x1B
.wait:								; until it returns A410h
	cmp	eax,strict dword 0xA410
	jz	.next
	mov	edx,0x64
	call	sub_8C51B
	jmp	.wait
.next:								; again unless 0
	test	ecx,ecx
	jnz	.loop
	mov	eax,0x50
	xor	edx,edx
	call	sub_68C33
	call	sub_689D1
	pop	edx
	pop	ecx
	pop	ebx
	ret
