#!/usr/bin/env python3
"""
sch_bridge.py -- draw a generated schematic's same-name connections as real wires.

A generated .sch can netlist perfectly and still read as a parts table: device terminals
carry a lab_pin each, and two terminals are on the same net only because their labels
spell the same word. This rewrites such a file so those connections are drawn, without
moving any device.

THE RULE IS OVER THE NETGRAPH, NOT OVER LINE GEOMETRY. Two schematic conventions exist in
our blocks and a geometric rule breaks one of them:

  - LDO style: the lab_pin sits at the far end of a throwaway stub from the terminal;
  - PLL style: the lab_pin sits ON the terminal and the wire leaving it is a real route.

"A wire touching a lab_pin is a stub" deletes real routing in the second (2026-09-18: all
eight PLL cells severed, `Rz vctrl nz` -> `Rz net1 nz`). So, in order:

  1. build connectivity the way xschem's netlister does: a wire ENDPOINT touching another
     wire anywhere connects; an instance pin touching a wire anywhere connects; two wires
     merely crossing do not;
  2. per net name, ADD wires (grid maze route) between fragments that share the name and
     are joined by no real wire, refusing any route that would touch another net;
  3. remove a lab_pin only if its fragment still carries the name through something else
     (a wired port, or one label kept per fragment);
  4. remove a wire only if it is a LEAF: one endpoint touches nothing, and nothing touches
     its interior. Removing a leaf cannot change connectivity, whatever its shape.

Ports (ipin/opin/iopin) are never moved or removed. A port that is not wired into its net
does not name it, so such a net keeps one lab_pin.

⛔ THIS SCRIPT'S CONNECTIVITY MODEL IS NOT THE PROOF. xschem's is: netlist the original
and the output, sort device lines, diff (`tools/sch_equiv.sh`). A checker written beside
this transform once passed a file missing a device entirely.
"""
import argparse, heapq, json, os, re, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ART = json.load(open(os.path.join(HERE, "sym_art.json")))

LABEL = "devices/lab_pin"
PORTS = {"devices/ipin", "devices/opin", "devices/iopin"}
NUM = r"(-?[0-9.eE+]+)"
RE_C = re.compile(r"^C\s+\{([^}]*)\}\s+" + NUM + r"\s+" + NUM + r"\s+(\d+)\s+(\d+)\s*\{(.*)\}\s*$")
RE_N = re.compile(r"^N\s+" + NUM + r"\s+" + NUM + r"\s+" + NUM + r"\s+" + NUM + r"\s*\{(.*)\}\s*$")

GRID = 10
BEND = 4          # grid steps a bend costs
CROSS = 12        # crossing another net's wire: legal, but read as clutter
HALO = 0          # grid steps of keep-out around a device body


def xf(x, y, rot, flip):
    if flip:
        x = -x
    for _ in range(rot % 4):
        x, y = -y, x
    return x, y


# ---------------------------------------------------------------- parse (record-preserving)

def records(path):
    """Split the file into records, keeping multi-line T/K/G/V/S/E blocks whole -- a
    split T{} block leaves an unterminated brace that swallows the next record."""
    out, buf, depth = [], [], 0
    for ln in open(path).read().split("\n"):
        buf.append(ln)
        depth += ln.count("{") - ln.count("}")
        if depth <= 0:
            out.append("\n".join(buf))
            buf, depth = [], 0
    if buf:
        out.append("\n".join(buf))
    return out


def sym_art(sym, srcdir):
    key = sym[:-4] if sym.endswith(".sym") else sym
    if key in ART:
        return ART[key]
    path = os.path.join(srcdir, key + ".sym")
    art = {"lines": [], "polys": [], "pins": []}
    if os.path.isfile(path):
        for ln in open(path, errors="ignore"):
            t = ln.split()
            if ln.startswith("L ") and len(t) >= 6:
                art["lines"].append([float(v) for v in t[2:6]])
            elif ln.startswith("B ") and "name=" in ln:
                x1, y1, x2, y2 = (float(v) for v in t[2:6])
                nm = re.search(r"name=([^\s}]+)", ln).group(1)
                art["pins"].append([nm, (x1 + x2) / 2, (y1 + y2) / 2])
        return art
    sys.exit(f"sch_bridge: no artwork for symbol {sym} -- refresh sym_art.json")


class Sch:
    def __init__(self, path):
        self.path = path
        self.srcdir = os.path.dirname(os.path.abspath(path))
        self.recs = records(path)
        self.wires = {}      # rec index -> (x1,y1,x2,y2,lab)
        self.inst = {}       # rec index -> dict
        for i, r in enumerate(self.recs):
            m = RE_N.match(r)
            if m:
                x1, y1, x2, y2 = (float(v) for v in m.groups()[:4])
                lab = re.search(r"lab=([^\s}]+)", m.group(5))
                self.wires[i] = (x1, y1, x2, y2, lab.group(1) if lab else None)
                continue
            m = RE_C.match(r)
            if m:
                sym, x, y, rot, flip, attr = m.groups()
                key = sym[:-4] if sym.endswith(".sym") else sym
                d = dict(re.findall(r"(\w+)=([^\s}]+)", attr))
                x, y, rot, flip = float(x), float(y), int(rot), int(flip)
                art = sym_art(sym, self.srcdir)
                pins = [(p[0],) + tuple(a + b for a, b in zip(xf(p[1], p[2], rot, flip), (x, y)))
                        for p in art["pins"]]
                xs, ys = [], []
                for l in art["lines"]:
                    for px, py in ((l[0], l[1]), (l[2], l[3])):
                        tx, ty = xf(px, py, rot, flip); xs.append(tx + x); ys.append(ty + y)
                for p in art.get("polys", []):
                    for k in range(0, len(p) - 1, 2):
                        tx, ty = xf(p[k], p[k + 1], rot, flip); xs.append(tx + x); ys.append(ty + y)
                self.inst[i] = dict(sym=key, x=x, y=y, attr=d, pins=pins,
                                    bbox=(min(xs), min(ys), max(xs), max(ys)) if xs else None)

    def kind(self, i):
        s = self.inst[i]["sym"]
        return "label" if s == LABEL else "port" if s in PORTS else "dev"

    def write(self, path, drop, add):
        out = [r for i, r in enumerate(self.recs) if i not in drop]
        while out and out[-1] == "":
            out.pop()
        out += add
        open(path, "w").write("\n".join(out) + "\n")


# ---------------------------------------------------------------- connectivity (xschem's)

def on_seg(px, py, w):
    x1, y1, x2, y2 = w[:4]
    if (px - x1) * (y2 - y1) - (py - y1) * (x2 - x1) != 0:
        return False
    return min(x1, x2) <= px <= max(x1, x2) and min(y1, y2) <= py <= max(y1, y2)


class DSU:
    def __init__(self):
        self.p = {}

    def f(self, a):
        self.p.setdefault(a, a)
        while self.p[a] != a:
            self.p[a] = self.p[self.p[a]]
            a = self.p[a]
        return a

    def u(self, a, b):
        self.p[self.f(a)] = self.f(b)


def connect(wires, pins):
    """wires: {id: (x1,y1,x2,y2,...)}, pins: [(key, x, y)] -> DSU over ('w',id) and pin keys."""
    d = DSU()
    wl = list(wires.items())
    for wid, w in wl:
        d.f(("w", wid))
    for a, wa in wl:
        for b, wb in wl:
            if a < b and (on_seg(wa[0], wa[1], wb) or on_seg(wa[2], wa[3], wb)
                          or on_seg(wb[0], wb[1], wa) or on_seg(wb[2], wb[3], wa)):
                d.u(("w", a), ("w", b))
    bypt = defaultdict(list)
    for k, x, y in pins:
        d.f(k)
        bypt[(x, y)].append(k)
        for wid, w in wl:
            if on_seg(x, y, w):
                d.u(k, ("w", wid))
    for ks in bypt.values():          # pins on the same point touch directly
        for k in ks[1:]:
            d.u(ks[0], k)
    return d


# ---------------------------------------------------------------- the transform

def bridge(sch, route_ports=False, verbose=False):
    pins = []                         # (key, x, y)
    pin_owner = {}                    # key -> (inst idx, pin name)
    for i, ins in sch.inst.items():
        for n, (pn, x, y) in enumerate(ins["pins"]):
            k = ("p", i, n)
            pins.append((k, x, y))
            pin_owner[k] = (i, pn)
    wires = {("o", i): w for i, w in sch.wires.items()}

    d = connect(wires, pins)
    # net name of every fragment, from its labels and ports
    names = defaultdict(set)
    for k, x, y in pins:
        i = pin_owner[k][0]
        if sch.kind(i) != "dev":
            names[d.f(k)].add(sch.inst[i]["attr"].get("lab"))
    # every element's fragment
    frag_of = {k: d.f(k) for k, _, _ in pins}
    for wid in wires:
        frag_of[("w", wid)] = d.f(("w", wid))
    for r, ns in names.items():
        if len(ns) > 1:
            sys.exit(f"sch_bridge: {sch.path}: one fragment carries two names {sorted(ns)} -- "
                     "the input is already shorted")
    net_of_frag = {r: next(iter(ns)) for r, ns in names.items()}

    # fragments per net, as the routable things inside each
    frags = defaultdict(lambda: defaultdict(lambda: {"pts": set(), "devpins": 0, "ports": 0}))
    for k, x, y in pins:
        r = frag_of[k]
        if r not in net_of_frag:
            continue
        kind = sch.kind(pin_owner[k][0])
        f = frags[net_of_frag[r]][r]
        if kind == "dev":
            f["devpins"] += 1
        elif kind == "port":
            f["ports"] += 1
        f["pts"].add((x, y))
    for wid, w in wires.items():
        r = frag_of[("w", wid)]
        if r in net_of_frag:
            f = frags[net_of_frag[r]][r]
            for x, y in grid_pts(w):
                f["pts"].add((x, y))

    # obstacle maps
    body = set()
    for i, ins in sch.inst.items():
        if sch.kind(i) == "dev" and ins["bbox"]:
            x1, y1, x2, y2 = ins["bbox"]
            for gx in range(snap_up(x1) + GRID, snap_dn(x2), GRID):
                for gy in range(snap_up(y1) + GRID, snap_dn(y2), GRID):
                    body.add((gx, gy))
    ob = Obstacles()
    for k, x, y in pins:
        ob.point(x, y, net_of_frag.get(frag_of[k], ("anon", frag_of[k])))
    for wid, w in wires.items():
        ob.wire(w, net_of_frag.get(frag_of[("w", wid)], ("anon", frag_of[("w", wid)])))

    added, unrouted = [], []
    order = sorted(frags, key=lambda n: (len(frags[n]), n))
    for net in order:
        fl = [f for f in frags[net].values() if route_ports or f["devpins"] or not f["ports"]]
        if len(fl) < 2:
            continue
        fl.sort(key=lambda f: -len(f["pts"]))
        tree = set(p for p in fl[0]["pts"] if on_grid(p))
        rest = fl[1:]
        while rest:
            targets = {}
            for n, f in enumerate(rest):
                for p in f["pts"]:
                    if on_grid(p):
                        targets[p] = n
            path = route(tree, targets, net, body, ob)
            if path is None:
                unrouted += [(net, f) for f in rest]
                break
            n = targets[path[-1]]
            segs = to_segments(path)
            for s in segs:
                w = (s[0], s[1], s[2], s[3], net)
                wires[("a", len(added))] = w
                added.append(w)
                ob.wire(w, net)
                tree.update(grid_pts(w))
            tree |= set(p for p in rest[n]["pts"] if on_grid(p))
            rest.pop(n)

    # ---- label clean-up over the bridged graph
    d2 = connect(wires, pins)
    comp_ports = defaultdict(int)
    for k, x, y in pins:
        if sch.kind(pin_owner[k][0]) == "port":
            comp_ports[d2.f(k)] += 1
    drop, kept_label = set(), {}
    for k, x, y in pins:
        i = pin_owner[k][0]
        if sch.kind(i) != "label":
            continue
        c = d2.f(k)
        if comp_ports[c] or c in kept_label:
            drop.add(i)
        else:
            kept_label[c] = i

    # ---- trim dangling wire ends, iteratively
    # A free END (touching nothing) is cut back to the nearest point that something does
    # touch -- an interior T, a pin, or the other end. A wire with nothing touching it
    # anywhere but one end is a leaf and goes entirely. Neither can change connectivity:
    # only the part beyond the last connection is removed.
    live_pins = [(x, y) for k, x, y in pins if pin_owner[k][0] not in drop]
    trimmed, gone = set(), set()
    changed = True
    while changed:
        changed = False
        for wid, w in list(wires.items()):
            if wid in gone:
                continue
            others = [v for u, v in wires.items() if u != wid and u not in gone]
            ends = ((w[0], w[1]), (w[2], w[3]))
            # every point along w that something else touches
            hits = set(p for p in live_pins if on_seg(p[0], p[1], w))
            for v in others:
                for p in ((v[0], v[1]), (v[2], v[3])):
                    if on_seg(p[0], p[1], w):
                        hits.add(p)
                for p in ends:
                    if on_seg(p[0], p[1], v):
                        hits.add(p)
            free = [p for p in ends if p not in hits]
            if not free:
                continue
            if not hits or (len(hits) == 1 and len(free) == 1):
                gone.add(wid); changed = True; continue   # leaf (or orphan)
            dist = lambda p, q: abs(p[0] - q[0]) + abs(p[1] - q[1])
            lo = min(hits, key=lambda p: dist(p, ends[0]))
            hi = min(hits, key=lambda p: dist(p, ends[1]))
            nw = ((lo if ends[0] in free else ends[0]) + (hi if ends[1] in free else ends[1]) + tuple(w[4:]))
            if nw[:2] == nw[2:4]:
                gone.add(wid); changed = True; continue
            wires[wid] = nw
            trimmed.add(wid); changed = True

    drop |= {wid[1] for wid in gone | trimmed if wid[0] == "o"}
    add = []
    for wid, w in wires.items():
        if wid in gone:
            continue
        if wid[0] == "a" or wid in trimmed:
            lab = w[4] if wid[0] == "a" else (w[4] or "")
            add.append("N %g %g %g %g {lab=%s}" % (w[0], w[1], w[2], w[3], lab))
    stats = dict(labels_before=sum(1 for i in sch.inst if sch.kind(i) == "label"),
                 labels_after=sum(1 for i in sch.inst if sch.kind(i) == "label" and i not in drop),
                 wires_added=sum(1 for w in wires if w[0] == 'a' and w not in gone), wires_pruned=len(gone), wires_trimmed=len(trimmed),
                 unrouted=sorted({n for n, _ in unrouted}))
    return drop, add, stats


def snap_up(v):
    return int(-(-v // GRID) * GRID)


def snap_dn(v):
    return int(v // GRID * GRID)


def on_grid(p):
    return p[0] % GRID == 0 and p[1] % GRID == 0


def grid_pts(w):
    x1, y1, x2, y2 = w[:4]
    if x1 == x2 and x1 % GRID == 0:
        lo, hi = sorted((y1, y2))
        return [(x1, y) for y in range(snap_up(lo), snap_dn(hi) + 1, GRID)]
    if y1 == y2 and y1 % GRID == 0:
        lo, hi = sorted((x1, x2))
        return [(x, y1) for x in range(snap_up(lo), snap_dn(hi) + 1, GRID)]
    return [p for p in ((x1, y1), (x2, y2)) if on_grid(p)]


def to_segments(path):
    segs, s = [], path[0]
    for a, b, c in zip(path, path[1:], path[2:]):
        if (b[0] - a[0], b[1] - a[1]) != (c[0] - b[0], c[1] - b[1]):
            segs.append((s[0], s[1], b[0], b[1]))
            s = b
    segs.append((s[0], s[1], path[-1][0], path[-1][1]))
    return segs


class Obstacles:
    """What another net's route must not touch, on the GRID.

    pt[p]    nets with a pin or a wire ENDPOINT at p   -> never step on p
    edge[e]  nets with an off-grid pin/endpoint inside grid edge e -> never use e
    thru_h/thru_v[p]  nets with a horizontal/vertical wire passing through p
             -> may cross at right angles, may not run along, may not bend or end there
    """
    def __init__(self):
        self.pt, self.edge = defaultdict(set), defaultdict(set)
        self.thru_h, self.thru_v = defaultdict(set), defaultdict(set)

    def point(self, x, y, net):
        if on_grid((x, y)):
            self.pt[(x, y)].add(net)
        elif y % GRID == 0:
            self.edge[((snap_dn(x), y), (snap_up(x), y))].add(net)
        elif x % GRID == 0:
            self.edge[((x, snap_dn(y)), (x, snap_up(y)))].add(net)

    def wire(self, w, net):
        x1, y1, x2, y2 = w[:4]
        self.point(x1, y1, net)
        self.point(x2, y2, net)
        if x1 != x2 and y1 != y2:             # diagonal: no lattice point on it may be used
            dx, dy = x2 - x1, y2 - y1
            for gx in range(snap_up(min(x1, x2)), snap_dn(max(x1, x2)) + 1, GRID):
                t = (gx - x1) / dx
                gy = y1 + t * dy
                if gy == int(gy) and int(gy) % GRID == 0:
                    self.pt[(gx, int(gy))].add(net)
            return
        for p in grid_pts(w):
            (self.thru_h if y1 == y2 else self.thru_v)[p].add(net)

    @staticmethod
    def foreign(nets, net):
        return any(n != net for n in nets)


def route(tree, targets, net, body, ob):
    """A* over the GRID from any tree point to any target point; see Obstacles for what
    another net forbids. Crossing another net's wire at right angles is legal (xschem
    connects an ENDPOINT on a wire, not a crossing) but costs, because it reads as clutter."""
    if not targets:
        return None
    allp = list(targets) + list(tree)
    box = (min(p[0] for p in allp) - 40 * GRID, min(p[1] for p in allp) - 40 * GRID,
           max(p[0] for p in allp) + 40 * GRID, max(p[1] for p in allp) + 40 * GRID)
    fr = lambda nets: Obstacles.foreign(nets, net)

    def h(p):
        return min(abs(p[0] - q[0]) + abs(p[1] - q[1]) for q in targets) // GRID

    def wire_at(p):
        return fr(ob.thru_h.get(p, ())) or fr(ob.thru_v.get(p, ()))

    pq, best = [], {}
    for p in tree:
        if wire_at(p) or fr(ob.pt.get(p, ())):
            continue
        heapq.heappush(pq, (h(p), 0, p, None, (p,)))
    while pq:
        f, g, p, dirn, path = heapq.heappop(pq)
        if p in targets and len(path) > 1:
            return list(path)
        if best.get((p, dirn), 1e18) <= g:
            continue
        best[(p, dirn)] = g
        for nd in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if dirn and nd == (-dirn[0], -dirn[1]):
                continue
            bend = dirn is not None and nd != dirn
            if bend and len(path) > 1 and wire_at(p):
                continue                      # a bend is an endpoint: it would join that wire
            q = (p[0] + nd[0] * GRID, p[1] + nd[1] * GRID)
            if not (box[0] <= q[0] <= box[2] and box[1] <= q[1] <= box[3]):
                continue
            if q in tree:
                continue
            e = (min(p, q), max(p, q))
            if fr(ob.pt.get(q, ())) or fr(ob.edge.get(e, ())):
                continue
            if q in body and q not in targets:
                continue
            horiz = nd[1] == 0
            along, perp = (ob.thru_h, ob.thru_v) if horiz else (ob.thru_v, ob.thru_h)
            if fr(along.get(q, ())) or fr(along.get(p, ())) and len(path) > 1:
                continue                      # running along another net's wire
            c = 1 + (BEND if bend and len(path) > 1 else 0)
            if fr(perp.get(q, ())):
                if q in targets:
                    continue                  # would END on it
                c += CROSS
            heapq.heappush(pq, (g + c + h(q), g + c, q, nd, path + (q,)))
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sch", nargs="+")
    ap.add_argument("--suffix", default="_wired", help="output beside the input as <cell><suffix>.sch")
    ap.add_argument("--route-ports", action="store_true",
                    help="also wire ports that sit apart from their net (off by default: the "
                         "port column stays a column, as in the LDO)")
    a = ap.parse_args()
    for path in a.sch:
        s = Sch(path)
        drop, add, st = bridge(s, a.route_ports)
        out = path[:-4] + a.suffix + ".sch"
        s.write(out, drop, add)
        print(f"{os.path.basename(out)}: labels {st['labels_before']} -> {st['labels_after']}, "
              f"+{st['wires_added']} wires, -{st['wires_pruned']} leaf, {st['wires_trimmed']} trimmed"
              + (f", UNROUTED {st['unrouted']}" if st["unrouted"] else ""))


if __name__ == "__main__":
    main()
