; More of the modem game link: syncing with a time limit, closing the link, flushing the input in a modem
; game, sending the pads of this machine's two controllers every frame and pairing them with the other
; machine's into the input queue, and the chat window, where both players type to each other.
;
; Chat text goes out four characters to a type 6 packet; Esc on either machine ends the chat. The window has
; two halves, one per machine, each with its own cursor; a line wraps at the window edge or on Enter.

; Syncs with the other machine, giving up 6000 ticks from now (LinkTimedOut as the poll routine).
; eax nonzero shows the wait sprite meanwhile. Only once connected.
LinkSyncWait:						; eax: show the wait sprite
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0xC
	mov	[ebp-8],eax
	test	byte [linkstate-obj4_base],2	; connected?
	jz	near .exit
	call	GetTicks				; give up 6000 ticks from now
	add	eax,strict dword 0x1770
	mov	[linkdeadline-obj4_base],eax
	mov	eax,LinkTimedOut-obj1_base	; polled by LinkSync
	call	SetLinkPollFn
	cmp	dword [ebp-8],0				; wait sprite?
	jz	.loop
	call	ShowWaitSprite
.loop:								; sync until it returns
	mov	edx,1						; sync, polling
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	test	eax,eax					; (LinkSync never returns negative)
	jnl	.1
	mov	dword [ebp-0xC],1
	jmp	.2
.1:									; synced or given up
	mov	dword [ebp-0xC],0
.2:									; [ebp-0Ch] 0
	mov	eax,[ebp-0xC]
	mov	[ebp-4],eax
	cmp	dword [ebp-4],0
	jz	.3
	mov	eax,str_ABORT-obj4_base		; "ABORT!"
	push	eax
	call	sub_AC9F0
	add	esp,4
.3:									; never negative: done
	cmp	dword [ebp-4],0
	jl	.loop
	cmp	dword [ebp-8],0				; sprite?
	jz	.4
	call	HideWaitSprite
.4:									; sprite off
	xor	eax,eax						; no poll routine
	call	SetLinkPollFn
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; The same as LinkSyncWait, showing the text eax as a link message instead of the wait sprite.
LinkSyncMessage:					; eax the message text
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0xC
	mov	[ebp-8],eax
	test	byte [linkstate-obj4_base],2	; connected?
	jz	near .exit
	mov	eax,LinkTimedOut-obj1_base	; polled by LinkSync
	call	SetLinkPollFn
	call	GetTicks				; give up 6000 ticks from now
	add	eax,strict dword 0x1770
	mov	[linkdeadline-obj4_base],eax
	mov	ecx,0xF0					; the message
	mov	ebx,0x140
	mov	edx,byte_17BDAE-obj4_base
	mov	eax,[ebp-8]
	call	sub_1AA62
.loop:								; sync until it returns
	mov	edx,1						; sync, polling
	inc	dword [linksyncid-obj4_base]
	mov	eax,[linksyncid-obj4_base]
	call	LinkSync
	test	eax,eax
	jnl	.1
	mov	dword [ebp-0xC],1
	jmp	.2
.1:									; synced or given up
	mov	dword [ebp-0xC],0
.2:									; [ebp-0Ch] 0
	mov	eax,[ebp-0xC]
	mov	[ebp-4],eax
	cmp	dword [ebp-4],0
	cmp	dword [ebp-4],0
	jl	.loop
	call	sub_1AA27				; message off
	xor	eax,eax						; no poll routine
	call	SetLinkPollFn
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Closes the modem link: in a modem game puts back bits 7-8 of the setup dword and drops the packet
; routines; with the port open takes its close off the exit list and closes it. Clears linkgame and
; linkstate.
LinkClose:							; clears linkgame, linkstate
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	mov	ax,[linkgame-obj4_base]		; modem game?
	and	eax,strict dword 1
	cwde
	test	eax,eax
	jz	.port
	mov	eax,[dword_114DCA-obj4_base]	; put back bits 7-8 of the setup dword
	and	eax,3
	and	word [dword_17C9A8-obj4_base],0xFE7F
	shl	eax,7
	or	[dword_17C9A8-obj4_base],eax
	xor	eax,eax						; no packet routine
	call	SetLinkRecvFn
	xor	eax,eax						; and the other one
	call	sub_1803B
.port:								; packet routines dropped
	test	byte [linkstate-obj4_base],1	; port open?
	jz	.closed
	mov	eax,sub_18234-obj1_base		; not closed at exit any more
	push	eax
	call	sub_AA664
	add	esp,4
	call	sub_186DC				; close the port
.closed:							; port closed
	mov	word [linkgame-obj4_base],0	; no modem game, nothing open
	mov	dword [linkstate-obj4_base],0
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Closes the link in a modem game, with the wait sprite shown while it does.
LinkHangUp:							; in a modem game
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0
	mov	ax,[linkgame-obj4_base]		; modem game?
	and	eax,strict dword 1
	cwde
	test	eax,eax
	jz	.exit
	call	ShowWaitSprite			; wait sprite on
	call	LinkClose				; close
	call	HideWaitSprite			; and off
.exit:								; done
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Flushes the input in a modem game: syncs, clears the controller pad rings and the input queue, syncs
; again. Not again until a packet is sent or taken (word_114DC0). FlushControllerInput calls it.
LinkFlushInput:						; syncs both machines
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 4
	cmp	word [word_114DC0-obj4_base],0	; already flushed?
	jnz	.exit
	test	byte [linkstate-obj4_base],2	; connected?
	jz	.exit
	mov	eax,[linkpadsready-obj4_base]	; no pads sent meanwhile
	mov	[ebp-4],eax
	mov	dword [linkpadsready-obj4_base],0
	xor	eax,eax						; sync, no sprite
	call	LinkSyncWait
	mov	dword [linkctlqhead-obj4_base],0	; clear the pad rings and the input queue
	mov	eax,[linkctlqhead-obj4_base]
	mov	[linkctlqtail-obj4_base],eax
	mov	dword [linkmyctlqhead-obj4_base],0
	mov	eax,[linkmyctlqhead-obj4_base]
	mov	[linkmyctlqtail-obj4_base],eax
	mov	dword [linkmyctlqcount-obj4_base],0
	mov	ecx,0x5A
	xor	eax,eax
	mov	edi,inputq-obj4_base
	rep	stosb
	mov	dword [inputqcount-obj4_base],0
	mov	dword [dword_114B9C-obj4_base],0
	mov	dword [inputqhead-obj4_base],0
	mov	ecx,0x10
	xor	eax,eax
	mov	edi,byte_114B8C-obj4_base
	rep	stosb
	xor	eax,eax						; sync again
	call	LinkSyncWait
	mov	eax,[ebp-4]					; pads again
	mov	[linkpadsready-obj4_base],eax
	mov	word [word_114DC0-obj4_base],1	; flushed
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; Every frame in a modem game: sends this machine's two controller pads (eax 0; at most four ahead) as a
; type 2 packet, and once one of ours and one of theirs are in, adds both machines' pads to the input
; queue: the caller's two controllers first.
LinkSendPads:						; eax nonzero: do not send
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x1C
	mov	[ebp-0x1C],eax
	test	byte [linkstate-obj4_base],2	; connected?
	jz	.1
	cmp	dword [linkpadsready-obj4_base],0	; and not busy?
	jnz	.run
.1:									; not connected, or busy
	jmp	.exit
.run:								; connected and free
	mov	dword [linkpadsready-obj4_base],0	; busy
	mov	eax,[dword_115008-obj4_base]
	inc	dword [dword_115008-obj4_base]
	cmp	dword [linkmyctlqcount-obj4_base],4	; four or more of ours in hand?
	jnl	.3
	cmp	dword [ebp-0x1C],0			; or told not to send?
	jz	.send
.3:									; four in hand, or not sending
	jmp	.pair
.send:								; build a type 2 packet
	imul	eax,[linkmyctlqhead-obj4_base],6	; our next slot
	mov	edx,linkmyctlq-obj4_base
	add	edx,eax
	mov	[ebp-0x18],edx
	mov	eax,[ebp-0x18]
	mov	byte [eax],2				; type 2
	mov	eax,[linkside-2-obj4_base]	; which side?
	sar	eax,0x10
	cmp	eax,1
	jnz	.side0
	mov	eax,[ctlrecs+ctl_pad-obj4_base]	; caller: controllers 0 and 1
	mov	[ebp-0xC],eax
	mov	eax,[ctlrecs+ctl_size+ctl_pad-obj4_base]
	mov	[ebp-8],eax
	jmp	.pack
.side0:								; answering side: controllers 2 and 3
	mov	eax,[ctlrecs+2*ctl_size+ctl_pad-obj4_base]
	mov	[ebp-0xC],eax
	mov	eax,[ctlrecs+3*ctl_size+ctl_pad-obj4_base]
	mov	[ebp-8],eax
.pack:								; [ebp-0Ch], [ebp-8] the two pads
	mov	edx,[ebp-0xC]				; pack both pads into one dword
	and	edx,3
	mov	eax,[ebp-8]
	and	eax,3
	or	edx,eax
	mov	[ebp-4],edx
	mov	edx,[ebp-0xC]
	shl	edx,6
	and	edx,0x3FF0000
	mov	eax,[ebp-8]
	shl	eax,6
	and	eax,strict dword 0x3FF0000
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[ebp-0xC]
	sar	eax,0xC
	and	eax,strict dword 0x100
	mov	edx,eax
	mov	eax,[ebp-0xC]
	and	eax,strict dword 0xFC
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[ebp-8]
	and	eax,strict dword 0xFC
	shl	eax,7
	mov	edx,eax
	mov	eax,[ebp-8]
	sar	eax,5
	and	eax,strict dword 0x8000
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[ebp-4]					; into the packet
	mov	edx,[ebp-0x18]
	mov	[edx+1],eax
	mov	word [word_114DC0-obj4_base],0
	mov	edx,6						; queue it
	mov	eax,[ebp-0x18]
	call	LinkSendPacket
	test	eax,eax
	jz	.pair
	inc	dword [linkmyctlqcount-obj4_base]	; one more of ours, next slot
	mov	edx,[linkmyctlqhead-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkmyctlqhead-obj4_base],edx
.pair:								; ours sent
	cmp	dword [linkmyctlqcount-obj4_base],1	; more than one of ours?
	jng	.8
	mov	eax,[linkctlqtail-obj4_base]	; and one of theirs?
	cmp	eax,[linkctlqhead-obj4_base]
	jnz	.9
.8:									; not enough in hand
	jmp	.10
.9:									; theirs in too
	cmp	dword [dword_114F08-obj4_base],1	; input wanted?
	jz	.11
.10:								; no room or not wanted
	jmp	.12
.11:								; input wanted
	cmp	dword [inputqcount-obj4_base],5	; and room in the input queue?
	jl	.queue
.12:								; queue full
	jmp	.done
.queue:								; into the input queue
	imul	edx,[inputqhead-obj4_base],0x12	; the next input queue entry (18 bytes)
	mov	eax,inputq-obj4_base
	add	eax,edx
	mov	[ebp-0x10],eax
	mov	edx,[inputqhead-obj4_base]
	inc	edx
	mov	ebx,5
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[inputqhead-obj4_base],edx
	inc	dword [inputqcount-obj4_base]
	imul	eax,[linkmyctlqtail-obj4_base],6	; our oldest packet
	mov	edx,linkmyctlq-obj4_base
	add	edx,eax
	mov	[ebp-0x18],edx
	mov	edx,[linkmyctlqtail-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkmyctlqtail-obj4_base],edx
	dec	dword [linkmyctlqcount-obj4_base]
	imul	eax,[linkctlqtail-obj4_base],6	; their oldest
	mov	edx,linkctlq-obj4_base
	add	edx,eax
	mov	[ebp-0x14],edx
	mov	edx,[linkctlqtail-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkctlqtail-obj4_base],edx
	mov	eax,[ebp-0x18]				; the two dwords
	mov	eax,[eax+1]
	mov	[ebp-0xC],eax
	mov	eax,[ebp-0x14]
	mov	eax,[eax+1]
	mov	[ebp-8],eax
	mov	eax,[ebp-0xC]				; our first pad
	sar	eax,6
	and	eax,strict dword 0xFFC00
	mov	edx,[ebp-0xC]
	and	edx,3
	or	edx,eax
	mov	[ebp-4],edx
	mov	eax,[ebp-0xC]
	shl	eax,0xC
	and	eax,strict dword 0x100000
	mov	edx,[ebp-0xC]
	and	edx,0xFC
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[linkside-2-obj4_base]	; caller?
	sar	eax,0x10
	cmp	eax,1
	jnz	.13
	mov	eax,[ebp-4]					; caller: at +0
	mov	edx,[ebp-0x10]
	mov	[edx],eax
	jmp	.14
.13:								; answering side: its first pad at +8
	mov	eax,[ebp-4]
	mov	edx,[ebp-0x10]
	mov	[edx+8],eax
.14:								; first pad stored
	mov	eax,[ebp-0xC]				; our second pad
	sar	eax,6
	and	eax,strict dword 0xFFC00
	mov	edx,[ebp-0xC]
	and	edx,3
	or	edx,eax
	mov	[ebp-4],edx
	mov	eax,[ebp-0xC]
	sar	eax,7
	and	eax,strict dword 0xFC
	mov	edx,eax
	mov	eax,[ebp-0xC]
	and	eax,strict dword 0x8000
	shl	eax,5
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[linkside-2-obj4_base]
	sar	eax,0x10
	cmp	eax,1
	jnz	.15
	mov	eax,[ebp-4]					; caller: at +4
	mov	edx,[ebp-0x10]
	mov	[edx+4],eax
	jmp	.theirs
.15:								; answering side: its second pad at +0Ch
	mov	eax,[ebp-4]
	mov	edx,[ebp-0x10]
	mov	[edx+0xC],eax
.theirs:							; their packet
	mov	eax,[ebp-8]					; their first pad
	sar	eax,6
	and	eax,strict dword 0xFFC00
	mov	edx,[ebp-8]
	and	edx,3
	or	edx,eax
	mov	[ebp-4],edx
	mov	eax,[ebp-8]
	shl	eax,0xC
	and	eax,strict dword 0x100000
	mov	edx,[ebp-8]
	and	edx,0xFC
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[linkside-2-obj4_base]
	sar	eax,0x10
	cmp	eax,1
	jnz	.16
	mov	eax,[ebp-4]					; caller: theirs at +8
	mov	edx,[ebp-0x10]
	mov	[edx+8],eax
	jmp	.17
.16:								; answering side: theirs at +0
	mov	eax,[ebp-4]
	mov	edx,[ebp-0x10]
	mov	[edx],eax
.17:								; their first pad stored
	mov	eax,[ebp-8]					; their second pad
	sar	eax,6
	and	eax,strict dword 0xFFC00
	mov	edx,[ebp-8]
	and	edx,3
	or	edx,eax
	mov	[ebp-4],edx
	mov	eax,[ebp-8]
	sar	eax,7
	and	eax,strict dword 0xFC
	mov	edx,eax
	mov	eax,[ebp-8]
	and	eax,strict dword 0x8000
	shl	eax,5
	or	eax,edx
	or	[ebp-4],eax
	mov	eax,[linkside-2-obj4_base]
	sar	eax,0x10
	cmp	eax,1
	jnz	.18
	mov	eax,[ebp-4]					; caller: at +0Ch
	mov	edx,[ebp-0x10]
	mov	[edx+0xC],eax
	jmp	.19
.18:								; answering side: their second at +4
	mov	eax,[ebp-4]
	mov	edx,[ebp-0x10]
	mov	[edx+4],eax
.19:								; four pads in the entry
	mov	eax,[ebp-0x10]				; 4 pads
	mov	word [eax+0x10],4
.done:								; pads paired or not
	mov	dword [linkpadsready-obj4_base],1	; not busy
	mov	eax,[dword_115008-obj4_base]
	dec	dword [dword_115008-obj4_base]
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret

; The chat window of a modem game. eax nonzero draws into a window of its own (else straight on the
; screen); edx and ebx place the two halves, ecx and the stack word (popped) are passed on. Waits for
; Enter and Esc to be let go, syncs, then until Esc on either machine: typed keys into chatbuf and
; our half, sent every 3 ticks; the other machine's characters from linkchatq into its half.
LinkChat:							; eax window, edx, ebx, ecx, stack word
	push	esi
	push	edi
	push	ebp
	mov	ebp,esp
	sub	esp,strict dword 0x74
	mov	[ebp-0x24],eax
	mov	[ebp-0x14],edx
	mov	[ebp-0x10],ebx
	mov	[ebp-0xC],ecx
	mov	dword [ebp-0x1C],0
	mov	dword [ebp-0x30],0
	mov	dword [ebp-0x2C],0
	mov	ax,[linkgame-obj4_base]		; modem game?
	and	eax,strict dword 1
	cwde
	test	eax,eax
	jz	.exit
	mov	eax,[mousewidth-obj4_base]	; window: three quarters of the screen
	sar	eax,2
	mov	edx,[mousewidth-obj4_base]
	sub	edx,eax
	mov	[ebp-0x4C],edx
	mov	eax,[mouseheight-obj4_base]
	sar	eax,2
	mov	edx,[mouseheight-obj4_base]
	sub	edx,eax
	mov	[ebp-0x48],edx
	mov	eax,[mousewidth-obj4_base]	; centred
	sub	eax,[ebp-0x4C]
	sar	eax,1
	mov	[ebp-0x44],eax
	mov	eax,[mouseheight-obj4_base]
	sub	eax,[ebp-0x48]
	sar	eax,1
	mov	[ebp-0x40],eax
	mov	ax,[str_X-obj4_base]		; "X": a one-character text
	mov	[ebp-4],eax
	xor	eax,eax						; line spacing
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,6
	mov	edx,[ebp-0x48]
	sub	edx,eax
	mov	eax,edx
	sar	eax,1
	sub	eax,3
	mov	[ebp-0x3C],eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,6
	mov	[ebp-0x74],eax
	mov	eax,[ebp-0x74]
	add	eax,[ebp-0x3C]
	add	eax,3
	mov	[ebp-0x70],eax
	movsx	edx,word [ebp+0x10]		; two of the arguments
	movsx	eax,word [ebp-0xC]
	call	sub_63F79
	cmp	word [ebp-0x24],0			; a window of its own?
	jz	.screen
	push	0						; make it
	mov	eax,[ebp-0x48]
	push	eax
	mov	eax,[ebp-0x4C]
	push	eax
	call	sub_AD35C
	add	esp,0xC
	mov	[ebp-0x2C],eax
	mov	edx,[ebp-0x2C]
	mov	edx,[edx+0x2C]
	mov	eax,[ebp-0x44]
	mov	[edx+0xC],ax
	mov	eax,[ebp-0x2C]
	mov	edx,[eax+0x2C]
	mov	eax,[ebp-0x40]
	mov	[edx+0xE],ax
	call	sub_DD6C4
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AA988
	add	esp,4
	xor	edx,edx
	mov	eax,[ebp-0x2C]
	mov	eax,[eax+0x2C]
	call	sub_63B0C
	mov	[ebp-0x30],eax
	push	0x20					; "SHAD" and "PAL" blocks
	push	0x100
	mov	eax,str_SHAD-obj4_base
	push	eax
	call	sub_AB758
	add	esp,0xC
	mov	[ebp-0x38],eax
	push	0x20
	push	0x300
	mov	eax,str_PAL-obj4_base
	push	eax
	call	sub_AB758
	add	esp,0xC
	mov	[ebp-0x28],eax
	mov	eax,[ebp-0x28]
	push	eax
	push	0x100
	push	0
	call	sub_DD6E0
	add	esp,0xC
	mov	eax,[ebp-0x38]
	push	eax
	mov	eax,[ebp-0x28]
	push	eax
	push	0x851E
	call	sub_AD620
	add	esp,0xC
	mov	eax,[ebp-0x2C]
	push	eax
	call	sub_DD708
	add	esp,4
	movsx	eax,word [ebp+0x10]
	push	eax
	movsx	eax,word [ebp-0xC]
	push	eax
	push	2
	mov	eax,[ebp-0x48]
	dec	eax
	push	eax
	mov	ecx,[ebp-0x4C]
	dec	ecx
	xor	ebx,ebx
	xor	edx,edx
	mov	eax,[ebp-0x38]
	call	sub_641D4
	mov	eax,[ebp-0x28]
	push	eax
	call	sub_ABF4C
	add	esp,4
	mov	eax,[ebp-0x38]
	push	eax
	call	sub_ABF4C
	add	esp,4
	mov	ebx,3
	mov	edx,[ebp-0x4C]
	sar	edx,1
	mov	eax,0x20B
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [ebp-0xC]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,5
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,3
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,5
	push	eax
	push	1
	call	sub_DD724
	add	esp,0x14
	movsx	eax,word [ebp-0xC]
	push	eax
	mov	eax,[ebp-0x70]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,3
	push	eax
	mov	eax,[ebp-0x70]
	sub	eax,2
	push	eax
	push	1
	call	sub_DD724
	add	esp,0x14
	call	sub_DD6C4
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	jmp	.start
.screen:							; no window: draw on the screen
	call	sub_DD6C4
	movsx	eax,word [ebp+0x10]
	push	eax
	mov	eax,[ebp-0x48]
	push	eax
	mov	eax,[ebp-0x4C]
	push	eax
	mov	eax,[ebp-0x40]
	push	eax
	mov	eax,[ebp-0x44]
	push	eax
	call	sub_AD680
	add	esp,0x14
	mov	ebx,[ebp-0x40]
	add	ebx,3
	mov	edx,[ebp-0x4C]
	sar	edx,1
	add	edx,[ebp-0x44]
	mov	eax,0x20B
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [ebp-0xC]
	push	eax
	mov	eax,[ebp-0x40]
	add	eax,[ebp-0x48]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x40]
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	inc	eax
	push	eax
	call	sub_ADA80
	add	esp,0x14
	movsx	eax,word [ebp-0xC]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,[ebp-0x40]
	add	eax,5
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,3
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,[ebp-0x40]
	add	eax,5
	push	eax
	mov	eax,[ebp-0x44]
	inc	eax
	push	eax
	call	sub_DD724
	add	esp,0x14
	movsx	eax,word [ebp-0xC]
	push	eax
	mov	eax,[ebp-0x40]
	add	eax,[ebp-0x70]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,3
	push	eax
	mov	eax,[ebp-0x40]
	add	eax,[ebp-0x70]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	inc	eax
	push	eax
	call	sub_DD724
	add	esp,0x14
.start:								; window drawn
	mov	word [chathead-obj4_base],0	; nothing typed
	mov	ax,[chathead-obj4_base]
	mov	[chattail-obj4_base],ax
	mov	byte [ebp-0x6C],6			; type 6 packets
	mov	ecx,10 * 6					; nothing received
	xor	eax,eax
	mov	edi,linkchatq-obj4_base
	rep	stosb
	mov	dword [linkchatqhead-obj4_base],0
	mov	eax,[linkchatqhead-obj4_base]
	mov	[linkchatqtail-obj4_base],eax
.release:							; until Enter and Esc are let go
	push	0x1C					; Enter held?
	call	KeyDown
	add	esp,4
	test	eax,eax
	jnz	.1
	push	1						; Esc held?
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.2
.1:									; held
	jmp	.3
.2:									; not held
	call	GetKey					; Esc waiting?
	cmp	eax,0x1B
	jnz	.4
.3:									; Esc waiting
	jmp	.wait
.4:									; no Esc
	call	GetKey					; Enter waiting?
	cmp	eax,0xD
	jnz	.go
.wait:								; not yet: wait a little
	call	sub_69A9B
	jmp	.release
.go:								; keys free
	mov	dword [dword_15199C-obj4_base],0
	mov	eax,1						; sync, with the wait sprite
	call	LinkSyncWait
	mov	word [ebp-0x32],0			; both cursors at the start
	mov	eax,[ebp-0x32]
	mov	[ebp-0x34],ax
	mov	eax,[ebp-0x34]
	mov	[ebp-0x5A],ax
	mov	eax,[ebp-0x5A]
	mov	[ebp-0x5C],ax
	movsx	eax,word [ebp-0x14]		; draw our cursor
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	eax,[ebp-0x40]
	inc	eax
	add	eax,[ebp-0x74]
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
	movsx	eax,word [ebp-0x10]		; and theirs
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	eax,[ebp-0x40]
	inc	eax
	add	eax,[ebp-0x70]
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
	call	sub_69A9B
	call	GetTicks				; tick for the next pass
	add	eax,4
	mov	[ebp-0x64],eax
	call	GetTicks				; and for the next send
	mov	[ebp-0x58],eax
.loop:								; each pass: a key, sending, receiving
	call	GetKey					; a key?
	mov	[ebp-0x20],eax
	cmp	word [ebp-0x20],0
	jz	.1a
	movsx	eax,word [ebp-0x20]		; Esc?
	cmp	eax,0x1B
	jnz	.key
.1a:								; no key, or Esc
	jmp	.esc
.key:								; a key
	movsx	eax,word [ebp-0x20]		; 20h-7Dh?
	cmp	eax,0x1F
	jng	.5
	movsx	eax,word [ebp-0x20]
	cmp	eax,0x7E
	jl	.typed
.5:									; not 20h-7Dh
	movsx	eax,word [ebp-0x20]		; Enter?
	cmp	eax,0xD
	jnz	.14
.typed:								; a character or Enter
	mov	edx,[chathead-2-obj4_base]	; room in chatbuf?
	sar	edx,0x10
	inc	edx
	mov	ebx,0x14
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	eax,[chattail-2-obj4_base]
	sar	eax,0x10
	cmp	edx,eax
	jz	.14
	mov	edx,[chathead-2-obj4_base]	; add it
	sar	edx,0x10
	mov	al,[ebp-0x20]
	mov	[edx+chatbuf-obj4_base],al
	mov	edx,[chathead-2-obj4_base]
	sar	edx,0x10
	inc	edx
	mov	ebx,0x14
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[chathead-obj4_base],dx
	cmp	word [ebp-0x24],0			; window?
	jz	.6
	mov	eax,[ebp-0x40]
	add	eax,[ebp-0x74]
	movsx	edx,word [ebp-0x34]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5C]
	mov	edx,[ebp-0x44]
	add	edx,3
	lea	esi,[edx+eax]
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	add	eax,esi
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5C]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.7
.6:									; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5C]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_AD680
	add	esp,0x14
.7:									; cursor cleared
	movsx	eax,word [ebp-0x20]
	cmp	eax,0xD						; draw it unless Enter
	jz	.8
	mov	al,[ebp-0x20]
	mov	[ebp-4],al
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	lea	ebx,[eax+1]
	movsx	edx,word [ebp-0x5C]
	mov	eax,[ebp-0x44]
	add	eax,3
	add	edx,eax
	lea	eax,[ebp-4]
	call	sub_63FEF
	lea	eax,[ebp-4]
	push	eax
	call	sub_ADBB4				; move the cursor on
	add	esp,4
	add	[ebp-0x5C],ax
.8:									; Enter: nothing drawn
	movsx	eax,word [ebp-0x20]
	cmp	eax,0xD						; Enter, or past the edge?
	jz	.newline
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	movsx	edx,word [ebp-0x5C]
	add	edx,eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	cmp	edx,eax
	jng	.cursor
.newline:							; Enter, or the line is full
	mov	word [ebp-0x5C],0			; start of the next line
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,strict dword 3
	add	[ebp-0x34],ax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	mov	edx,[ebp-0x3C]
	sub	edx,eax
	mov	eax,edx
	movsx	edx,word [ebp-0x34]
	cmp	edx,eax
	jl	.9							; past the bottom: back to the top
	mov	word [ebp-0x34],0
.9:									; y in range
	cmp	word [ebp-0x24],0
	jz	.10
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.11
.10:								; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
.11:								; line cleared
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,[ebp-0x34]
	add	eax,strict dword 3
	mov	[ebp-0x18],eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	mov	edx,[ebp-0x3C]
	sub	edx,eax
	mov	eax,edx
	movsx	edx,word [ebp-0x18]
	cmp	edx,eax
	jl	.12
	mov	dword [ebp-0x18],0
.12:								; next y in range
	cmp	word [ebp-0x24],0
	jz	.13
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.cursor
.13:								; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x74]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
.cursor:							; draw the cursor
	movsx	eax,word [ebp-0x14]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	eax,[ebp-0x40]
	inc	eax
	mov	edx,[ebp-0x74]
	add	edx,eax
	movsx	eax,word [ebp-0x34]
	add	eax,edx
	push	eax
	movsx	eax,word [ebp-0x5C]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_AD680
	add	esp,0x14
.14:								; key done
	jmp	near .out
.esc:								; no key or Esc: Esc held?
	push	1						; Esc held?
	call	KeyDown
	add	esp,4
	test	eax,eax
	jz	.15
	mov	dword [ebp-0x1C],1			; yes: we end
	mov	word [ebp-0x20],0
	jmp	.out
.15:								; Esc not held
	cmp	word [ebp-0x1C],0			; ending?
	jz	.out
	mov	word [ebp-0x20],0x1B		; send an Esc
	mov	edx,[chathead-2-obj4_base]
	sar	edx,0x10
	inc	edx
	mov	ebx,0x14
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	eax,[chattail-2-obj4_base]
	sar	eax,0x10
	cmp	edx,eax
	jz	.out
	mov	edx,[chathead-2-obj4_base]
	sar	edx,0x10
	mov	al,[ebp-0x20]
	mov	[edx+chatbuf-obj4_base],al
	mov	edx,[chathead-2-obj4_base]
	sar	edx,0x10
	inc	edx
	mov	ebx,0x14
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[chathead-obj4_base],dx
.out:								; send what was typed
	call	GetTicks				; time to send?
	cmp	eax,[ebp-0x58]
	jng	.in
	mov	ax,[chattail-obj4_base]		; anything typed?
	cmp	ax,[chathead-obj4_base]
	jz	.in
	mov	dword [ebp-0x54],0
.outloop:							; up to four characters
	mov	ax,[chattail-obj4_base]
	cmp	ax,[chathead-obj4_base]
	jz	.16
	cmp	dword [ebp-0x54],4
	jl	.outchar
.16:								; four, or none left
	jmp	.outsend
.outchar:							; one character from chatbuf
	mov	edx,[chattail-2-obj4_base]	; into the packet
	sar	edx,0x10
	mov	bl,[edx+chatbuf-obj4_base]
	mov	edx,[ebp-0x54]
	mov	[edx+ebp-0x6A],bl
	mov	edx,[chattail-2-obj4_base]
	sar	edx,0x10
	inc	edx
	mov	ebx,0x14
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[chattail-obj4_base],dx
	mov	edx,[ebp-0x54]
	inc	dword [ebp-0x54]
	jmp	.outloop
.outsend:							; [ebp-54h] the count
	mov	al,[ebp-0x54]				; the count
	mov	[ebp-0x6B],al
.17:								; until queued
	mov	edx,6						; queue it
	lea	eax,[ebp-0x6C]
	call	LinkSendPacket
	test	eax,eax
	jnz	.18
	call	sub_69A9B
	jmp	.17
.18:								; sent
	call	GetTicks				; next send in 3 ticks
	add	eax,3
	mov	[ebp-0x58],eax
.in:								; their packets
	mov	eax,[linkchatqtail-obj4_base]	; anything received?
	cmp	eax,[linkchatqhead-obj4_base]
	jz	.tick
	mov	eax,[linkchatqhead-obj4_base]	; up to the head now
	mov	[ebp-0x60],eax
	mov	dword [ebp-8],0
.inloop:							; up to the head seen
	mov	eax,[linkchatqtail-obj4_base]
	cmp	eax,[ebp-0x60]
	jz	.19
	movsx	eax,word [ebp-8]
	cmp	eax,0x1B
	jnz	.inpkt
.19:								; all taken, or their Esc
	jmp	.tick
.inpkt:								; one packet
	imul	eax,[linkchatqtail-obj4_base],6	; the packet
	mov	edx,linkchatq-obj4_base
	add	edx,eax
	mov	[ebp-0x50],edx
	mov	dword [ebp-0x54],0
.incharloop:						; its characters
	mov	eax,[ebp-0x50]				; byte 1: the count
	movsx	eax,byte [eax+1]
	cmp	eax,[ebp-0x54]
	jng	.20
	movsx	eax,word [ebp-8]
	cmp	eax,0x1B
	jnz	.inchar
.20:								; packet done
	jmp	.inpktnext
.inchar:							; one character
	mov	eax,[ebp-0x50]				; from byte 2
	add	eax,[ebp-0x54]
	movsx	ax,[eax+2]
	mov	[ebp-8],eax
	movsx	eax,word [ebp-8]
	cmp	eax,0x1B					; their Esc?
	jz	.innext
	cmp	word [ebp-0x24],0
	jz	.21
	mov	eax,[ebp-0x40]
	add	eax,[ebp-0x70]
	movsx	edx,word [ebp-0x32]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5A]
	mov	edx,[ebp-0x44]
	add	edx,3
	lea	esi,[edx+eax]
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	add	eax,esi
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5A]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.22
.21:								; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	inc	eax
	push	eax
	movsx	eax,word [ebp-0x5A]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_AD680
	add	esp,0x14
.22:								; cursor cleared
	movsx	eax,word [ebp-8]
	cmp	eax,0xD
	jz	.23
	mov	al,[ebp-8]
	mov	[ebp-4],al
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	lea	ebx,[eax+1]
	movsx	edx,word [ebp-0x5A]
	mov	eax,[ebp-0x44]
	add	eax,3
	add	edx,eax
	lea	eax,[ebp-4]
	call	sub_63FEF
	lea	eax,[ebp-4]
	push	eax
	call	sub_ADBB4
	add	esp,4
	add	[ebp-0x5A],ax
.23:								; Enter: nothing drawn
	movsx	eax,word [ebp-8]
	cmp	eax,0xD
	jz	.innewline
	movsx	esi,word [ebp-0x5A]
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	add	esi,eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	cmp	esi,eax
	jng	.incursor
.innewline:							; Enter, or the line is full
	mov	word [ebp-0x5A],0
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,strict dword 3
	add	[ebp-0x32],ax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	mov	edx,[ebp-0x3C]
	sub	edx,eax
	mov	eax,edx
	movsx	edx,word [ebp-0x32]
	cmp	edx,eax
	jl	.24
	mov	word [ebp-0x32],0
.24:								; y in range
	cmp	word [ebp-0x24],0
	jz	.25
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.26
.25:								; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
.26:								; line cleared
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	add	eax,[ebp-0x32]
	add	eax,strict dword 3
	mov	[ebp-0x18],eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	mov	edx,[ebp-0x3C]
	sub	edx,eax
	mov	eax,edx
	movsx	edx,word [ebp-0x18]
	cmp	edx,eax
	jl	.27
	mov	dword [ebp-0x18],0
.27:								; next y in range
	cmp	word [ebp-0x24],0
	jz	.28
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	xor	edx,edx
	mov	dl,[byte_11FA2F-obj4_base]
	inc	eax
	add	eax,edx
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,[ebp-0x4C]
	sub	eax,2
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_DD760
	add	esp,0x10
	mov	eax,[ebp-0x2C]
	push	dword [eax+0x2C]
	call	sub_AADA4
	add	esp,4
	push	dword [mouseheight-obj4_base]
	push	0
	push	dword [mousewidth-obj4_base]
	push	0
	call	sub_DD760
	add	esp,0x10
	jmp	.incursor
.28:								; no window
	movsx	eax,word [ebp+0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	push	eax
	mov	eax,[ebp-0x4C]
	sub	eax,5
	push	eax
	mov	edx,[ebp-0x40]
	add	edx,[ebp-0x70]
	movsx	eax,word [ebp-0x18]
	add	eax,edx
	inc	eax
	push	eax
	mov	eax,[ebp-0x44]
	add	eax,3
	push	eax
	call	sub_AD680
	add	esp,0x14
.incursor:							; draw their cursor
	movsx	eax,word [ebp-0x10]
	push	eax
	xor	eax,eax
	mov	al,[byte_11FA2F-obj4_base]
	dec	eax
	push	eax
	mov	eax,str_X-obj4_base
	push	eax
	call	sub_ADBB4
	add	esp,4
	push	eax
	mov	eax,[ebp-0x40]
	inc	eax
	mov	edx,[ebp-0x70]
	add	edx,eax
	movsx	eax,word [ebp-0x32]
	add	eax,edx
	push	eax
	movsx	eax,word [ebp-0x5A]
	mov	edx,[ebp-0x44]
	add	edx,3
	add	eax,edx
	push	eax
	call	sub_AD680
	add	esp,0x14
.innext:							; next character
	mov	eax,[ebp-0x54]
	inc	dword [ebp-0x54]
	jmp	.incharloop
.inpktnext:							; next packet
	mov	edx,[linkchatqtail-obj4_base]
	inc	edx
	mov	ebx,0xA
	mov	eax,edx
	sar	edx,0x1F
	idiv	ebx
	mov	[linkchatqtail-obj4_base],edx
	jmp	.inloop
.tick:								; every 4 ticks
	call	GetTicks				; every 4 ticks
	cmp	eax,[ebp-0x64]
	jng	.29
	call	sub_69A9B
	call	GetTicks
	add	eax,4
	mov	[ebp-0x64],eax
.29:								; tick done
	movsx	eax,word [ebp-0x20]		; our Esc?
	cmp	eax,0x1B
	jz	.end
	movsx	eax,word [ebp-8]		; or theirs?
	cmp	eax,0x1B
	jnz	.loop
.end:								; an Esc: done
	mov	eax,1						; sync, with the wait sprite
	call	LinkSyncWait
	cmp	word [ebp-0x24],0			; window?
	jz	.exit
	mov	eax,[ebp-0x30]				; take it down and free it
	push	eax
	call	sub_AADA4
	add	esp,4
	mov	eax,[ebp-0x30]
	push	eax
	call	sub_ABF4C
	add	esp,4
	mov	eax,[ebp-0x2C]
	push	eax
	call	sub_ADBEC
	add	esp,4
.exit:								; done
	mov	esp,ebp
	pop	ebp
	pop	edi
	pop	esi
	ret	4
