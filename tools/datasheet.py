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

Inputs, all produced by sim/run.sh, sim/run_pvt.sh and sim/run_cp.sh:
    sim/_report_tb_vco_sweep.spice.log   the tt tuning curve
    sim/_report_tb_pll_lock.spice.log    control voltage and phase error during lock
    sim/pvt/vco.txt                      corner temp rail vctrl frequency, 189 points
    sim/pvt/cp_*.csv                     charge-pump branch currents vs vctrl, 27 corners
"""

import argparse
import glob
import math
import os
import re
import sys
from datetime import datetime, timezone

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME = "pll_rosc"

# ------------------------------------------------------------------ loop parameters
#
# Every value here is a property of the drawn design, and each is stated with what fixes it
# so a reader can check it against the schematic rather than trust this file.
# ⛔ Icp IS NOT A CONSTANT HERE ANY MORE, AND IT NEVER SHOULD HAVE BEEN. This file used to
# carry ICP = 1e-6, "mirrored 1:1 from the harness ibias1u_* reference". The mirror is 1:1
# in WIDTH; it is not 1:1 in drain-source voltage, and on 0.5 um devices that is worth more
# than half the current. Measured (sim/run_cp.sh, 27 corners) the pump delivers 1.16-2.26 uA
# and tracks rail and process. Loop gain is proportional to it, so a phase margin computed
# from 1 uA is the phase margin of a different loop. The value below is what the HARNESS
# supplies into `ibias`; what the pump does with it is read from the measurement.
# 🔑 250 nA, NOT 1 uA, AND THE FILTER IS THE REASON. Required loop-filter capacitance
# scales with the pump current, so the reference this block asks the harness for is an AREA
# decision as much as a bias one: from the 1 uA rail the measured pump delivers 1.16-2.26 uA
# and a filter holding 45 degrees costs 15,908 um2; from the 250 nA rail the filter below
# costs 6,980 um2 and holds 53.9. It also asks the shared rail for less rather than more.
IBIAS_REF = 250e-9  # the harness reference current this block asks for (ibias1_250n)
RZ_NOM = 125.09e3   # rhigh, w = 1 um, l = 88 um -- measured, not sheet arithmetic
CZ = 8.654e-12      # cap_cmomf, 82 x 82 um at 1.287 fF/um2
CP = 0.3295e-12     # cap_cmomf, 16 x 16 um at 1.287 fF/um2
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
# Re-measured at l = 88 um when the filter was re-sized. ✅ The corner RATIOS came back
# unchanged -- 0.8188/1.1971 against 0.8189/1.1967 at l = 56.9 um -- which is the evidence
# that the width correction above is a function of WIDTH and not of length, and that a
# length change may be scaled. It was measured rather than assumed because this file says
# to measure it, and the same run reproduced all three of the old values to within 0.07 %.
RZ_CORNERS = [("res_bcs", 102.42e3), ("res_typ", 125.09e3), ("res_wcs", 149.75e3)]

# ⛔ THE SPECIFIED SUPPLY RAIL, AND IT IS A SPECIFICATION AND NOT A SWEEP RANGE.
# This block runs entirely from the 1.2 V core rail, which is a hard input requirement. The
# PDK ships two core-rail families -- 1p08/1p20/1p32 and 1p35/1p50/1p65 -- so a 1.2 V rail
# has exactly these corners.
#
# The sweep previously ran 0.98 / 1.20 / 1.50 V on the strength of a verbal sketch recorded
# only in a code comment, and NEITHER outer point is a corner of a 1.2 V rail: 0.98 V is
# BELOW the slowest characterised standard cell, which makes it undefined rather than
# pessimistic (the PFD and divider are standard cells), and 1.50 V is the other family's
# nominal, i.e. a different rail choice. The block's own proposal had said 1.08-1.32 V all
# along. Both are still swept and are reported separately for comparison; they are not
# corners, so they are not judged.
RAILS_SPEC = ("1.08", "1.20", "1.32")

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
    """{corner/temp/rail control-span: Kvco} -- EVERY local slope the sweep resolves.

    ⛔ The LOCAL slope, never the average across the tuning range. Loop gain is proportional
    to Kvco and this ring's curve is steepest at the bottom of the control range, so an
    average understates the worst case badly -- at ff/-40C it gives about 1168 MHz/V
    against a local 1989, which is the difference between reporting a pass and a fail.

    ⛔ AND EVERY SEGMENT, NOT THE STEEPEST ONE. This returned a single slope per corner,
    taken at the two lowest control points, on the assumption that the worst case for
    stability is the highest Kvco. That assumption is wrong for a type-II loop, which loses
    phase margin at BOTH ends of the gain spread: high Kvco pushes the crossover up toward
    the filter pole, low Kvco lets it fall back toward the zero. With this filter the
    N = 16 window is Kvco >= ~720 MHz/V, and the low end of it is the FLAT TOP of the
    tuning curve -- 346 MHz/V between 1.1 and 1.2 V where the bottom of the same curve
    reads 1650. Keeping only the steep pair discarded exactly the segments that fail.

    🔑 The label carries the control span, because a corner no longer names one number.
    """
    # ⛔ FIND the control points, never NAME them. These were hardcoded to 0.70 -> 0.80 V,
    # which silently became "the 1.20 V rail only" the moment the sweep started expressing
    # control as a fraction of the supply: 0.70 V is not a swept point at 0.98 V or at
    # 1.50 V. The symptom was a phase-margin table that looked like the worst corner had
    # moved to the nominal rail, when in fact the other two rails had dropped out of the
    # calculation entirely.
    return {lab: kv for lab, kv, _, _, _ in _segments()}


def _segments(rails=RAILS_SPEC):
    """[(label, Kvco, Icp, f_lo, f_hi)] for every COMPLIANT control segment.

    Each segment carries its own measured pump current, because Icp and Kvco are both
    functions of the same corner and multiplying one corner's Kvco by another corner's --
    or by a constant -- is not a corner at all.
    """
    sweeps = cp_sweeps()
    out = []
    for key, pts in sorted(_tuning_rows().items()):
        if rails is not None and key[2] not in rails:
            continue
        cp = sweeps.get(key)
        lim = cp_limit(cp) if cp else float("inf")
        corner, temp, vdd = key
        for (lo_v, lo), (hi_v, hi) in zip(pts, pts[1:]):
            if hi_v == lo_v or hi_v > lim + 1e-9:
                continue
            icp = cp_icp(cp, (lo_v + hi_v) / 2) if cp else IBIAS_REF
            out.append((f"{corner}/{temp}C/{vdd}V {lo_v:.2f}-{hi_v:.2f}",
                        (hi - lo) / (hi_v - lo_v), icp, lo, hi))
    return out


# The reference range this block is specified over. It is a loop-stability input and not
# only a datasheet row: the loop settles where f_out = N * f_ref, so a tuning-curve segment
# whose f_out needs a reference outside this band is not an operating point the part can be
# commanded into. Judging phase margin there is not conservatism -- it is judging a circuit
# that does not exist, and it costs capacitor area to satisfy.
FREF_LO_HZ, FREF_HI_HZ = 16e6, 50e6


def loop_points(rails=RAILS_SPEC):
    """[(label, Kvco, Icp, f_lo, N)] -- every operating point the part can be asked for."""
    return [(lab, kv, icp, f_lo, n) for lab, kv, icp, f_lo, f_hi in _segments(rails)
            for n in DIVIDERS if f_hi / n >= FREF_LO_HZ and f_lo / n <= FREF_HI_HZ]


# ------------------------------------------------------------------ the charge pump
#
# 🔑 THE CRITERION IS A CHOICE, SO IT IS STATED. "In compliance" is not something the
# simulator reports; it is a threshold someone picks. This one is: the up branch still
# delivers 90 % of its plateau current. It matters -- at 95 % the guaranteed ceiling reads
# 260 MHz on a 1.20 V rail and at 90 % it reads 513 MHz, because the current falls off a
# cliff over the last 150 mV. A figure published without its threshold cannot be checked.
CP_COMPLIANCE = 0.90


def cp_sweeps():
    """{(corner, temp, vdd): [(vctrl, i_up, i_dn)]} from sim/run_cp.sh."""
    out = {}
    for p in sorted(glob.glob(os.path.join(ROOT, "sim", "pvt", "cp_*.csv"))):
        corner, temp, vdd = os.path.basename(p)[3:-4].rsplit("_", 2)
        pts = []
        for line in open(p):
            c = line.split()
            # wrdata writes an x column per trace; the up current is column 1 and the down
            # current column 3, and the down branch SINKS, so its sign is flipped here.
            if len(c) >= 4:
                pts.append((float(c[0]), float(c[1]), -float(c[3])))
        if pts:
            out[(corner, temp, vdd)] = pts
    return out


def cp_limit(pts):
    """The highest control voltage the pump can still drive, by CP_COMPLIANCE.

    ⛔ This is the top of the usable control range, and it is well below the rail: the up
    branch's source device and switch need their Vdsat, so the current collapses to zero at
    vctrl = vdd. Every corner here holds to about 0.85 x vdd. Tuning-curve points above it
    are not operating points the loop can hold, and the lowest Kvco in the whole sweep --
    292 MHz/V, the one that used to set the phase-margin worst case -- is one of them.
    """
    plateau = max(u for _, u, _ in pts)
    for v, u, _ in pts:
        if v > 0.3 and u < CP_COMPLIANCE * plateau:
            return v
    return pts[-1][0]


def cp_icp(pts, vctrl):
    """The pump current at a control voltage: the mean of the two branches, which is what
    a PFD/charge-pump loop's small-signal gain uses. They are not equal -- the up branch
    runs 5-10 % high over most of the range -- so naming either one alone would bias it."""
    best = min(pts, key=lambda p: abs(p[0] - vctrl))
    return (best[1] + best[2]) / 2


def lock_points(n=16, fref=FREF_LO_HZ):
    """Per-corner operating point for the acquisition bench: (corner, temp, vdd, f0, kvco, vc0).

    🔑 WHY THIS IS DERIVED AND NOT WRITTEN DOWN. The acquisition bench models the ring
    behaviourally, and its F0/KVCO/VC0 describe the ring AT ONE CORNER -- they were taken
    from the tt curve around 0.70 V and then used to report a single lock time for the
    block. That was tolerable while lock read 4 us against a 20 us limit. It is not
    tolerable now: sizing the loop to respect its own f_ref/10 bound cost most of that
    margin, so the corner spread in lock time is the question rather than a detail.

    The target is the SLOWEST operating point the part can be asked for -- N * f_ref at the
    bottom of the reference range -- because acquisition scales with the loop gain there.
    A corner that cannot reach it inside the charge pump's compliance is reported as such
    rather than silently dropped.
    """
    target = n * fref
    sweeps = cp_sweeps()
    out = []
    for key, pts in sorted(_tuning_rows().items()):
        if key[2] not in RAILS_SPEC:
            continue
        cp = sweeps.get(key)
        lim = cp_limit(cp) if cp else float("inf")
        usable = [(v, f) for v, f in pts if v <= lim + 1e-9]
        # ⛔ "NOT IN THE SWEEP" AND "NOT IN THE CIRCUIT" ARE DIFFERENT ANSWERS, and calling
        # both unreachable hides one of them. The control sweep starts at 0.5 x vdd, so on a
        # 1.50 V rail its lowest point is 0.75 V and the band below that is simply not
        # characterised -- the ring runs there (5.6 MHz at 0.40 V on the tt curve), the
        # sweep just never asked. Above the compliance limit is the opposite: the pump
        # cannot hold the loop there at all, whatever the ring does.
        if len(usable) < 2:
            out.append((key, "no-compliant-points", None, None))
            continue
        if target < usable[0][1]:
            out.append((key, "below-sweep", None, None))
            continue
        if target > usable[-1][1]:
            out.append((key, "above-compliance", None, None))
            continue
        for (v0, f0), (v1, f1) in zip(usable, usable[1:]):
            if f0 <= target <= f1:
                kvco = (f1 - f0) / (v1 - v0)
                vc0 = v0 + (target - f0) / kvco
                out.append((key, target, kvco, vc0))
                break
    return out


def lock_over_corners():
    """(worst lock time, where, corners measured) from sim/run_lock.sh.

    ⛔ THE HEADLINE LOCK TIME IS ONE CORNER, AND IT IS NOT THE WORST ONE. The acquisition
    bench models the ring behaviourally at a single process/temperature/rail, which was
    defensible while lock read 4 us against a 20 us limit -- no corner spread closes a 5x
    gap. Sizing the loop to respect its own f_ref/10 bound spent most of that margin, so
    the spread is now the result rather than a detail.

    ⚠️ The count is returned and published with the figure. This is a worst case over the
    corners that were MEASURED, not over the corner set: each one is a transistor-level
    transient that takes hours, so they are chosen by loop gain at the lock point and the
    rest are inference. A worst case quoted without how many corners produced it invites
    exactly the reading it does not support.
    """
    p = os.path.join(ROOT, "sim", "pvt", "lock.txt")
    if not os.path.isfile(p):
        return None
    worst = None
    n = 0
    for line in open(p):
        f = line.split()
        if len(f) < 5 or "fail" in f:
            continue
        corner, temp, vdd, tstop = f[0], f[1], f[2], f[3]
        vals = [float(x) for x in f[4:]]
        n += 1
        total = float(tstop.rstrip("u")) * 1e-6
        step = total / len(vals)
        final = vals[-1]
        t_lock = total
        for i, v in enumerate(vals):
            if abs(v - final) <= LOCK_TOL * abs(final):
                t_lock = step * (i + 1)
                break
        if worst is None or t_lock > worst[0]:
            worst = (t_lock, f"{corner}/{temp}C/{vdd}V")
    return (worst[0], worst[1], n) if worst else None


def pvt_ceiling():
    """The highest output frequency GUARANTEED across PVT: the slowest corner's top.

    A tuning range measured at the typical corner is not a range the part can be sold on --
    the ceiling any unit reaches is set by the slowest corner, not the typical one.

    ⛔ And the top of the control range is the pump's limit, not the rail. Reading the
    ceiling at vctrl = vdd reports a frequency the loop cannot hold there, because the up
    branch has no current left to hold it: 599.5 MHz against 513.1 MHz on a 1.20 V rail.
    """
    sweeps = cp_sweeps()
    tops = {}
    for key, pts in _tuning_rows().items():
        if key[2] not in RAILS_SPEC:
            continue
        lim = cp_limit(sweeps[key]) if key in sweeps else float("inf")
        usable = [f for v, f in pts if v <= lim + 1e-9]
        if usable:
            tops[key] = max(usable)
    return min(tops.values()) if tops else None


def _tuning_rows():
    """{(corner, temp, vdd): [(vctrl, f_out)]} -- the tuning sweep, read once."""
    p = os.path.join(ROOT, "sim", "pvt", "vco.txt")
    out = {}
    if not os.path.isfile(p):
        return out
    for line in open(p):
        f = line.split()
        if len(f) == 5 and f[4] != "fail":
            key, v, hz = (f[0], f[1], f[2]), float(f[3]), float(f[4])
        elif len(f) == 4 and f[3] != "fail":
            key, v, hz = (f[0], f[1], "1.20"), float(f[2]), float(f[3])
        else:
            continue
        out.setdefault(key, []).append((v, hz))
    return {k: sorted(v) for k, v in out.items()}


def pm_over_corners(rails=RAILS_SPEC):
    """{N: (worst PM, where)} over every operating point and every resistor corner.

    Both gain terms come from measurement at the same corner: Kvco from the tuning sweep,
    Icp from the charge-pump sweep. ⛔ If the pump was never swept this returns nothing
    rather than falling back to the nominal reference current -- the fallback is how a
    figure gets published for a loop whose gain was assumed, and it reads exactly like a
    figure that was measured.
    """
    pts = loop_points(rails)
    if not pts or not cp_sweeps():
        return {}
    out = {}
    for n in DIVIDERS:
        worst = None
        for sheet, rz in RZ_CORNERS:
            for label, kvco, icp, _, pn in pts:
                if pn != n:
                    continue
                _, pm = loop(rz, CZ, CP, icp, kvco, n)
                if worst is None or pm < worst[0]:
                    worst = (pm, f"{label} {sheet}")
        if worst:
            out[n] = worst
    return out


def crossover_margin(rails=RAILS_SPEC):
    """(worst fc / (f_ref/10), where) -- the continuous-time approximation's own bound.

    A type-II charge-pump loop is a sampled system, and the s-domain phase margin above is
    only meaningful while the crossover stays well under the reference rate. The block has
    claimed f_ref/10 since the filter was first sized; this measures it instead.
    """
    pts = loop_points(rails)
    if not pts or not cp_sweeps():
        return None
    worst = None
    for sheet, rz in RZ_CORNERS:
        for label, kvco, icp, f_lo, n in pts:
            fc, _ = loop(rz, CZ, CP, icp, kvco, n)
            # Where a segment only reaches into the reference band from below, the binding
            # reference is the specified floor, not the segment's own bottom.
            ratio = fc / (max(f_lo / n, FREF_LO_HZ) / 10.0)
            if worst is None or ratio > worst[0]:
                worst = (ratio, f"N={n} {sheet} {label}")
    return worst


# Control-voltage samples the lock bench takes, in seconds. Lock time is resolved to this
# grid and no finer -- reporting "3.7 us" from samples at 2 and 4 us would be inventing
# precision the measurement does not have.
LOCK_SAMPLES = [(2e-6, "vc2u"), (4e-6, "vc4u"), (8e-6, "vc8u"), (12e-6, "vc12u"),
                (16e-6, "vc16u"), (20e-6, "vc20u"), (23.5e-6, "vc235")]
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
    # Published because the block has always CLAIMED it -- "the crossover stays below
    # f_ref/10 everywhere" was written when the filter was first sized and was never
    # measured. It is the bound that makes the s-domain phase margin above mean anything
    # for a sampled loop, so a margin quoted without it is quoted without its precondition.
    xo = crossover_margin()
    if xo:
        out.append(("Crossover, worst / (f_ref/10)", "", None, 1.0, one(xo[0])))
    lk = lock_over_corners()
    if lk:
        # Stable row name: the corner COUNT belongs in the prose, not in the key a checker
        # matches on, or adding a corner silently breaks the check it should have tightened.
        out.append(("Lock time, worst corner", "us", None, 20e-6, one(lk[0])))
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


def plots_section(written):
    """The figures, under the table. A table states a number; a plot shows the margin around
    it, which is what a reader deciding whether to use the block actually needs."""
    if not written:
        return ""
    out = ["", "## Plots", ""]
    for slug, caption in written:
        out += [f"### {caption}", "", f"![{caption}]({NAME}_{slug}.svg)", ""]
    return "\n".join(out)


# ------------------------------------------------------------------ published-figure check
#
# Which README table row each derived figure is published in. Only the LABELS are here; the
# values are parsed out of README.md at check time. Copying the numbers into this file would
# recreate the duplication this check exists to catch.
PUBLISHED_AS = {
    "VCO tuning range, low": ("Output, typical corner", 0),
    "VCO tuning range, high": ("Output, typical corner", 1),
    "Lock time": ("Lock time, typical", 0),
    "Output ceiling over PVT": ("Output, guaranteed over PVT", 0),
    "Phase margin, N = 16": ("Phase margin, N = 16", 0),
    "Phase margin, N = 8": ("Phase margin, N = 8", 0),
    "Crossover, worst / (f_ref/10)": ("Crossover vs f_ref/10", 0),
    "Lock time, worst corner": ("Lock time, worst measured corner", 0),
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


def footer():
    """Attribution line for the generated sheet.

    The year is taken from the clock at emit time rather than typed in, for the same
    reason every measured figure here is: a constant someone has to remember to update is
    a constant that goes stale, and this file exists to stop that happening.
    """
    return (f"\n---\n\n© {datetime.now(timezone.utc).year} Vyges "
            f"(https://vyges.com) · generated by `tools/datasheet.py`, "
            f"do not edit by hand\n")

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="verify README figures against the simulations; exit 1 on drift")
    ap.add_argument("--lock-points", action="store_true",
                    help="per-corner operating point for sim/run_lock.sh, one line each")
    a = ap.parse_args()
    if a.check:
        return check()
    if a.lock_points:
        pts = lock_points()
        if not pts:
            print("no tuning sweep on disk -- run sim/run_pvt.sh and sim/run_cp.sh",
                  file=sys.stderr)
            return 2
        for (corner, temp, vdd), f0, kvco, vc0 in pts:
            if isinstance(f0, str):
                # Printed, not dropped. A corner that cannot reach the slowest selectable
                # output inside the pump's compliance is a result about the block, and a
                # runner that simply saw fewer lines would report a clean sweep of a
                # smaller set without saying so.
                print(f"{corner} {temp} {vdd} {f0}")
            else:
                print(f"{corner} {temp} {vdd} {f0:.6g} {kvco:.6g} {vc0:.4f}")
        return 0
    d = os.path.join(ROOT, "doc", "datasheet")
    os.makedirs(d, exist_ok=True)
    written = []
    for slug, fn, caption in PLOTS:
        svg = fn()
        if svg is None:
            print(f"skipped plot {slug}: its inputs are absent")
            continue
        q = os.path.join(d, f"{NAME}_{slug}.svg")
        open(q, "w").write(svg)
        written.append((slug, caption))
        print(f"wrote {os.path.relpath(q, ROOT)}")
    for source in ("schematic",):
        p = os.path.join(d, f"{NAME}_{source}.md")
        open(p, "w").write(table(source) + plots_section(written) + footer())
        print(f"wrote {os.path.relpath(p, ROOT)}")
    return 0




# ---------------------------------------------------------------- plots
#
# Plots are emitted as SVG by hand rather than through matplotlib. The block's tooling is
# stdlib-only and staying that way matters more than the extra features would: an SVG is
# text, so it diffs and reviews like the rest of the repository, and there is no plotting
# library whose version can change what a published figure looks like.

def _svg(w, h, body, title):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}" font-family="sans-serif" font-size="12">\n'
            f'<title>{title}</title>\n'
            f'<rect width="{w}" height="{h}" fill="#ffffff"/>\n' + body + '</svg>\n')


def _axes(x0, y0, x1, y1, xlo, xhi, ylo, yhi, xlabel, ylabel, xfmt="{:g}", yfmt="{:g}"):
    """Frame, ticks and labels. Returns (svg, project) where project maps data -> pixels."""
    def px(x):
        return x0 + (x - xlo) / (xhi - xlo) * (x1 - x0)

    def py(y):
        return y1 - (y - ylo) / (yhi - ylo) * (y1 - y0)

    s = [f'<rect x="{x0}" y="{y0}" width="{x1-x0}" height="{y1-y0}" fill="none" '
         f'stroke="#334155" stroke-width="1"/>']
    for i in range(6):
        v = xlo + (xhi - xlo) * i / 5
        s.append(f'<line x1="{px(v):.1f}" y1="{y1}" x2="{px(v):.1f}" y2="{y1+4}" stroke="#334155"/>')
        s.append(f'<text x="{px(v):.1f}" y="{y1+18}" text-anchor="middle" fill="#334155">'
                 f'{xfmt.format(v)}</text>')
        if i:
            s.append(f'<line x1="{px(v):.1f}" y1="{y0}" x2="{px(v):.1f}" y2="{y1}" '
                     f'stroke="#e2e8f0" stroke-width="1"/>')
    for i in range(6):
        v = ylo + (yhi - ylo) * i / 5
        s.append(f'<line x1="{x0-4}" y1="{py(v):.1f}" x2="{x0}" y2="{py(v):.1f}" stroke="#334155"/>')
        s.append(f'<text x="{x0-8}" y="{py(v)+4:.1f}" text-anchor="end" fill="#334155">'
                 f'{yfmt.format(v)}</text>')
        if i:
            s.append(f'<line x1="{x0}" y1="{py(v):.1f}" x2="{x1}" y2="{py(v):.1f}" '
                     f'stroke="#e2e8f0" stroke-width="1"/>')
    s.append(f'<text x="{(x0+x1)/2:.0f}" y="{y1+38}" text-anchor="middle" fill="#0f172a">{xlabel}</text>')
    s.append(f'<text x="18" y="{(y0+y1)/2:.0f}" text-anchor="middle" fill="#0f172a" '
             f'transform="rotate(-90 18 {(y0+y1)/2:.0f})">{ylabel}</text>')
    return "\n".join(s) + "\n", px, py


def _series(pts, px, py, colour, width=2):
    d = " ".join(f"{'M' if i == 0 else 'L'}{px(x):.1f},{py(y):.1f}" for i, (x, y) in enumerate(pts))
    return (f'<path d="{d}" fill="none" stroke="{colour}" stroke-width="{width}" '
            f'stroke-linejoin="round"/>\n')


def _limit_line(val, px, py, x0, x1, label, colour="#dc2626"):
    """A specification limit, drawn so a reader can see the margin rather than compute it."""
    y = py(val)
    return (f'<line x1="{x0}" y1="{y:.1f}" x2="{x1}" y2="{y:.1f}" stroke="{colour}" '
            f'stroke-width="1.5" stroke-dasharray="6 4"/>\n'
            f'<text x="{x1-4}" y="{y-5:.1f}" text-anchor="end" fill="{colour}">{label}</text>\n')


CORNER_COLOURS = {"ss": "#2563eb", "tt": "#16a34a", "ff": "#dc2626"}


def plot_tuning():
    """The tt tuning curve, with the specification band it has to cover.

    This is the plot the block is judged on: the curve's top is the tuning-range figure,
    and the shortfall against 800 MHz is the block's headline miss. A reader should be able
    to see the miss rather than take it on trust from a table.
    """
    pts = [(v, f / 1e6) for v, f in vco_curve() if f]
    body, px, py = _axes(70, 30, 620, 330, 0.4, 1.2, 0, 900,
                         "control voltage (V)", "output frequency (MHz)",
                         "{:.1f}", "{:.0f}")
    body += _limit_line(VCO_SPEC_HI_HZ / 1e6, px, py, 70, 620, "800 MHz specified")
    body += _limit_line(VCO_SPEC_LO_HZ / 1e6, px, py, 70, 620, "100 MHz floor", "#64748b")
    body += _series(pts, px, py, "#16a34a")
    for v, f in pts:
        body += f'<circle cx="{px(v):.1f}" cy="{py(f):.1f}" r="3" fill="#16a34a"/>\n'
    top = max(f for _, f in pts)
    body += (f'<text x="620" y="24" text-anchor="end" fill="#0f172a">tt, 27 °C — '
             f'tops out at {top:.1f} MHz</text>\n')
    return _svg(650, 380, body, "VCO tuning curve")


def plot_tuning_pvt():
    """The tuning curve at every process corner and temperature.

    The typical curve is not what the part guarantees. Drawing all nine makes the spread
    visible and shows where the guaranteed ceiling comes from -- the slowest corner's top,
    not the typical one's.
    """
    p = os.path.join(ROOT, "sim", "pvt", "vco.txt")
    if not os.path.isfile(p):
        return None
    rows = {}
    for line in open(p):
        f = line.split()
        if len(f) == 5 and f[4] != "fail":
            rows.setdefault((f[0], f[1], f[2]), []).append((float(f[3]), float(f[4]) / 1e6))
        elif len(f) == 4 and f[3] != "fail":
            rows.setdefault((f[0], f[1], "1.20"), []).append((float(f[2]), float(f[3]) / 1e6))
    body, px, py = _axes(70, 30, 620, 330, 0.7, 1.2, 0, 1000,
                         "control voltage (V)", "output frequency (MHz)",
                         "{:.1f}", "{:.0f}")
    body += _limit_line(VCO_SPEC_HI_HZ / 1e6, px, py, 70, 620, "800 MHz specified")
    ceiling = pvt_ceiling()
    if ceiling:
        body += _limit_line(ceiling / 1e6, px, py, 70, 620,
                            f"{ceiling/1e6:.0f} MHz guaranteed", "#ea580c")
    for (corner, temp, _vdd), pts in sorted(rows.items()):
        body += _series(sorted(pts), px, py, CORNER_COLOURS.get(corner, "#64748b"), 1.5)
    for i, (c, col) in enumerate(sorted(CORNER_COLOURS.items())):
        body += (f'<line x1="{500}" y1="{46+i*16}" x2="{524}" y2="{46+i*16}" stroke="{col}" '
                 f'stroke-width="2"/><text x="530" y="{50+i*16}" fill="#334155">{c}</text>\n')
    return _svg(650, 380, body, "VCO tuning over PVT")


def plot_phase_margin():
    """Phase margin at every Kvco corner and resistor corner, per divider setting.

    ⛔ Both divider settings are drawn because their worst corners are OPPOSITE ones: N=8
    fails toward high Kvco and high Rz, N=16 toward low. A single-N plot would suggest the
    margin moves one way with corner, and it does not.

    The x axis is the loop gain Icp*Kvco/N, not Kvco: with Icp measured per corner rather
    than assumed constant, two points at the same Kvco no longer sit at the same gain.
    """
    all_pts = loop_points()
    if not all_pts:
        return None
    body, px, py = _axes(70, 30, 620, 330, 0, max(len(all_pts) // len(DIVIDERS) - 1, 1), 25, 65,
                         "operating point (increasing loop gain →)", "phase margin (deg)",
                         "{:.0f}", "{:.0f}")
    body += _limit_line(45.0, px, py, 70, 620, "45° specified")
    styles = {8: ("#dc2626", "N = 8"), 16: ("#2563eb", "N = 16")}
    for n in DIVIDERS:
        mine = sorted((kvco * icp / n, kvco, icp) for lab, kvco, icp, _, pn in all_pts
                      if pn == n)
        for sheet, rz in RZ_CORNERS:
            pts = [(i, loop(rz, CZ, CP, icp, kvco, n)[1])
                   for i, (_, kvco, icp) in enumerate(mine)]
            body += _series(pts, px, py, styles[n][0], 1.2)
    for i, n in enumerate(DIVIDERS):
        body += (f'<line x1="{500}" y1="{46+i*16}" x2="{524}" y2="{46+i*16}" '
                 f'stroke="{styles[n][0]}" stroke-width="2"/>'
                 f'<text x="530" y="{50+i*16}" fill="#334155">{styles[n][1]}</text>\n')
    body += ('<text x="620" y="24" text-anchor="end" fill="#0f172a">three resistor corners '
             'per divider setting</text>\n')
    return _svg(650, 380, body, "Phase margin over corners")


PLOTS = [("tuning", plot_tuning, "VCO tuning curve, typical corner"),
         ("tuning_pvt", plot_tuning_pvt, "VCO tuning over process and temperature"),
         ("phase_margin", plot_phase_margin, "Phase margin over Kvco and resistor corners")]


if __name__ == "__main__":
    sys.exit(main())
