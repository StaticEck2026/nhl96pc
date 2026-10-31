; Object 1 page CF000: not yet disassembled.
	incbin	"Extracted/segments/obj1_CF000.bin", 0, 0x928
MouseSetPos:						; (x, y on the stack): sets the mouse position
	incbin	"Extracted/segments/obj1_CF000.bin", 0x928, 0x67
MouseSetRange:						; (xmin, ymin, xmax, ymax on the stack): the area the mouse moves in
	incbin	"Extracted/segments/obj1_CF000.bin", 0x98F, 0x109
MouseInit:							; sets the mouse up; returns 0 when there is no mouse
	incbin	"Extracted/segments/obj1_CF000.bin", 0xA98, 0x404
KeyDown:							; (scan code on the stack): nonzero while that key is held down
	incbin	"Extracted/segments/obj1_CF000.bin", 0xE9C, 0x18
GetTicks:							; returns the timer tick count
	incbin	"Extracted/segments/obj1_CF000.bin", 0xEB4, 0x74
GetKey:								; takes the next key from the keyboard buffer; 0 when it is empty
	incbin	"Extracted/segments/obj1_CF000.bin", 0xF28
