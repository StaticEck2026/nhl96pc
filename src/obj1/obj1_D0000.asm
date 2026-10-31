; Object 1 page D0000: not yet disassembled.
	incbin	"Extracted/segments/obj1_D0000.bin", 0, 0x51
ReadJoyPort:						; times the joystick port into joy1x-joy2y; returns button and axis bits
	incbin	"Extracted/segments/obj1_D0000.bin", 0x51, 0x405
EnableJoysticks:					; switches joystick reading on and resets its limits
	incbin	"Extracted/segments/obj1_D0000.bin", 0x456
