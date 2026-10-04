#!/usr/bin/env python3
"""Floorplan for the ring-oscillator PLL slot -- placement as data, checked, then drawn.

    python3 tools/floorplan.py            # check and report; exit 1 on any violation
    python3 tools/floorplan.py --svg      # also write doc/datasheet/pll_rosc_floorplan.svg

⛔ WHY THIS IS DATA AND NOT A DRAWING. Same reason as the LDO's: a diagram cannot fail. Every
device footprint below was measured by tools/area_budget.py (PDK PyCells, standard cells from
the LEF), and the run fails if a region cannot hold what is assigned to it, leaves the slot,
lands on another, or breaks one of the routing rules this block depends on.

AREA IS NOT THE CONSTRAINT HERE, ROUTING IS. The devices total 7,678 um2 -- 5.2 % of the slot --
and the loop filter is 93 % of that. So the checks that matter are not "does it fit" but:

  1. vctrl is SHORT. It is the highest-impedance node in the block and sets frequency
     directly; with a 0.31-0.63 uA pump, any charge coupled onto it is a frequency step.
     The filter, the pump output and the ring's bias input are therefore mutually adjacent.
  2. up/dn are SHORT AND EQUAL. Their mismatch is static phase offset and reference spur.
     The PFD abuts the charge pump.
  3. DIGITAL STAYS AWAY FROM THE FILTER. The PFD and divider are standard cells switching at
     up to the VCO rate; the charge pump sits between them and the filter.
  4. NOTHING IS PLACED OVER THE INCOMING ROUTES. ibias0 and the four controls (porb, rstb,
     nsel0, nsel1) all arrive in one band of the core-facing LEFT edge (y 72-99); a channel
     is reserved for them across to the blocks that use them.

PIN GEOMETRY (slot6_wrapper.mag, harness @ 1906830; y from the slot bottom):

  right / pad edge   ref      s6_an[0]  y  77.2-101.9
                     vco_out  s6_an[1]  y 187.2-211.9
  left / core edge   vdd_1v2  TopMetal1 y   1.5-56.8   (magic calls it metal5)
                     vss_1v2  TopMetal1 y  66.4-96.4
                     ibias0   metal3    y  97.2-99.2
                     dig_in   metal3    y  72.2-90.0   (porb, rstb, nsel0, nsel1; bits not
                                                         yet assigned by the harness owner)

⚠️ WHAT THIS IS NOT. A first-cut placement, not a routed floorplan. It reserves one guard
ring per analog region and one channel; it does not route, and region shapes are rectangles.
The packing checks are floors: a row of devices fitting a region's width does not prove the
local routing does. Power is on TopMetal1 (both rails arrive on it) and can run over every
region, so no power channel is reserved -- except that Cz occupies M1-M4 over its whole area,
which is why nothing is routed through the filter region.
"""
import os, sys

# ⛔ The real slot, read from the harness wrapper layout (magic/slot6_wrapper.mag,
# magscale 1 2, harness @ 1906830). chipalooza/tools/slot_fit.py re-derives it.
SLOT_W, SLOT_H = 537.15, 273.0
EDGE = 6.0              # wrapper pins are a 2 um strip; 4 um more keeps devices off them
GUARD = 3.0             # one guard ring, per side, around each analog region
FILL_MAX = 0.25         # device area / region area for the small regions: the rest is local
                        # routing, taps and (for the pump) the common-centroid arrangement
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Measured footprints, W x H um, from tools/area_budget.py run on the pll_rosc netlist
# (2026-10-04, PDK pin as implementation.md). Grouped by the region that holds them.
RES_PITCH = 1.2         # rhigh fold pitch, DRC-verified on this PDK (LDO tools/floorplan.py)


def snake(length_um, height_um, pitch=RES_PITCH):
    cols = int(length_um / height_um) + 1
    return cols * pitch, height_um


RZ_W, RZ_H = snake(89.22, 20.0)         # Xlf/XRz, 1.40 x 89.22 drawn
DEVICES = {
    "lf":   [("Cz", 82.00, 82.50), ("Cp", 16.00, 16.50), ("Rz", RZ_W, RZ_H)],
    "cp":   [("Mn0", 1.18, 2.36), ("Mn1", 1.18, 2.36), ("Mp0", 1.80, 4.62),
             ("Mpsrc", 1.80, 4.62), ("Mnsnk", 1.18, 2.36), ("Mpi", 1.43, 2.62),
             ("Mni", 0.81, 1.36), ("Mswup", 1.43, 4.62), ("Mswdn", 0.81, 2.36)],
    "pfd":  [("Xup", 13.92, 3.78), ("Xdn", 13.92, 3.78), ("Xnand", 1.92, 3.78),
             ("Xand", 2.40, 3.78)],
    "div":  [("Xd1", 13.92, 3.78), ("Xd2", 13.92, 3.78), ("Xd3", 13.92, 3.78),
             ("Xd4", 13.92, 3.78), ("Xmux", 10.08, 3.78)],
    "vco":  [("Mpr", 1.43, 1.62), ("Mnr", 0.81, 1.36)]
            + [(f"X{i}.{d}", w, h) for i in range(1, 8)
               for d, w, h in (("Mps", 1.43, 1.62), ("Mpu", 1.43, 2.62),
                               ("Mnd", 0.81, 2.36), ("Mns", 0.81, 1.36))]
            + [(f"Xdum{i}", 1.44, 3.78) for i in range(2, 8)]
            + [("Xtap", 1.44, 3.78), ("Xbuf", 2.88, 3.78)],
}
MEASURED_TOTAL = 7678.3     # area_budget.py's own total; the table above must reproduce it

# name, x, y, w, h, group(key into DEVICES, or "route")
BLOCKS = [
    # Reserved: the incoming bias and control routes, from the left-edge pin band to the
    # pump (ibias), the PFD (porb) and the divider (rstb, nsel0/1). Nothing is placed here.
    ("bias + control channel", 6,   70,  316,  30,  "route"),

    # The quiet core. Filter, then pump hard against its right side: vctrl is the pump's
    # output and the filter's input, and it leaves the filter's top-right corner for the
    # ring's bias input directly above.
    ("loop filter (Cz Cp Rz)", 150, 102, 120,  100, "lf"),
    ("charge pump",            276, 132, 40,   40,  "cp"),

    # Digital, on the far side of the pump from the filter. The PFD abuts the pump so up/dn
    # are two short, equal wires; the divider sits under the PFD, which takes its output.
    ("PFD",                    322, 132, 45,   20,  "pfd"),
    ("divider /N",             322, 102, 80,   22,  "div"),

    # The ring, above. Its bias end (Mpr/Mnr) is the LEFT end, over the filter's corner; its
    # output end (Xtap, Xbuf) is the RIGHT end, facing the vco_out pad at y 187-212. Seven
    # stages in one row with identical surroundings: Kvco is a uniform stage delay.
    ("VCO ring + output buffer", 300, 190, 140, 45, "vco"),
]

# Routing rules, each a distance between two regions' nearest edges (um), and the limit.
# They are the reason for the placement above; a move that breaks one fails the run.
RULES = [
    ("vctrl: filter -> pump",          "loop filter (Cz Cp Rz)", "charge pump",            "max", 8),
    ("vctrl: filter -> ring bias",     "loop filter (Cz Cp Rz)", "VCO ring + output buffer", "max", 40),
    ("up/dn: PFD -> pump",             "PFD",                    "charge pump",            "max", 8),
    ("div_out: divider -> PFD",        "divider /N",             "PFD",                    "max", 10),
    ("PFD kept off the filter",        "PFD",                    "loop filter (Cz Cp Rz)", "min", 40),
    ("divider kept off the filter",    "divider /N",             "loop filter (Cz Cp Rz)", "min", 40),
    # The ring switches at hundreds of MHz too, but it is the filter's own load and its bias
    # input has to be near vctrl; 25 um is room for the guard rings of both plus a shield.
    ("ring kept off the filter",       "VCO ring + output buffer", "loop filter (Cz Cp Rz)", "min", 25),
]
# Pin rules: a region's nearest edge to a wrapper pin rectangle (x, y1, y2 on that edge).
PINS = {"ref": (SLOT_W, 77.2, 101.9), "vco_out": (SLOT_W, 187.2, 211.9),
        "ibias0": (0.0, 97.2, 99.2), "dig_in": (0.0, 72.2, 90.0)}
PIN_RULES = [
    # vco_out is driven by Xbuf (inv_4) into the pad: every micron is load on a 735 MHz edge.
    ("vco_out: ring output end -> pad", "VCO ring + output buffer", "vco_out", "max", 100),
]


def by_name(n):
    return next(b for b in BLOCKS if b[0] == n)


def gap(a, b):
    """Edge-to-edge distance between two rectangles (0 if they touch or overlap)."""
    dx = max(b[1] - (a[1] + a[3]), a[1] - (b[1] + b[3]), 0)
    dy = max(b[2] - (a[2] + a[4]), a[2] - (b[2] + b[4]), 0)
    return (dx * dx + dy * dy) ** 0.5


def pin_gap(a, pin):
    px, y1, y2 = PINS[pin]
    dx = max(px - (a[1] + a[3]), a[1] - px, 0)
    dy = max(y1 - (a[2] + a[4]), a[2] - y2, 0)
    return (dx * dx + dy * dy) ** 0.5


def check():
    bad = []
    # the channel must actually cover the pins it is reserved for
    ch = next(b for b in BLOCKS if b[5] == "route")
    for pin in ("ibias0", "dig_in"):
        _, y1, y2 = PINS[pin]
        if y1 < ch[2] or y2 > ch[2] + ch[4]:
            bad.append(f"{pin} (y {y1}-{y2}) is not inside the reserved channel "
                       f"(y {ch[2]}-{ch[2] + ch[4]})")
    for n, x, y, w, h, _ in BLOCKS:
        if x < EDGE or y < EDGE or x + w > SLOT_W - EDGE or y + h > SLOT_H - EDGE:
            bad.append(f"{n!r} is outside the slot less its {EDGE:g} um edge: ({x},{y}) {w}x{h}")
    for i, a in enumerate(BLOCKS):
        for b in BLOCKS[i + 1:]:
            if a[1] < b[1] + b[3] and b[1] < a[1] + a[3] and a[2] < b[2] + b[4] and b[2] < a[2] + a[4]:
                bad.append(f"{a[0]!r} overlaps {b[0]!r}")
    # every measured device is assigned, exactly once
    # (Rz is listed folded; area_budget.py measured it drawn straight, so compare like with like)
    total = sum(w * h for devs in DEVICES.values() for _, w, h in devs) - RZ_W * RZ_H + 1.40 * 89.22
    if abs(total - MEASURED_TOTAL) > 0.5:
        bad.append(f"device table sums to {total:.1f} um2, area_budget.py measured {MEASURED_TOTAL}")
    # each region holds its devices
    for n, x, y, w, h, g in BLOCKS:
        if g == "route":
            continue
        devs = DEVICES[g]
        iw, ih = w - 2 * GUARD, h - 2 * GUARD
        if any(dw > iw or dh > ih for _, dw, dh in devs):
            bad.append(f"{n!r}: a device is larger than the region inside its guard ring")
        area = sum(dw * dh for _, dw, dh in devs)
        if g == "lf":
            # three big parts side by side, 2 um apart: the row has to fit
            row = sum(dw for _, dw, _ in devs) + 2 * (len(devs) - 1)
            if row > iw:
                bad.append(f"{n!r}: Cz, Cp and Rz side by side need {row:.1f} um, have {iw:.1f}")
        elif area > FILL_MAX * iw * ih:
            bad.append(f"{n!r}: devices fill {100*area/(iw*ih):.0f} % > {100*FILL_MAX:.0f} %")
    for label, a, b, kind, lim in RULES:
        d = gap(by_name(a), by_name(b))
        if (kind == "max" and d > lim) or (kind == "min" and d < lim):
            bad.append(f"rule {label!r}: {d:.1f} um, limit {kind} {lim}")
    for label, a, pin, kind, lim in PIN_RULES:
        d = pin_gap(by_name(a), pin)
        if (kind == "max" and d > lim) or (kind == "min" and d < lim):
            bad.append(f"rule {label!r}: {d:.1f} um, limit {kind} {lim}")
    return bad


def report():
    S = SLOT_W * SLOT_H
    print(f"slot {SLOT_W} x {SLOT_H} um = {S:.0f} um2")
    print(f"{'region':<26} {'x':>6} {'y':>6} {'w':>6} {'h':>6} {'devices um2':>12} {'fill':>6}")
    for n, x, y, w, h, g in BLOCKS:
        a = 0 if g == "route" else sum(dw * dh for _, dw, dh in DEVICES[g])
        fill = "" if g == "route" else f"{100*a/((w-2*GUARD)*(h-2*GUARD)):.1f}%"
        print(f"{n:<26} {x:>6} {y:>6} {w:>6} {h:>6} {a:>12.1f} {fill:>6}")
    used = sum(w * h for _, _, _, w, h, g in BLOCKS if g != "route")
    print(f"regions reserve {used:.0f} um2 = {100*used/S:.1f} % of the slot; "
          f"devices are {MEASURED_TOTAL:.0f} um2 = {100*MEASURED_TOTAL/S:.1f} %")
    print("rules:")
    for label, a, b, kind, lim in RULES:
        print(f"  {label:<34} {gap(by_name(a), by_name(b)):6.1f} um  ({kind} {lim})")
    for label, a, pin, kind, lim in PIN_RULES:
        print(f"  {label:<34} {pin_gap(by_name(a), pin):6.1f} um  ({kind} {lim})")
    bad = check()
    if bad:
        print(f"\n{len(bad)} problem(s):")
        for b in bad:
            print(f"  {b}")
        return 1
    print("\nevery region is inside the slot, none overlap, each holds its devices, every rule holds")
    return 0


# Which region each netlist instance is placed in, for chipalooza's placement-only slot GDS
# (tools/slot_gds.py there). Instance-path regex, first match wins; every device must match.
PLACE = [
    (r"/Xlf/",  "loop filter (Cz Cp Rz)"),
    (r"/Xcp/",  "charge pump"),
    (r"/Xpfd/", "PFD"),
    (r"/Xdiv/", "divider /N"),
    (r"/Xvco/", "VCO ring + output buffer"),
]
# Every analog region keeps its guard ring free; Rz folds at the height used above.
PACK = {r[0]: dict(inset=GUARD) for r in BLOCKS if r[5] != "route"}
# Rz is placed STRAIGHT (1.40 x 89.22 um fits the 94 um inner height). Folding it with the
# PDK's serpentine changes what LVS extracts -- per-segment l plus bends -- so a folded Rz
# would need b and a per-segment l in the schematic, and a re-simulation for the bend
# resistance. Found by LVS on the first routed slot GDS (2026-10-04).
PACK["VCO ring + output buffer"]["order"] = "netlist"   # stages X1..X7 in sequence, not by size

COLOUR = {"lf": "#2a9d8f", "cp": "#e76f51", "pfd": "#adb5bd", "div": "#ced4da",
          "vco": "#219ebc", "route": "#ffffff"}


def svg():
    S = 1.6
    H = SLOT_H
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{SLOT_W*S+80:.0f}" height="{H*S+90:.0f}">',
           '<rect width="100%" height="100%" fill="#ffffff"/>',
           f'<text x="40" y="26" font-family="sans-serif" font-size="15" font-weight="bold">'
           f'pll_rosc floorplan -- {SLOT_W:g} x {SLOT_H:g} um slot (slot 6)</text>',
           f'<rect x="40" y="40" width="{SLOT_W*S:.0f}" height="{H*S:.0f}" '
           f'fill="#f8f9fa" stroke="#212529" stroke-width="2"/>']
    for n, x, y, w, h, g in BLOCKS:
        px, py = 40 + x * S, 40 + (H - y - h) * S
        dash = ' stroke-dasharray="4 3"' if g == "route" else ""
        out.append(f'<rect x="{px:.1f}" y="{py:.1f}" width="{w*S:.1f}" height="{h*S:.1f}" '
                   f'fill="{COLOUR[g]}" fill-opacity="0.75" stroke="#212529" stroke-width="1"{dash}/>')
        out.append(f'<text x="{px+3:.1f}" y="{py+13:.1f}" font-family="sans-serif" font-size="10">{n}</text>')
    for pin, (px, y1, y2) in PINS.items():
        x = 40 + px * S - (4 if px > 0 else 0)
        out.append(f'<rect x="{x:.1f}" y="{40+(H-y2)*S:.1f}" width="4" height="{(y2-y1)*S:.1f}" fill="#d00000"/>')
        tx = x - 4 - 6.2 * len(pin) if px > 0 else x + 8
        out.append(f'<text x="{tx:.1f}" y="{40+(H-(y1+y2)/2)*S+4:.1f}" font-family="sans-serif" '
                   f'font-size="10" fill="#d00000">{pin}</text>')
    out.append(f'<text x="40" y="{H*S+62:.0f}" font-family="sans-serif" font-size="11">'
               f'first-cut placement from measured device geometry; red = wrapper pins; '
               f'dashed = reserved routing channel</text>')
    out.append("</svg>\n")
    p = os.path.join(ROOT, "doc", "datasheet", "pll_rosc_floorplan.svg")
    open(p, "w").write("\n".join(out))
    print(f"wrote {os.path.relpath(p, ROOT)}")


if __name__ == "__main__":
    rc = report()
    if "--svg" in sys.argv and rc == 0:
        svg()
    sys.exit(rc)
