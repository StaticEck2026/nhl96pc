;	Segment build for obj1/obj1_01000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py obj1_01000).
%include "inc/le_objects.inc"
%include "inc/input.inc"
	bits	32
	org	0x11107
; Outside addresses, read from the retail EXE. Equates only (the full build has the labels).
GrLink	equ	0x10D66
_searchenv_	equ	0xA9BCC
strcpy_	equ	0xA9CB3
strcat_	equ	0xA9CD2
fopen_	equ	0xA9EA0
fseek_	equ	0xA9F78
ftell_	equ	0xAA074
fclose_	equ	0xAA0A4
_nmalloc_	equ	0xAA1E6
fread_	equ	0xAA2C9
_nfree_	equ	0xAA493
ReadJoyPort	equ	0xE0051
EnableJoysticks	equ	0xE0456
str_PATH	equ	0x110004
str_rb	equ	0x110009
joy1calib	equ	0x114CB0
joy2calib	equ	0x114CB4
str_GRIPGLL	equ	0x114CB8
str_GRIP	equ	0x114CC1
str_CGRIP	equ	0x114CC6
grlinked	equ	0x114CCF
grslotcount	equ	0x114CD3
grslotmask	equ	0x114CD7
grpadbuf	equ	0x114CDB
joy1x	equ	0x11F910
joy1y	equ	0x11F914
joy2x	equ	0x11F918
joy2y	equ	0x11F91C
joyaxes	equ	0x11F924
grpads	equ	0x151630
graxismax	equ	0x151638
unk_151648	equ	0x151648
joybtnmask1	equ	0x151698
joybtnmask2	equ	0x1516A8
unk_1516B8	equ	0x1516B8
joyslots	equ	0x151708
word_151768	equ	0x151768
grslotmap	equ	0x151770
grbuttons	equ	0x151774
joyrawbits	equ	0x151778
grentry	equ	0x151784
grdossel	equ	0x15178A
grcodesel	equ	0x15178C
grbtnbits	equ	0x15178E
graxis	equ	0x151792
grpadbits	equ	0x151794
grslot	equ	0x151798
%include "obj1/obj1_01000.asm"
