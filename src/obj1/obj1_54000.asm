; Object 1 page 54000: not yet disassembled.
	incbin	"Extracted/segments/obj1_54000.bin", 0, 0xD3
sub_640D3:							; LinkChat calls it with a text
	incbin	"Extracted/segments/obj1_54000.bin", 0xD3, 0x101
sub_641D4:							; LinkChat calls it with its window bitmap
	incbin	"Extracted/segments/obj1_54000.bin", 0x1D4
