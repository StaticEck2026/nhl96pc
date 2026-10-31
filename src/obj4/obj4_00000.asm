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
	incbin	"Extracted/segments/obj4_00000.bin", 0x16, 0x5
str_ABORT:							; "ABORT!\n"
	incbin	"Extracted/segments/obj4_00000.bin", 0x1B, 0x8
str_X:								; "X"
	incbin	"Extracted/segments/obj4_00000.bin", 0x23, 0x2
str_SHAD:							; "SHAD"
	incbin	"Extracted/segments/obj4_00000.bin", 0x25, 0x5
str_PAL:							; "PAL"
	incbin	"Extracted/segments/obj4_00000.bin", 0x2A, 0x6
str_fmtd:							; "%d"
	incbin	"Extracted/segments/obj4_00000.bin", 0x30, 0x3
str_fmtdotd:						; "%d.%d"
	incbin	"Extracted/segments/obj4_00000.bin", 0x33, 0x6
str_zero:							; "0.0"
	incbin	"Extracted/segments/obj4_00000.bin", 0x39, 0x4
str_fmtslash:						; "%d/%d"
	incbin	"Extracted/segments/obj4_00000.bin", 0x3D, 0x6
str_fmttime:						; "%d:%02d"
	incbin	"Extracted/segments/obj4_00000.bin", 0x43, 0x8
str_fmtpct:							; "%d/%d (%d%%)"
	incbin	"Extracted/segments/obj4_00000.bin", 0x4B
