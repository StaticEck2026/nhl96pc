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
	incbin	"Extracted/segments/obj4_0F000.bin", 0x600
