; Object 4 page 0F000: not yet disassembled.
	incbin	"Extracted/segments/obj4_0F000.bin", 0, 0x5A8
mousex:								; mouse x
	incbin	"Extracted/segments/obj4_0F000.bin", 0x5A8, 0x4
mousey:								; mouse y
	incbin	"Extracted/segments/obj4_0F000.bin", 0x5AC, 0x14
mousewidth:							; width of the mouse area
	incbin	"Extracted/segments/obj4_0F000.bin", 0x5C0, 0x4
mouseheight:						; height of the mouse area
	incbin	"Extracted/segments/obj4_0F000.bin", 0x5C4, 0x3C
mousepollfn:						; reads the mouse: updates mousex, mousey and returns the buttons
	incbin	"Extracted/segments/obj4_0F000.bin", 0x600, 0x310
joy1x:								; joystick 1 x, from ReadJoyPort
	incbin	"Extracted/segments/obj4_0F000.bin", 0x910, 0x4
joy1y:								; joystick 1 y
	incbin	"Extracted/segments/obj4_0F000.bin", 0x914, 0x4
joy2x:								; joystick 2 x
	incbin	"Extracted/segments/obj4_0F000.bin", 0x918, 0x4
joy2y:								; joystick 2 y
	incbin	"Extracted/segments/obj4_0F000.bin", 0x91C, 0x8
joyaxes:							; bits 0-3: the joystick axes that answer
	incbin	"Extracted/segments/obj4_0F000.bin", 0x924, 0x10B
byte_11FA2F:						; LinkChat: the line spacing comes from it
	incbin	"Extracted/segments/obj4_0F000.bin", 0xA2F
