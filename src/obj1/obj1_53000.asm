; Object 1 page 53000: not yet disassembled.
	incbin	"Extracted/segments/obj1_53000.bin", 0, 0x968
sub_63968:							; called after the banner is drawn
	incbin	"Extracted/segments/obj1_53000.bin", 0x968, 0x30
sub_63998:							; called before the menu loops
	incbin	"Extracted/segments/obj1_53000.bin", 0x998, 0xC3
sub_63A5B:							; (3): called when the end-of-game screens close
	incbin	"Extracted/segments/obj1_53000.bin", 0xA5B, 0xB1
sub_63B0C:							; (shape, 0): makes a sprite, returns it
	incbin	"Extracted/segments/obj1_53000.bin", 0xB0C, 0x46D
sub_63F79:							; LinkChat calls it first, with two of its arguments
	incbin	"Extracted/segments/obj1_53000.bin", 0xF79, 0x76
sub_63FEF:							; LinkChat calls it for each character
	incbin	"Extracted/segments/obj1_53000.bin", 0xFEF
