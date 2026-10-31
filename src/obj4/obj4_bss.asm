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
inputq:								; input queue: five 18-byte entries, four pad dwords and a word each
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
linkblockbuf:						; modem game: the block being sent or received
	resb	0x200
dword_15199C:						; cleared when LinkChat starts
	resd	1
chatbuf:							; LinkChat: ring of 20 typed characters waiting to be sent
	resb	20
linkpkt5:							; LinkRecvSync: the packet
	resd	1
linkpkt3:							; LinkRecvBlockStart: the packet
	resd	1
linkpkt4:							; LinkRecvBlockData: the packet
	resd	1
linkchatq:							; ring of ten 6-byte chat packets (type 6) from the other machine
	resb	10 * 6
linkmyctlqhead:						; cleared with the link queues
	resd	1
linkmyctlqtail:						; cleared with the link queues
	resd	1
linkpadq:							; ring of ten 6-byte pad packets (type 1) from the other machine
	resb	10 * 6
linkchatqhead:						; linkchatq: next entry written
	resd	1
linkmyctlq:							; ring of ten 6-byte packets: our controller pads, sent and waiting
	resb	10 * 6
linkpadqhead:						; linkpadq: next entry written
	resd	1
linkchatqtail:						; linkchatq: next entry read
	resd	1
linkctlqhead:						; linkctlq: next entry written
	resd	1
linkpadqtail:						; linkpadq: next entry read
	resd	1
linkctlqtail:						; linkctlq: next entry read
	resd	1
linkctlq:							; ring of ten 6-byte packets: the other machine's controller pads (type 2)
	resb	10 * 6
waitsprite:							; the wait sprite while it is shown, else 0
	resd	1
linkhdrpkt:							; LinkSendBlock: type 3 packet (the block length)
	resb	6
linkdatapkt:						; LinkSendBlock: type 4 packet (length byte, up to 4 bytes)
	resb	6
chathead:							; LinkChat: chatbuf entry written next (word)
	resw	1
chattail:							; LinkChat: chatbuf entry sent next (word)
	resw	1
unk_151AE4:							; ThreeStarsTick: the sparkle's x
	resd	1
unk_151AE8:							; ThreeStarsTick: the sparkle's y
	resd	1
unk_151AEC:							; ThreeStarsScreen: star shapes, ThreeStarsTick shows them 8 a row
	resb	0x1C
unk_151B08:							; ThreeStarsScreen: sprites, a dword per star
	resb	0x44
unk_151B4C:							; ThreeStarsScreen: a bitmap (sprite at +2Ch); shapes follow it
	resd	1
unk_151B50:							; shapes ThreeStarsTick indexes by its streak step
	resb	0x14
unk_151B64:							; ThreeStarsTick: the sparkle sprite
	resd	1
unk_151B68:							; ThreeStarsTick: the streak sprite, or 0
	resd	1
unk_151B6C:							; ThreeStarsScreen: the STRK shape
	resd	1
unk_151B70:							; ThreeStarsScreen: a sprite made from STRK
	resd	1
unk_151B74:							; ThreeStarsTick: sparkle shape of step 4
	resd	1
unk_151B78:							; ThreeStarsTick: sparkle shape of steps 3 and 5
	resd	1
unk_151B7C:							; ThreeStarsTick: sparkle shape of steps 2 and 6
	resd	1
	resb	0xD9C
linkpollfn:							; routine LinkSync calls while it waits (SetLinkPollFn), or 0
	resd	1
	resb	0x638
unk_152F58:							; GameStatsScreen: a shape bank
	resd	1
	resb	0x4257
unk_1571B3:							; ThreeStarsScreen: player records, 4B4h a team and 2Bh a player
	resb	1
	resb	0xE524
teamstats:							; the two teams' game stats, teamstats_size bytes each (DrawTeamStats)
	resb	2 * teamstats_size
	resb	0x11274
startm:								; the three stars: team of star n (word, every 4 bytes; 3 entries)
	resw	1
starpl:								; the three stars: player of star n (word, every 4 bytes)
	resw	1
	resb	8
	resb	0x50B0
unk_17BC74:							; ThreeStarsScreen: given to the routine after the background
	resd	1
unk_17BC78:							; given to the same routine after the chat and at the end
	resd	1
	resb	0x66
unk_17BCE2:							; the Chat button (66h bytes, copied into the menus)
	resb	0x66
unk_17BD48:							; the Done button (66h bytes, copied into the menus)
	resb	0x66
byte_17BDAE:						; a screen buffer given to the link messages
	resb	0xBF2
dword_17C9A0:						; game setup: pointer to the controller devices and teams
	resd	1
	resb	4
dword_17C9A8:						; game setup: bits 7-8 are exchanged when a modem game connects
	resd	1
word_17C9AC:						; game setup word (LinkOpen)
	resw	1
word_17C9AE:						; game setup word (LinkOpen)
	resw	1
word_17C9B0:						; game setup word: nonzero skips LinkOpen's first message
	resw	1
	resw	1
word_17C9B4:						; game setup word (LinkOpen)
	resw	1
	resw	1
byte_17C9B8:						; game setup string (LinkOpen)
	resb	0x14
byte_17C9CC:						; game setup string (LinkOpen)
	resb	0x28
byte_17C9F4:						; game setup string (LinkOpen)
	resb	0x2D
byte_17CA21:						; bit 7 picks keybindtab1 instead of keybindtab0
	resb	1
byte_17CA22:						; bit 0 swaps the two mouse buttons
	resb	1
	resb	0x3A
byte_17CA5D:						; bit 5: the mouse area is 640 by 480, else 320 by 200
	resb	1
	resb	0x17
byte_17CA75:						; B9h bytes the calling machine sends when connecting
	resb	0x7FD
byte_17D272:						; where those B9h bytes are sent from and received into
	resb	0xB9
	resb	0x4DC6
unk_1820F1:							; ThreeStarsMenu clears it before the second choice
	resb	1
