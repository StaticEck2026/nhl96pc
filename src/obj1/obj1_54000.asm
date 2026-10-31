; Object 1 page 54000: not yet disassembled.
	incbin	"Extracted/segments/obj1_54000.bin", 0, 0x54
sub_64054:							; ThreeStarsScreen: called with the player's name
	incbin	"Extracted/segments/obj1_54000.bin", 0x54, 0x7F
sub_640D3:							; LinkChat calls it with a text
	incbin	"Extracted/segments/obj1_54000.bin", 0xD3, 0x101
sub_641D4:							; LinkChat calls it with its window bitmap
	incbin	"Extracted/segments/obj1_54000.bin", 0x1D4, 0x6A
sub_6423E:							; ThreeStarsScreen: called before the background
	incbin	"Extracted/segments/obj1_54000.bin", 0x23E, 0x58
sub_64296:							; ThreeStarsTick calls it with a fraction and a shape
	incbin	"Extracted/segments/obj1_54000.bin", 0x296, 0x1F7
sub_6448D:							; ThreeStarsScreen: called after the palette
	incbin	"Extracted/segments/obj1_54000.bin", 0x48D, 0x294
sub_64721:							; (3): called before the arrows and the buttons
	incbin	"Extracted/segments/obj1_54000.bin", 0x721, 0x838
sub_64F59:							; (items, count, ...): the end-of-game menus wait in it for a choice
	incbin	"Extracted/segments/obj1_54000.bin", 0xF59
