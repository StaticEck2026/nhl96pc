; Object 1 page 0A000: not yet disassembled.
	incbin	"Extracted/segments/obj1_0A000.bin", 0, 0x109
sub_1A109:							; shows a message box (LinkOpen, LinkConnect)
	incbin	"Extracted/segments/obj1_0A000.bin", 0x109, 0x91E
sub_1AA27:							; called before and after the link messages
	incbin	"Extracted/segments/obj1_0A000.bin", 0xA27, 0x3B
sub_1AA62:							; (text, screen, width, height): shows a link message
	incbin	"Extracted/segments/obj1_0A000.bin", 0xA62
