; A data table the next module reads (words, three fractions, sixteen point pairs), then
; DrawTeamStats: the game's team stats page, a row per stat with its name and both teams' values.
;
; The row names are texts 20Ch-21Ah (by text number); the values are words of teamstats, the first team's
; at +0, the second's teamstats_size on. Rows 217h-21Ah are only drawn once statsfirstrow is past 6.

teamstats_size	equ	0x136			; bytes of one team's stats in teamstats
statsrowtop_off	equ	statsrowtop-obj4_base	; statsrowtop as the code stores it; an equate because
									; NASM ignores nosplit for [edx*2+label-base]

word_144BD:							; three words the next module reads
	dw	0x9E, 0x86, 0x71
word_144C3:							; three more
	dw	0xAE, 0x95, 0x7B
dword_144C9:						; three dwords (probably 16.16 fractions: 0.99, 0.84, 0.71)
	dd	0xFD70, 0xD70A, 0xB5C2
dword_144D5:						; six dwords
	dd	0x4E, 0x108, 0x174, 0x4F, 0x1B0, 0x148
dword_144ED:						; sixteen x, y pairs of dwords
	dd	0x10F, 0x162, 0x119, 0x15B, 0x189, 0x15B, 0x195, 0x162
	dd	0x195, 0x16B, 0x187, 0x171, 0x119, 0x171, 0x10F, 0x16A
	dd	0x111, 0x199, 0x11A, 0x191, 0x18C, 0x191, 0x197, 0x198
	dd	0x197, 0x1A1, 0x18D, 0x1A7, 0x119, 0x1A7, 0x110, 0x1A1

; Draws the team stats page: eax the page (+4 width, +6 height). Makes a bitmap that size, then one
; row per stat from statsfirstrow on: its name at statslabelx and the two teams' values at
; statsteam1x and statsteam2x, each row at its y from statsrowtop; then passes the
; bitmap on.
DrawTeamStats:						; eax the page
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	enter	0x20,0
	mov	esi,eax						; esi the page
	push	0						; a bitmap the page's size
	movsx	eax,word [eax+6]
	push	eax
	movsx	eax,word [esi+4]
	push	eax
	call	sub_AD35C
	add	esp,0xC
	push	eax
	mov	edi,eax						; edi the bitmap
	call	sub_DD708
	add	esp,4
	push	0
	push	0
	push	esi
	call	sub_AAB40
	add	esp,0xC
	mov	edx,0xFE
	mov	eax,0xFC
	call	sub_63F79
	cmp	word [statsfirstrow-obj4_base],0	; first row shown?
	jnz	.1
									; row: text 20Ch, each team's +10h as "%d"
	mov	eax,0x20C
	mov	ebx,1						; y 1
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x10-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	ebx,1
	call	sub_ADC18
	lea	eax,[ebp-0x20]
	add	esp,0xC
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x10-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	ebx,1
	call	sub_ADC18
	lea	eax,[ebp-0x20]
	add	esp,0xC
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
.1:									; row 20Dh, while statsfirstrow < 2
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,2
	jnl	.2
	mov	edx,3
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
									; row: text 20Dh, each team's +0 as "%d"
	mov	eax,0x20D
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,3
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,3
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
.2:									; row 20Eh, while statsfirstrow < 3
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,3
	jnl	.7
	mov	edx,4
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	lea	ebx,[eax+1]
									; row: text 20Eh, each team's +10h as a percentage of +0 as "%d.%d"
	mov	eax,0x20E
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	esi,word [teamstats-obj4_base]
	movsx	ebx,word [teamstats+0x10-obj4_base]
	test	esi,esi
	jng	.3
	imul	eax,ebx,dword 0x3E8		; +10h * 1000 / +0, then the tenths
	cdq
	idiv	esi
	mov	ecx,0xA
	cdq
	idiv	ecx
	imul	eax,ebx,0x64
	push	edx
	cdq
	idiv	esi
	push	eax
	push	strict dword str_fmtdotd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	call	sub_ADC18
	add	esp,0x10
	jmp	.4
.3:									; no +0 yet: "0.0"
	mov	eax,[str_zero-obj4_base]
	mov	[ebp-0x20],eax
.4:									; first team done
	mov	edx,4
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	esi,word [teamstats+teamstats_size-obj4_base]
	movsx	ebx,word [teamstats+teamstats_size+0x10-obj4_base]
	test	esi,esi
	jng	.5
	imul	eax,ebx,dword 0x3E8
	cdq
	idiv	esi
	mov	ecx,0xA
	cdq
	idiv	ecx
	imul	eax,ebx,0x64
	push	edx
	cdq
	idiv	esi
	push	eax
	push	strict dword str_fmtdotd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	call	sub_ADC18
	add	esp,0x10
	jmp	.6
.5:									; no +0 yet: "0.0"
	mov	eax,[str_zero-obj4_base]
	mov	[ebp-0x20],eax
.6:									; second team done
	mov	edx,4
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
.7:									; row 20Fh, while statsfirstrow < 4
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,4
	jnl	.8
	mov	edx,5
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	lea	ebx,[eax+1]
									; row: text 20Fh, each team's +1Ah and +1Ch as "%d/%d"
	mov	eax,0x20F
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x1A-obj4_base]
	push	eax
	movsx	eax,word [teamstats+0x1C-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,5
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam1x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x1A-obj4_base]
	push	eax
	movsx	eax,word [teamstats+teamstats_size+0x1C-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,5
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam2x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
.8:									; row 210h, while statsfirstrow < 5
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,5
	jnl	.9
	mov	edx,6
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statslabelx-obj4_base]
	sub	ebx,eax
									; row: text 210h, each team's +1Eh and +20h as "%d/%d"
	mov	eax,0x210
	inc	ebx
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x1E-obj4_base]
	push	eax
	movsx	eax,word [teamstats+0x20-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,6
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam1x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x1E-obj4_base]
	push	eax
	movsx	eax,word [teamstats+teamstats_size+0x20-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,6
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0x10
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam2x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
.9:									; row 211h, while statsfirstrow < 6
	cmp	word [statsfirstrow-obj4_base],0
	jng	.10
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,6
	jnl	.10
	mov	edx,7
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	lea	ebx,[eax+1]
									; row: text 211h, each team's +2 and +4 as "%d/%d"
	mov	eax,0x211
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+4-obj4_base]
	push	eax
	movsx	eax,word [teamstats+2-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,7
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam1x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+4-obj4_base]
	push	eax
	movsx	eax,word [teamstats+teamstats_size+2-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,7
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0x10
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam2x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
.10:								; row 212h, while statsfirstrow < 7
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,1
	jng	.11
	cmp	eax,7
	jnl	.11
	mov	ebx,8
	sub	ebx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit ebx*2+statsrowtop_off]
	movsx	edx,word [statslabelx-obj4_base]
	sub	ebx,eax
									; row: text 212h, each team's +8, in seconds as "%d:%02d"
	mov	eax,0x212
	inc	ebx
	call	sub_77355
	call	sub_640D3
	movsx	esi,word [teamstats+8-obj4_base]
	mov	eax,esi
	mov	ebx,0x3C
	cdq
	idiv	ebx
	mov	eax,esi
	push	edx
	cdq
	idiv	ebx
	push	eax
	push	strict dword str_fmttime-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,8
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0x10
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	esi,word [teamstats+teamstats_size+8-obj4_base]
	mov	eax,esi
	mov	ebx,0x3C
	cdq
	idiv	ebx
	mov	eax,esi
	push	edx
	cdq
	idiv	ebx
	push	eax
	push	strict dword str_fmttime-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,8
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0x10
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam2x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
.11:								; row 213h
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,2
	jng	.12
	cmp	eax,8
	jnl	.12
	mov	edx,9
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
									; row: text 213h, each team's +6 as "%d"
	mov	eax,0x213
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+6-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,9
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0xC
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam1x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+6-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,9
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
.12:								; row 214h
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,3
	jng	.13
	cmp	eax,9
	jnl	.13
	mov	edx,0xA
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statslabelx-obj4_base]
	sub	ebx,eax
									; row: text 214h, each team's +0Ah and +0Ch as "%d/%d"
	mov	eax,0x214
	inc	ebx
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0xC-obj4_base]
	push	eax
	movsx	eax,word [teamstats+0xA-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xA
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam1x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0xC-obj4_base]
	push	eax
	movsx	eax,word [teamstats+teamstats_size+0xA-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xA
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam2x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
.13:								; row 215h
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,4
	jng	.14
	cmp	eax,0xA
	jnl	.14
	mov	edx,0xB
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	lea	ebx,[eax+1]
									; row: text 215h, each team's +12h as "%d"
	mov	eax,0x215
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x12-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xB
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x12-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xB
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
.14:								; row 216h; rows 217h-21Ah only past row 6
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,5
	jng	.19
	mov	edx,0xC
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
									; row: text 216h, each team's +22h and +24h as "%d/%d"
	mov	eax,0x216
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x22-obj4_base]
	push	eax
	movsx	eax,word [teamstats+0x24-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xC
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0x10
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x22-obj4_base]
	push	eax
	movsx	eax,word [teamstats+teamstats_size+0x24-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xC
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0x10
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam2x-obj4_base]
	call	sub_640D3
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,6
	jng	.19
	mov	edx,0xD
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
									; row: text 217h, each team's +14h as "%d/%d"
	mov	eax,0x217
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x14-obj4_base]
	movsx	esi,word [teamstats+teamstats_size+0x14-obj4_base]
	add	esi,eax
	push	esi
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xD
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0x10
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	push	esi
	movsx	eax,word [teamstats+teamstats_size+0x14-obj4_base]
	push	eax
	push	strict dword str_fmtslash-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xD
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0x10
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam2x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,7
	jng	.19
	mov	edx,0xE
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statslabelx-obj4_base]
	sub	ebx,eax
									; row: text 218h, each team's +26h as "%d"
	mov	eax,0x218
	inc	ebx
	call	sub_77355
	call	sub_640D3
	movsx	eax,word [teamstats+0x26-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xE
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	add	esp,0xC
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	eax,word [teamstats+teamstats_size+0x26-obj4_base]
	push	eax
	push	strict dword str_fmtd-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xE
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	add	esp,0xC
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	ebx,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsteam2x-obj4_base]
	sub	ebx,eax
	lea	eax,[ebp-0x20]
	inc	ebx
	call	sub_640D3
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,8
	jng	.19
	mov	edx,0xF
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	lea	ebx,[eax+1]
									; row: text 219h, each team's +0Eh, in seconds as "%d:%02d"
	mov	eax,0x219
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	esi,word [teamstats+0xE-obj4_base]
	mov	eax,esi
	mov	ebx,0x3C
	cdq
	idiv	ebx
	mov	eax,esi
	push	edx
	cdq
	idiv	ebx
	push	eax
	push	strict dword str_fmttime-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xF
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam1x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	esi,word [teamstats+teamstats_size+0xE-obj4_base]
	mov	eax,esi
	mov	ebx,0x3C
	cdq
	idiv	ebx
	mov	eax,esi
	push	edx
	cdq
	idiv	ebx
	push	eax
	push	strict dword str_fmttime-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	mov	edx,0xF
	call	sub_ADC18
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	ebx,word [statsrowtop+4-obj4_base]
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	sub	eax,ebx
	add	esp,0x10
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam2x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
	movsx	eax,word [statsfirstrow-obj4_base]
	cmp	eax,0xA
	jnz	.19
	mov	edx,0x10
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
									; row: text 21Ah, each team's +28h and +2Ah as "%d/%d (%d%%)"
	mov	eax,0x21A
	movsx	edx,word [statslabelx-obj4_base]
	call	sub_77355
	call	sub_640D3
	movsx	esi,word [teamstats+0x28-obj4_base]
	movsx	ebx,word [teamstats+0x2A-obj4_base]
	test	esi,esi
	jng	.15
	imul	eax,ebx,0x64
	cdq
	idiv	esi
	push	eax
	jmp	.16
.15:								; first team: no +28h yet, 0 percent
	push	0
.16:								; eax the percentage
	push	esi
	push	ebx
	push	strict dword str_fmtpct-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	call	sub_ADC18
	add	esp,0x14
	mov	edx,0x10
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [statsrowtop+4-obj4_base]
	movsx	edx,word [nosplit edx*2+statsrowtop_off]
	sub	edx,eax
	lea	ebx,[edx+1]
	lea	eax,[ebp-0x20]
	movsx	edx,word [statsteam1x-obj4_base]
	call	sub_640D3
	movsx	esi,word [teamstats+teamstats_size+0x28-obj4_base]
	movsx	ebx,word [teamstats+teamstats_size+0x2A-obj4_base]
	test	esi,esi
	jng	.17
	imul	eax,ebx,0x64
	cdq
	idiv	esi
	push	eax
	jmp	.18
.17:								; second team: no +28h yet
	push	0
.18:								; eax the percentage
	push	esi
	push	ebx
	push	strict dword str_fmtpct-obj4_base
	lea	eax,[ebp-0x20]
	push	eax
	call	sub_ADC18
	add	esp,0x14
	mov	edx,0x10
	movsx	eax,word [statsfirstrow-obj4_base]
	sub	edx,eax
	movsx	eax,word [nosplit edx*2+statsrowtop_off]
	movsx	edx,word [statsrowtop+4-obj4_base]
	sub	eax,edx
	lea	ebx,[eax+1]
	movsx	edx,word [statsteam2x-obj4_base]
	lea	eax,[ebp-0x20]
	call	sub_640D3
.19:								; rows done
	call	sub_DD6C4
	movsx	eax,word [statsrowtop+4-obj4_base]
	dec	eax
	push	eax
	push	0
	push	dword [edi+0x2C]
	call	sub_AAB40
	add	esp,0xC
	push	edi
	call	sub_ADBEC
	add	esp,4
	leave
.tail:								; shared tail: GameStatsScreen ends here too
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	ret
