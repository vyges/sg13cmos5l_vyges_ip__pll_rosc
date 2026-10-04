# Area budget for the ring-oscillator PLL, from GENERATED geometry rather than estimates.
#
# Every transistor, resistor and capacitor in the netlist is instantiated with the PDK's own
# PyCell and its bounding box measured; every standard cell is sized from the PDK's LEF. That
# is the only way to answer "does it fit" without guessing at contact rows and enclosures.
# Same method as the LDO's tools/area_budget.py, extended to lv devices and standard cells.
#
#   KLAYOUT_PATH=<pdk>/libs.tech/klayout klayout -zz -r tools/area_budget.py \
#       -rd net=<xschem netlist of pll_rosc> -rd lef=<pdk>/libs.ref/sg13cmos5l_stdcell/lef/sg13cmos5l_stdcell.lef
#
# Prints one line per DEVICE (cell, instance, model, W x H) and per-cell totals; that table is
# what tools/floorplan.py takes its footprints from.
#
# ⚠️ WHAT THIS IS NOT: a floorplan. It sums device bounding boxes. Routing, guard rings, taps
# and spacing are the floorplan's job.
import re, os, sys

layout = pya.Layout()
layout.technology_name = "sg13cmos5l"
dbu = layout.dbu

NET = globals().get("net", "/work/sim/netlist/pll_rosc.spice")
LEF = globals().get("lef")
SLOT_W, SLOT_H = 537.15, 273.0          # slot6_wrapper outline, harness @ 1906830

MAP = {"sg13_hv_nmos": "nmosHV", "sg13_hv_pmos": "pmosHV",
       "sg13_lv_nmos": "nmos", "sg13_lv_pmos": "pmos",
       "rhigh": "rhigh", "cap_cmomf": "cap_cmomf"}


def um(v):
    v = v.strip()
    return float(v[:-1]) * 1e-6 if v.endswith("u") else float(v)


def lef_sizes(path):
    out, cur = {}, None
    for ln in open(path):
        t = ln.split()
        if t[:1] == ["MACRO"]:
            cur = t[1]
        elif t[:1] == ["SIZE"] and cur:
            out[cur] = (float(t[1]), float(t[3]))
            cur = None
    return out


STD = lef_sizes(LEF) if LEF else {}
cache = {}


def dev_dims(model, p):
    key = (model, tuple(sorted(p.items())))
    if key in cache:
        return cache[key]
    name = MAP[model]
    if model.startswith("sg13_"):
        par = {"w": um(p["w"]), "l": um(p["l"]), "ng": int(float(p.get("ng", 1)))}
    elif model == "rhigh":
        par = {"w": um(p["w"]), "l": um(p["l"])}
    else:
        par = {"w": um(p["w"]), "l": um(p["l"]), "nx": 1, "ny": 1,
               "topmetal": int(float(p.get("mmax", 4))), "botmetal": int(float(p.get("mmin", 1)))}
    try:
        c = layout.create_cell(name, "SG13_dev", par)
        b = c.bbox()
        cache[key] = (b.width() * dbu, b.height() * dbu)
    except Exception as e:
        print("  ! %s %s: %s" % (model, par, str(e)[:70]))
        cache[key] = None
    return cache[key]


# Walk the .subckt definitions. Hierarchy is flattened by multiplying each sub-cell's
# instances by how often the parent instantiates it -- the ring's seven cs_inv stages matter.
subckts, cur = {}, None
for line in open(NET):
    t = line.split()
    if not t:
        continue
    if t[0] in (".subckt", "**.subckt"):
        cur = t[1]; subckts[cur] = []
    elif t[0] in (".ends", "**.ends"):
        cur = None
    elif cur and t[0][0] in "Xx":
        subckts[cur].append(t)

rows = []                                   # (path, model, W, H)


def walk(cell, path):
    for t in subckts.get(cell, []):
        inst = path + "/" + t[0]
        model = next((x for x in t if x in MAP), None)
        p = dict(kv.split("=", 1) for kv in t if "=" in kv)
        if model and "w" in p and "l" in p:
            d = dev_dims(model, p)
            m = int(float(p.get("m", 1)))
            for _ in range(m):
                rows.append((inst, model, d))
            continue
        sub = next((x for x in reversed(t) if "=" not in x and x in subckts), None)
        std = next((x for x in reversed(t) if "=" not in x and x in STD), None)
        if sub:
            walk(sub, inst)
        elif std:
            rows.append((inst, std, STD[std]))
        else:
            rows.append((inst, "?" + t[-1], None))


top = sys.argv[-1] if False else "pll_rosc"
walk(top, top)
tot, unknown, per = 0.0, [], {}
print("%-34s %-22s %16s %10s" % ("instance", "model", "W x H um", "area um2"))
for inst, model, d in rows:
    if d is None:
        unknown.append((inst, model)); continue
    a = d[0] * d[1]
    tot += a
    blk = inst.split("/")[1] if inst.count("/") >= 1 else inst
    per[blk] = per.get(blk, 0.0) + a
    print("%-34s %-22s %7.2f x %6.2f %10.1f" % (inst, model, d[0], d[1], a))
print("-" * 86)
print("%d devices measured, %d not generated" % (len(rows) - len(unknown), len(unknown)))
for i, m in unknown:
    print("   NOT GENERATED: %s (%s)" % (i, m))
print("\nper top-level instance:")
for b, a in sorted(per.items(), key=lambda x: -x[1]):
    print("  %-16s %9.1f um2  %5.2f %% of slot" % (b, a, 100 * a / (SLOT_W * SLOT_H)))
print("\ndevice area total : %10.1f um2  = %.2f %% of the %.2f x %.2f um slot"
      % (tot, 100 * tot / (SLOT_W * SLOT_H), SLOT_W, SLOT_H))
sys.exit(1 if unknown else 0)
