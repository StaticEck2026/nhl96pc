; Object 1 page 58000: not yet disassembled.
	incbin	"Extracted/segments/obj1_58000.bin", 0, 0x6DF
sub_686DF:							; ThreeStarsScreen: called at its end
	incbin	"Extracted/segments/obj1_58000.bin", 0x6DF, 0x2F2
sub_689D1:							; called by LinkOpen before its first message
	incbin	"Extracted/segments/obj1_58000.bin", 0x9D1, 0x3A
sub_68A0B:							; first of a group of four calls in LinkOpen and LinkConnect
	incbin	"Extracted/segments/obj1_58000.bin", 0xA0B, 0xA6
sub_68AB1:							; third of that group
	incbin	"Extracted/segments/obj1_58000.bin", 0xAB1, 0x149
sub_68BFA:							; fourth of that group
	incbin	"Extracted/segments/obj1_58000.bin", 0xBFA, 0x39
sub_68C33:							; (50h, 0): called by LinkOpen
	incbin	"Extracted/segments/obj1_58000.bin", 0xC33, 0x5C
sub_68C8F:							; GameStatsScreen tests its result before the menu
	incbin	"Extracted/segments/obj1_58000.bin", 0xC8F
