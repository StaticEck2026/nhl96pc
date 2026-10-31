; The joystick code under the pads: the GrIP library glue (GrUnlink, loading GRIP.GLL, finding the slots and
; reading the Gravis pads through the library's function codes) and the analog sticks on the game port, which
; calibrate themselves from the range they see. Both end in joyrawbits, a byte per slot for the pad readers.
;
; A joyrawbits byte: bit 0 up, 1 down, 2 right, 3 left, bits 4-5 the two buttons. The library is called far
; through grentry with the function in ax (bh slot, bl class: 1 buttons, 2 axes); what each function is comes
; from how its result is used here.

; GrIP library: unlinks the library GrLink linked: calls its unlink function, frees the code selector
; and the DOS memory. Returns 1 when done, 0 when it was not linked or a free failed.
GrUnlink:							; returns eax 1 or 0
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	cmp	dword [grlinked-obj4_base],0	; linked?
	jnz	.linked
	mov	dword [ebp-4],0				; result 0
	jmp	.exit
.linked:							; unlink
	mov	ax,0x8491					; unlink function
	call	far [grentry-obj4_base]	; call the library
	mov	bx,[grcodesel-obj4_base]	; DPMI 1: free the code selector
	mov	eax,1
	int	0x31
	setc	al
	test	al,al
	jz	.1
	mov	dword [ebp-4],0
	jmp	.exit
.1:									; selector freed
	mov	dx,[grdossel-obj4_base]		; DPMI 101h: free the DOS memory
	mov	eax,0x101
	int	0x31
	jc	.2
	xor	eax,eax
.2:									; al nonzero: failed
	test	al,al
	jz	.done
	mov	dword [ebp-4],0
	jmp	.exit
.done:								; both freed
	mov	dword [grlinked-obj4_base],0	; not linked now
	mov	dword [ebp-4],1				; result 1
.exit:								; eax the result
	mov	eax,[ebp-4]
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Sets the joystick button masks from eax: four byte pairs, one per slot (pad button 1, pad button 2).
SetJoyButtonMasks:					; eax four byte pairs
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	mov	[ebp-8],eax					; the pairs
	mov	dword [ebp-4],0
.loop:								; for each slot
	cmp	dword [ebp-4],js_count
	jl	.slot
	jmp	.exit
.next:								; next slot
	mov	eax,[ebp-4]
	inc	dword [ebp-4]
	jmp	.loop
.slot:								; copy one pair
	mov	eax,[ebp-4]
	add	eax,eax
	add	eax,[ebp-8]
	movsx	edx,byte [eax]
	mov	eax,[ebp-4]
	shl	eax,2
	mov	[eax+joybtnmask1-obj4_base],edx	; first byte: pad button 1
	mov	eax,[ebp-4]
	add	eax,eax
	add	eax,[ebp-8]
	movsx	edx,byte [eax+1]
	mov	eax,[ebp-4]
	shl	eax,2
	mov	[eax+joybtnmask2-obj4_base],edx	; second byte: pad button 2
	jmp	.next
.exit:								; all four done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Copies the joystick button masks back into eax's four byte pairs (the reverse of SetJoyButtonMasks).
GetJoyButtonMasks:					; eax four byte pairs
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	mov	[ebp-8],eax					; the pairs
	mov	dword [ebp-4],0
.loop:								; for each slot
	cmp	dword [ebp-4],js_count
	jl	.slot
	jmp	.exit
.next:								; next slot
	mov	eax,[ebp-4]
	inc	dword [ebp-4]
	jmp	.loop
.slot:								; copy one pair
	mov	edx,[ebp-4]
	shl	edx,2
	mov	eax,[ebp-4]
	add	eax,eax
	add	eax,[ebp-8]
	mov	dl,[edx+joybtnmask1-obj4_base]	; pad button 1
	mov	[eax],dl
	mov	edx,[ebp-4]
	shl	edx,2
	mov	eax,[ebp-4]
	add	eax,eax
	add	eax,[ebp-8]
	mov	dl,[edx+joybtnmask2-obj4_base]	; pad button 2
	mov	[eax+1],dl
	jmp	.next
.exit:								; all four done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Loads the GrIP library: looks for GRIP.GLL through the GRIP variable, then PATH, then in C:\GRIP\,
; reads it (up to 32K) and links it with GrLink. grslotcount becomes 0 when it is linked.
LoadGrip:							; sets grslotcount 0 when linked
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x90
	mov	byte [ebp-0x90],0			; buf (90h bytes) empty
	lea	ebx,[ebp-0x90]				; the GRIP variable
	mov	edx,str_GRIP-obj4_base
	mov	eax,str_GRIPGLL-obj4_base
	call	_searchenv_
	cmp	byte [ebp-0x90],0
	jnz	.1
	lea	ebx,[ebp-0x90]				; not found: PATH
	mov	edx,str_PATH-obj4_base
	mov	eax,str_GRIPGLL-obj4_base
	call	_searchenv_
.1:									; path so far
	cmp	byte [ebp-0x90],0
	jnz	.open
	mov	edx,str_CGRIP-obj4_base		; still not found: C:\GRIP\GRIP.GLL
	lea	eax,[ebp-0x90]
	call	strcpy_
	mov	edx,str_GRIPGLL-obj4_base
	lea	eax,[ebp-0x90]
	call	strcat_
.open:								; buf the full name
	mov	edx,str_rb-obj4_base		; open it
	lea	eax,[ebp-0x90]
	call	fopen_
	mov	[ebp-0x10],eax
	cmp	dword [ebp-0x10],0
	jz	.exit
	mov	ebx,2						; its size: seek to the end
	xor	edx,edx
	mov	eax,[ebp-0x10]
	call	fseek_
	mov	eax,[ebp-0x10]
	call	ftell_
	mov	[ebp-0xC],eax
	cmp	dword [ebp-0xC],0x8000		; over 32K?
	jng	.size
	mov	eax,[ebp-0x10]				; too big
	call	fclose_
	jmp	.exit
.size:								; up to 32K
	mov	eax,[ebp-0xC]				; memory for it
	call	_nmalloc_
	mov	[ebp-8],eax
	cmp	dword [ebp-8],0
	jnz	.read
	mov	eax,[ebp-0x10]				; none
	call	fclose_
	jmp	.exit
.read:								; memory there
	xor	ebx,ebx						; back to the start
	xor	edx,edx
	mov	eax,[ebp-0x10]
	call	fseek_
	mov	ecx,[ebp-0x10]				; read it all
	mov	ebx,[ebp-0xC]
	mov	edx,1
	mov	eax,[ebp-8]
	call	fread_
	mov	eax,[ebp-0x10]
	call	fclose_
	xor	edx,edx						; link it
	mov	dx,[ebp-0xC]
	mov	eax,[ebp-8]
	call	GrLink
	test	ax,ax
	jz	.free
	mov	dword [grslotcount-obj4_base],0	; linked: no slots yet
.free:								; linked or not
	mov	eax,[ebp-8]					; the image is copied: free it
	call	_nfree_
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Finds the GrIP pads: lets the library settle (120 refreshes), reads the slot map, and for each slot
; with a pad takes its names, its buttons (button masks 1 and 2 by default) and the range of its two
; axes. A slot with at least two buttons and two axes goes into grslotmask and joyslots.
ScanGripSlots:						; fills grslotmask, joyslots
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x20
	mov	dword [ebp-8],0
.settle:							; 120 times
	cmp	dword [ebp-8],0x78
	jl	.refresh
	jmp	.slots
.settlenext:						; next refresh
	mov	eax,[ebp-8]
	inc	dword [ebp-8]
	jmp	.settle
.refresh:							; one refresh
	xor	edx,edx						; refresh function
	mov	ax,0x84A0
	call	far [grentry-obj4_base]
	jmp	.settlenext
.slots:								; settled
	mov	dword [grslotmask-obj4_base],0	; no usable slots yet
	mov	ax,0x84B0					; slot map function
	call	far [grentry-obj4_base]
	mov	[grslotmap-obj4_base],eax
	mov	dword [ebp-8],1
.loop:								; for slots 1-4
	cmp	dword [ebp-8],js_count+1
	jl	.slot
	jmp	.exit
.next:								; next slot
	mov	eax,[ebp-8]
	inc	dword [ebp-8]
	jmp	.loop
.slot:								; [ebp-8] the slot
	mov	cl,[ebp-8]					; slot in the map?
	mov	eax,[grslotmap-obj4_base]
	shr	eax,cl
	test	al,1
	jz	.skip
	mov	eax,[ebp-8]					; 20 bytes per slot
	dec	eax
	imul	eax,eax,0x14
	mov	edi,unk_1516B8-obj4_base
	add	edi,eax
	mov	bh,[ebp-8]
	mov	ax,0x84D0					; function 84D0h: 16 bytes
	call	far [grentry-obj4_base]
	mov	[edi],ebx
	mov	[edi+4],ecx
	mov	[edi+8],edx
	mov	[edi+0xC],esi
	mov	eax,[ebp-8]
	dec	eax
	imul	eax,eax,0x14
	mov	edi,unk_151648-obj4_base	; 20 bytes per slot
	add	edi,eax
	mov	bh,[ebp-8]
	mov	ax,0x84D1					; function 84D1h: 16 bytes and a word
	call	far [grentry-obj4_base]
	mov	[edi],ebx
	mov	[edi+4],ecx
	mov	[edi+8],edx
	mov	[edi+0xC],esi
	mov	edi,[ebp-8]
	add	edi,edi
	mov	[edi+word_151768-2-obj4_base],ax
	mov	dword [ebp-0xC],1			; usable so far
	mov	bh,[ebp-8]
	mov	ax,0x84B1					; class map function
	call	far [grentry-obj4_base]
	test	al,2					; bit 1: buttons
	jz	.nobuttons
	mov	bl,1						; buttons
	mov	bh,[ebp-8]
	mov	ax,0x84B3					; highest index function
	call	far [grentry-obj4_base]
	mov	bl,al
	mov	eax,[ebp-8]
	inc	bl							; the number of buttons
	mov	[eax+grbuttons-1-obj4_base],bl
	mov	eax,[ebp-8]
	mov	al,[eax+grbuttons-1-obj4_base]
	and	eax,strict dword 0xFF
	cmp	eax,2						; at least two?
	jnl	.masks
	mov	dword [ebp-0xC],0			; not usable
	jmp	.1
.masks:								; two buttons or more
	mov	eax,[ebp-8]					; default masks: button 1 and button 2
	shl	eax,2
	mov	dword [eax+joybtnmask1-4-obj4_base],1
	mov	eax,[ebp-8]
	shl	eax,2
	mov	dword [eax+joybtnmask2-4-obj4_base],2
.1:									; buttons done
	jmp	.axes
.nobuttons:							; no button class
	mov	eax,[ebp-8]					; no buttons
	mov	byte [eax+grbuttons-1-obj4_base],0
	mov	dword [ebp-0xC],0
.axes:								; [ebp-0Ch] still 1: test the axes
	cmp	dword [ebp-0xC],0
	jz	.2
	mov	bh,[ebp-8]
	mov	ax,0x84B1					; class map again
	call	far [grentry-obj4_base]
	test	al,4					; bit 2: axes
	jnz	.axisclass
.2:									; no axis class
	jmp	.noaxes
.axisclass:							; it has axes
	mov	bl,2						; axes
	mov	bh,[ebp-8]
	mov	ax,0x84B3
	call	far [grentry-obj4_base]
	mov	[ebp-4],al
	xor	eax,eax
	mov	al,[ebp-4]
	cmp	eax,1						; highest axis index at least 1 (two axes)?
	jnl	.3
	mov	dword [ebp-0xC],0
.3:									; fewer than two: cleared
	cmp	dword [ebp-0xC],0
	jz	.4
	xor	ch,ch						; axis 0 (x)
	mov	bl,2
	mov	bh,[ebp-8]
	mov	ax,0x84B4					; largest value function
	call	far [grentry-obj4_base]
	mov	edx,[ebp-8]
	shl	edx,2
	mov	[edx+graxismax-4-obj4_base],ax
	mov	ch,1						; axis 1 (y)
	mov	bl,2
	mov	bh,[ebp-8]
	mov	ax,0x84B4
	call	far [grentry-obj4_base]
	mov	edx,[ebp-8]
	shl	edx,2
	mov	[edx+graxismax-2-obj4_base],ax
.4:									; axes done
	jmp	.usable
.noaxes:							; no axes: not usable
	mov	dword [ebp-0xC],0
.usable:							; [ebp-0Ch] 1: usable
	cmp	dword [ebp-0xC],0
	jz	.skip
	mov	ecx,[ebp-8]					; usable: bit in grslotmask
	dec	ecx
	mov	eax,1
	shl	eax,cl
	mov	ecx,eax
	or	[grslotmask-obj4_base],ecx
	mov	ecx,[ebp-8]					; and the slot has a pad
	dec	ecx
	imul	ecx,ecx,js_size
	mov	word [ecx+joyslots+js_flags-obj4_base],1
.skip:								; not in the map, or not usable
	jmp	.next
.exit:								; all slots done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads the GrIP pads into the grpads dword not written last, then makes it the current one. For each
; slot in grslotmask: buttons through the button masks, each axis scaled to 0-2 (0 and 2 the ends).
ReadGripPads:						; fills grpads
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	cmp	dword [grslotmask-obj4_base],0	; any GrIP pads?
	jz	.exit
	mov	ax,[grpadbuf-obj4_base]		; clear the dword not written last
	xor	al,1
	cwde
	shl	eax,2
	mov	dword [eax+grpads-obj4_base],0
	mov	dword [grslot-obj4_base],0	; slot 0
.loop:								; for slots 0-3
	cmp	dword [grslot-obj4_base],js_count
	jl	.slot
	jmp	.flip
.next:								; next slot
	inc	dword [grslot-obj4_base]
	jmp	.loop
.slot:								; read one slot
	mov	edx,1						; refresh function (edx 1)
	mov	ax,0x84A0
	call	far [grentry-obj4_base]
	mov	dword [grpadbits-obj4_base],0	; the slot's byte
	mov	cl,[grslot-obj4_base]		; slot usable?
	mov	edx,1
	shl	edx,cl
	test	[grslotmask-obj4_base],edx
	jz	.store
	mov	eax,[grslot-obj4_base]		; all the buttons
	mov	cl,[eax+grbuttons-obj4_base]
	dec	cl
	xor	ch,ch						; from index 0
	mov	bl,1
	mov	bh,[grslot-obj4_base]
	inc	bh
	mov	ax,0x84C1					; packed values function
	call	far [grentry-obj4_base]
	mov	[grbtnbits-obj4_base],eax
	mov	eax,[grslot-obj4_base]		; a button of pad button 1?
	shl	eax,2
	mov	edx,[grbtnbits-obj4_base]
	test	[eax+joybtnmask1-obj4_base],edx
	jz	.1
	or	byte [grpadbits-obj4_base],0x10	; bit 4
.1:									; button 1 done
	mov	eax,[grslot-obj4_base]		; a button of pad button 2?
	shl	eax,2
	mov	edx,[grbtnbits-obj4_base]
	test	[eax+joybtnmask2-obj4_base],edx
	jz	.2
	or	byte [grpadbits-obj4_base],0x20	; bit 5
.2:									; button 2 done
	xor	ch,ch						; axis 0 (x)
	mov	bl,2
	mov	bh,[grslot-obj4_base]
	inc	bh
	mov	ax,0x84C0					; value function
	call	far [grentry-obj4_base]
	mov	[graxis-obj4_base],ax
	mov	edx,[grslot-obj4_base]		; scaled: value * 3 / largest, 0-2
	shl	edx,2
	xor	ebx,ebx
	mov	bx,[edx+graxismax-obj4_base]
	xor	edx,edx
	mov	dx,[graxis-obj4_base]
	lea	edx,[edx+edx*2]
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[graxis-obj4_base],ax
	xor	eax,eax
	mov	ax,[graxis-obj4_base]
	cmp	eax,1						; 2: right
	jng	.3
	or	byte [grpadbits-obj4_base],4	; bit 2
	jmp	.y
.3:									; x not at the top end
	cmp	word [graxis-obj4_base],0	; 0: left
	jnz	.y
	or	byte [grpadbits-obj4_base],8	; bit 3
.y:									; x done
	mov	ch,1						; axis 1 (y)
	mov	bl,2
	mov	bh,[grslot-obj4_base]
	inc	bh
	mov	ax,0x84C0
	call	far [grentry-obj4_base]
	mov	[graxis-obj4_base],ax
	mov	edx,[grslot-obj4_base]
	shl	edx,2
	xor	ebx,ebx
	mov	bx,[edx+graxismax+2-obj4_base]
	xor	edx,edx
	mov	dx,[graxis-obj4_base]
	lea	edx,[edx+edx*2]
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[graxis-obj4_base],ax
	xor	eax,eax
	mov	ax,[graxis-obj4_base]
	cmp	eax,1						; 2: up
	jng	.4
	or	byte [grpadbits-obj4_base],1	; bit 0
	jmp	.store
.4:									; y not at the top end
	cmp	word [graxis-obj4_base],0	; 0: down
	jnz	.store
	or	byte [grpadbits-obj4_base],2	; bit 1
.store:								; the slot's byte into the grpads dword
	mov	ax,[grpadbuf-obj4_base]		; the dword not written last
	xor	al,1
	cwde
	shl	eax,2
	mov	ecx,[grslot-obj4_base]		; slot * 8
	shl	ecx,3
	mov	edx,[grpadbits-obj4_base]
	shl	edx,cl
	mov	ecx,edx
	or	[eax+grpads-obj4_base],ecx
	jmp	.next
.flip:								; all slots done
	xor	byte [grpadbuf-obj4_base],1	; it is the current one now
.exit:								; no GrIP pads
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads the GrIP pads and puts the current grpads dword in joyrawbits (0 when there are no pads).
ReadGripJoysticks:					; sets joyrawbits
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	call	ReadGripPads			; read them
	cmp	dword [grslotmask-obj4_base],0	; any GrIP pads?
	jz	.none
	mov	eax,[grpadbuf-2-obj4_base]	; grpadbuf (the high word)
	sar	eax,0x10
	shl	eax,2
	mov	eax,[eax+grpads-obj4_base]
	mov	[joyrawbits-obj4_base],eax	; the current dword
	jmp	.exit
.none:								; no GrIP pads
	mov	dword [joyrawbits-obj4_base],0	; no joystick bits
.exit:								; done
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Reads the game port sticks into joyslots 0 and 1. The first sample (joy1calib, joy2calib) also sets
; which sticks answer, the rest position and the range; later samples widen the range.
ReadJoyAxes:						; fills joyslots 0 and 1
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	call	ReadJoyPort				; sample the port: eax buttons
	mov	[ebp-4],eax
	cmp	dword [joy1calib-obj4_base],0	; a stick to calibrate?
	jnz	.calib
	cmp	dword [joy2calib-obj4_base],0
	jz	.rest1
.calib:								; a stick to calibrate
	mov	eax,[joyaxes-obj4_base]		; all four axes answer?
	and	eax,0xF
	cmp	eax,0xF
	jnz	.1
	mov	dword [ebp-8],2				; both sticks
	jmp	.2
.1:									; not all four axes
	mov	dword [ebp-8],1				; one stick
.2:									; [ebp-8] 2: both sticks, else 1
	push	dword [ebp-8]
	call	EnableJoysticks			; switch reading on
	add	esp,4
	test	byte [joyaxes-obj4_base],3	; stick 1 axes?
	jz	.4
	cmp	dword [joy1x-obj4_base],0	; and a nonzero x or y
	jnz	.3
	cmp	dword [joy1y-obj4_base],0
	jz	.4
.3:									; an axis read
	jmp	.stick1
.4:									; no x/y on stick 1
	jmp	.nostick1
.stick1:							; stick 1 answers
	mov	word [joyslots+js_flags-obj4_base],1
	jmp	.5
.nostick1:							; stick 1 does not answer
	mov	word [joyslots+js_flags-obj4_base],0
.5:									; stick 1 known
	test	byte [joyaxes-obj4_base],0xC	; stick 2 axes?
	jz	.7
	cmp	dword [joy2x-obj4_base],0	; and a nonzero x or y
	jnz	.6
	cmp	dword [joy2y-obj4_base],0
	jz	.7
.6:									; an axis read
	jmp	.stick2
.7:									; no x/y on stick 2
	jmp	.nostick2
.stick2:							; stick 2 answers
	mov	word [joyslots+js_size+js_flags-obj4_base],1
	jmp	.8
.nostick2:							; stick 2 does not answer
	mov	word [joyslots+js_size+js_flags-obj4_base],0
.8:									; stick 2 known
	mov	word [joyslots+2*js_size+js_flags-obj4_base],0	; no slots 2 and 3 on the game port
	mov	word [joyslots+3*js_size+js_flags-obj4_base],0
.rest1:								; calibration of stick 1
	cmp	dword [joy1calib-obj4_base],0	; calibrate stick 1?
	jz	.rest2
	mov	ax,[joy1x-obj4_base]		; range and rest position from this sample
	mov	[joyslots+js_minx-obj4_base],ax
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_miny-obj4_base],ax
	mov	ax,[joy1x-obj4_base]
	mov	[joyslots+js_maxx-obj4_base],ax
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_maxy-obj4_base],ax
	mov	ax,[joy1x-obj4_base]
	mov	[joyslots+js_cx-obj4_base],ax
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_cy-obj4_base],ax
	mov	dword [joy1calib-obj4_base],0	; done
.rest2:								; calibration of stick 2
	cmp	dword [joy2calib-obj4_base],0	; calibrate stick 2?
	jz	.range1
	mov	ax,[joy2x-obj4_base]		; the same
	mov	[joyslots+js_size+js_minx-obj4_base],ax
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_miny-obj4_base],ax
	mov	ax,[joy2x-obj4_base]
	mov	[joyslots+js_size+js_maxx-obj4_base],ax
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_maxy-obj4_base],ax
	mov	ax,[joy2x-obj4_base]
	mov	[joyslots+js_size+js_cx-obj4_base],ax
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_cy-obj4_base],ax
	mov	dword [joy2calib-obj4_base],0	; done
.range1:							; widen stick 1's range
	mov	eax,[joyslots+js_minx-2-obj4_base]	; smallest x
	sar	eax,0x10
	cmp	eax,[joy1x-obj4_base]
	jng	.9
	mov	ax,[joy1x-obj4_base]
	mov	[joyslots+js_minx-obj4_base],ax
.9:									; smallest x done
	mov	eax,[joyslots+js_maxx-2-obj4_base]	; largest x
	sar	eax,0x10
	cmp	eax,[joy1x-obj4_base]
	jnl	.10
	mov	ax,[joy1x-obj4_base]
	mov	[joyslots+js_maxx-obj4_base],ax
.10:								; largest x done
	mov	eax,[joyslots+js_miny-2-obj4_base]	; smallest y
	sar	eax,0x10
	cmp	eax,[joy1y-obj4_base]
	jng	.11
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_miny-obj4_base],ax
.11:								; smallest y done
	mov	eax,[joyslots+js_maxy-2-obj4_base]	; largest y
	sar	eax,0x10
	cmp	eax,[joy1y-obj4_base]
	jnl	.now1
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_maxy-obj4_base],ax
.now1:								; x, y, buttons now
	mov	ax,[joy1x-obj4_base]		; x and y now
	mov	[joyslots+js_x-obj4_base],ax
	mov	ax,[joy1y-obj4_base]
	mov	[joyslots+js_y-obj4_base],ax
	mov	eax,[ebp-4]					; buttons 1-2: the port bits are 0 while down
	or	eax,strict dword 0xFFFFFFFC
	mov	[joyslots+js_buttons-obj4_base],ax
	not	word [joyslots+js_buttons-obj4_base]
	mov	eax,[joyslots+js_size+js_minx-2-obj4_base]	; stick 2: smallest x
	sar	eax,0x10
	cmp	eax,[joy2x-obj4_base]
	jng	.12
	mov	ax,[joy2x-obj4_base]
	mov	[joyslots+js_size+js_minx-obj4_base],ax
.12:								; smallest x done
	mov	eax,[joyslots+js_size+js_maxx-2-obj4_base]	; largest x
	sar	eax,0x10
	cmp	eax,[joy2x-obj4_base]
	jnl	.13
	mov	ax,[joy2x-obj4_base]
	mov	[joyslots+js_size+js_maxx-obj4_base],ax
.13:								; largest x done
	mov	eax,[joyslots+js_size+js_miny-2-obj4_base]	; smallest y
	sar	eax,0x10
	cmp	eax,[joy2y-obj4_base]
	jng	.14
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_miny-obj4_base],ax
.14:								; smallest y done
	mov	eax,[joyslots+js_size+js_maxy-2-obj4_base]	; largest y
	sar	eax,0x10
	cmp	eax,[joy2y-obj4_base]
	jnl	.now2
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_maxy-obj4_base],ax
.now2:								; x, y, buttons now
	mov	ax,[joy2x-obj4_base]		; x and y now
	mov	[joyslots+js_size+js_x-obj4_base],ax
	mov	ax,[joy2y-obj4_base]
	mov	[joyslots+js_size+js_y-obj4_base],ax
	mov	eax,[ebp-4]					; buttons 3-4 of the port
	sar	eax,2
	or	eax,-4
	not	eax
	mov	[joyslots+js_size+js_buttons-obj4_base],ax
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Samples the joysticks into joyrawbits and returns it: through GrIP when it has pads, else the game
; port sticks, a direction when a stick is 7Ch past its rest position (or, with the range, its middle).
ReadJoysticks:						; returns eax joyrawbits
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	cmp	dword [grslotcount-obj4_base],0	; GrIP pads?
	jng	.analog
	call	ReadGripJoysticks		; read them
	jmp	.exit
.analog:							; no GrIP pads: game port sticks
	call	ReadJoyAxes
	mov	dword [joyrawbits-obj4_base],0	; build the bits
	cmp	word [joyslots+js_flags-obj4_base],0	; stick 0 there?
	jz	.slot1
	mov	dword [ebp-8],0				; [ebp-8]: test by the range
	mov	ax,[joyslots+js_flags-obj4_base]	; flags or 6 = 6: only without bit 0
	or	al,6
	cwde
	cmp	eax,6
	jnz	.1
	mov	dword [ebp-8],1
	jmp	.xrange0
.1:									; flags or 6 is not 6
	mov	ax,[joyslots+js_flags-obj4_base]	; flags or 6 is never 2 or 4 (bits 1-2 set)
	or	al,6
	cwde
	cmp	eax,2
	jnz	.4
	mov	eax,[joyslots+js_cx-2-obj4_base]	; right of rest + 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.2
	or	byte [joyslots+js_flags-obj4_base],4	; flag: right
	mov	dword [ebp-8],1
	jmp	.3
.2:									; not right of the dead zone
	mov	eax,[joyslots+js_cx-2-obj4_base]	; left of rest - 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.3
	or	byte [joyrawbits-obj4_base],8	; left
.3:									; x done
	jmp	.xrange0
.4:									; flags or 6 is not 2
	mov	ax,[joyslots+js_flags-obj4_base]
	or	al,6
	cwde
	cmp	eax,4
	jnz	.x0
	mov	eax,[joyslots+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.5
	or	byte [joyslots+js_flags-obj4_base],2
	mov	dword [ebp-8],1
	jmp	.6
.5:									; not left of the dead zone
	mov	eax,[joyslots+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.6
	or	byte [joyrawbits-obj4_base],4
.6:									; x done
	jmp	.xrange0
.x0:								; flags or 6 is not 4: both sides of the dead zone
	mov	eax,[joyslots+js_cx-2-obj4_base]	; left of rest - 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.7
	or	byte [joyslots+js_flags-obj4_base],2	; flag: left
	or	byte [joyrawbits-obj4_base],8	; left
	jmp	.xrange0
.7:									; not left
	mov	eax,[joyslots+js_cx-2-obj4_base]	; right of rest + 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.xrange0
	or	byte [joyslots+js_flags-obj4_base],4	; flag: right
	or	byte [joyrawbits-obj4_base],4	; right
.xrange0:							; by the range: when [ebp-8] is set
	cmp	dword [ebp-8],0
	jz	.y0
	mov	edx,[joyslots+js_maxx-2-obj4_base]	; a range over F8h?
	sar	edx,0x10
	mov	eax,[joyslots+js_minx-2-obj4_base]
	sar	eax,0x10
	sub	edx,eax
	cmp	edx,0xF8
	jng	.y0
	mov	edx,[joyslots+js_maxx-2-obj4_base]	; its middle
	sar	edx,0x10
	mov	eax,[joyslots+js_minx-2-obj4_base]
	sar	eax,0x10
	add	eax,edx
	sar	eax,1
	mov	[ebp-8],eax
	mov	edx,[joyslots+js_x-2-obj4_base]	; under half the middle?
	sar	edx,0x10
	mov	eax,[ebp-8]
	sar	eax,1
	cmp	edx,eax
	jnl	.8
	or	byte [joyrawbits-obj4_base],8	; left
	jmp	.y0
.8:									; not left of the middle
	mov	eax,[ebp-8]					; over one and a half?
	sar	eax,1
	add	eax,[ebp-8]
	mov	edx,[joyslots+js_x-2-obj4_base]
	sar	edx,0x10
	cmp	edx,eax
	jng	.y0
	or	byte [joyrawbits-obj4_base],4	; right
.y0:								; stick 0 y: the same with flag bits 3-4
	mov	dword [ebp-8],0
	mov	ax,[joyslots+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,0x18
	jnz	.9
	mov	dword [ebp-8],1
	jmp	.yrange0
.9:									; flags or 18h is not 18h
	mov	ax,[joyslots+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,8
	jnz	.12
	mov	eax,[joyslots+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.10
	or	byte [joyslots+js_flags-obj4_base],0x10
	mov	dword [ebp-8],1
	jmp	.11
.10:								; not below the dead zone
	mov	eax,[joyslots+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.11
	or	byte [joyrawbits-obj4_base],1
.11:								; y done
	jmp	.yrange0
.12:								; flags or 18h is not 8
	mov	ax,[joyslots+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,0x10
	jnz	.y0both
	mov	eax,[joyslots+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.13
	or	byte [joyslots+js_flags-obj4_base],8
	mov	dword [ebp-8],1
	jmp	.14
.13:								; not above the dead zone
	mov	eax,[joyslots+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.14
	or	byte [joyrawbits-obj4_base],2
.14:								; y done
	jmp	.yrange0
.y0both:							; flags or 18h is not 10h: both sides
	mov	eax,[joyslots+js_cy-2-obj4_base]	; above rest - 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.15
	or	byte [joyslots+js_flags-obj4_base],8	; flag: up
	or	byte [joyrawbits-obj4_base],1	; up
	jmp	.yrange0
.15:								; not above
	mov	eax,[joyslots+js_cy-2-obj4_base]	; below rest + 7Ch?
	sar	eax,0x10
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.yrange0
	or	byte [joyslots+js_flags-obj4_base],0x10	; flag: down
	or	byte [joyrawbits-obj4_base],2	; down
.yrange0:							; by the range
	cmp	dword [ebp-8],0
	jz	.buttons0
	mov	edx,[joyslots+js_maxy-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_miny-2-obj4_base]
	sar	eax,0x10
	sub	edx,eax
	cmp	edx,0xF8
	jng	.buttons0
	mov	edx,[joyslots+js_maxy-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_miny-2-obj4_base]
	sar	eax,0x10
	add	eax,edx
	sar	eax,1
	mov	[ebp-8],eax
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	mov	eax,[ebp-8]
	sar	eax,1
	cmp	edx,eax
	jnl	.16
	or	byte [joyrawbits-obj4_base],1	; up
	jmp	.buttons0
.16:								; not above the middle
	mov	eax,[ebp-8]
	sar	eax,1
	add	eax,[ebp-8]
	mov	edx,[joyslots+js_y-2-obj4_base]
	sar	edx,0x10
	cmp	edx,eax
	jng	.buttons0
	or	byte [joyrawbits-obj4_base],2	; down
.buttons0:							; stick 0 buttons: bits 4-5
	mov	eax,[joyslots+js_buttons-2-obj4_base]	; buttons
	sar	eax,0x10
	shl	eax,4
	or	[joyrawbits-obj4_base],eax
.slot1:								; stick 1: the same, into the second byte
	cmp	word [joyslots+js_size+js_flags-obj4_base],0	; stick 1 there?
	jz	.exit
	mov	dword [ebp-8],0
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,6
	cwde
	cmp	eax,6
	jnz	.17
	mov	dword [ebp-8],1
	jmp	.xrange1
.17:								; flags or 6 is not 6
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,6
	cwde
	cmp	eax,2
	jnz	.20
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.18
	or	byte [joyslots+js_size+js_flags-obj4_base],4
	mov	dword [ebp-8],1
	jmp	.19
.18:								; not right of the dead zone
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.19
	or	byte [joyrawbits+1-obj4_base],8
.19:								; x done
	jmp	.xrange1
.20:								; flags or 6 is not 2
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,6
	cwde
	cmp	eax,4
	jnz	.x1
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.21
	or	byte [joyslots+js_size+js_flags-obj4_base],2
	mov	dword [ebp-8],1
	jmp	.22
.21:								; not left of the dead zone
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.22
	or	byte [joyrawbits+1-obj4_base],4
.22:								; x done
	jmp	.xrange1
.x1:								; both sides of the dead zone
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.23
	or	byte [joyslots+js_size+js_flags-obj4_base],2
	or	byte [joyrawbits+1-obj4_base],8
	jmp	.xrange1
.23:								; not left
	mov	eax,[joyslots+js_size+js_cx-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.xrange1
	or	byte [joyslots+js_size+js_flags-obj4_base],4
	or	byte [joyrawbits+1-obj4_base],4
.xrange1:							; by the range
	cmp	dword [ebp-8],0
	jz	.y1
	mov	edx,[joyslots+js_size+js_maxx-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_size+js_minx-2-obj4_base]
	sar	eax,0x10
	sub	edx,eax
	cmp	edx,0xF8
	jng	.y1
	mov	edx,[joyslots+js_size+js_maxx-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_size+js_minx-2-obj4_base]
	sar	eax,0x10
	add	eax,edx
	sar	eax,1
	mov	[ebp-8],eax
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	mov	eax,[ebp-8]
	sar	eax,1
	cmp	edx,eax
	jnl	.24
	or	byte [joyrawbits+1-obj4_base],8
	jmp	.y1
.24:								; not left of the middle
	mov	eax,[ebp-8]
	sar	eax,1
	add	eax,[ebp-8]
	mov	edx,[joyslots+js_size+js_x-2-obj4_base]
	sar	edx,0x10
	cmp	edx,eax
	jng	.y1
	or	byte [joyrawbits+1-obj4_base],4
.y1:								; stick 1 y
	mov	dword [ebp-8],0
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,0x18
	jnz	.25
	mov	dword [ebp-8],1
	jmp	.yrange1
.25:								; flags or 18h is not 18h
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,8
	jnz	.28
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.26
	or	byte [joyslots+js_size+js_flags-obj4_base],0x10
	mov	dword [ebp-8],1
	jmp	.27
.26:								; not below
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.27
	or	byte [joyrawbits+1-obj4_base],1
.27:								; y done
	jmp	.yrange1
.28:								; flags or 18h is not 8
	mov	ax,[joyslots+js_size+js_flags-obj4_base]
	or	al,0x18
	cwde
	cmp	eax,0x10
	jnz	.y1both
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.29
	or	byte [joyslots+js_size+js_flags-obj4_base],8
	mov	dword [ebp-8],1
	jmp	.30
.29:								; not above
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.30
	or	byte [joyrawbits+1-obj4_base],2
.30:								; y done
	jmp	.yrange1
.y1both:							; both sides
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	sub	eax,0x7C
	cmp	edx,eax
	jnl	.31
	or	byte [joyslots+js_size+js_flags-obj4_base],8
	or	byte [joyrawbits+1-obj4_base],1
	jmp	.yrange1
.31:								; not above
	mov	eax,[joyslots+js_size+js_cy-2-obj4_base]
	sar	eax,0x10
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	add	eax,0x7C
	cmp	edx,eax
	jng	.yrange1
	or	byte [joyslots+js_size+js_flags-obj4_base],0x10
	or	byte [joyrawbits+1-obj4_base],2
.yrange1:							; by the range
	cmp	dword [ebp-8],0
	jz	.buttons1
	mov	edx,[joyslots+js_size+js_maxy-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_size+js_miny-2-obj4_base]
	sar	eax,0x10
	sub	edx,eax
	cmp	edx,0xF8
	jng	.buttons1
	mov	edx,[joyslots+js_size+js_maxy-2-obj4_base]
	sar	edx,0x10
	mov	eax,[joyslots+js_size+js_miny-2-obj4_base]
	sar	eax,0x10
	add	eax,edx
	sar	eax,1
	mov	[ebp-8],eax
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	mov	eax,[ebp-8]
	sar	eax,1
	cmp	edx,eax
	jnl	.32
	or	byte [joyrawbits+1-obj4_base],1
	jmp	.buttons1
.32:								; not above the middle
	mov	eax,[ebp-8]
	sar	eax,1
	add	eax,[ebp-8]
	mov	edx,[joyslots+js_size+js_y-2-obj4_base]
	sar	edx,0x10
	cmp	edx,eax
	jng	.buttons1
	or	byte [joyrawbits+1-obj4_base],2
.buttons1:							; stick 1 buttons: bits 12-13
	mov	eax,[joyslots+js_size+js_buttons-2-obj4_base]	; buttons
	sar	eax,0x10
	shl	eax,0xC
	or	[joyrawbits-obj4_base],eax
.exit:								; returns joyrawbits
	mov	eax,[joyrawbits-obj4_base]	; result
	mov	[ebp-4],eax
	mov	eax,[ebp-4]
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret
