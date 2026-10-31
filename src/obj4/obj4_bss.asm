; Object 4 after its last file page: memory the loader gives the program cleared (BSS), up to the stack top.
; It has no bytes in the EXE, so this file only places labels: each variable converted code uses, at its
; place, with the gaps still unknown as plain reserved space.
obj4_bss:							; end of object 4's file pages
	absolute	obj4_bss
	resb	1
joytapdir:							; joystick double tap: last direction, one dword per joystick slot
	resd	4
curpad:								; the pad being read (ReadControllerPads)
	resd	1
	resb	4
kbdtapdir:							; keyboard double tap: last direction held
	resd	1
ctlrecs:							; the four controllers: type, device and last pad of each (ctl_ fields)
	resb	4 * ctl_size
keybindings:						; the key binding table in use: keybindtab0 or keybindtab1
	resd	1
byte_1515D4:						; input queue, cleared by SetupControllers and FlushControllerInput
	resb	0x5A
	resb	0xE6
word_151714:						; joystick slot 0: read before the joysticks are sampled
	resw	1
	resb	0x16
word_15172C:						; joystick slot 1: the same
	resw	1
	resb	0x16
word_151744:						; joystick slot 2: the same
	resw	1
	resb	0x16
word_15175C:						; joystick slot 3: the same
	resw	1
	resb	0x1A
joyrawbits:							; joystick bits sampled by ReadJoysticks, one byte per slot
	resd	1
grlinkhdr:							; GrIP: the 14-byte entry header copied from the library image
	resb	8
grentry:							; GrIP: far pointer (offset, selector) to the library's entry point
	resd	1
	resw	1
grdossel:							; GrIP: selector of the DOS memory block the library is copied to
	resw	1
grcodesel:							; GrIP: code selector made for that block
	resw	1
	resb	0x2B212
dword_17C9A0:						; pointer to the game setup: controller devices and teams
	resd	1
	resb	0x7D
byte_17CA21:						; bit 7 picks keybindtab1 instead of keybindtab0
	resb	1
byte_17CA22:						; bit 0 swaps the two mouse buttons
	resb	1
	resb	0x3A
byte_17CA5D:						; bit 5: the mouse area is 640 by 480, else 320 by 200
	resb	1
