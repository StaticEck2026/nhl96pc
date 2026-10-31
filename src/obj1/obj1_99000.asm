; Object 1 page 99000: not yet disassembled.
	incbin	"Extracted/segments/obj1_99000.bin", 0, 0xBCC
_searchenv_:						; (name, variable, buffer): the file's path in buffer, "" if not found
	incbin	"Extracted/segments/obj1_99000.bin", 0xBCC, 0xE7
strcpy_:							; (dest, src): copies a string
	incbin	"Extracted/segments/obj1_99000.bin", 0xCB3, 0x1F
strcat_:							; (dest, src): appends a string
	incbin	"Extracted/segments/obj1_99000.bin", 0xCD2, 0x1CE
fopen_:								; (name, mode): opens a file, returns the FILE or 0
	incbin	"Extracted/segments/obj1_99000.bin", 0xEA0, 0xD8
fseek_:								; (FILE, offset, whence)
	incbin	"Extracted/segments/obj1_99000.bin", 0xF78
