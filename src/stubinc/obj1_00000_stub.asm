;	Segment build for obj1/obj1_00000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py obj1_00000).
%include "inc/le_objects.inc"
%include "inc/input.inc"
	bits	32
	org	0x10000
; Outside addresses, read from the retail EXE. Equates only (the full build has the labels).
ReadJoysticks	equ	0x11A88
DetectJoysticks	equ	0x1218A
LinkFlushInput	equ	0x13338
sub_619E2	equ	0x619E2
MouseSetPos	equ	0xDF928
MouseSetRange	equ	0xDF98F
MouseInit	equ	0xDFA98
KeyDown	equ	0xDFE9C
GetTicks	equ	0xDFEB4
GetKey	equ	0xDFF28
joyslotmask	equ	0x114B40
mousepresent	equ	0x114B42
mousechecked	equ	0x114B44
ctlavailmask	equ	0x114B48
homekeytime	equ	0x114B5C
awaykeytime	equ	0x114B60
kbdtaptime	equ	0x114B64
joytaptime	equ	0x114B68
kbdtapstate	equ	0x114B78
joytapstate	equ	0x114B7C
byte_114B8C	equ	0x114B8C
dword_114B9C	equ	0x114B9C
inputqhead	equ	0x114BA0
inputqcount	equ	0x114BA4
keybindtab0	equ	0x114BA8
keybindtab1	equ	0x114C00
dirmaptab	equ	0x114C58
grlinked	equ	0x114CCF
linkgame	equ	0x114CE0
linkside	equ	0x114CE4
dword_114F08	equ	0x114F08
cont1team	equ	0x1178D2
dword_11D91F	equ	0x11D91F
mousex	equ	0x11F5A8
mousey	equ	0x11F5AC
mousewidth	equ	0x11F5C0
mouseheight	equ	0x11F5C4
mousepollfn	equ	0x11F600
joytapdir	equ	0x151598
curpad	equ	0x1515A8
kbdtapdir	equ	0x1515B0
ctlrecs	equ	0x1515B4
keybindings	equ	0x1515D0
inputq	equ	0x1515D4
joyslots	equ	0x151708
joyrawbits	equ	0x151778
grlinkhdr	equ	0x15177C
grentry	equ	0x151784
grdossel	equ	0x15178A
grcodesel	equ	0x15178C
dword_17C9A0	equ	0x17C9A0
byte_17CA21	equ	0x17CA21
byte_17CA22	equ	0x17CA22
byte_17CA5D	equ	0x17CA5D
%include "obj1/obj1_00000.asm"
