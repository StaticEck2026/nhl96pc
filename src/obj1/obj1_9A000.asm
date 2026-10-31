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
	incbin	"Extracted/segments/obj1_9A000.bin", 0x493
