# Handoff

## State (2026-10-31)

- Full build MATCH (SHA-1 `426fb8c0c80088c6a2c56a9dac50509cb9c24540`, 1,613,291 bytes); `tools/verify_all.sh` MATCH (full build and all 283 segments built on
  their own). Onboarding: StaticEck.
- Source: the LE header fields and object table (`src/le/le_header.asm`) and obj1 from 0x10000 to 0x144BD: the controller
  code and GrLink (obj1_00000), the GrIP glue and game port sticks (obj1_01000), joystick detection and the modem link
  (obj1_02000), the link close, pads exchange and chat window (obj1_03000), a data table and DrawTeamStats (obj1_04000),
  the team stats and three stars screens (obj1_05000). Everything else is incbin, with labels split in where converted
  code points. Next: obj1_06000 (from 0x168DA).
- Record equates shared by pages: `src/inc/input.inc` (ctlrecs ctl_, joyslots js_).
- Object 4 BSS labels: `src/obj4/obj4_bss.asm` (no bytes, `absolute` after the last obj4 page).

## Known facts

- Watcom C/C++32 runtime string "(c) Copyright by WATCOM International Corp. 1988-1994": the 10.0 family, like NHL95PC (10.5 says
  1988-1995). EACSNDF.LIB "32 Bit Sound Library - Build: Aug 28 1995". DOS/4GW Professional (Rational Systems 1990-1994).
- Entry point `start` in object 1 (the same name NHL95PC gives its entry). Stack: top of object 4.
- No C work here: the toolchain is NASM 2.15+ and Python 3 only.

## Unsure / open

- obj1_00000 auto names (purpose not clear yet): `dword_17C9A0` (pointer to a game setup: +5+n team flag, +9+2n device of
  controller n), `byte_17CA21` (bit 7 key table), `byte_17CA22` (bit 0 swaps the mouse buttons), `byte_17CA5D` (bit 5
  640x480), `dword_11D91F` (keyboard for every controller), `byte_114B8C`, `dword_114B9C` (probably the inputq read index),
  `dword_114F08`, `sub_619E2` (dirmaptab row 0-7, probably the camera view).
- obj1_01000: GrIP library function codes (84A0h refresh?, 84A1h slot count?, 84B0h slot map, 84B1h class map, 84B3h
  highest index, 84B4h largest value, 84C0h value, 84C1h packed values, 84D0h/84D1h 16-byte strings, probably names) are
  read from how the results are used, not from the SDK. Auto names `unk_151648`, `unk_1516B8`, `word_151768` (84D0h/84D1h
  results). js_flags: ReadJoysticks tests `(flags or 6) = 2 / 4`, which can never match; only the both-sides dead-zone test
  runs. The first dword of a joyslots record is unknown.
- obj1_02000: the port driver at 0x18000 (sub_183CD open, sub_18540 connect, sub_18234 close), the message routines
  (sub_77355 text by number, sub_1AA62, sub_1A109, sub_1AA27), the sprite calls (sub_63B0C, sub_AA988, sub_AAA8C,
  sub_AADA4, sub_ABF4C, sub_E04E0) and the group of four calls (sub_68A0B, sub_69A94, sub_68AB1, sub_68BFA) keep auto
  names. The modem settings
  copied by LinkOpen (dword_114D0E..byte_114D6E) and the game setup fields at 0x17C9A8-0x17C9F4 are auto names.
- obj1_03000: LinkChat's drawing calls (sub_63F79, sub_63FEF, sub_640D3, sub_641D4, sub_AD35C, sub_AD620, sub_AD680,
  sub_ADA80, sub_ADBB4, sub_ADBEC, sub_DD6C4-sub_DD760, sub_AB758) keep auto names; the window layout comments follow the
  arithmetic, not a confirmed drawing API. dword_114F08 must be 1 for LinkSendPads to fill the input queue.
- obj1_04000: the team stats rows are texts 20Ch-21Ah from the language file, so the stats are described by their
  teamstats offsets, not named; teamstats' record start and size (136h) come from the two bases this code uses. The data
  table at 0x144BD (word_144BD .. dword_144ED) is read by the next module and keeps auto names.
- obj1_05000: ThreeStarsScreen's first button (result 2: ThreeStarsMenu waits on sub_8C51B until it returns A410h) is
  not identified, nor the third animation of ThreeStarsTick. The screen and shape routines it calls (sub_62AF7,
  sub_64F59 the menu runner, sub_AAA40, sub_B0494 ...) keep auto names and comments that only say how they are called.
- Key bindings 0 and 1 (pad bits 0-1) and the team extra keys (bits 10-13, 18 / 14-17, 19): what they do in the game.
- GrLink, the cont1team / ctl_type meanings and the home / away reading of the setup flag are medium confidence (see name_map).

- Object 2 (52 bytes) and object 3 (24 bytes): what they hold.
- Fixup records stay incbin until generated from labels.
