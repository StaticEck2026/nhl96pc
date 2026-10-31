; Object 1 page 9B000: not yet disassembled.
	incbin	"Extracted/segments/obj1_9B000.bin", 0, 0x758
sub_AB758:							; (name, size, 20h on the stack): LinkChat's "SHAD" and "PAL" blocks
	incbin	"Extracted/segments/obj1_9B000.bin", 0x758, 0x7F4
sub_ABF4C:							; (sprite on the stack): HideWaitSprite's second call
	incbin	"Extracted/segments/obj1_9B000.bin", 0xF4C
