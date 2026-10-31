; Records of the controller code (equates only, no bytes): the four controllers in ctlrecs and the four
; joystick slots in joyslots.
ctl_type	equ	0						; byte: 1 read here, 2 the other machine's (modem game), 0 none
ctl_device	equ	1					; word: 1 none, 2 mouse, 4/8/10h/20h joystick slot 0-3, 40h keyboard
ctl_pad		equ	3					; dword: the pad read last
ctl_size	equ	7					; size of a ctlrecs entry
ctl_count	equ	4					; number of controllers
;
js_minx		equ	4					; word: smallest x seen
js_miny		equ	6					; word: smallest y seen
js_maxx		equ	8					; word: largest x seen
js_maxy		equ	0xA					; word: largest y seen
js_flags	equ	0xC					; word: nonzero when the slot has a pad; bits 1-4 set as the stick is
									; pushed left, right, up, down past the dead zone
js_x		equ	0xE					; word: x now
js_y		equ	0x10				; word: y now
js_cx		equ	0x12				; word: x at rest (the first sample)
js_cy		equ	0x14				; word: y at rest
js_buttons	equ	0x16				; word: buttons 1 and 2 in bits 0-1, set while down
js_size		equ	0x18				; size of a joyslots entry
js_count	equ	4					; number of joystick slots
