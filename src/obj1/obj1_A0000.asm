; Object 1 page A0000: not yet disassembled.
	incbin	"Extracted/segments/obj1_A0000.bin", 0, 0x284
sub_B0284:							; (value on the stack): called around the backgrounds
	incbin	"Extracted/segments/obj1_A0000.bin", 0x284, 0x174
rand_:								; returns a random number
	incbin	"Extracted/segments/obj1_A0000.bin", 0x3F8, 0x38
sub_B0430:							; (name on the stack): ThreeStarsScreen tests the photo file name with it
	incbin	"Extracted/segments/obj1_A0000.bin", 0x430, 0x64
sub_B0494:							; (name, 0 on the stack): called with "profile.fsh" and "card"
	incbin	"Extracted/segments/obj1_A0000.bin", 0x494
