; Object 1 page 9A000: not yet disassembled.
	incbin	"Extracted/segments/obj1_9A000.bin", 0, 0x74
ftell_:								; (FILE): the file position
	incbin	"Extracted/segments/obj1_9A000.bin", 0x74, 0x30
fclose_:							; (FILE)
	incbin	"Extracted/segments/obj1_9A000.bin", 0xA4, 0x142
_nmalloc_:							; (size): allocates memory, returns 0 when there is none
	incbin	"Extracted/segments/obj1_9A000.bin", 0x1E6, 0xE3
fread_:								; (buffer, size, count, FILE)
	incbin	"Extracted/segments/obj1_9A000.bin", 0x2C9, 0x1CA
_nfree_:							; (block): frees memory
	incbin	"Extracted/segments/obj1_9A000.bin", 0x493, 0x199
sub_AA62C:							; (routine on the stack): adds it to an 8-entry exit list
	incbin	"Extracted/segments/obj1_9A000.bin", 0x62C, 0x38
sub_AA664:							; (routine on the stack): takes it off the exit list
	incbin	"Extracted/segments/obj1_9A000.bin", 0x664, 0x324
sub_AA988:							; (sprite on the stack): ShowWaitSprite's first call
	incbin	"Extracted/segments/obj1_9A000.bin", 0x988, 0x104
sub_AAA8C:							; (shape on the stack): its second
	incbin	"Extracted/segments/obj1_9A000.bin", 0xA8C, 0xB4
sub_AAB40:							; (bitmap, 0, 0 on the stack): DrawTeamStats calls it first
	incbin	"Extracted/segments/obj1_9A000.bin", 0xB40, 0x264
sub_AADA4:							; (sprite on the stack): HideWaitSprite's first call
	incbin	"Extracted/segments/obj1_9A000.bin", 0xDA4
