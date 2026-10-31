; Object 1 from its start: the Watcom start-of-code trap, then the controller code. It finds the mouse
; and the joystick slots, sets up the four controllers before a game and reads each one into a pad word every
; frame: the keyboard through key binding tables, the mouse by screen zones, the joysticks from sampled bits.
;
; A pad word: bits 0-1 key bindings 0 and 1, bits 2-5 the direction (4 up, 8 down, 10h right, 20h left), bits
; 6-7 the two buttons, bits 10-13 and 18 the home team's extra keys, bits 14-17 and 19 the away team's, bit 20
; a double tap of the same direction. The file ends with GrLink, the GrIP library's loader for Gravis pads.

dirmaptab_off	equ	dirmaptab-obj4_base	; dirmaptab as the code stores it; an equate because
									; NASM swaps base and index for [ebx+eax+label-base]

; Watcom start of code. A call through a null code pointer lands here and stops.
forever:							; trap
	int3							; breakpoint
	jmp	forever						; and stay
___begtext:							; start of the program code (Watcom ___begtext)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

; Returns which controllers there are, as ctlavailmask holds them.
GetCtlAvailMask:					; returns eax: bit 0 mouse, bits 1-4 joystick slots 0-3
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	mov	dword [ebp-8],0				; the mask
	cmp	word [mousepresent-obj4_base],0	; bit 0: the mouse
	jz	.1
	or	dword [ebp-8],1
.1:									; joystick slots next
	mov	ax,[joyslotmask-obj4_base]	; bits 1-4: joystick slots 0-3
	and	eax,strict dword 1
	cwde
	test	eax,eax
	jz	.2
	or	dword [ebp-8],2
.2:									; slot 0 done
	mov	ax,[joyslotmask-obj4_base]
	and	eax,strict dword 2
	cwde
	test	eax,eax
	jz	.3
	or	dword [ebp-8],4
.3:									; slot 1 done
	mov	ax,[joyslotmask-obj4_base]
	and	eax,strict dword 4
	cwde
	test	eax,eax
	jz	.4
	or	dword [ebp-8],8
.4:									; slot 2 done
	mov	ax,[joyslotmask-obj4_base]
	and	eax,strict dword 8
	cwde
	test	eax,eax
	jz	.5
	or	dword [ebp-8],0x10
.5:									; slot 3 done
	mov	eax,[ebp-8]
	mov	[ebp-4],eax
	mov	eax,[ebp-4]					; returns the mask
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Looks for the controllers: the mouse the first time only, the joystick slots every time.
DetectControllers:					; sets joyslotmask, mousepresent
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	mov	word [joyslotmask-obj4_base],0	; looks again every time
	mov	word [mousepresent-obj4_base],0
	cmp	word [mousechecked-obj4_base],0	; the mouse only the first time
	jnz	.joysticks
	call	MouseInit				; returns 0 when there is no mouse
	test	eax,eax
	jz	.1
	mov	word [mousepresent-obj4_base],1
	call	[mousepollfn-obj4_base]	; first read of the mouse
.1:									; mouse looked for
	mov	word [mousechecked-obj4_base],1
.joysticks:							; the joystick slots, every time
	call	DetectJoysticks			; a bit per slot with a pad
	mov	[joyslotmask-obj4_base],ax
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads one key binding into a pad. Args: eax Ctrl held, edx Alt held, ebx binding number, ecx the pad
; bits, on the stack the pad's address (popped). A binding that needs Ctrl (or else Alt) only counts
; with that key held; one that needs neither counts on its own.
ReadKeyBinding:						; eax Ctrl, edx Alt, ebx binding, ecx bits, [esp+4] pad
	push	esi
	push	edi
	enter	4,0
	mov	esi,[ebp+0x10]				; esi the pad's address
	mov	[ebp-4],eax					; Ctrl held
	mov	edi,ecx						; edi the bits
	mov	eax,[keybindings-obj4_base]	; the binding: 4 bytes each
	shl	ebx,2
	add	eax,ebx
	cmp	byte [eax],0				; needs Ctrl?
	jz	.noctrl
	cmp	dword [ebp-4],0
.modifier:							; Z: the modifier the binding needs is not held
	jz	.exit
	movsx	eax,word [eax+2]		; its scan code
	push	eax
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.exit
	jmp	.down
.noctrl:							; the binding does not need Ctrl
	cmp	byte [eax+1],0				; needs Alt?
	jz	.plain
	test	edx,edx					; Alt held?
	jmp	.modifier
.plain:								; the binding needs no modifier
	movsx	eax,word [eax+2]
	push	eax
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.exit
.down:								; the key is down
	or	[esi],edi					; set the bits
.exit:								; pops the pad address
	leave
	pop	edi
	pop	esi
	ret	4

; Starts a pad: eax the pad's address. Clears it and reads key bindings 0 and 1 into bits 0 and 1.
ReadSharedKeys:						; eax pad address
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	enter	4,0
	mov	esi,eax
	push	0x1D					; Ctrl
	mov	dword [eax],0				; the pad starts empty
	call	KeyDown
	add	esp,4
	push	0x38					; Alt
	mov	[ebp-4],eax
	call	KeyDown
	mov	ecx,1						; binding 0 -> bit 0
	add	esp,4
	mov	edi,eax
	mov	edx,eax
	push	esi
	xor	ebx,ebx
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,2						; binding 1 -> bit 1
	mov	ebx,1
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	leave
.exit:								; shared tail: SetupControllers ends here too
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Maps a pad's direction through dirmaptab. eax the pad's address; the row (0-7, probably the camera
; view) comes from a routine still to be named. Not called: ReadControllerPads has the same code inline.
MapPadDirection:					; eax pad address
	push	ebx
	push	edx
	mov	edx,eax
	mov	ebx,[eax]					; the direction: bits 2-5
	sar	ebx,2
	and	ebx,0xF
	and	byte [eax],0xC3				; clear it in the pad
	cmp	ebx,0xA						; over 10 (left and down)?
	jng	.1
	xor	ebx,ebx
.1:									; ebx the direction, 0-10
	call	sub_619E2				; the row, 0-7
	movsx	eax,al
	imul	eax,eax,0xB				; 11 directions a row
	movsx	ebx,byte [ebx+eax+dirmaptab_off]
	mov	eax,ebx						; the mapped direction back into bits 2-5
	and	eax,0xF
	shl	eax,2
	or	[edx],eax
	pop	edx
	pop	ebx
	ret

; Reads the keyboard into a pad. eax the pad's address, edx nonzero for the home team. Key bindings 2-11
; give the buttons and the eight directions; a second press of a direction within 10 ticks sets the
; double-tap bit. Then the team's five extra keys, read at most every 18 ticks.
ReadKeyboardPad:					; eax pad address, edx home team
	push	ebx
	push	ecx
	push	esi
	push	edi
	enter	0x10,0
	mov	esi,eax
	mov	[ebp-0xC],edx
	push	0x1D					; Ctrl
	call	KeyDown
	add	esp,4
	push	0x38					; Alt
	mov	[ebp-0x10],eax
	mov	[ebp-4],eax
	call	KeyDown
	mov	ecx,0x80					; binding 3 -> button 80h
	mov	ebx,3
	add	esp,4
	mov	edi,eax
	mov	[ebp-8],eax
	push	esi
	mov	edx,eax
	mov	eax,[ebp-0x10]
	call	ReadKeyBinding
	mov	ecx,0x40					; binding 2 -> button 40h
	mov	ebx,2
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x20					; bindings 4-11: the eight directions, 7 8 9 / 4 6 / 1 2 3
	mov	ebx,4
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,4						; up and left
	mov	eax,[ebp-0x10]
	push	esi
	mov	edx,edi
	mov	ebx,ecx
	call	ReadKeyBinding
	mov	ecx,4						; up
	mov	ebx,5
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,4						; up and right
	mov	ebx,6
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x10
	mov	ebx,6
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x20					; left
	mov	ebx,7
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x10					; right
	mov	ebx,8
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,8						; down and left
	mov	ebx,9
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x20
	mov	ebx,9
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,8						; down
	mov	ebx,0xA
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,8						; down and right
	mov	ebx,0xB
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x10
	mov	ebx,0xB
	push	esi
	mov	eax,[ebp-0x10]
	mov	edx,edi
	call	ReadKeyBinding
	mov	edi,[esi]					; the direction held now
	sar	edi,2
	mov	eax,[kbdtapstate-obj4_base]	; double tap state
	and	edi,0xF
	test	eax,eax
	jna	.tapfree
	cmp	eax,1
	jz	.tapheld
	jmp	.teamkeys
.tapfree:							; no direction held before
	test	edi,edi
	jz	.teamkeys
	call	GetTicks				; a direction pushed
	cmp	edi,[kbdtapdir-obj4_base]	; the same one as last time
	jnz	.held
	cmp	eax,[kbdtaptime-obj4_base]	; before the time ran out?
	jnl	.held
	or	byte [esi+2],0x10			; double tap: pad bit 20
	mov	[kbdtaptime-obj4_base],eax	; ends the time
.held:								; now held
	mov	dword [kbdtapstate-obj4_base],1	; held
	jmp	.lastdir
.tapheld:							; a direction was held
	test	edi,edi					; still held?
	jnz	.lastdir
	mov	[kbdtapstate-obj4_base],edi	; let go:
	call	GetTicks
	add	eax,0xA						; the same one counts for 10 ticks
	mov	[kbdtaptime-obj4_base],eax
	jmp	.teamkeys
.lastdir:							; remember the direction
	mov	[kbdtapdir-obj4_base],edi
.teamkeys:							; the extra keys of the team
	cmp	dword [ebp-0xC],0			; home team?
	jz	.away
	call	GetTicks				; not read again for 18 ticks
	cmp	eax,[homekeytime-obj4_base]
	jng	.exit
	mov	ecx,0x400					; bindings 0Ch-0Fh -> bits 10-13
	mov	ebx,0xC
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x800
	mov	ebx,0xD
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x1000
	mov	ebx,0xE
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x2000
	mov	ebx,0xF
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x40000					; binding 14h -> bit 18
	mov	ebx,0x14
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12					; 18 ticks
	mov	[homekeytime-obj4_base],eax
	jmp	.exit
.away:								; away team: bindings 10h-13h and 15h
	call	GetTicks
	cmp	eax,[awaykeytime-obj4_base]
	jng	.exit
	mov	ecx,0x4000					; bindings 10h-13h -> bits 14-17
	mov	ebx,0x10
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x8000
	mov	ebx,0x11
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x10000
	mov	ebx,0x12
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x20000
	mov	ebx,0x13
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	mov	ecx,0x80000					; binding 15h -> bit 19
	mov	ebx,0x15
	push	esi
	mov	edx,[ebp-8]
	mov	eax,[ebp-4]
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12
	mov	[awaykeytime-obj4_base],eax
.exit:								; shared tail: ReadMousePad ends here too
	leave
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret

; Reads the keyboard into a pad (eax) as the home team, with Enter as button 2. Not called: the same code
; is inline in ReadControllerPads.
ReadKeyboardPadEnter:				; eax pad address
	push	ebx
	push	ecx
	push	edx
	push	esi
	mov	esi,eax
	mov	edx,1						; as the home team
	call	ReadKeyboardPad
	push	0x1C					; Enter
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.1
	or	byte [esi],0x80				; button 80h
.1:									; done
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads the mouse into a pad. eax the pad's address, edx nonzero for the home team. First the team's
; five extra keys (Ctrl and Alt work with the mouse), then the direction from the screen zone the
; pointer is in and the two buttons.
ReadMousePad:						; eax pad address, edx home team
	push	ebx
	push	ecx
	push	esi
	push	edi
	enter	8,0
	mov	esi,eax
	mov	[ebp-8],edx
	push	0x1D					; Ctrl
	call	KeyDown
	add	esp,4
	push	0x38					; Alt
	mov	[ebp-4],eax
	call	KeyDown
	mov	edi,eax
	add	esp,4
	cmp	dword [ebp-8],0				; home team?
	jz	.away
	call	GetTicks				; not read again for 18 ticks
	cmp	eax,[homekeytime-obj4_base]
	jng	.mouse
	mov	ecx,0x400					; bindings 0Ch-0Fh -> bits 10-13
	mov	ebx,0xC
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x800
	mov	ebx,0xD
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x1000
	mov	ebx,0xE
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x2000
	mov	ebx,0xF
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x40000					; binding 14h -> bit 18
	mov	ebx,0x14
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12					; 18 ticks
	mov	[homekeytime-obj4_base],eax
	jmp	.mouse
.away:								; away team: bindings 10h-13h and 15h
	call	GetTicks
	cmp	eax,[awaykeytime-obj4_base]
	jng	.mouse
	mov	ecx,0x4000					; bindings 10h-13h -> bits 14-17
	mov	ebx,0x10
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x8000
	mov	ebx,0x11
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x10000
	mov	ebx,0x12
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x20000
	mov	ebx,0x13
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	mov	ecx,0x80000					; binding 15h -> bit 19
	mov	ebx,0x15
	push	esi
	mov	eax,[ebp-4]
	mov	edx,edi
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12
	mov	[awaykeytime-obj4_base],eax
.mouse:								; extra keys done
	call	[mousepollfn-obj4_base]	; read the mouse: al the buttons
	test	byte [byte_17CA5D-obj4_base],0x20	; 640 by 480?
	jz	.lores
	cmp	dword [mousex-obj4_base],0xA0	; left of 160
	jnl	.1
	or	byte [esi],0x20				; left
	jmp	.hiy
.1:									; not left
	cmp	dword [mousex-obj4_base],0x1E0	; right of 480
	jng	.hiy
	or	byte [esi],0x10				; right
.hiy:								; up or down
	cmp	dword [mousey-obj4_base],0x78	; above 120
	jnl	.2
.up:								; above the top zone
	or	byte [esi],4				; up
	jmp	.buttons
.2:									; not up
	cmp	dword [mousey-obj4_base],0x168	; below 360
	jng	.buttons
	jmp	.down
.lores:								; 320 by 200: the zones end at 80, 240 and 50, 150
	cmp	dword [mousex-obj4_base],0x50	; left of 80
	jnl	.3
	or	byte [esi],0x20
	jmp	.loy
.3:									; not left
	cmp	dword [mousex-obj4_base],0xF0	; right of 240
	jng	.loy
	or	byte [esi],0x10
.loy:								; up or down
	cmp	dword [mousey-obj4_base],0x32	; above 50
	jl	.up
	cmp	dword [mousey-obj4_base],0x96	; below 150
	jng	.buttons
.down:								; below the bottom zone
	or	byte [esi],8				; down
.buttons:							; direction done
	test	byte [byte_17CA22-obj4_base],1	; buttons swapped?
	jz	.unswapped
	test	al,2					; right button
	jz	.4
	or	byte [esi],0x40				; button 40h
.4:									; not the right button
	test	al,1					; left button
	jz	ReadKeyboardPad.exit
	jmp	.button2
.unswapped:							; left button 40h, right 80h
	test	al,1					; left button
	jz	.5
	or	byte [esi],0x40
.5:									; not the left button
	test	al,2					; right button
	jz	ReadKeyboardPad.exit
.button2:							; the second button
	or	byte [esi],0x80				; button 80h
	jmp	ReadKeyboardPad.exit

; Reads a joystick into a pad. eax the joystick slot (0-3), edx the pad's address, ebx nonzero for the
; home team. The team's extra keys, then the direction and buttons from the slot's byte of
; joyrawbits; a second push of a direction within 12 ticks sets the double-tap bit.
ReadJoyPad:							; eax slot, edx pad address, ebx home team
	push	ecx
	push	esi
	push	edi
	enter	0xC,0
	push	eax						; the slot, at [ebp-10h]
	mov	esi,edx
	mov	[ebp-0xC],ebx
	push	0x1D					; Ctrl
	call	KeyDown
	add	esp,4
	push	0x38					; Alt
	mov	edi,eax
	call	KeyDown
	mov	[ebp-4],eax
	add	esp,4
	cmp	dword [ebp-0xC],0			; home team?
	jz	.away
	call	GetTicks				; not read again for 18 ticks
	cmp	eax,[homekeytime-obj4_base]
	jng	.stick
	mov	ecx,0x400					; bindings 0Ch-0Fh -> bits 10-13
	mov	ebx,0xC
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x800
	mov	ebx,0xD
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x1000
	mov	ebx,0xE
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x2000
	mov	ebx,0xF
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x40000					; binding 14h -> bit 18
	mov	ebx,0x14
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12					; 18 ticks
	mov	[homekeytime-obj4_base],eax
	jmp	.stick
.away:								; away team: bindings 10h-13h and 15h
	call	GetTicks
	cmp	eax,[awaykeytime-obj4_base]
	jng	.stick
	mov	ecx,0x4000					; bindings 10h-13h -> bits 14-17
	mov	ebx,0x10
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x8000
	mov	ebx,0x11
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x10000
	mov	ebx,0x12
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x20000
	mov	ebx,0x13
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	mov	ecx,0x80000					; binding 15h -> bit 19
	mov	ebx,0x15
	push	esi
	mov	edx,[ebp-4]
	mov	eax,edi
	call	ReadKeyBinding
	call	GetTicks
	add	eax,0x12
	mov	[awaykeytime-obj4_base],eax
.stick:								; extra keys done
	mov	ecx,[ebp-0x10]				; the slot's byte of joyrawbits
	mov	eax,[joyrawbits-obj4_base]
	shl	ecx,3
	sar	eax,cl
	and	eax,0x3F					; direction and two buttons
	shl	eax,2						; -> pad bits 2-7
	or	[esi],eax
	mov	eax,[esi]					; the direction held now
	sar	eax,2
	mov	edi,[ebp-0x10]
	and	eax,0xF
	shl	edi,2						; dword index
	mov	[ebp-8],eax
	mov	eax,[edi+joytapstate-obj4_base]	; the slot's double tap state
	test	eax,eax
	jna	.tapfree
	cmp	eax,1
	jz	.tapheld
	leave
	pop	edi
	pop	esi
	pop	ecx
	ret
.tapfree:							; no direction held before
	cmp	dword [ebp-8],0
	jz	.exit
	call	GetTicks				; a direction pushed
	mov	ecx,[ebp-8]
	cmp	ecx,[edi+joytapdir-obj4_base]	; the same one as last time
	jnz	.held
	cmp	eax,[edi+joytaptime-obj4_base]	; before the time ran out?
	jnl	.held
	or	byte [esi+2],0x10			; double tap: pad bit 20
	mov	[edi+joytaptime-obj4_base],eax	; ends the time
.held:								; now held
	mov	esi,[ebp-0x10]
	mov	eax,[ebp-8]
	mov	dword [esi*4+joytapstate-obj4_base],1	; held
	mov	[esi*4+joytapdir-obj4_base],eax
	leave
	pop	edi
	pop	esi
	pop	ecx
	ret
.tapheld:							; a direction was held
	cmp	dword [ebp-8],0
	jnz	.lastdir					; still held?
	mov	dword [edi+joytapstate-obj4_base],0	; let go:
	call	GetTicks
	add	eax,0xC						; the same one counts for 12 ticks
	mov	[edi+joytaptime-obj4_base],eax
	leave
	pop	edi
	pop	esi
	pop	ecx
	ret
.lastdir:							; remember the direction
	mov	eax,[ebp-8]
	mov	[edi+joytapdir-obj4_base],eax
.exit:								; nothing held
	leave
	pop	edi
	pop	esi
	pop	ecx
	ret

; Sets the controllers up for play: clears the double-tap state, picks the key binding table, fills
; ctlrecs and cont1team from the game setup, gives the mouse the 320 by 200 area and centres it, and
; clears the input queue.
SetupControllers:					; fills ctlrecs
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	mov	dword [kbdtapdir-obj4_base],0	; no double taps under way
	mov	dword [kbdtapstate-obj4_base],0
	mov	dword [joytapdir+4-obj4_base],0
	mov	dword [joytapdir-obj4_base],0
	mov	dword [joytapstate+4-obj4_base],0
	mov	dword [joytapstate-obj4_base],0
	call	GetTicks				; the team keys may be read at once
	mov	[homekeytime-obj4_base],eax
	call	GetTicks
	mov	[awaykeytime-obj4_base],eax
	call	GetCtlAvailMask			; which controllers there are
	mov	[ctlavailmask-obj4_base],eax
	test	byte [byte_17CA21-obj4_base],0x80	; which key binding table
	jz	.1
	mov	dword [keybindings-obj4_base],keybindtab1-obj4_base
	jmp	.records
.1:									; bit 7 clear
	mov	dword [keybindings-obj4_base],keybindtab0-obj4_base
.records:							; table picked
	mov	ecx,ctl_count*ctl_size		; clear ctlrecs
	mov	edi,ctlrecs-obj4_base
	xor	eax,eax
	rep	stosb
	xor	ebx,ebx						; ebx the controller
	xor	edx,edx						; edx its record
	mov	di,[linkgame-obj4_base]	; bit 0: a modem game
	mov	esi,[dword_17C9A0-obj4_base]	; esi the game setup
	xor	eax,eax						; eax the controller * 2
	and	edi,1
.loop:								; for each controller
	mov	ecx,[dword_17C9A0-obj4_base]	; its device from the setup
	mov	cx,[ecx+eax+9]
	mov	[edx+ctlrecs+ctl_device-obj4_base],cx
	movsx	ecx,di
	mov	byte [edx+ctlrecs+ctl_type-obj4_base],1	; a player at this machine
	test	ecx,ecx					; modem game?
	jz	.team
	movsx	ecx,word [linkside-obj4_base]	; which two
	cmp	ecx,1
	jnz	.2
	mov	byte [ctlrecs+2*ctl_size+ctl_type-obj4_base],2	; controllers 2 and 3
	mov	byte [ctlrecs+3*ctl_size+ctl_type-obj4_base],2
	jmp	.team
.2:									; or controllers 0 and 1
	mov	byte [ctlrecs+ctl_type-obj4_base],2	; controllers 0 and 1
	mov	byte [ctlrecs+ctl_size+ctl_type-obj4_base],2
.team:								; the controller's team
	movsx	ecx,word [edx+ctlrecs+ctl_device-obj4_base]	; device 1: none
	cmp	ecx,1
	jnz	.3
	mov	word [eax+cont1team-obj4_base],0	; no team
	jmp	.next
.3:									; it has a device
	cmp	byte [esi+ebx+5],0			; the setup's team flag
	jz	.4
	mov	word [eax+cont1team-obj4_base],1	; home team
	jmp	.next
.4:									; flag clear
	mov	word [eax+cont1team-obj4_base],2	; away team
.next:								; team set
	inc	eax
	inc	eax
	inc	ebx
	add	edx,ctl_size
	cmp	ebx,ctl_count
	jl	.loop
	test	byte [ctlavailmask-obj4_base],1	; a mouse?
	jz	.queue
	push	0xC8					; the 320 by 200 area
	push	0x140
	push	0
	push	0
	call	MouseSetRange
	add	esp,0x10
	push	0x64					; centred
	push	0xA0
	call	MouseSetPos
	add	esp,8
	call	[mousepollfn-obj4_base]	; read it once
.queue:								; the input queue
	mov	ecx,0x10					; 16 bytes
	mov	edi,byte_114B8C-obj4_base
	xor	eax,eax
	rep	stosb
	mov	ecx,0x5A					; the input queue: 90 bytes
	mov	edi,byte_1515D4-obj4_base
	xor	eax,eax
	rep	stosb
	mov	dword [dword_114BA4-obj4_base],0
	mov	dword [dword_114B9C-obj4_base],0
	mov	dword [dword_114BA0-obj4_base],0
	mov	dword [dword_114F08-obj4_base],0
	jmp	ReadSharedKeys.exit

; Undoes SetupControllers: clears ctlrecs, gives the mouse its whole area back and centres it, and
; clears the input queue.
ReleaseControllers:					; clears ctlrecs
	push	ebx
	push	ecx
	push	edx
	push	edi
	mov	ecx,ctl_count*ctl_size		; clear ctlrecs
	mov	edi,ctlrecs-obj4_base
	xor	eax,eax
	rep	stosb
	test	byte [ctlavailmask-obj4_base],1	; a mouse?
	jz	.queue
	push	dword [mouseheight-obj4_base]	; its whole area
	push	dword [mousewidth-obj4_base]
	push	0
	push	0
	call	MouseSetRange
	mov	eax,[mouseheight-obj4_base]	; centred
	add	esp,0x10
	sar	eax,1
	push	eax
	mov	eax,[mousewidth-obj4_base]
	sar	eax,1
	push	eax
	call	MouseSetPos
	add	esp,8
	call	[mousepollfn-obj4_base]	; read it once
.queue:								; the input queue
	mov	ecx,0x5A					; the input queue: 90 bytes
	mov	edi,byte_1515D4-obj4_base
	xor	eax,eax
	mov	dword [dword_114F08-obj4_base],0
	rep	stosb
	mov	dword [dword_114BA4-obj4_base],0
	mov	dword [dword_114B9C-obj4_base],0
	mov	dword [dword_114BA0-obj4_base],0
	pop	edi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads every controller at this machine into its ctlrecs pad. Samples the joysticks when a
; slot is in use, reads the keys every controller shares, then the controller's own device.
ReadControllerPads:					; reads every pad
	push	ebx
	push	ecx
	push	edx
	push	esi
	enter	4,0
	cmp	word [joyslots+js_flags-obj4_base],0	; any joystick slot in use?
	jnz	.joysticks
	cmp	word [joyslots+js_size+js_flags-obj4_base],0
	jnz	.joysticks
	cmp	word [joyslots+2*js_size+js_flags-obj4_base],0
	jnz	.joysticks
	cmp	word [joyslots+3*js_size+js_flags-obj4_base],0
	jz	.keys
.joysticks:							; a slot is in use
	call	ReadJoysticks			; sample them
.keys:								; joysticks done
	mov	eax,curpad-obj4_base		; keys every controller shares
	call	ReadSharedKeys
	cmp	dword [dword_11D91F-obj4_base],0	; keyboard for everybody?
	jz	.shared
	mov	edx,1						; as the home team
	mov	eax,curpad-obj4_base
	call	ReadKeyboardPad
	push	0x1C					; Enter
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.shared
	or	byte [curpad-obj4_base],0x80	; button 80h
.shared:							; eax the shared pad
	mov	eax,[curpad-obj4_base]		; the shared keys
	xor	esi,esi						; esi the controller
	xor	ecx,ecx						; ecx its record
	mov	[ebp-4],eax
.loop:								; for each controller
	mov	eax,[ebp-4]					; each pad starts from the shared keys
	mov	[curpad-obj4_base],eax
	movsx	eax,byte [ecx+ctlrecs+ctl_type-obj4_base]	; a player at this machine?
	cmp	eax,1
	jnz	.next
	mov	ax,[ecx+ctlrecs+ctl_device-obj4_base]	; its device
	cmp	ax,strict word 8
	jc	.2
	jna	near .joy1
	cmp	ax,strict word 0x20
	jc	.1
	jna	near .joy3
	cmp	ax,strict word 0x40
	jz	near .keyboard
	jmp	.map
.1:									; device 9h-1Fh
	cmp	ax,strict word 0x10
	jz	.joy2
	jmp	.map
.2:									; device under 8
	cmp	ax,strict word 2
	jc	near .map
	jna	.mouse
	cmp	ax,strict word 4
	jz	.joy0
	jmp	.map
.mouse:								; device 2
	mov	edx,[dword_17C9A0-obj4_base]	; the game setup
	mov	eax,curpad-obj4_base
	movsx	edx,byte [edx+esi+5]	; its team flag
	call	ReadMousePad
	jmp	.map
.joy0:								; device 4: joystick slot 0
	mov	edx,[dword_17C9A0-obj4_base]
	xor	eax,eax						; slot 0
.joy:								; eax the slot
	movsx	ebx,byte [edx+esi+5]	; its team flag
	mov	edx,curpad-obj4_base
	call	ReadJoyPad
	jmp	.map
.joy1:								; device 8
	mov	edx,[dword_17C9A0-obj4_base]
	mov	eax,1						; slot 1
	jmp	.joy
.joy2:								; device 10h
	mov	edx,[dword_17C9A0-obj4_base]
	mov	eax,2						; slot 2
	jmp	.joy
.joy3:								; device 20h
	mov	edx,[dword_17C9A0-obj4_base]
	mov	eax,3						; slot 3
	jmp	.joy
.keyboard:							; device 40h
	mov	edx,[dword_17C9A0-obj4_base]
	mov	eax,curpad-obj4_base
	movsx	edx,byte [edx+esi+5]	; its team flag
	call	ReadKeyboardPad
.map:								; device read
	cmp	dword [dword_11D91F-obj4_base],0	; directions not mapped while the keyboard is for everybody
	jnz	.store
	mov	ebx,[curpad-obj4_base]		; as MapPadDirection
	sar	ebx,2
	mov	edx,curpad-obj4_base
	and	ebx,0xF
	and	byte [curpad-obj4_base],0xC3
	cmp	ebx,0xA
	jng	.3
	xor	ebx,ebx
.3:									; ebx the direction, 0-10
	call	sub_619E2
	movsx	eax,al
	imul	eax,eax,0xB
	movsx	ebx,byte [ebx+eax+dirmaptab_off]
	and	ebx,0xF
	shl	ebx,2
	or	[edx],ebx
.store:								; pad done
	mov	eax,[curpad-obj4_base]		; the controller's pad
	mov	[ecx+ctlrecs+ctl_pad-obj4_base],eax
.next:								; next controller
	inc	esi
	add	ecx,ctl_size
	cmp	esi,ctl_count
	jl	.loop
	leave
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Clears the pads in ctlrecs and the input queue. In a modem game another routine clears the queue.
FlushControllerInput:				; clears pads and queue
	push	ecx
	push	edx
	push	edi
	mov	ecx,0x10					; the 16 bytes SetupControllers clears too
	mov	edi,byte_114B8C-obj4_base
	xor	eax,eax
	rep	stosb
	xor	eax,eax						; eax the record offset
.loop:								; for each controller
	add	eax,ctl_size
	mov	dword [eax+ctlrecs+ctl_pad-ctl_size-obj4_base],0	; its pad
	cmp	eax,ctl_count*ctl_size		; past the last record?
	jnz	.loop
	mov	ax,[linkgame-obj4_base]	; modem game?
	xor	ah,ah
	and	al,1
	cwde
	test	eax,eax
	jz	.local
	call	sub_13338				; clears the queue its own way
	pop	edi
	pop	edx
	pop	ecx
	ret
.local:								; all four read here
	mov	ecx,0x5A					; the input queue: 90 bytes
	mov	edi,byte_1515D4-obj4_base
	mov	edx,[dword_114F08-obj4_base]	; kept: saved, and put back below
	mov	[dword_114F08-obj4_base],eax
	rep	stosb
	mov	dword [dword_114BA4-obj4_base],0
	mov	dword [dword_114B9C-obj4_base],0
	mov	dword [dword_114BA0-obj4_base],0
	mov	[dword_114F08-obj4_base],edx
	pop	edi
	pop	edx
	pop	ecx
	ret

; Returns 1 for a mouse button, 2 for a joystick button, 3 for a key, else 0.
AnyInputPressed:					; returns eax 0-3
	push	ebx
	push	ecx
	push	edx
	call	[mousepollfn-obj4_base]	; read the mouse
	test	al,3					; a button?
	jz	.joysticks
	mov	eax,1						; 1: mouse button
	pop	edx
	pop	ecx
	pop	ebx
	ret
.joysticks:							; no mouse button
	call	ReadJoysticks			; sample them
	xor	eax,eax						; eax the bit shift
.loop:								; for each joystick slot (8 bits each)
	mov	edx,[joyrawbits-obj4_base]
	mov	cl,al
	sar	edx,cl
	test	dl,0x30					; a button?
	jz	.next
	mov	eax,2						; 2: joystick button
	pop	edx
	pop	ecx
	pop	ebx
	ret
.next:								; no button on this slot
	add	eax,8
	cmp	eax,0x20
	jl	.loop
	call	GetKey					; a key?
	test	eax,eax
	jz	.exit
	mov	eax,3						; 3: key
.exit:								; eax 0 or 3
	pop	edx
	pop	ecx
	pop	ebx
	ret

; GrIP library: links the GRIP.GLL image. eax the image, edx its size. Checks the "DB" header and its
; checksum, copies the code into DOS memory, makes a code selector for it and calls its link entry.
; Returns 1 when linked, 0 when not (already linked, bad image or no memory).
GrLink:								; eax image, edx size; returns eax 1 or 0
	push	ebx
	push	ecx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x28
	mov	[ebp-0x28],eax				; the image
	mov	[ebp-0x10],edx				; its size
	cmp	dword [grlinked-obj4_base],0	; already linked?
	jz	.check
	mov	dword [ebp-0x14],0			; result 0
	jmp	.exit
.check:								; not linked yet
	cmp	dword [ebp-0x28],0			; no image?
	jz	.fail1
	xor	eax,eax						; at least 10h bytes?
	mov	ax,[ebp-0x10]
	cmp	eax,0x10
	jnl	.image
.fail1:								; no image or under 10h bytes
	mov	dword [ebp-0x14],0
	jmp	.exit
.image:								; image and size fine
	mov	eax,[ebp-0x28]
	mov	[ebp-0x18],eax
	mov	eax,[ebp-0x18]				; first two bytes "DB"
	mov	al,[eax]
	and	eax,strict dword 0xFF
	cmp	eax,'D'
	jnz	.fail2
	mov	eax,[ebp-0x18]
	mov	al,[eax+1]
	and	eax,strict dword 0xFF
	cmp	eax,'B'
	jz	.header
.fail2:								; not "DB"
	mov	dword [ebp-0x14],0
	jmp	.exit
.header:							; "DB" found
	mov	eax,[ebp-0x18]				; six hex digits, one per byte:
	mov	al,[eax+2]
	and	al,0xF
	xor	dh,dh
	mov	dl,al
	shl	edx,0xC
	mov	eax,[ebp-0x18]
	mov	al,[eax+3]
	and	al,0xF
	xor	ah,ah
	shl	eax,8
	or	edx,eax
	mov	eax,[ebp-0x18]
	mov	al,[eax+4]
	and	al,0xF
	xor	ah,ah
	shl	eax,4
	or	eax,edx
	mov	edx,[ebp-0x18]
	mov	dl,[edx+5]
	and	dl,0xF
	xor	dh,dh
	or	eax,edx
	mov	[ebp-0xC],eax				; code offset, in paragraphs
	mov	eax,[ebp-0x18]
	mov	al,[eax+6]
	and	al,0xF
	xor	ah,ah
	shl	eax,0xC
	mov	edx,eax
	mov	eax,[ebp-0x18]
	mov	al,[eax+7]
	and	al,0xF
	xor	ah,ah
	shl	eax,8
	or	edx,eax
	mov	eax,[ebp-0x18]
	mov	al,[eax+8]
	and	al,0xF
	xor	ah,ah
	shl	eax,4
	or	edx,eax
	mov	eax,[ebp-0x18]
	mov	al,[eax+9]
	and	al,0xF
	xor	ah,ah
	or	edx,eax
	mov	[ebp-8],edx					; code size, in paragraphs
	mov	eax,[ebp-0x18]
	mov	al,[eax+0xA]
	and	al,0xF
	shl	al,4
	mov	ah,al
	mov	edx,[ebp-0x18]
	mov	al,[edx+0xB]
	and	al,0xF
	or	ah,al
	mov	[ebp-4],ah					; checksum byte
	xor	edx,edx						; the image must hold offset + size
	mov	dx,[ebp-0xC]
	xor	eax,eax
	mov	ax,[ebp-8]
	add	eax,edx
	shl	eax,4
	xor	edx,edx
	mov	dx,[ebp-0x10]
	cmp	edx,eax
	jnl	.sum
	mov	dword [ebp-0x14],0
	jmp	.exit
.sum:								; size fine
	xor	eax,eax						; the code, at offset * 16
	mov	ax,[ebp-0xC]
	shl	eax,4
	mov	edx,[ebp-0x18]
	add	edx,eax
	mov	[ebp-0x24],edx
	mov	dword [ebp-0x1C],0			; XOR of the code and the checksum
.sumloop:							; until size * 16 bytes are done
	xor	eax,eax
	mov	ax,[ebp-8]
	shl	eax,4
	cmp	eax,[ebp-0x1C]
	jg	.sumbyte
	jmp	.sumdone
.sumnext:							; next byte
	mov	eax,[ebp-0x1C]
	inc	dword [ebp-0x1C]
	jmp	.sumloop
.sumbyte:							; XOR one byte
	mov	eax,[ebp-0x24]
	add	eax,[ebp-0x1C]
	mov	al,[eax]
	xor	[ebp-4],al
	jmp	.sumnext
.sumdone:							; checksum done
	cmp	byte [ebp-4],0				; must be 0
	jz	.dosmem
	mov	dword [ebp-0x14],0
	jmp	.exit
.dosmem:							; checksum fine
	mov	ecx,grdossel-obj4_base		; DPMI 100h: DOS memory for the code
	mov	ebx,[ebp-8]
	mov	eax,0x100
	int	0x31
	mov	ebx,0
	jc	.1
	mov	ebx,eax						; its linear address
	shl	ebx,4
	mov	[ecx],dx					; and its selector
.1:									; ebx linear address or 0
	mov	[ebp-0x20],ebx
	cmp	dword [ebp-0x20],0
	jnz	.copy
	mov	dword [ebp-0x14],0
	jmp	.exit
.copy:								; memory there
	mov	dword [ebp-0x1C],0			; copy the code there, a dword at a time
.copyloop:							; until size * 4 dwords are done
	xor	eax,eax
	mov	ax,[ebp-8]
	shl	eax,2
	cmp	eax,[ebp-0x1C]
	jg	.copydword
	jmp	.selector
.copynext:							; next dword
	mov	eax,[ebp-0x1C]
	inc	dword [ebp-0x1C]
	jmp	.copyloop
.copydword:							; copy one dword
	mov	edx,[ebp-0x1C]
	shl	edx,2
	add	edx,[ebp-0x24]
	mov	eax,[ebp-0x1C]
	shl	eax,2
	add	eax,[ebp-0x20]
	mov	edx,[edx]
	mov	[eax],edx
	jmp	.copynext
.selector:							; code copied
	mov	eax,0						; DPMI 0: a descriptor for the code
	mov	ecx,1
	int	0x31
	jnc	.2
	xor	eax,eax
.2:									; ax the selector or 0
	mov	[grcodesel-obj4_base],ax
	cmp	word [grcodesel-obj4_base],0
	jnz	.base
	mov	dx,[grdossel-obj4_base]		; DPMI 101h: free the DOS memory
	mov	eax,0x101
	int	0x31
	jc	.3
	xor	eax,eax
.3:									; freed
	mov	dword [ebp-0x14],0			; result 0
	jmp	.exit
.base:								; selector made
	mov	esi,[ebp-8]					; DPMI 7: its base is the DOS block
	shl	esi,4
	mov	edx,[ebp-0x20]
	mov	bx,[grcodesel-obj4_base]
	mov	ecx,edx
	shr	ecx,0x10
	mov	eax,7
	int	0x31
	jc	.4
	mov	edx,esi						; DPMI 8: its limit the code size
	dec	edx
	xor	ecx,ecx
	mov	eax,8
	int	0x31
	jc	.4
	xor	eax,eax
.4:									; al nonzero: failed
	test	al,al
	jz	.rights
	mov	bx,[grcodesel-obj4_base]	; DPMI 1: free the descriptor
	mov	eax,1
	int	0x31
	setc	al
	mov	dx,[grdossel-obj4_base]
	mov	eax,0x101
	int	0x31
	jc	.5
	xor	eax,eax
.5:									; freed
	mov	dword [ebp-0x14],0
	jmp	.exit
.rights:							; base and limit set
	mov	bx,[grcodesel-obj4_base]	; DPMI 9: the same access rights as our code
	mov	cx,cs
	lar	ecx,cx
	shr	cx,8
	mov	eax,9
	int	0x31
	setc	al						; failed?
	test	al,al
	jz	.entry
	mov	bx,[grcodesel-obj4_base]
	mov	eax,1
	int	0x31
	setc	al
	mov	dx,[grdossel-obj4_base]
	mov	eax,0x101
	int	0x31
	jc	.6
	xor	eax,eax
.6:									; freed
	mov	dword [ebp-0x14],0
	jmp	.exit
.entry:								; access rights set
	mov	dword [ebp-0x1C],0			; copy the code's 14-byte entry header
.hdrloop:							; until 14 bytes are done
	cmp	dword [ebp-0x1C],0xE
	jc	.hdrbyte
	jmp	.call
.hdrnext:							; next byte
	mov	eax,[ebp-0x1C]
	inc	dword [ebp-0x1C]
	jmp	.hdrloop
.hdrbyte:							; copy one byte
	mov	eax,[ebp-0x24]
	add	eax,[ebp-0x1C]
	mov	dl,[eax]
	mov	eax,[ebp-0x1C]
	mov	[eax+grlinkhdr-obj4_base],dl
	jmp	.hdrnext
.call:								; header copied
	mov	word [grlinkhdr+2-obj4_base],0	; the entry header points into the new code
	mov	ax,[grcodesel-obj4_base]
	mov	[grlinkhdr+6-obj4_base],ax
	mov	ax,[grcodesel-obj4_base]
	mov	[grentry+4-obj4_base],ax
	mov	eax,[ebp-0x20]				; fields of the library's data block
	mov	word [eax+0x12],0
	mov	eax,[ebp-0x20]
	mov	word [eax+0x16],0
	mov	eax,[ebp-0x20]
	mov	word [eax+0x10],0
	mov	dx,[grdossel-obj4_base]
	mov	eax,[ebp-0x20]
	mov	[eax+0x14],dx				; the DOS block's selector
	mov	ax,0x8490					; link function
	call	far [grentry-obj4_base]	; call the library
	test	ax,ax					; linked?
	jnz	.linked
	mov	bx,[grcodesel-obj4_base]
	mov	eax,1
	int	0x31
	setc	al
	mov	dx,[grdossel-obj4_base]
	mov	eax,0x101
	int	0x31
	jc	.7
	xor	eax,eax
.7:									; freed
	mov	dword [ebp-0x14],0
	jmp	.exit
.linked:							; the library said yes
	mov	dword [grlinked-obj4_base],1	; result 1
	mov	dword [ebp-0x14],1
.exit:								; eax the result
	mov	eax,[ebp-0x14]				; result
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret
