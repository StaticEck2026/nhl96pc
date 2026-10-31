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
	resb	2
grpads:								; GrIP pads, two dwords written in turn (grpadbuf): a byte per slot
	resd	2
graxismax:							; GrIP: largest x and y (words) of each slot's stick
	resd	js_count
unk_151648:							; GrIP: 16 bytes per slot (20 apart) from library function 84D1h
	resb	20 * js_count
joybtnmask1:						; per joystick slot: the stick buttons that give pad button 1
	resd	js_count
joybtnmask2:						; per joystick slot: the stick buttons that give pad button 2
	resd	js_count
unk_1516B8:							; GrIP: 16 bytes per slot (20 apart) from library function 84D0h
	resb	20 * js_count
joyslots:							; the four joystick slots: range, position and buttons (js_ fields)
	resb	js_count * js_size
word_151768:						; GrIP: a word per slot returned by library function 84D1h
	resw	js_count
grslotmap:							; GrIP: the slot map (function 84B0h), bit n for slot n
	resd	1
grbuttons:							; GrIP: number of buttons of each slot, a byte each
	resb	js_count
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
grbtnbits:							; ReadGripPads: the slot's button bits
	resd	1
graxis:								; ReadGripPads: one axis, scaled to 0-2
	resw	1
grpadbits:							; ReadGripPads: the slot's pad byte being built
	resd	1
grslot:								; ReadGripPads: the slot being read
	resd	1
	resb	0x2B204
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
