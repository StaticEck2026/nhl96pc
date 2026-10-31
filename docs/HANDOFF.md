# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `426fb8c0c80088c6a2c56a9dac50509cb9c24540`, 1,613,291 bytes); `tools/verify_all.sh` MATCH (full build and all 283 segments built on
  their own). Onboarding: StaticEck.
- Source: the LE header fields and object table (`src/le/le_header.asm`), obj1_00000 (0x10000-0x11107, the controller code
  and GrLink), obj1_01000 (0x11107-0x1214A, the GrIP glue and game port sticks) and obj1_02000 (0x1214A-0x13146, joystick
  detection and the modem game link). Everything else is incbin, with labels split in where converted code points.
  Next: obj1_03000 (from 0x13146; sub_13338, the modem-game input flush, at 0x13338).
- Record equates shared by pages: `src/inc/input.inc` (ctlrecs ctl_, joyslots js_).
- Object 4 BSS labels: `src/obj4/obj4_bss.asm` (no bytes, `absolute` after the last obj4 page).

## Known facts

- Watcom C/C++32 runtime string "(c) Copyright by WATCOM International Corp. 1988-1994": the 10.0 family, like NHL95PC (10.5 says
  1988-1995). EACSNDF.LIB "32 Bit Sound Library - Build: Aug 28 1995". DOS/4GW Professional (Rational Systems 1990-1994).
- Entry point `start` in object 1 (the same name NHL95PC gives its entry). Stack: top of object 4.
- No C work here: the toolchain is NASM 2.15+ and Python 3 only.

## Unsure / open

- obj1_00000 auto names (purpose not clear yet): `dword_17C9A0` (pointer to a game setup: +5+n team flag, +9+2n device of
  controller n), `byte_17CA21` (bit 7 key table), `byte_17CA22` (bit 0 swaps the mouse buttons), `byte_17CA5D` (bit 5 640x480),
  `dword_11D91F` (keyboard for every
  controller), `byte_114B8C`, `byte_1515D4` (90-byte input queue?), `dword_114B9C`, `dword_114BA0`, `dword_114BA4`,
  `dword_114F08`, `word_151714`..`word_15175C` (one per joystick slot, 18h apart), `sub_619E2` (dirmaptab row 0-7, probably
  the camera view), `sub_13338`.
- obj1_01000: GrIP library function codes (84A0h refresh?, 84A1h slot count?, 84B0h slot map, 84B1h class map, 84B3h
  highest index, 84B4h largest value, 84C0h value, 84C1h packed values, 84D0h/84D1h 16-byte strings, probably names) are
  read from how the results are used, not from the SDK. Auto names `unk_151648`, `unk_1516B8`, `word_151768` (84D0h/84D1h
  results). js_flags: ReadJoysticks tests `(flags or 6) = 2 / 4`, which can never match; only the both-sides dead-zone test
  runs. The first dword of a joyslots record is unknown.
- obj1_02000: the port driver at 0x18000 (sub_183CD open, sub_18540 connect, sub_18234 close), the message routines
  (sub_77355 text by number, sub_1AA62, sub_1A109, sub_1AA27), the sprite calls (sub_63B0C, sub_AA988, sub_AAA8C,
  sub_AADA4, sub_ABF4C, sub_E04E0) and the group of four calls (sub_68A0B, sub_69A94, sub_68AB1, sub_68BFA) keep auto
  names. Packet types 2 and 6 (linkq2, linkq6) and the fourth ring (byte_151A44) are read elsewhere. The modem settings
  copied by LinkOpen (dword_114D0E..byte_114D6E) and the game setup fields at 0x17C9A8-0x17C9F4 are auto names.
- Key bindings 0 and 1 (pad bits 0-1) and the team extra keys (bits 10-13, 18 / 14-17, 19): what they do in the game.
- GrLink, the cont1team / ctl_type meanings and the home / away reading of the setup flag are medium confidence (see name_map).

- Object 2 (52 bytes) and object 3 (24 bytes): what they hold.
- Fixup records stay incbin until generated from labels.
