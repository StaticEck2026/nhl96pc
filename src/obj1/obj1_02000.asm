; The end of the joystick setup (ShutdownGrip, DetectJoysticks), then the modem game link: opening the port,
; connecting and agreeing on sides, sending and receiving 6-byte packets, blocks of data and sync numbers, and
; swapping the pads of both machines every frame. The wait sprite shows while the other machine is late.
;
; A packet: byte 0 the type (1 pads, 2 controller pads, 3 block start, 4 block data, 5 sync, 6 chat), bytes
; 1-4 a dword, byte 5 the sender's side. LinkRecvPacket sorts what arrives into rings, blocks and syncs.

; Shuts the GrIP library down at exit: library function 84A2h while it has slots, then GrUnlink.
ShutdownGrip:						; registered by DetectJoysticks
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	cmp	dword [grslotcount-obj4_base],0	; GrIP slots?
	jng	.1
	mov	ax,0x84A2					; library function 84A2h
	call	far [grentry-obj4_base]
	mov	dword [grslotcount-obj4_base],0
.1:									; no slots
	cmp	dword [grslotcount-obj4_base],0	; library loaded and slots 0?
	jnz	.exit
	call	GrUnlink				; unlink it
.exit:								; done
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Finds the joysticks the first time (joy1calib and joy2calib both set): registers ShutdownGrip at
; exit, asks GrIP for its slots and scans them, else takes a first game port sample. Returns a bit for
; each joyslots entry that has a pad.
DetectJoysticks:					; returns eax: a bit per slot
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	mov	dword [ebp-8],0
	cmp	dword [joy1calib-obj4_base],0	; first time?
	jz	.1
	cmp	dword [joy2calib-obj4_base],0
	jnz	.find
.1:									; already found
	jmp	.mask
.find:								; first time
	mov	word [joyslots+js_flags-obj4_base],0	; no slots yet
	mov	word [joyslots+js_size+js_flags-obj4_base],0
	mov	word [joyslots+2*js_size+js_flags-obj4_base],0
	mov	word [joyslots+3*js_size+js_flags-obj4_base],0
	mov	eax,ShutdownGrip-obj1_base	; shut GrIP down at exit
	push	eax
	call	AtExit
	add	esp,4
	mov	dword [grslotmask-obj4_base],0
	cmp	dword [grslotcount-obj4_base],0	; GrIP slots before?
	jng	.3
	mov	ax,0x84A2					; library function 84A2h
	call	far [grentry-obj4_base]
	mov	dword [grslotcount-obj4_base],0
.3:									; no slots now
	cmp	dword [grslotcount-obj4_base],0	; library loaded?
	jl	.4
	mov	ax,0x84A1					; library function 84A1h: the number of slots
	call	far [grentry-obj4_base]
	and	eax,strict dword 0xFFFF
	mov	[grslotcount-obj4_base],eax
.4:									; library not loaded
	cmp	dword [grslotcount-obj4_base],0
	jng	.port
	call	ScanGripSlots			; scan the slots
	mov	dword [joy2calib-obj4_base],0	; found: no first game port sample
	mov	eax,[joy2calib-obj4_base]
	mov	[joy1calib-obj4_base],eax
	jmp	.mask
.port:								; no GrIP slots: the game port
	call	ReadJoysticks			; first sample, calibrates
.mask:								; the slots with a pad
	mov	dword [ebp-8],0
	cmp	word [joyslots+js_flags-obj4_base],0
	jz	.7
	or	dword [ebp-8],1
.7:									; slot 0 done
	cmp	word [joyslots+js_size+js_flags-obj4_base],0
	jz	.8
	or	dword [ebp-8],2
.8:									; slot 1 done
	cmp	word [joyslots+2*js_size+js_flags-obj4_base],0
	jz	.9
	or	dword [ebp-8],4
.9:									; slot 2 done
	cmp	word [joyslots+3*js_size+js_flags-obj4_base],0
	jz	.10
	or	dword [ebp-8],8
.10:								; slot 3 done
	mov	eax,[ebp-8]
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

; Opens the modem port for a game. eax nonzero when this machine calls, edx the routine to poll while
; it waits. Takes the port settings from the game setup, clears the packet rings and opens the port;
; on failure shows a message. Returns 1 when open (and registers the close at exit), else 0.
LinkOpen:							; eax caller, edx poll; eax 1 or 0
	push	ebx
	push	ecx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x10
	mov	[ebp-0x10],eax
	mov	[ebp-0xC],edx
	cmp	dword [linkstate-obj4_base],0	; already open?
	jz	.open
	mov	dword [ebp-4],0
	jmp	.exit
.open:								; not open yet
	mov	eax,[word_17C9AC-2-obj4_base]	; port settings from the game setup
	sar	eax,0x10
	mov	[dword_114D0E-obj4_base],eax
	mov	eax,[word_17C9AE-2-obj4_base]
	sar	eax,0x10
	add	eax,eax
	mov	eax,[eax+word_114DC2-2-obj4_base]
	sar	eax,0x10
	mov	[dword_114D36-obj4_base],eax
	mov	eax,[word_17C9B4-2-obj4_base]
	sar	eax,0x10
	mov	[dword_114D3A-obj4_base],eax
	cmp	word [word_17C9B0-obj4_base],0	; setup word: skip the message
	jz	.message
	mov	dword [dword_114D1E-obj4_base],1
	mov	dword [dword_114D12-obj4_base],9
	jmp	.port
.message:							; the setup word is 0
	mov	ecx,0xF0					; message 55h
	mov	ebx,0x140
	mov	edx,byte_17BDAE-obj4_base
	mov	eax,0x55
	call	sub_77355
	call	sub_1AA62
	xor	edx,edx
	mov	eax,0x50
	call	sub_68C33
	call	sub_689D1
	mov	edx,byte_17C9B8-obj4_base	; three strings from the setup
	mov	eax,byte_114CE6-obj4_base
	call	strcpy_
	mov	edx,byte_17C9CC-obj4_base
	mov	eax,byte_114D46-obj4_base
	call	strcpy_
	mov	edx,byte_17C9F4-obj4_base
	mov	eax,byte_114D6E-obj4_base
	call	strcpy_
	mov	dword [dword_114D12-obj4_base],9
	mov	dword [dword_114D1E-obj4_base],0
.port:								; settings done
	mov	eax,[ebp-0x10]				; eax nonzero: this machine calls
	mov	[linkcaller-obj4_base],eax
	mov	ecx,0x3C					; clear the four packet rings
	xor	eax,eax
	mov	edi,linkctlq-obj4_base
	rep	stosb
	mov	dword [linkctlqhead-obj4_base],0
	mov	eax,[linkctlqhead-obj4_base]
	mov	[linkctlqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkpadq-obj4_base
	rep	stosb
	mov	dword [linkpadqhead-obj4_base],0
	mov	eax,[linkpadqhead-obj4_base]
	mov	[linkpadqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkmyctlq-obj4_base
	rep	stosb
	mov	dword [linkmyctlqcount-obj4_base],0
	mov	eax,[linkmyctlqcount-obj4_base]
	mov	[linkmyctlqhead-obj4_base],eax
	mov	eax,[linkmyctlqhead-obj4_base]
	mov	[linkmyctlqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkchatq-obj4_base
	rep	stosb
	mov	dword [linkchatqhead-obj4_base],0
	mov	eax,[linkchatqhead-obj4_base]
	mov	[linkchatqtail-obj4_base],eax
	mov	dword [linksyncid-obj4_base],0	; no sync, no blocks
	mov	dword [linkblocksin-obj4_base],0
	mov	dword [linkblockswant-obj4_base],0
	mov	dword [linkblockleft-obj4_base],0
	mov	dword [linkblockptr-obj4_base],0
	mov	word [linksameside-obj4_base],0
	mov	eax,[ebp-0xC]				; the poll routine
	call	SetLinkPollFn
	mov	eax,byte_114CE6-obj4_base	; open the port
	call	sub_183CD
	test	eax,eax
	jnz	.opened
	cmp	word [word_17C9B0-obj4_base],0	; failed: fade out unless the setup word
	jnz	.1
	call	sub_68A0B
	mov	eax,2
	call	sub_69A94
	call	sub_68AB1
	call	sub_68BFA
.1:									; faded, or the setup word is set
	cmp	word [word_17C9B0-obj4_base],0
	jnz	.2
	call	sub_1AA27
.2:									; then the message box
	xor	eax,eax						; no poll routine
	call	SetLinkPollFn
	xor	eax,eax						; message 129h in a box
	call	sub_77355
	mov	[ebp-8],eax
	push	2
	push	0
	push	0xF0
	push	0x140
	push	0
	mov	ecx,byte_17BDAE-obj4_base
	lea	ebx,[ebp-8]
	mov	edx,1
	mov	eax,0x129
	call	sub_77355
	call	sub_1A109
	mov	dword [linkstate-obj4_base],0	; not open
	mov	dword [ebp-4],0
	jmp	.exit
.opened:							; the port is open
	or	byte [linkstate-obj4_base],1	; open
	mov	eax,sub_18234-obj1_base		; close it at exit
	push	eax
	call	sub_AA62C
	add	esp,4
	cmp	word [word_17C9B0-obj4_base],0
	jnz	.3
	call	sub_1AA27
.3:									; no poll routine now
	xor	eax,eax						; no poll routine
	call	SetLinkPollFn
	mov	dword [ebp-4],1				; result 1
.exit:								; eax the result
	mov	eax,[ebp-4]
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret

; Packet type 3 (eax): a block starts. Its bytes go to linkblockbuf; the dword is the length.
LinkRecvBlockStart:					; eax packet
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	mov	[ebp-4],eax
	mov	eax,[ebp-4]					; the packet
	mov	[linkpkt3-obj4_base],eax
	mov	dword [linkblockptr-obj4_base],linkblockbuf-obj4_base	; the block goes to linkblockbuf
	mov	eax,[linkpkt3-obj4_base]	; its length
	mov	eax,[eax+1]
	mov	[linkblockleft-obj4_base],eax
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Packet type 4 (eax): block data, byte 1 the count and the bytes from byte 2. Counts the block in
; linkblocksin when it is complete.
LinkRecvBlockData:					; eax packet
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	mov	[ebp-4],eax
	mov	eax,[ebp-4]					; the packet
	mov	[linkpkt4-obj4_base],eax
	cmp	dword [linkblockptr-obj4_base],0	; a block under way?
	jz	.1
	cmp	dword [linkblockleft-obj4_base],0
	jg	.copy
.1:									; no block under way
	jmp	.exit
.copy:								; copy the data
	mov	eax,[linkpkt4-obj4_base]	; byte 1: the count, data from byte 2
	movsx	ebx,byte [eax+1]
	mov	eax,[linkpkt4-obj4_base]
	lea	edx,[eax+2]
	mov	eax,[linkblockptr-obj4_base]
	call	CopyBytes
	mov	eax,[linkpkt4-obj4_base]
	movsx	eax,byte [eax+1]
	sub	[linkblockleft-obj4_base],eax	; less to come
	mov	eax,[linkpkt4-obj4_base]
	movsx	eax,byte [eax+1]
	add	[linkblockptr-obj4_base],eax
	cmp	dword [linkblockleft-obj4_base],0	; complete?
	jnz	.exit
	inc	dword [linkblocksin-obj4_base]	; one more block in
	mov	dword [linkblockptr-obj4_base],0
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Sends a block: eax the data, edx its length. A type 3 packet with the length, then type 4 packets of up
; to four bytes each, every one sent again until it is queued.
LinkSendBlock:						; eax data, edx length
	push	ebx
	push	ecx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x14
	mov	[ebp-0x14],eax
	mov	[ebp-0x10],edx
	mov	word [word_114DC0-obj4_base],0	; type 3 packet: the length
	mov	byte [linkhdrpkt-obj4_base],3
	mov	eax,[ebp-0x10]
	mov	[linkhdrpkt+1-obj4_base],eax
.header:							; until it is queued
	mov	edx,6
	mov	eax,linkhdrpkt-obj4_base
	call	LinkSendPacket
	test	eax,eax
	jnz	.data
	call	sub_69A9B
	jmp	.header
.data:								; header sent
	mov	dword [linkblockptr-obj4_base],linkblockbuf-obj4_base	; copy the data to linkblockbuf
	mov	ebx,[ebp-0x10]
	mov	edx,[ebp-0x14]
	mov	eax,[linkblockptr-obj4_base]
	call	CopyBytes
	mov	eax,[ebp-0x10]
	mov	[linkblockleft-obj4_base],eax
	mov	byte [linkdatapkt-obj4_base],4	; type 4 packets
.loop:								; while bytes are left
	cmp	dword [linkblockleft-obj4_base],4	; up to four bytes
	jng	.1
	mov	dword [ebp-8],4
	jmp	.2
.1:									; four or fewer left
	mov	eax,[linkblockleft-obj4_base]
	mov	[ebp-8],eax
.2:									; [ebp-8] the count
	mov	al,[ebp-8]
	mov	[linkdatapkt+1-obj4_base],al
	mov	ebx,[ebp-8]					; into the packet
	mov	edx,[linkblockptr-obj4_base]
	mov	eax,linkdatapkt+2-obj4_base
	call	CopyBytes
	mov	edx,6						; queue it
	mov	eax,linkdatapkt-obj4_base
	call	LinkSendPacket
	test	eax,eax
	jz	.retry
	mov	eax,[ebp-8]					; sent: move on
	add	[linkblockptr-obj4_base],eax
	mov	eax,[ebp-8]
	sub	[linkblockleft-obj4_base],eax
	jmp	.next
.retry:								; not queued
	call	sub_69A9B				; not queued: wait and try again
.next:								; bytes left?
	cmp	dword [linkblockleft-obj4_base],0
	jg	.loop
	mov	dword [linkblockptr-obj4_base],0
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret

; Waits for the next block from the other machine and copies it: eax where to, edx how many bytes.
LinkRecvBlock:						; eax buffer, edx length
	push	ebx
	push	ecx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0xC
	mov	[ebp-0xC],eax
	mov	[ebp-8],edx
	inc	dword [linkblockswant-obj4_base]	; one more block wanted
.wait:								; until the block is in
	mov	eax,[linkblocksin-obj4_base]	; in yet?
	cmp	eax,[linkblockswant-obj4_base]
	jnl	.copy
	call	sub_69A9B
	jmp	.wait
.copy:								; it is in
	mov	ebx,[ebp-8]					; copy it out
	mov	edx,linkblockbuf-obj4_base
	mov	eax,[ebp-0xC]
	call	CopyBytes
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret

; Packet type 5 (eax): a sync number. From the other side it is linkpeersync; from our own side it means
; both machines took the same side (linksameside).
LinkRecvSync:						; eax packet
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	mov	[ebp-4],eax
	mov	eax,[ebp-4]
	mov	[linkpkt5-obj4_base],eax
	mov	eax,[linkpkt5-obj4_base]	; from the other side?
	movsx	ax,[eax+5]
	cmp	ax,[linkside-obj4_base]
	jz	.same
	mov	eax,[linkpkt5-obj4_base]	; its sync number
	mov	eax,[eax+1]
	mov	[linkpeersync-obj4_base],eax
	jmp	.exit
.same:								; our own side
	mov	word [linksameside-obj4_base],1	; our own side
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Takes a received packet (eax) by its type. SetLinkRecvFn installs it for the connection.
LinkRecvPacket:						; eax packet
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 8
	mov	[ebp-4],eax
	jmp	.1
.table:								; by type: 1-6
	dd	.type1-obj1_base			; 1: pads
	dd	.type2-obj1_base			; 2: controller pads
	dd	.type3-obj1_base			; 3: block start
	dd	.type4-obj1_base			; 4: block data
	dd	.type5-obj1_base			; 5: sync number
	dd	.type6-obj1_base			; 6: chat
.1:									; the type
	mov	word [word_114DC0-obj4_base],0
	mov	eax,[ebp-4]
	mov	al,[eax]
	dec	al							; type 1-6 -> 0-5
	mov	[ebp-8],al
	cmp	byte [ebp-8],5				; not 1-6: ignore
	ja	.exit
	xor	eax,eax
	mov	al,[ebp-8]
	shl	eax,2
	jmp	[cs:eax+.table-obj1_base]	; by type
.type6:								; type 6: chat characters
	mov	ebx,6						; type 6: into linkchatq
	mov	edx,[ebp-4]
	imul	eax,[linkchatqhead-obj4_base],6
	mov	ecx,linkchatq-obj4_base
	add	eax,ecx
	call	CopyBytes
	mov	edx,[linkchatqhead-obj4_base]	; next entry, mod 10
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkchatqhead-obj4_base],edx
	mov	eax,[linkchatqhead-obj4_base]	; full: drop the oldest
	cmp	eax,[linkchatqtail-obj4_base]
	jnz	.type2
	mov	edx,[linkchatqtail-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkchatqtail-obj4_base],edx
.type2:								; type 2: controller pads (type 6 falls through to here too)
	mov	ebx,6						; type 2 (and 6): into linkctlq
	mov	edx,[ebp-4]
	imul	eax,[linkctlqhead-obj4_base],6
	mov	ecx,linkctlq-obj4_base
	add	eax,ecx
	call	CopyBytes
	mov	edx,[linkctlqhead-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkctlqhead-obj4_base],edx
	mov	eax,[linkctlqhead-obj4_base]
	cmp	eax,[linkctlqtail-obj4_base]
	jnz	.2
	mov	edx,[linkctlqtail-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkctlqtail-obj4_base],edx
.2:									; type 2 done
	jmp	near .exit
.type1:								; type 1: pads
	mov	ebx,6						; type 1: pads, into linkpadq
	mov	edx,[ebp-4]
	imul	eax,[linkpadqhead-obj4_base],6
	mov	ecx,linkpadq-obj4_base
	add	eax,ecx
	call	CopyBytes
	mov	edx,[linkpadqhead-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkpadqhead-obj4_base],edx
	mov	eax,[linkpadqhead-obj4_base]
	cmp	eax,[linkpadqtail-obj4_base]
	jnz	.3
	mov	edx,[linkpadqhead-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkpadqtail-obj4_base],edx
.3:									; type 1 done
	jmp	.exit
.type3:								; type 3: block start
	mov	eax,[ebp-4]					; type 3: block start
	call	LinkRecvBlockStart
	jmp	.exit
.type4:								; type 4: block data
	mov	eax,[ebp-4]					; type 4: block data
	call	LinkRecvBlockData
	jmp	.exit
.type5:								; type 5: sync number
	mov	eax,[ebp-4]					; type 5: sync number
	call	LinkRecvSync
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Swaps pads with the other machine. eax, edx, ebx (0 or 1) our values; ecx and the two stack dwords
; (popped) where the other machine's three go. Sends them as one type 1 packet and waits for the other
; machine's, showing the wait sprite after 25 ticks. Only once connected.
LinkExchangePads:					; eax, edx, ebx ours; ecx, stack: theirs
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x24
	mov	[ebp-0x1C],eax
	mov	[ebp-0x14],edx
	mov	[ebp-0x18],ebx
	mov	[ebp-0xC],ecx
	test	byte [linkstate-obj4_base],2	; connected?
	jz	.exit
	mov	byte [ebp-0x24],1			; type 1 packet
	mov	eax,[ebp-0x1C]				; bits 11-20: eax
	shl	eax,0xB
	mov	[ebp-0x23],eax
	mov	eax,[ebp-0x14]				; bits 1-10: edx
	add	eax,eax
	or	[ebp-0x23],eax
	cmp	dword [ebp-0x18],0			; bit 0: ebx
	jz	.1
	or	dword [ebp-0x23],1
.1:									; packet built
	mov	word [word_114DC0-obj4_base],0
.send:								; until it is queued
	mov	edx,6
	lea	eax,[ebp-0x24]
	call	LinkSendPacket
	test	eax,eax
	jnz	.sent
	call	sub_69A9B
	jmp	.send
.sent:								; queued
	call	GetTicks				; the other machine has 25 ticks
	add	eax,0x19
	mov	[ebp-8],eax
	mov	dword [ebp-4],0
.wait:								; until the other machine's pads are in
	mov	eax,[linkpadqtail-obj4_base]	; its pads in?
	cmp	eax,[linkpadqhead-obj4_base]
	jnz	.take
	call	GetTicks				; late?
	cmp	eax,[ebp-8]
	jng	.timer
	cmp	dword [ebp-4],0
	jz	.late
.timer:								; not late, or already shown
	jmp	.2
.late:								; 25 ticks late
	mov	dword [ebp-4],1
	call	ShowWaitSprite			; show the wait sprite once
.2:									; wait a little
	call	sub_69A9B
	jmp	.wait
.take:								; a pad packet is in
	imul	eax,[linkpadqtail-obj4_base],6	; the oldest pad packet
	mov	edx,linkpadq-obj4_base
	add	edx,eax
	mov	[ebp-0x10],edx
	mov	edx,[ebp-0x10]				; bits 11-20
	mov	eax,[edx+1]
	and	eax,strict dword 0x1FF800
	mov	edx,[ebp-0xC]
	sar	eax,0xB
	mov	[edx],eax
	mov	edx,[ebp-0x10]				; bits 1-10
	mov	eax,[edx+1]
	and	eax,strict dword 0x7FE
	mov	edx,[ebp+0x10]
	sar	eax,1
	mov	[edx],eax
	mov	edx,[ebp-0x10]				; bit 0
	mov	edx,[edx+1]
	and	edx,1
	mov	eax,[ebp+0x14]
	mov	[eax],edx
	mov	edx,[linkpadqtail-obj4_base]	; next entry, mod 10
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkpadqtail-obj4_base],edx
	cmp	dword [ebp-4],0				; sprite shown?
	jz	.exit
	call	HideWaitSprite			; remove it
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	ret	8

; Connects a modem game: eax the routine to poll while waiting (none: returns 0). The port must be
; open. Connects, takes sides (the caller is side 1), syncs, sets linkgame, and the caller sends the
; game setup bytes. Shows a message for each step and for a failure. Returns 1 when connected, else 0.
LinkConnect:						; eax poll routine; returns eax 1 or 0
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x24
	mov	[ebp-0x14],eax
	cmp	dword [ebp-0x14],0			; a poll routine?
	jnz	.1
	mov	dword [ebp-4],0
	jmp	.exit
.1:									; a poll routine
	cmp	dword [linkstate-obj4_base],1	; port open and not connected?
	jz	.open
	mov	dword [ebp-4],0
	jmp	.exit
.open:								; the port is open
	cmp	dword [linkcaller-obj4_base],0	; calling?
	jz	.answer
	mov	ecx,0xF0					; message 56h
	mov	ebx,0x140
	mov	edx,byte_17BDAE-obj4_base
	mov	eax,0x56
	call	sub_77355
	call	sub_1AA62
	jmp	.connect
.answer:							; this machine answers
	mov	ecx,0xF0					; message 57h
	mov	ebx,0x140
	mov	edx,byte_17BDAE-obj4_base
	mov	eax,0x57
	call	sub_77355
	call	sub_1AA62
.connect:							; message shown
	mov	eax,[ebp-0x14]				; the poll routine
	call	SetLinkPollFn
	mov	dword [linksyncid-obj4_base],0	; clear the sync number and the rings
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkctlq-obj4_base
	rep	stosb
	mov	dword [linkctlqhead-obj4_base],0
	mov	eax,[linkctlqhead-obj4_base]
	mov	[linkctlqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkpadq-obj4_base
	rep	stosb
	mov	dword [linkpadqhead-obj4_base],0
	mov	eax,[linkpadqhead-obj4_base]
	mov	[linkpadqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkmyctlq-obj4_base
	rep	stosb
	mov	dword [linkmyctlqcount-obj4_base],0
	mov	eax,[linkmyctlqcount-obj4_base]
	mov	[linkmyctlqhead-obj4_base],eax
	mov	eax,[linkmyctlqhead-obj4_base]
	mov	[linkmyctlqtail-obj4_base],eax
	mov	ecx,0x3C
	xor	eax,eax
	mov	edi,linkchatq-obj4_base
	rep	stosb
	mov	dword [linkchatqhead-obj4_base],0
	mov	eax,[linkchatqhead-obj4_base]
	mov	[linkchatqtail-obj4_base],eax
	mov	dword [linkblocksin-obj4_base],0	; no blocks
	mov	dword [linkblockswant-obj4_base],0
	mov	dword [linkblockleft-obj4_base],0
	mov	dword [linkblockptr-obj4_base],0
	mov	eax,LinkRecvPacket-obj1_base	; packets go to LinkRecvPacket
	call	SetLinkRecvFn
	call	sub_18540				; connect
	test	eax,eax
	jnz	.connected
	xor	eax,eax						; failed: no poll routine
	call	SetLinkPollFn
	cmp	word [word_17C9B0-obj4_base],0
	jnz	.1a
	call	sub_68A0B
	mov	eax,2
	call	sub_69A94
	call	sub_68AB1
	call	sub_68BFA
.1a:								; fade skipped
	call	sub_1AA27
	xor	eax,eax						; message 58h in a box
	call	sub_77355
	mov	[ebp-0xC],eax
	push	2
	push	0
	push	0xF0
	push	0x140
	push	0
	mov	ecx,byte_17BDAE-obj4_base
	lea	ebx,[ebp-0xC]
	mov	edx,1
	mov	eax,0x58
	call	sub_77355
	call	sub_1A109
	mov	dword [ebp-4],0				; result 0
	jmp	.exit
.connected:							; connected
	cmp	dword [linkcaller-obj4_base],0	; side 1 when calling, else 0
	jz	.side0
	mov	word [linkside-obj4_base],1
	jmp	.2
.side0:								; the answering side
	mov	word [linkside-obj4_base],0
.2:									; side set
	call	sub_1AA27
	mov	dword [ebp-0x20],0xF0		; message 20Ah or 209h
	mov	dword [ebp-0x1C],0x140
	mov	eax,byte_17BDAE-obj4_base
	mov	[ebp-0x18],eax
	cmp	word [word_17C9B0-obj4_base],0
	jz	.3
	mov	eax,0x20A
	call	sub_77355
	mov	[ebp-0x24],eax
	jmp	.4
.3:									; setup word 0: message 209h
	mov	eax,0x209
	call	sub_77355
	mov	[ebp-0x24],eax
.4:									; eax the text
	mov	eax,[ebp-0x24]
	mov	ecx,[ebp-0x20]
	mov	ebx,[ebp-0x1C]
	mov	edx,[ebp-0x18]
	call	sub_1AA62
	cmp	word [word_17C9B0-obj4_base],0
	jnz	.sync
	call	sub_68A0B
	mov	eax,2
	call	sub_69A94
	call	sub_68AB1
	call	sub_68BFA
.sync:								; fade done
	mov	word [linksameside-obj4_base],0	; not the same side yet
	mov	edx,1						; sync, with polling
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	test	eax,eax
	jnz	.synced
	call	sub_1AA27
	xor	eax,eax
	call	sub_77355
	mov	[ebp-0xC],eax
	cmp	word [linksameside-obj4_base],0	; both on one side?
	jz	.5
	mov	eax,0x261					; message 261h
	call	sub_77355
	mov	[ebp-8],eax
	jmp	.6
.5:									; not the same side
	mov	eax,0x58					; message 58h
	call	sub_77355
	mov	[ebp-8],eax
.6:									; eax the text
	push	2
	push	0
	push	0xF0
	push	0x140
	push	0
	mov	ecx,byte_17BDAE-obj4_base
	lea	ebx,[ebp-0xC]
	mov	edx,1
	mov	eax,[ebp-8]
	call	sub_1A109
	mov	word [linksameside-obj4_base],0
	mov	dword [ebp-4],0				; result 0
	jmp	.exit
.synced:							; synced
	mov	word [linksameside-obj4_base],0
	call	sub_1AA27
	xor	eax,eax						; no poll routine
	call	SetLinkPollFn
	or	byte [linkstate-obj4_base],2	; connected
	or	byte [linkgame-obj4_base],1	; a modem game
	mov	ecx,0xF0					; message 59h
	mov	ebx,0x140
	mov	edx,byte_17BDAE-obj4_base
	mov	eax,0x59
	call	sub_77355
	call	sub_1AA62
	cmp	word [linkside-obj4_base],0	; which side?
	jnz	.caller
	mov	edx,0xB9					; side 0: receive the setup bytes
	mov	eax,byte_17D272-obj4_base
	call	LinkRecvBlock
	xor	edx,edx						; sync
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	mov	edx,4						; and four more bytes
	mov	eax,dword_114DCA-obj4_base
	call	LinkRecvBlock
	mov	eax,[dword_17C9A8-obj4_base]	; swap bits 7-8 of the setup dword
	shl	eax,0x17
	shr	eax,0x1E
	mov	[ebp-0x10],eax
	mov	eax,[dword_114DCA-obj4_base]
	and	eax,3
	and	word [dword_17C9A8-obj4_base],0xFE7F
	shl	eax,7
	or	[dword_17C9A8-obj4_base],eax
	mov	eax,[ebp-0x10]
	mov	[dword_114DCA-obj4_base],eax
	xor	edx,edx						; sync
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	jmp	.done
.caller:							; side 1: send
	mov	ecx,0xB9					; side 1: send the setup bytes
	mov	esi,byte_17CA75-obj4_base
	mov	edi,byte_17D272-obj4_base
	rep	movsb
	mov	edx,0xB9
	mov	eax,byte_17D272-obj4_base
	call	LinkSendBlock
	xor	edx,edx						; sync
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	mov	eax,[dword_17C9A8-obj4_base]	; bits 7-8 of the setup dword
	shl	eax,0x17
	shr	eax,0x1E
	mov	[dword_114DCA-obj4_base],eax
	mov	edx,4						; send them
	mov	eax,dword_114DCA-obj4_base
	call	LinkSendBlock
	xor	edx,edx						; sync
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
.done:								; setup bytes swapped
	call	sub_1AA27
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

; Shows the wait sprite in the middle of the screen (HGwt, HFwt or LGwt by screen size), once.
ShowWaitSprite:						; once
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	cmp	dword [waitsprite-obj4_base],0	; already shown?
	jnz	.exit
	cmp	dword [mousewidth-obj4_base],0x140	; wide screen?
	jng	.narrow
	cmp	dword [dword_11BCE4-obj4_base],0	; which wide shape
	jnz	.1
	mov	eax,str_HGwt-obj4_base		; HGwt
	push	eax
	push	dword [dword_1150D4-obj4_base]
	call	sub_E04E0
	add	esp,8
	mov	[ebp-4],eax
	jmp	.2
.1:									; HFwt
	mov	eax,str_HFwt-obj4_base		; HFwt
	push	eax
	push	dword [dword_1150D4-obj4_base]
	call	sub_E04E0
	add	esp,8
	mov	[ebp-4],eax
.2:									; eax the shape
	jmp	.show
.narrow:							; 320 wide
	mov	eax,str_LGwt-obj4_base		; LGwt
	push	eax
	push	dword [dword_1150D4-obj4_base]
	call	sub_E04E0
	add	esp,8
	mov	[ebp-4],eax
.show:								; eax the shape
	mov	eax,[ebp-4]					; centred: x
	mov	eax,[eax+2]
	sar	eax,0x10
	sar	eax,1
	mov	edx,[mousewidth-obj4_base]
	sar	edx,1
	sub	edx,eax
	mov	eax,[ebp-4]
	mov	[eax+0xC],dx
	mov	eax,[ebp-4]					; y
	mov	eax,[eax+4]
	sar	eax,0x10
	sar	eax,1
	mov	edx,[mouseheight-obj4_base]
	sar	edx,1
	sub	edx,eax
	mov	eax,[ebp-4]
	mov	[eax+0xE],dx
	xor	edx,edx						; make the sprite
	mov	eax,[ebp-4]
	call	sub_63B0C
	mov	[waitsprite-obj4_base],eax
	push	dword [waitsprite-obj4_base]	; show it
	call	sub_AA988
	add	esp,4
	mov	eax,[ebp-4]
	push	eax
	call	sub_AAA8C
	add	esp,4
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Removes the wait sprite if it is shown.
HideWaitSprite:						; if shown
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	cmp	dword [waitsprite-obj4_base],0	; shown?
	jz	.exit
	push	dword [waitsprite-obj4_base]
	call	sub_AADA4
	add	esp,4
	push	dword [waitsprite-obj4_base]
	call	sub_ABF4C
	add	esp,4
	mov	dword [waitsprite-obj4_base],0	; not shown now
.exit:								; done
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Returns 1 once the tick count is past linkdeadline, else 0: the poll routine LinkSyncWait and
; LinkSyncMessage give LinkSync.
LinkTimedOut:						; returns eax 1 or 0
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	call	sub_69A9B
	call	GetTicks				; past the tick?
	cmp	eax,[linkdeadline-obj4_base]
	jng	.1
	mov	dword [ebp-4],1
	jmp	.exit
.1:									; not yet
	mov	dword [ebp-4],0
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

; Syncs with the other machine: eax the sync number, edx nonzero to call linkpollfn while waiting (its
; nonzero result gives up). The caller sends it and waits for the same number back; the other side
; waits, then sends. Returns 1 when synced, 0 when given up or both took the same side.
LinkSync:							; eax number, edx poll; returns eax 1 or 0
	push	ebx
	push	ecx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x18
	mov	[ebp-0xC],eax
	mov	[ebp-0x10],edx
	mov	dword [ebp-4],0
	mov	word [word_114DC0-obj4_base],0	; not given up
	mov	byte [ebp-0x18],5			; type 5 packet: the number and our side
	mov	eax,[ebp-0xC]
	mov	[ebp-0x17],eax
	mov	al,[linkside-obj4_base]
	mov	[ebp-0x13],al
	mov	eax,[linkside-2-obj4_base]	; side 1 (the caller)?
	sar	eax,0x10
	cmp	eax,1
	jnz	.answer
.send:								; caller: send until queued
	cmp	word [ebp-4],0				; given up?
	jnz	.1
	mov	edx,6						; queue it
	lea	eax,[ebp-0x18]
	call	LinkSendPacket
	test	eax,eax
	jz	.2
.1:									; queued or given up
	jmp	.wait
.2:									; not queued
	mov	ax,[linksameside-obj4_base]	; given up if both on one side
	mov	[ebp-4],eax
	cmp	dword [ebp-0x10],0			; polling, and a poll routine?
	jz	.3
	cmp	dword [linkpollfn-obj4_base],0
	jnz	.4
.3:									; not polling
	jmp	.5
.4:									; polling: unless given up
	cmp	word [ebp-4],0
	jz	.poll
.5:									; no poll this time
	jmp	.6
.poll:								; ask the poll routine
	call	[linkpollfn-obj4_base]	; nonzero: give up
	mov	[ebp-4],eax
.6:									; wait a little, then again
	call	sub_69A9B
	jmp	.send
.wait:								; then wait for the number back
	mov	eax,[linkpeersync-obj4_base]	; the number back?
	cmp	eax,[ebp-0xC]
	jz	.7
	cmp	word [ebp-4],0
	jz	.8
.7:									; the number is back, or given up
	jmp	.13
.8:									; not yet
	mov	ax,[linksameside-obj4_base]
	mov	[ebp-4],eax
	cmp	dword [ebp-0x10],0
	jz	.9
	cmp	dword [linkpollfn-obj4_base],0
	jnz	.10
.9:									; not polling
	jmp	.11
.10:								; polling: unless given up
	cmp	word [ebp-4],0
	jz	.poll2
.11:								; no poll this time
	jmp	.12
.poll2:								; ask the poll routine
	call	[linkpollfn-obj4_base]
	mov	[ebp-4],eax
.12:								; wait a little, then again
	call	sub_69A9B
	jmp	.wait
.13:								; synced or given up
	jmp	.done
.answer:							; other side: wait first
	mov	eax,[linkpeersync-obj4_base]	; the other side's number?
	cmp	eax,[ebp-0xC]
	jz	.14
	cmp	word [ebp-4],0
	jz	.15
.14:								; the number is in, or given up
	jmp	.send2
.15:								; not yet
	mov	ax,[linksameside-obj4_base]
	mov	[ebp-4],eax
	cmp	dword [ebp-0x10],0
	jz	.16
	cmp	dword [linkpollfn-obj4_base],0
	jnz	.17
.16:								; not polling
	jmp	.18
.17:								; polling: unless given up
	cmp	word [ebp-4],0
	jz	.poll3
.18:								; no poll this time
	jmp	.19
.poll3:								; ask the poll routine
	call	[linkpollfn-obj4_base]
	mov	[ebp-4],eax
.19:								; wait a little, then again
	call	sub_69A9B
	jmp	.answer
.send2:								; then send until queued
	cmp	word [ebp-4],0				; given up?
	jnz	.20
	mov	edx,6
	lea	eax,[ebp-0x18]
	call	LinkSendPacket
	test	eax,eax
	jz	.21
.20:								; queued or given up
	jmp	.done
.21:								; not queued
	mov	ax,[linksameside-obj4_base]
	mov	[ebp-4],eax
	cmp	dword [ebp-0x10],0
	jz	.22
	cmp	dword [linkpollfn-obj4_base],0
	jnz	.23
.22:								; not polling
	jmp	.24
.23:								; polling: unless given up
	cmp	word [ebp-4],0
	jz	.poll4
.24:								; no poll this time
	jmp	.25
.poll4:								; ask the poll routine
	call	[linkpollfn-obj4_base]
	mov	[ebp-4],eax
.25:								; wait a little, then again
	call	sub_69A9B
	jmp	.send2
.done:								; eax the result next
	cmp	word [ebp-4],0				; result: 1 unless given up
	jz	.ok
	mov	dword [ebp-8],0
	jmp	.exit
.ok:								; not given up
	mov	dword [ebp-8],1
.exit:								; eax the result
	mov	eax,[ebp-8]
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	ret
