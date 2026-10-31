#!/usr/bin/env python3
# le_fixups.py: list the LE fixups of the retail EXE (read from its fixup page table and record table), so a page being
# disassembled can write every fixed-up address as a label. The value stored at a fixup source is the target's offset in
# its object, not its linear address; this prints the target as a linear address.
#   python3 tools/le_fixups.py <segment>      fixups whose source lies in that object page: source, target object, target
#   python3 tools/le_fixups.py --to <segment> fixups from anywhere whose target lies in that object page
# Records are all type 07 (32-bit offset), internal reference, as in NHL95PC (BUILD_NOTES.md). A fixup that crosses a
# page end is stored in both pages (the second copy with a negative source offset); it is listed once.
import os, struct, sys
sys.path.insert(0, os.path.dirname(__file__))
from exefile import SEGMAP, need

def parse(d):
    mz = d.find(b'MZ', 0x20000)
    while d[mz + struct.unpack_from('<I', d, mz + 0x3C)[0]:][:2] != b'LE': mz = d.find(b'MZ', mz + 1)
    le = mz + struct.unpack_from('<I', d, mz + 0x3C)[0]
    u32 = lambda o: struct.unpack_from('<I', d, le + o)[0]
    npages, nobj = u32(0x14), u32(0x44)
    objs = [struct.unpack_from('<6I', d, le + u32(0x40) + 24 * n) for n in range(nobj)]
    fpt, frt = le + u32(0x68), le + u32(0x6C)
    offs = struct.unpack_from('<%dI' % (npages + 1), d, fpt)
    fix = {}
    for size, base, flags, first, count, _ in objs:
        for k in range(count):
            p = first - 1 + k; pos, end = frt + offs[p], frt + offs[p + 1]; page = base + k * 0x1000
            while pos < end:
                src, flg = d[pos], d[pos + 1]; pos += 2
                if src & 0x20: cnt = d[pos]; pos += 1; so = None
                else: cnt = 1; so = [struct.unpack_from('<h', d, pos)[0]]; pos += 2
                if flg & 3: sys.exit('unsupported fixup target type at page %d' % p)
                if flg & 0x40: tobj = struct.unpack_from('<H', d, pos)[0]; pos += 2
                else: tobj = d[pos]; pos += 1
                if flg & 0x10: toff = struct.unpack_from('<I', d, pos)[0]; pos += 4
                else: toff = struct.unpack_from('<H', d, pos)[0]; pos += 2
                if so is None: so = list(struct.unpack_from('<%dh' % cnt, d, pos)); pos += 2 * cnt
                for s in so: fix[page + s] = (tobj, objs[tobj - 1][1] + toff, src & 0xF)
    return [o[1] for o in objs], fix

def seg_range(name, bases):
    # objN_...: object N; its linear address from the segment's file offset past the object's first segment (objN_00000),
    # since a page that was split at a routine boundary no longer starts where its name says
    s = next((s for s in SEGMAP['segments'] if s['name'] == name), None)
    if not s or not name.startswith('obj'): sys.exit('no object segment ' + name)
    first = next(f for f in SEGMAP['segments'] if f['name'] == name[:5] + '00000')
    base = bases[int(name[3]) - 1] + s['off'] - first['off']
    return base, base + s['size']

if __name__ == '__main__':
    args = sys.argv[1:]
    to = args and args[0] == '--to'
    if to: args = args[1:]
    if len(args) != 1: sys.exit('usage: python3 tools/le_fixups.py [--to] <segment>')
    _, d = need()
    bases, fix = parse(d)
    lo, hi = seg_range(args[0], bases)
    for src in sorted(fix):
        tobj, tgt, typ = fix[src]
        if (lo <= tgt < hi) if to else (lo <= src < hi):
            print('%06X obj%d %06X' % (src, tobj, tgt) + ('' if typ == 7 else ' type%d' % typ))
