;	Segment build for obj1/obj1_03000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py obj1_03000).
%include "inc/le_objects.inc"
%include "inc/input.inc"
	bits	32
	org	0x13146
; Outside addresses, read from the retail EXE. Equates only (the full build has the labels).
ShowWaitSprite	equ	0x12E50
HideWaitSprite	equ	0x12F33
LinkTimedOut	equ	0x12F77
LinkSync	equ	0x12FB3
SetLinkPollFn	equ	0x1802B
sub_1803B	equ	0x1803B
SetLinkRecvFn	equ	0x1804B
sub_18234	equ	0x18234
sub_186DC	equ	0x186DC
LinkSendPacket	equ	0x1891A
sub_1AA27	equ	0x1AA27
sub_1AA62	equ	0x1AA62
sub_63B0C	equ	0x63B0C
sub_63F79	equ	0x63F79
sub_63FEF	equ	0x63FEF
sub_640D3	equ	0x640D3
sub_641D4	equ	0x641D4
sub_69A9B	equ	0x69A9B
sub_77355	equ	0x77355
sub_AA664	equ	0xAA664
sub_AA988	equ	0xAA988
sub_AADA4	equ	0xAADA4
sub_AB758	equ	0xAB758
sub_ABF4C	equ	0xABF4C
sub_AC9F0	equ	0xAC9F0
sub_AD35C	equ	0xAD35C
sub_AD620	equ	0xAD620
sub_AD680	equ	0xAD680
sub_ADA80	equ	0xADA80
sub_ADBB4	equ	0xADBB4
sub_ADBEC	equ	0xADBEC
sub_DD6C4	equ	0xDD6C4
sub_DD6E0	equ	0xDD6E0
sub_DD708	equ	0xDD708
sub_DD724	equ	0xDD724
sub_DD760	equ	0xDD760
KeyDown	equ	0xDFE9C
GetTicks	equ	0xDFEB4
GetKey	equ	0xDFF28
str_ABORT	equ	0x11001B
str_X	equ	0x110023
str_SHAD	equ	0x110025
str_PAL	equ	0x11002A
byte_114B8C	equ	0x114B8C
dword_114B9C	equ	0x114B9C
inputqhead	equ	0x114BA0
inputqcount	equ	0x114BA4
linkgame	equ	0x114CE0
linkside	equ	0x114CE4
linkstate	equ	0x114D96
linkmyctlqcount	equ	0x114D9A
linkdeadline	equ	0x114DA2
linksyncid	equ	0x114DA6
linkpadsready	equ	0x114DAA
word_114DC0	equ	0x114DC0
dword_114DCA	equ	0x114DCA
dword_114F08	equ	0x114F08
dword_115008	equ	0x115008
mousewidth	equ	0x11F5C0
mouseheight	equ	0x11F5C4
byte_11FA2F	equ	0x11FA2F
ctlrecs	equ	0x1515B4
inputq	equ	0x1515D4
dword_15199C	equ	0x15199C
chatbuf	equ	0x1519A0
linkchatq	equ	0x1519C0
linkmyctlqhead	equ	0x1519FC
linkmyctlqtail	equ	0x151A00
linkchatqhead	equ	0x151A40
linkmyctlq	equ	0x151A44
linkchatqtail	equ	0x151A84
linkctlqhead	equ	0x151A88
linkctlqtail	equ	0x151A90
linkctlq	equ	0x151A94
chathead	equ	0x151AE0
chattail	equ	0x151AE2
byte_17BDAE	equ	0x17BDAE
dword_17C9A8	equ	0x17C9A8
%include "obj1/obj1_03000.asm"
