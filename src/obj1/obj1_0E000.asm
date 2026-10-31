; Object 1 page 0E000: not yet disassembled.
	incbin	"Extracted/segments/obj1_0E000.bin", 0, 0x643
sub_1E643:							; ThreeStarsScreen calls it with -8 after the cards
	incbin	"Extracted/segments/obj1_0E000.bin", 0x643, 0x1B3
sub_1E7F6:							; (number): the end-of-game screens call it before each shape bank
	incbin	"Extracted/segments/obj1_0E000.bin", 0x7F6
