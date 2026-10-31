; Object 4 page 04000: not yet disassembled.
	incbin	"Extracted/segments/obj4_04000.bin", 0, 0xB40
joyslotmask:						; word: bit n set when joystick slot n has a pad (DetectJoysticks)
	incbin	"Extracted/segments/obj4_04000.bin", 0xB40, 0x2
mousepresent:						; word: 1 when MouseInit found a mouse
	incbin	"Extracted/segments/obj4_04000.bin", 0xB42, 0x2
mousechecked:						; word: 1 once DetectControllers has looked for the mouse
	incbin	"Extracted/segments/obj4_04000.bin", 0xB44, 0x4
ctlavailmask:						; controllers available: bit 0 the mouse, bits 1-4 joystick slots 0-3
	incbin	"Extracted/segments/obj4_04000.bin", 0xB48, 0x14
homekeytime:						; home team's extra keys (0Ch-0Fh, 14h): not read again before this tick
	incbin	"Extracted/segments/obj4_04000.bin", 0xB5C, 0x4
awaykeytime:						; the away team's extra keys (bindings 10h-13h, 15h): the same
	incbin	"Extracted/segments/obj4_04000.bin", 0xB60, 0x4
kbdtaptime:							; keyboard double tap: a second press before this tick counts
	incbin	"Extracted/segments/obj4_04000.bin", 0xB64, 0x4
joytaptime:							; joystick double tap: the same, one dword per joystick slot
	incbin	"Extracted/segments/obj4_04000.bin", 0xB68, 0x10
kbdtapstate:						; keyboard double tap: 1 while a direction is held, 0 after it is let go
	incbin	"Extracted/segments/obj4_04000.bin", 0xB78, 0x4
joytapstate:						; joystick double tap: the same, one dword per joystick slot
	incbin	"Extracted/segments/obj4_04000.bin", 0xB7C, 0x10
byte_114B8C:						; 16 bytes cleared by SetupControllers and FlushControllerInput
	incbin	"Extracted/segments/obj4_04000.bin", 0xB8C, 0x10
dword_114B9C:						; cleared with the input queue
	incbin	"Extracted/segments/obj4_04000.bin", 0xB9C, 0x4
dword_114BA0:						; cleared with the input queue
	incbin	"Extracted/segments/obj4_04000.bin", 0xBA0, 0x4
dword_114BA4:						; cleared with the input queue
	incbin	"Extracted/segments/obj4_04000.bin", 0xBA4, 0x4
keybindtab0:						; key bindings: 4 bytes each (Ctrl needed, Alt needed, scan code word)
	incbin	"Extracted/segments/obj4_04000.bin", 0xBA8, 0x58
keybindtab1:						; the other key binding table
	incbin	"Extracted/segments/obj4_04000.bin", 0xC00, 0x58
dirmaptab:							; pad direction map: rows of 11 directions, the row picked by a value 0-7
	incbin	"Extracted/segments/obj4_04000.bin", 0xC58, 0x58
joy1calib:							; 1: take joystick 1's centre and range from its next sample
	incbin	"Extracted/segments/obj4_04000.bin", 0xCB0, 0x4
joy2calib:							; the same for joystick 2
	incbin	"Extracted/segments/obj4_04000.bin", 0xCB4, 0x4
str_GRIPGLL:						; "GRIP.GLL"
	incbin	"Extracted/segments/obj4_04000.bin", 0xCB8, 0x9
str_GRIP:							; "GRIP"
	incbin	"Extracted/segments/obj4_04000.bin", 0xCC1, 0x5
str_CGRIP:							; "C:\GRIP\"
	incbin	"Extracted/segments/obj4_04000.bin", 0xCC6, 0x9
grlinked:							; 1 while the GrIP library is linked (GrLink)
	incbin	"Extracted/segments/obj4_04000.bin", 0xCCF, 0x4
grslotcount:						; GrIP slots found; -1 until the library is loaded
	incbin	"Extracted/segments/obj4_04000.bin", 0xCD3, 0x4
grslotmask:							; bit n: GrIP slot n+1 has buttons and two axes
	incbin	"Extracted/segments/obj4_04000.bin", 0xCD7, 0x4
grpadbuf:							; word, 0 or 1: the grpads dword written last
	incbin	"Extracted/segments/obj4_04000.bin", 0xCDB, 0x5
word_114CE0:						; bit 0: two controllers are not read here (probably a link game)
	incbin	"Extracted/segments/obj4_04000.bin", 0xCE0, 0x4
word_114CE4:						; 1: controllers 2 and 3 are the ones not read here, else 0 and 1
	incbin	"Extracted/segments/obj4_04000.bin", 0xCE4, 0x224
dword_114F08:						; kept by FlushControllerInput, cleared by SetupControllers
	incbin	"Extracted/segments/obj4_04000.bin", 0xF08
