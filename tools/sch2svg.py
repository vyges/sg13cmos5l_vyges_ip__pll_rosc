#!/usr/bin/env python3
"""
sch2svg.py -- render an xschem .sch to a clean, standalone SVG.

Why not Graphviz: Graphviz routes edges as splines into node bounding boxes, so wires
would not land on device terminals and would not be orthogonal. It is the right tool for
the block diagrams in design/dot/ and the wrong one for a schematic.

Why not xschem's own SVG print: it dumps the editor canvas -- dark background, whatever
zoom happened to be set, and the symbol's full parameter annotation stacked on top of the
net labels. Unreadable without opening xschem to tune it, which defeats the purpose.

This renders from the .sch itself, so the picture cannot drift from the netlisted
circuit, and draws the PDK's OWN symbol artwork (cached in sym_art.json, extracted from
the .sym files) so a transistor looks like a transistor.

Usage:  sch2svg.py <file.sch> ... --out <dir>
"""
import argparse, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ART = json.load(open(os.path.join(HERE, "sym_art.json")))

LABEL_SYMS = {"devices/lab_pin", "devices/ipin", "devices/opin", "devices/iopin"}

_RE_SL = re.compile(r"^L\s+\S+\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)")
_RE_SB = re.compile(r"^B\s+\S+\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)\s+\{([^}]*)\}")
_RE_ST = re.compile(r"^T\s+\{([^}]*)\}\s+(-?[0-9.eE+]+)\s+(-?[0-9.eE+]+)")


def local_sym(sym, srcdir):
    """Load a locally generated .sym (a sub-block of this design). Without this the
    renderer falls back to a generic box, and the wires -- which are routed to the
    symbol's REAL pin coordinates -- end up terminating away from the drawn box."""
    path = os.path.join(srcdir, sym + ".sym")
    if not os.path.isfile(path):
        return None
    art = {"lines": [], "polys": [], "pins": [], "texts": []}
    for line in open(path, errors="ignore"):
        m = _RE_SL.match(line)
        if m:
            art["lines"].append([float(v) for v in m.groups()]); continue
        m = _RE_SB.match(line)
        if m:
            x1, y1, x2, y2, attr = m.groups()
            nm = re.search(r"name=([^\s}]+)", attr)
            if nm:
                art["pins"].append([nm.group(1), (float(x1) + float(x2)) / 2,
                                    (float(y1) + float(y2)) / 2])
            continue
        m = _RE_ST.match(line)
        if m and "@name" not in m.group(1):
            art["texts"].append([m.group(1), float(m.group(2)), float(m.group(3))])
    return art
NUM = r"(-?[0-9.eE+]+)"
RE_C = re.compile(r"^C\s+\{([^}]*)\}\s+" + NUM + r"\s+" + NUM + r"\s+(\d+)\s+(\d+)\s*\{(.*)\}\s*$")
RE_N = re.compile(r"^N\s+" + NUM + r"\s+" + NUM + r"\s+" + NUM + r"\s+" + NUM)
RE_T = re.compile(r"^T\s+\{(.*)$", re.S)


def xf(x, y, rot, flip):
    if flip:
        x = -x
    for _ in range(rot % 4):
        x, y = -y, x
    return x, y


def esc(s):
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def parse(path):
    """Return (instances, wires, texts). T blocks may span lines, so the file is walked
    with an explicit brace scan rather than line-by-line regex."""
    src = open(path).read()
    inst, wires, texts, i = [], [], [], 0
    lines = src.split("\n")
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("T {"):
            buf, j = ln[3:], i
            while "}" not in buf:
                j += 1
                buf += "\n" + lines[j]
            body = buf[:buf.index("}")]
            rest = buf[buf.index("}") + 1:].split()
            if len(rest) >= 2:
                texts.append((body, float(rest[0]), float(rest[1]),
                              float(rest[4]) if len(rest) > 4 else 0.3))
            i = j + 1
            continue
        m = RE_C.match(ln)
        if m:
            sym, x, y, rot, flip, attr = m.groups()
            sym = sym[:-4] if sym.endswith(".sym") else sym
            d = dict(re.findall(r"(\w+)=([^\s]+)", attr))
            inst.append((sym, float(x), float(y), int(rot), int(flip), d))
            i += 1
            continue
        m = RE_N.match(ln)
        if m:
            wires.append([float(v) for v in m.groups()])
        i += 1
    return inst, wires, texts


def render(path):
    srcdir = os.path.dirname(os.path.abspath(path))
    inst, wires, texts = parse(path)
    S, out, pts = 1.0, [], []

    def note(x, y):
        pts.append((x, y))

    for x1, y1, x2, y2 in wires:
        note(x1, y1); note(x2, y2)
    body = []
    # wires first, so glyphs and text sit on top
    for x1, y1, x2, y2 in wires:
        body.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
                    f'stroke="#2b6cb0" stroke-width="2" stroke-linecap="round"/>')
    # junction dots wherever three or more wire ends coincide
    ends = {}
    for x1, y1, x2, y2 in wires:
        for p in ((x1, y1), (x2, y2)):
            ends[p] = ends.get(p, 0) + 1
    for (x, y), n in ends.items():
        if n >= 3:
            body.append(f'<circle cx="{x}" cy="{y}" r="3.2" fill="#2b6cb0"/>')

    for sym, x, y, rot, flip, attr in inst:
        if sym in LABEL_SYMS:
            lab = attr.get("lab", "?")
            anchor = "end" if flip else "start"
            dx = -7 if flip else 7
            body.append(f'<circle cx="{x}" cy="{y}" r="2.6" fill="#c05621"/>')
            body.append(f'<text x="{x + dx}" y="{y + 4.5}" text-anchor="{anchor}" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="11" '
                        f'fill="#7b341e">{esc(lab)}</text>')
            note(x + dx * 6, y); note(x, y)
            continue
        art = ART.get(sym) or local_sym(sym, srcdir)
        if art is not None and art.get("texts") is not None and art.get("polys") == []:
            # locally generated sub-block symbol: box outline, pin stubs and pin names
            for x1, y1, x2, y2 in art["lines"]:
                body.append(f'<line x1="{x+x1}" y1="{y+y1}" x2="{x+x2}" y2="{y+y2}" '
                            f'stroke="#4a6fa5" stroke-width="2" stroke-linecap="round"/>')
                note(x + x1, y + y1); note(x + x2, y + y2)
            xs_ = [v for ln in art["lines"] for v in (ln[0], ln[2])]
            ys_ = [v for ln in art["lines"] for v in (ln[1], ln[3])]
            if xs_:
                body.append(f'<rect x="{x+min(xs_)}" y="{y+min(ys_)}" '
                            f'width="{max(xs_)-min(xs_)}" height="{max(ys_)-min(ys_)}" '
                            f'fill="#f4f7fb" fill-opacity="0.7" stroke="none"/>')
            for pn, pxo, pyo in art["pins"]:
                body.append(f'<circle cx="{x+pxo}" cy="{y+pyo}" r="2.4" fill="#4a6fa5"/>')
                body.append(f'<text x="{x+pxo+(6 if pxo>=0 else -6)}" y="{y+pyo+3.5}" '
                            f'text-anchor="{"start" if pxo>=0 else "end"}" '
                            f'font-family="Helvetica,Arial,sans-serif" font-size="8.5" '
                            f'fill="#4a6fa5">{esc(pn)}</text>')
            body.append(f'<text x="{x}" y="{y+4}" text-anchor="middle" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="12" '
                        f'font-weight="bold" fill="#2f5c9e">{esc(attr.get("name", sym))}</text>')
            body.append(f'<text x="{x}" y="{y+18}" text-anchor="middle" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="9" '
                        f'fill="#6b7f9e">{esc(sym)}</text>')
            continue
        if art is None:                      # unknown symbol: draw a titled box
            w, h = 60, 60
            body.append(f'<rect x="{x-w}" y="{y-h}" width="{2*w}" height="{2*h}" rx="6" '
                        f'fill="#f4f7fb" stroke="#4a6fa5" stroke-width="2"/>')
            body.append(f'<text x="{x}" y="{y+4}" text-anchor="middle" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="12" '
                        f'font-weight="bold" fill="#2f5c9e">{esc(sym)}</text>')
            note(x - w, y - h); note(x + w, y + h)
            continue
        for x1, y1, x2, y2 in art["lines"]:
            a = xf(x1, y1, rot, flip); b = xf(x2, y2, rot, flip)
            body.append(f'<line x1="{x+a[0]}" y1="{y+a[1]}" x2="{x+b[0]}" y2="{y+b[1]}" '
                        f'stroke="#1a202c" stroke-width="2" stroke-linecap="round"/>')
            note(x + a[0], y + a[1]); note(x + b[0], y + b[1])
        for poly in art["polys"]:
            pp = []
            for k in range(0, len(poly) - 1, 2):
                a = xf(poly[k], poly[k + 1], rot, flip)
                pp.append(f"{x+a[0]},{y+a[1]}")
                note(x + a[0], y + a[1])
            body.append(f'<polygon points="{" ".join(pp)}" fill="#1a202c"/>')
        # instance name and the sizes that matter, in one compact stack clear of the body
        name = attr.get("name", "")
        bits = [b for b in (f"W={attr['w']}" if "w" in attr else "",
                            f"L={attr['l']}" if "l" in attr else "",
                            f"m={attr['m']}" if attr.get("m", "1") != "1" else "") if b]
        body.append(f'<text x="{x-30}" y="{y-38}" text-anchor="end" '
                    f'font-family="Helvetica,Arial,sans-serif" font-size="11" '
                    f'font-weight="bold" fill="#1a202c">{esc(name)}</text>')
        if bits:
            body.append(f'<text x="{x-30}" y="{y-25}" text-anchor="end" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="9.5" '
                        f'fill="#4a5568">{esc(" ".join(bits))}</text>')
        note(x - 95, y - 45)

    # Circuit bbox first; the title block is then stacked ABOVE it. Honouring the
    # author's text coordinates put the title straight through M3 once device placement
    # was scaled up -- the text has no business fighting the circuit for space.
    cxs = [p[0] for p in pts]; cys = [p[1] for p in pts]
    tx = min(cxs)
    ty = min(cys) - 30
    blocks = sorted(texts, key=lambda t: -t[3])
    stack = []
    for txt, _ax, _ay, size in blocks:
        fs = 17.0 if size >= 0.4 else 12.0
        rows = txt.split("\n")
        stack.append((txt, fs, size, rows))
    total = sum(len(r) * (f + 4) + 14 for _t, f, _s, r in stack)
    cur = ty - total
    for txt, fs, size, rows in stack:
        weight = "bold" if size >= 0.4 else "normal"
        fill = "#1a202c" if size >= 0.4 else "#5a4b81"
        for row in rows:
            body.append(f'<text x="{tx}" y="{cur}" '
                        f'font-family="Helvetica,Arial,sans-serif" font-size="{fs:.1f}" '
                        f'font-weight="{weight}" fill="{fill}">{esc(row)}</text>')
            note(tx, cur); note(tx + len(row) * fs * 0.55, cur)
            cur += fs + 4
        cur += 14

    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    pad = 40
    x0, y0 = min(xs) - pad, min(ys) - pad
    w, h = max(xs) - x0 + pad, max(ys) - y0 + pad
    out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w*S:.0f}" '
               f'height="{h*S:.0f}" viewBox="{x0:.0f} {y0:.0f} {w:.0f} {h:.0f}">')
    out.append(f'<rect x="{x0}" y="{y0}" width="{w}" height="{h}" fill="#ffffff"/>')
    out += body
    out.append("</svg>")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("schematics", nargs="+")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for s in a.schematics:
        svg = render(s)
        name = os.path.basename(s)[:-4] + ".svg"
        open(os.path.join(a.out, name), "w").write(svg)
        print(f"  {name:<28} {len(svg):>7} bytes")


if __name__ == "__main__":
    main()
