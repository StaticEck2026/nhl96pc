;	Segment build for obj1/obj1_04000.asm: sets its origin and the outside labels it uses, then includes the file on its own
;	for checking against the EXE (tools/verify_segment.py obj1_04000).
%include "inc/le_objects.inc"
%include "inc/input.inc"
	bits	32
	org	0x144BD
; Outside addresses, read from the retail EXE. Equates only (the full build has the labels).
sub_63F79	equ	0x63F79
sub_640D3	equ	0x640D3
sub_77355	equ	0x77355
sub_AAB40	equ	0xAAB40
sub_AD35C	equ	0xAD35C
sub_ADBEC	equ	0xADBEC
sub_ADC18	equ	0xADC18
sub_DD6C4	equ	0xDD6C4
sub_DD708	equ	0xDD708
str_fmtd	equ	0x110030
str_fmtdotd	equ	0x110033
str_zero	equ	0x110039
str_fmtslash	equ	0x11003D
str_fmttime	equ	0x110043
str_fmtpct	equ	0x11004B
statslabelx	equ	0x114DD2
statsteam1x	equ	0x114DD4
statsteam2x	equ	0x114DD6
statsrowtop	equ	0x114DD8
statsfirstrow	equ	0x114DE6
teamstats	equ	0x1656D8
%include "obj1/obj1_04000.asm"
