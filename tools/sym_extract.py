#!/usr/bin/env python3
"""
sym_extract.py -- rebuild sym_art.json from the PDK's .sym files.

sym_art.json is a CACHE of PDK symbol artwork, and a cache with no generator is a
cache that goes stale silently. It did: the PDK renamed cap_mfringe -> cap_cmomf
(and its pins c1/c2 -> c0/c1), the cache kept only the old name, and every
schematic using the new one drew the capacitor as a labelled box -- while every
transistor drew correctly, so nothing looked broken enough to notice.

Run this after a PDK bump. --check tells you whether the cache still matches the
PDK without writing anything, which is the form a CI gate wants.

What is kept, matching the existing cache exactly:
  L <layer> x1 y1 x2 y2     -> lines  [x1,y1,x2,y2]
  P <layer> n x1 y1 ...     -> polys  [x1,y1,x2,y2,...]      (any layer)
  A <layer> cx cy r a b     -> arcs   [cx,cy,r]              (angles dropped)
  B <layer> x1 y1 x2 y2 {name=..}  -> pins [name, cx, cy]
  B with no name=           -> dropped (decorative boxes, e.g. the FET gate bar)
  T                         -> dropped (rendered from instance attrs instead)
"""
import argparse, json, os, re, sys

RE_L = re.compile(r"^L\s+\S+\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)")
RE_B = re.compile(r"^B\s+\S+\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+\{(.*)\}")
RE_P = re.compile(r"^P\s+\S+\s+(\d+)\s+(.*?)\s*\{")
RE_A = re.compile(r"^A\s+\S+\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)\s+(-?[\d.eE+-]+)")

def extract(path):
    art = {"lines": [], "polys": [], "pins": [], "arcs": []}   # key order matches the cache
    for ln in open(path, errors="ignore"):
        m = RE_L.match(ln)
        if m: art["lines"].append([float(v) for v in m.groups()]); continue
        m = RE_B.match(ln)
        if m:
            x1, y1, x2, y2, attr = m.groups()
            nm = re.search(r"\bname=([^\s}]+)", attr)
            if nm:
                art["pins"].append([nm.group(1), (float(x1)+float(x2))/2, (float(y1)+float(y2))/2])
            continue
        m = RE_P.match(ln)
        if m:
            v = [float(t) for t in m.group(2).split()[:2*int(m.group(1))]]
            art["polys"].append(v); continue
        m = RE_A.match(ln)
        if m: art["arcs"].append([float(v) for v in m.groups()])
    return art

skipped = []


def scan(root):
    """key each symbol as <parent-dir>/<stem>, matching the existing cache keys."""
    out = {}
    for dirpath, _, files in os.walk(root):
        for f in sorted(files):
            if not f.endswith(".sym"): continue
            full = os.path.join(dirpath, f)
            try:
                out[f"{os.path.basename(dirpath)}/{f[:-4]}"] = extract(full)
            except OSError as e:
                # a PDK tree carries broken symlinks and unreadable files; one of
                # them must not cost us the other 139 symbols.
                skipped.append((full, e.strerror))
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("roots", nargs="+", help="directories of .sym files (PDK xschem libs)")
    ap.add_argument("--cache", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "sym_art.json"))
    ap.add_argument("--check", action="store_true", help="report drift, write nothing")
    ap.add_argument("--write", action="store_true", help="merge findings into the cache")
    a = ap.parse_args()

    found = {}
    for r in a.roots: found.update(scan(r))
    cache = json.load(open(a.cache)) if os.path.exists(a.cache) else {}

    added   = sorted(k for k in found if k not in cache)
    changed = sorted(k for k in found if k in cache and cache[k] != found[k])
    print(f"scanned {len(found)} symbols; cache has {len(cache)}")
    if skipped:
        print(f"  unreadable, skipped : {len(skipped)}")
        for f, why in skipped[:5]: print(f"      ! {os.path.basename(f)} ({why})")
    print(f"  missing from cache : {len(added)}")
    for k in added[:20]: print(f"      + {k}")
    print(f"  differ from PDK    : {len(changed)}")
    for k in changed[:20]: print(f"      ~ {k}")

    if a.write:
        # Preserve the cache's existing order and compact one-line formatting: this
        # file is reviewed by diffing it, so a reformat would bury the real change.
        merged = dict(cache)
        merged.update(found)
        with open(a.cache, "w") as fh:
            json.dump(merged, fh, separators=(", ", ": "))
        print(f"wrote {a.cache}: {len(merged)} entries "
              f"({len(added)} added, {len(changed)} updated)")
    elif a.check and (added or changed):
        sys.exit(1)

main()
