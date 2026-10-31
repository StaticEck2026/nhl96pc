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
inputqhead:							; input queue: next entry written (0-4)
	incbin	"Extracted/segments/obj4_04000.bin", 0xBA0, 0x4
inputqcount:						; input queue: entries in it (up to 5)
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
linkgame:							; bit 0: a modem game is connected (LinkConnect)
	incbin	"Extracted/segments/obj4_04000.bin", 0xCE0, 0x4
linkside:							; modem game: 1 on the calling machine, 0 on the answering one
	incbin	"Extracted/segments/obj4_04000.bin", 0xCE4, 0x2
byte_114CE6:						; LinkOpen: a string from the game setup, given to the port open
	incbin	"Extracted/segments/obj4_04000.bin", 0xCE6, 0x28
dword_114D0E:						; LinkOpen: a word from the game setup
	incbin	"Extracted/segments/obj4_04000.bin", 0xD0E, 0x4
dword_114D12:						; LinkOpen: 9
	incbin	"Extracted/segments/obj4_04000.bin", 0xD12, 0x8
linkcaller:							; nonzero: this machine calls (LinkConnect makes it side 1)
	incbin	"Extracted/segments/obj4_04000.bin", 0xD1A, 0x4
dword_114D1E:						; LinkOpen: 1 or 0 by a game setup word
	incbin	"Extracted/segments/obj4_04000.bin", 0xD1E, 0x18
dword_114D36:						; LinkOpen: from a word table, by a setup word
	incbin	"Extracted/segments/obj4_04000.bin", 0xD36, 0x4
dword_114D3A:						; LinkOpen: a word from the game setup
	incbin	"Extracted/segments/obj4_04000.bin", 0xD3A, 0xC
byte_114D46:						; LinkOpen: a string from the setup
	incbin	"Extracted/segments/obj4_04000.bin", 0xD46, 0x28
byte_114D6E:						; LinkOpen: another string from the setup
	incbin	"Extracted/segments/obj4_04000.bin", 0xD6E, 0x28
linkstate:							; bit 0: the port is open (LinkOpen), bit 1: connected (LinkConnect)
	incbin	"Extracted/segments/obj4_04000.bin", 0xD96, 0x4
linkmyctlqcount:					; linkmyctlq: entries in it
	incbin	"Extracted/segments/obj4_04000.bin", 0xD9A, 0x4
linkpeersync:						; the last sync number from the other machine
	incbin	"Extracted/segments/obj4_04000.bin", 0xD9E, 0x4
linkdeadline:						; LinkSyncWait sets it 6000 ticks ahead; LinkTimedOut compares
	incbin	"Extracted/segments/obj4_04000.bin", 0xDA2, 0x4
linksyncid:							; the last sync number sent
	incbin	"Extracted/segments/obj4_04000.bin", 0xDA6, 0x4
linkpadsready:						; 1 when LinkSendPads may run; it clears it while it runs
	incbin	"Extracted/segments/obj4_04000.bin", 0xDAA, 0x4
linkblocksin:						; blocks received
	incbin	"Extracted/segments/obj4_04000.bin", 0xDAE, 0x4
linkblockswant:						; blocks asked for (LinkRecvBlock)
	incbin	"Extracted/segments/obj4_04000.bin", 0xDB2, 0x4
linkblockleft:						; bytes of the block still to come or go
	incbin	"Extracted/segments/obj4_04000.bin", 0xDB6, 0x4
linkblockptr:						; where the next block bytes go
	incbin	"Extracted/segments/obj4_04000.bin", 0xDBA, 0x4
linksameside:						; word: 1 when a sync came from our own side (both machines on one side)
	incbin	"Extracted/segments/obj4_04000.bin", 0xDBE, 0x2
word_114DC0:						; word cleared before each packet is sent or taken
	incbin	"Extracted/segments/obj4_04000.bin", 0xDC0, 0x2
word_114DC2:						; word table, indexed by a setup word
	incbin	"Extracted/segments/obj4_04000.bin", 0xDC2, 0x8
dword_114DCA:						; four bytes the two machines exchange after connecting
	incbin	"Extracted/segments/obj4_04000.bin", 0xDCA, 0x8
statslabelx:						; DrawTeamStats: x of the stat names
	incbin	"Extracted/segments/obj4_04000.bin", 0xDD2, 0x2
statsteam1x:						; x of the first team's values
	incbin	"Extracted/segments/obj4_04000.bin", 0xDD4, 0x2
statsteam2x:						; x of the second team's values
	incbin	"Extracted/segments/obj4_04000.bin", 0xDD6, 0x2
statsrowtop:						; DrawTeamStats: the row tops, a word per row; entry 2 is the first row's
	incbin	"Extracted/segments/obj4_04000.bin", 0xDD8, 0xC
unk_114DE4:							; GameStatsScreen: added to the panel top
	incbin	"Extracted/segments/obj4_04000.bin", 0xDE4, 0x2
statsfirstrow:						; DrawTeamStats: the first row shown
	incbin	"Extracted/segments/obj4_04000.bin", 0xDE6, 0x2
unk_114DE8:							; ThreeStarsTick: three sparkle areas, 40h apart: x from
	incbin	"Extracted/segments/obj4_04000.bin", 0xDE8, 0x8
unk_114DF0:							; x to
	incbin	"Extracted/segments/obj4_04000.bin", 0xDF0, 0x4
unk_114DF4:							; y from
	incbin	"Extracted/segments/obj4_04000.bin", 0xDF4, 0x8
unk_114DFC:							; y to
	incbin	"Extracted/segments/obj4_04000.bin", 0xDFC, 0xAC
unk_114EA8:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xEA8, 0x4
unk_114EAC:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xEAC, 0x4
unk_114EB0:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xEB0, 0x4
unk_114EB4:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xEB4, 0x1C
unk_114ED0:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xED0, 0x4
unk_114ED4:							; ThreeStarsScreen data
	incbin	"Extracted/segments/obj4_04000.bin", 0xED4, 0x14
unk_114EE8:							; ThreeStarsTick: tick for the next sparkle
	incbin	"Extracted/segments/obj4_04000.bin", 0xEE8, 0x4
unk_114EEC:							; ThreeStarsTick: tick for the third effect
	incbin	"Extracted/segments/obj4_04000.bin", 0xEEC, 0x4
unk_114EF0:							; ThreeStarsTick: tick for the next streak
	incbin	"Extracted/segments/obj4_04000.bin", 0xEF0, 0x4
unk_114EF4:							; ThreeStarsTick: tick for its next pass
	incbin	"Extracted/segments/obj4_04000.bin", 0xEF4, 0x4
unk_114EF8:							; ThreeStarsTick: the sparkle step, 6 down to 0
	incbin	"Extracted/segments/obj4_04000.bin", 0xEF8, 0x2
unk_114EFA:							; ThreeStarsTick: the streak step
	incbin	"Extracted/segments/obj4_04000.bin", 0xEFA, 0x2
unk_114EFC:							; ThreeStarsTick: the third effect's step
	incbin	"Extracted/segments/obj4_04000.bin", 0xEFC, 0x2
unk_114EFE:							; ThreeStarsTick: wait before the next star frame
	incbin	"Extracted/segments/obj4_04000.bin", 0xEFE, 0x2
unk_114F00:							; ThreeStarsTick: the star frame, 0-23
	incbin	"Extracted/segments/obj4_04000.bin", 0xF00, 0x8
dword_114F08:						; kept by FlushControllerInput, cleared by SetupControllers
	incbin	"Extracted/segments/obj4_04000.bin", 0xF08
