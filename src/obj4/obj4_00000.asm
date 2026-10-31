; Object 4 page 00000: not yet disassembled.
	incbin	"Extracted/segments/obj4_00000.bin", 0, 0x4
str_PATH:							; "PATH"
	incbin	"Extracted/segments/obj4_00000.bin", 0x4, 0x5
str_rb:								; "rb"
	incbin	"Extracted/segments/obj4_00000.bin", 0x9, 0x3
str_HGwt:							; "HGwt": a shape name
	incbin	"Extracted/segments/obj4_00000.bin", 0xC, 0x5
str_HFwt:							; "HFwt"
	incbin	"Extracted/segments/obj4_00000.bin", 0x11, 0x5
str_LGwt:							; "LGwt"
	incbin	"Extracted/segments/obj4_00000.bin", 0x16
