; Object 1 page 08000: not yet disassembled.
	incbin	"Extracted/segments/obj1_08000.bin", 0, 0x2B
SetLinkPollFn:						; (routine): the one LinkSync calls while it waits; returns the old one
	incbin	"Extracted/segments/obj1_08000.bin", 0x2B, 0x20
SetLinkRecvFn:						; (routine): the one each received packet goes to
	incbin	"Extracted/segments/obj1_08000.bin", 0x4B, 0x1E9
sub_18234:							; registered at exit by LinkOpen
	incbin	"Extracted/segments/obj1_08000.bin", 0x234, 0x199
sub_183CD:							; (string): LinkOpen's port open; 0 on failure
	incbin	"Extracted/segments/obj1_08000.bin", 0x3CD, 0x173
sub_18540:							; LinkConnect's connection; 0 on failure
	incbin	"Extracted/segments/obj1_08000.bin", 0x540, 0x3DA
LinkSendPacket:						; (packet, length): queues a packet to send; 0 when the queue is full
	incbin	"Extracted/segments/obj1_08000.bin", 0x91A
