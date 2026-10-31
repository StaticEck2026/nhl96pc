; Object 1 page 53000: not yet disassembled.
	incbin	"Extracted/segments/obj1_53000.bin", 0, 0xB0C
sub_63B0C:							; (shape, 0): makes a sprite, returns it
	incbin	"Extracted/segments/obj1_53000.bin", 0xB0C, 0x46D
sub_63F79:							; LinkChat calls it first, with two of its arguments
	incbin	"Extracted/segments/obj1_53000.bin", 0xF79, 0x76
sub_63FEF:							; LinkChat calls it for each character
	incbin	"Extracted/segments/obj1_53000.bin", 0xFEF
