; Object 1 page 9D000: not yet disassembled.
	incbin	"Extracted/segments/obj1_9D000.bin", 0, 0x35C
sub_AD35C:							; (width, height, 0 on the stack): returns LinkChat's window
	incbin	"Extracted/segments/obj1_9D000.bin", 0x35C, 0x2C4
sub_AD620:							; LinkChat calls it with the SHAD and PAL blocks
	incbin	"Extracted/segments/obj1_9D000.bin", 0x620, 0x60
sub_AD680:							; LinkChat calls it with a text and a position
	incbin	"Extracted/segments/obj1_9D000.bin", 0x680, 0x400
sub_ADA80:							; LinkChat calls it with the window's corners
	incbin	"Extracted/segments/obj1_9D000.bin", 0xA80, 0x134
sub_ADBB4:							; (text on the stack): LinkChat compares the result with the window width
	incbin	"Extracted/segments/obj1_9D000.bin", 0xBB4, 0x38
sub_ADBEC:							; LinkChat calls it with a text
	incbin	"Extracted/segments/obj1_9D000.bin", 0xBEC
