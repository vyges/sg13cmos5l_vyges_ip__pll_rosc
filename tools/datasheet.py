#!/usr/bin/env python3
"""Emit this IP's datasheet from the simulation results already on disk.

The output is the CACE summary format -- one table per netlist source, the same rows in
every one, rows that cannot run against a given source marked Skip rather than dropped.
CACE itself is not a dependency; see doc/datasheet/README.md for why.

🔑 THIS FILE EXISTS TO CLOSE A SPECIFIC GAP. The headline figures for this block -- phase
margin, tuning range, Kvco -- used to be derived by a script that was NOT in this
repository, so "where does 49.3 degrees come from?" answered "a tool you cannot see". Every
number below is derived here, from inputs that ship here, by a rule stated here.

⛔ AND THE LOOP CONSTANTS BELONG WITH THE DESIGN, NOT WITH THE CHECKER. The external gate
carried Cz = 9.21 pF and Cp = 0.75 pF -- the capacitance those same geometries had before
the MoM density was recalibrated from 2.320 to 1.287 fF/um2 on 2026-09-01. Nothing told it
the design had moved, so it reproduced the pre-fix 38.4 degrees and would have failed a
block that passes. A checker's own constants need the same provenance as its measurements.

Usage:
    python3 tools/datasheet.py                 # write doc/datasheet/*.md
    python3 tools/datasheet.py --check         # verify README.md figures, exit 1 on drift

Inputs, all produced by sim/run.sh and sim/run_pvt.sh:
    sim/_report_tb_vco_sweep.spice.log   the tt tuning curve
    sim/_report_tb_pll_lock.spice.log    control voltage and phase error during lock
    sim/pvt/vco.txt                      corner temp vctrl frequency, 27 points
"""

import argparse
import math
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME = "pll_rosc"

# ------------------------------------------------------------------ loop parameters
#
# Every value here is a property of the drawn design, and each is stated with what fixes it
# so a reader can check it against the schematic rather than trust this file.
ICP = 1e-6          # charge-pump current: mirrored 1:1 from the harness ibias1u_* reference
RZ_NOM = 80.77e3    # rhigh, w = 1 um, l = 56.9 um -- measured, not sheet arithmetic
CZ = 5.11e-12       # cap_cmomf, 63 x 63 um at 1.287 fF/um2
CP = 0.417e-12      # cap_cmomf, 18 x 18 um at 1.287 fF/um2
RSH_TYP = 1360.0    # rhigh typical sheet, ohm/sq -- the sheet RZ_NOM was drawn against

# Rz corners are MEASURED on the PDK at each rhigh corner, never derived from sheet x
# geometry. Two reasons, both learned the hard way:
#
#  ⛔ The sheet ratio is not the resistance ratio. res_wcs is 1560/1360 = 1.147x the typical
#     sheet, but the measured resistor is 96.64/80.77 = 1.197x -- the difference is a width
#     correction that geometry arithmetic does not see. Scaling by sheet gives 92.7 kOhm and
#     the wrong phase margin.
#  ⛔ The corners themselves moved. This PDK pin carries the rhigh fix: +/-14.7 %, where it
#     was +/-25 % before. An external checker still holding the old 1020/1360/1700 sheets
#     computes a worst case that no longer exists.
#
# Rz is rhigh, and it sets both the loop zero AND the filter's high-frequency gain: raising
# it pushes crossover up faster than it lowers the zero, so a WORST-CASE sheet LOSES margin.
# That is the opposite direction to the same resistor in the LDO's nulling role, where it
# fails at both extremes for different reasons. Neither is guessable, so all three are swept.
RZ_CORNERS = [("res_bcs", 66.16e3), ("res_typ", 80.77e3), ("res_wcs", 96.64e3)]

# The divider settings the control bus can select. N is a loop parameter, not merely a
# frequency setting -- crossover goes as Icp*Kvco/N, so a programmable divider drags the
# crossover across the filter's fixed zero/pole pair. The design target is the WORST N.
DIVIDERS = (8, 16)

# The proposal's spec table says 100-800 MHz. Not 1 GHz: a checker here carried 1e9 for a
# while and so did the README, which overstated our own target and made the block look worse
# against it than it is.
VCO_SPEC_LO_HZ = 100e6
VCO_SPEC_HI_HZ = 800e6


def loop(rz, cz, cp, icp, kvco_hz_per_v, n):
    """(f_crossover, phase margin) for a type-II charge-pump loop.

        T(s) = (Icp*Kvco/N) * Z(s)/s
        Z(s) = (1 + s*Rz*Cz) / (s*(Cz+Cp)*(1 + s*Rz*Cz*Cp/(Cz+Cp)))

    with a zero at 1/(Rz*Cz) and a pole at (Cz+Cp)/(Rz*Cz*Cp). Crossover is found by
    bisection in log frequency, which is where the magnitude is monotonic.
    """
    k = icp * kvco_hz_per_v / n
    wz = 1 / (rz * cz)
    wp = (cz + cp) / (rz * cz * cp)

    def mag(w):
        return k * math.hypot(1, w / wz) / (w * (cz + cp) * math.hypot(1, w / wp) * w)

    lo, hi = 1.0, 1e12
    for _ in range(300):
        mid = math.sqrt(lo * hi)
        if mag(mid) > 1:
            lo = mid
        else:
            hi = mid
    wc = math.sqrt(lo * hi)
    return wc / (2 * math.pi), math.degrees(math.atan(wc / wz) - math.atan(wc / wp))


# ------------------------------------------------------------------ reading results

def _log(name):
    p = os.path.join(ROOT, "sim", f"_report_{name}.log")
    if not os.path.isfile(p):
        raise SystemExit(f"no such bench log: {p}\nrun sim/run.sh first")
    return open(p).read()


def vco_curve():
    """[(vctrl, f_out)] for the tt tuning sweep; f_out is None where it did not oscillate.

    ⛔ per4 is measured once per control point and the log repeats the name, so reading a
    single `per4` gives whichever matched first -- the SLOWEST point, which reads like a
    broken VCO. The curve is the result, never one sample.
    """
    pts = []
    for m in re.finditer(r"VCTRL ([\d.]+)(.*?)(?=VCTRL |\Z)", _log("tb_vco_sweep.spice"), re.S):
        vc, body = float(m.group(1)), m.group(2)
        if "NO-OSCILLATION" in body:
            pts.append((vc, None))
            continue
        p = re.search(r"^per4\s*=\s*([-0-9.eE+]+)", body, re.M)
        pts.append((vc, 4.0 / float(p.group(1)) if p else None))
    if not pts:
        raise SystemExit("the tuning sweep produced no control points")
    return pts


def pvt_kvco():
    """{corner/temp: Kvco} from the PVT tuning sweep.

    ⛔ The LOCAL slope at the high-gain end (0.70 -> 0.80 V), never the average across the
    tuning range. Loop gain is proportional to Kvco and this ring's curve is steepest at
    the bottom of the control range, so an average understates the worst case badly -- at
    ff/-40C it gives about 1168 MHz/V against a local 1989, which is the difference between
    reporting a pass and a fail. The worst case is the point of the sweep.
    """
    p = os.path.join(ROOT, "sim", "pvt", "vco.txt")
    if not os.path.isfile(p):
        return {}
    rows = {}
    for line in open(p):
        f = line.split()
        if len(f) == 4 and f[3] != "fail":
            rows[(f[0], f[1], f[2])] = float(f[3])
    out = {}
    for (corner, temp, vc) in list(rows):
        if vc == "0.70" and (corner, temp, "0.80") in rows:
            out[f"{corner}/{temp}C"] = (rows[(corner, temp, "0.80")] - rows[(corner, temp, vc)]) / 0.1
    return out


def pvt_ceiling():
    """The highest output frequency GUARANTEED across PVT: the slowest corner's top.

    A tuning range measured at the typical corner is not a range the part can be sold on --
    the ceiling any unit reaches is set by the slowest corner, not the typical one.
    """
    p = os.path.join(ROOT, "sim", "pvt", "vco.txt")
    if not os.path.isfile(p):
        return None
    tops = {}
    for line in open(p):
        f = line.split()
        if len(f) == 4 and f[3] != "fail":
            key = (f[0], f[1])
            tops[key] = max(tops.get(key, 0.0), float(f[3]))
    return min(tops.values()) if tops else None


def pm_over_corners():
    """{N: (worst PM, where)} across every Kvco corner and every resistor corner."""
    kv = pvt_kvco()
    if not kv:
        return {}
    out = {}
    for n in DIVIDERS:
        worst = None
        for sheet, rz in RZ_CORNERS:
            for corner, k in sorted(kv.items()):
                _, pm = loop(rz, CZ, CP, ICP, k, n)
                if worst is None or pm < worst[0]:
                    worst = (pm, f"{corner} {sheet}")
        out[n] = worst
    return out


# Control-voltage samples the lock bench takes, in seconds. Lock time is resolved to this
# grid and no finer -- reporting "3.7 us" from samples at 2 and 4 us would be inventing
# precision the measurement does not have.
LOCK_SAMPLES = [(1e-6, "vc1u"), (2e-6, "vc2u"), (4e-6, "vc4u"), (6e-6, "vc6u"), (7.8e-6, "vc78")]
LOCK_TOL = 0.01     # "locked" = control voltage within 1 % of its final value


def lock_time():
    """Earliest sampled time at which the control voltage has settled to within LOCK_TOL.

    Stating the criterion is the point. "Locked" is not a property the simulator reports;
    it is a threshold someone chooses, and a figure published without it cannot be checked
    by anyone.
    """
    txt = _log("tb_pll_lock.spice")
    vals = {}
    for t, key in LOCK_SAMPLES:
        m = re.search(rf"^{key}\s*=\s*([-0-9.eE+]+)", txt, re.M)
        if m:
            vals[t] = float(m.group(1))
    if not vals:
        raise SystemExit("the lock bench measured no control voltage")
    final = vals[max(vals)]
    for t in sorted(vals):
        if abs(vals[t] - final) <= LOCK_TOL * abs(final):
            return t
    return None


def band():
    """(low, high) of the output band: the frequencies over the control range where the VCO
    meets its specified floor.

    🔑 The LOW end is derived, not chosen. The ring oscillates well below it -- 5.6 MHz at
    vctrl 0.40 V -- but those points are under the specified 100 MHz floor and are not part
    of any band the block can claim. Taking the raw minimum would publish 5.6 MHz as the
    bottom of the tuning range, which is true of the oscillator and false of the product.
    """
    osc = [f for _, f in vco_curve() if f]
    inband = [f for f in osc if f >= VCO_SPEC_LO_HZ]
    if not inband:
        raise SystemExit(f"no control point reaches the {VCO_SPEC_LO_HZ/1e6:.0f} MHz floor")
    return min(inband), max(osc)


def rows():
    lo_f, hi_f = band()
    pm = pm_over_corners()
    lock = lock_time()

    def one(v):
        return (v, v, v)

    out = [
        # Reported, not judged. The band's low end is the lowest CONTROL POINT that clears
        # the 100 MHz floor, and the control grid is 0.1 V -- the ring passes through the
        # floor somewhere between 0.50 V (34.4 MHz) and 0.60 V (115.4 MHz), so it plainly
        # covers it and the sweep simply cannot say where. Gating this row against the
        # floor would report a failure that is a property of the sampling, not the design.
        ("VCO tuning range, low", "MHz", None, None, one(lo_f)),
        ("VCO tuning range, high", "MHz", VCO_SPEC_HI_HZ, None, one(hi_f)),
        ("Lock time", "us", None, 20e-6, one(lock)),
    ]
    ceiling = pvt_ceiling()
    if ceiling:
        out.append(("Output ceiling over PVT", "MHz", VCO_SPEC_HI_HZ, None, one(ceiling)))
    for n in DIVIDERS:
        if n in pm:
            out.append((f"Phase margin, N = {n}", "deg", 45.0, None, one(pm[n][0])))
    return out


# Rows whose measurement cannot run against a given netlist source. Declared and Skipped
# rather than omitted: a missing row reads as an oversight, a Skipped one says the check
# exists and what it will be judged against. There is no extracted layout yet, and the
# physical checks will come from the Loom engines when there is -- `vacuous` maps to Skip.
PHYSICAL = [
    ("Area", "um2", None, 530 * 310e-12),
    ("Magic DRC", "", None, 0),
    ("Netgen LVS", "", None, 0),
    ("KLayout DRC", "", None, 0),
    ("Antenna violations", "", None, 0),
]

SCALE = {"MHz": 1e-6, "us": 1e6, "deg": 1, "um2": 1e12, "MHz/V": 1e-6, "": 1}


# ------------------------------------------------------------------ rendering

def _fmt(v, unit):
    return f"{v * SCALE[unit]:.3f} {unit}".strip()


def _limit(v, unit):
    return "any" if v is None else _fmt(v, unit)


def _status(lo, hi, mn, mx):
    if lo is not None and mn < lo:
        return "Fail ❌"
    if hi is not None and mx > hi:
        return "Fail ❌"
    return "Pass ✅"


def table(source):
    out = [f"# Datasheet for {NAME}", "", f"**netlist source**: {source}", "",
           "| Parameter | Unit | Min Limit | Min Value | Typ Value | Max Limit | Max Value | Status |",
           "| :-------- | :--- | --------: | --------: | --------: | --------: | --------: | :----: |"]
    for disp, unit, lo, hi, (mn, ty, mx) in rows():
        out.append(f"| {disp} | {unit or '-'} | {_limit(lo, unit)} | {_fmt(mn, unit)} | "
                   f"{_fmt(ty, unit)} | {_limit(hi, unit)} | {_fmt(mx, unit)} | "
                   f"{_status(lo, hi, mn, mx)} |")
    for disp, unit, lo, hi in PHYSICAL:
        out.append(f"| {disp} | {unit or '-'} | {_limit(lo, unit)} | ​ | ​ | "
                   f"{_limit(hi, unit)} | ​ | Skip 🟧 |")
    return "\n".join(out) + "\n"


# ------------------------------------------------------------------ published-figure check
#
# Which README table row each derived figure is published in. Only the LABELS are here; the
# values are parsed out of README.md at check time. Copying the numbers into this file would
# recreate the duplication this check exists to catch.
PUBLISHED_AS = {
    "VCO tuning range, low": ("Output, typical corner", 0),
    "VCO tuning range, high": ("Output, typical corner", 1),
    "Lock time": ("Lock time", 0),
    "Output ceiling over PVT": ("Output, guaranteed over PVT", 0),
    "Phase margin, N = 16": ("Phase margin, N = 16", 0),
    "Phase margin, N = 8": ("Phase margin, N = 8", 0),
}

NUM = re.compile(r"[-+]?\d+\.?\d*")


def _tolerance(literal):
    """Half of the last digit the figure is published to.

    ⛔ Must come from the published literal, never a constant: a fixed 0.05 is half a
    megahertz against a figure quoted in MHz and fifty against one quoted in GHz, so a
    constant lets whole classes of row pass a window they cannot fall out of. A check that
    cannot fail proves nothing.
    """
    frac = literal.split(".")[1] if "." in literal else ""
    return 0.5 * 10 ** (-len(frac))


def _readme_figures():
    out = {}
    for line in open(os.path.join(ROOT, "README.md"), encoding="utf-8"):
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) >= 2:
            out[cells[0]] = NUM.findall(cells[1])
    return out


def check():
    by_name = {r[0]: r for r in rows()}
    published = _readme_figures()
    bad, missing = [], []
    print(f"{'figure':<28} {'published':>10} {'derived':>10}   status")
    for name, (label, idx) in PUBLISHED_AS.items():
        if name not in by_name:
            missing.append(name)
            continue
        if label not in published or len(published[label]) <= idx:
            raise SystemExit(f"README.md has no figure {idx} in row {label!r} -- the table "
                             f"was edited without updating tools/datasheet.py")
        literal = published[label][idx]
        disp, unit, lo, hi, (mn, ty, mx) = by_name[name]
        derived = ty * SCALE[unit]
        ok = abs(derived - float(literal)) <= _tolerance(literal)
        if not ok:
            bad.append(name)
        print(f"{name:<28} {literal:>10} {derived:>10.6g}   {'ok' if ok else 'DRIFTED'}")
    if missing:
        print(f"\n{len(missing)} figure(s) could not be derived -- the inputs are absent:")
        for n in missing:
            print(f"  {n}   (run sim/run_pvt.sh)")
        return 2
    if bad:
        print(f"\n{len(bad)} published figure(s) no longer match the simulations:")
        for n in bad:
            print(f"  {n}")
        return 1
    print("\nevery figure README.md publishes still matches the simulation behind it")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="verify README figures against the simulations; exit 1 on drift")
    a = ap.parse_args()
    if a.check:
        return check()
    d = os.path.join(ROOT, "doc", "datasheet")
    os.makedirs(d, exist_ok=True)
    for source in ("schematic",):
        p = os.path.join(d, f"{NAME}_{source}.md")
        open(p, "w").write(table(source))
        print(f"wrote {os.path.relpath(p, ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
