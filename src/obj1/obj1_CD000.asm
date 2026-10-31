; Object 1 page CD000: not yet disassembled.
	incbin	"Extracted/segments/obj1_CD000.bin", 0, 0x6C4
sub_DD6C4:							; LinkChat calls it before drawing
	incbin	"Extracted/segments/obj1_CD000.bin", 0x6C4, 0x1C
sub_DD6E0:							; LinkChat calls it with the PAL block
	incbin	"Extracted/segments/obj1_CD000.bin", 0x6E0, 0x28
sub_DD708:							; LinkChat calls it with the window
	incbin	"Extracted/segments/obj1_CD000.bin", 0x708, 0x1C
sub_DD724:							; LinkChat calls it with two points
	incbin	"Extracted/segments/obj1_CD000.bin", 0x724, 0x3C
sub_DD760:							; LinkChat calls it with a screen area
	incbin	"Extracted/segments/obj1_CD000.bin", 0x760
