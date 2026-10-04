#!/bin/bash
# sch_equiv.sh -- prove a rewritten schematic is the same circuit, by xschem's netlister.
#
#   tools/sch_equiv.sh <a.sch> <b.sch> [<a.sch> <b.sch> ...]
#
# Netlists each file with xschem, keeps only the device lines, sorts them, and diffs each
# pair. Exit status is non-zero if ANY pair differs or if either side lost a device
# ("IS MISSING" -- xschem writes that as a comment, so it would otherwise diff clean).
#
# Why xschem and not a parser of our own: a checker written beside sch_bridge.py once
# passed a file missing a device entirely. The netlister is what the benches consume, so
# it is the only connectivity that counts.
#
# Run where xschem and the PDK symbols resolve (the IIC-OSIC-TOOLS container, with
# PDK_ROOT pointing at the tree xschemrc expects). --selftest first proves the check can
# fail: it swaps two node names in a copy and requires a non-zero exit.
set -u
cd "$(dirname "$0")/../xschem" || exit 2
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

netlist() {           # $1 = .sch  ->  prints sorted device lines
    local stem; stem=$(basename "$1" .sch)
    rm -f "$out/$stem.spice"
    xschem --rcfile ./xschemrc -n -q -s -o "$out" "$1" >/dev/null 2>&1
    [ -s "$out/$stem.spice" ] || { echo "⛔ no netlist for $1" >&2; return 3; }
    if grep -q "IS MISSING" "$out/$stem.spice"; then
        echo "⛔ $1 lost a device (IS MISSING)" >&2; return 3
    fi
    # join continuation lines, drop comments/directives, sort
    awk '/^\+/{sub(/^\+/," "); buf=buf $0; next} {if(buf!="")print buf; buf=$0} END{print buf}' \
        "$out/$stem.spice" | grep -vE '^\s*($|\*|\.)' | sort
}

selftest() {
    local f=loop_filter.sch t=_selftest_short.sch
    sed 's/lab=nz}/lab=vctrl}/' "$f" > "$t"
    if diff <(netlist "$f") <(netlist "$t") >/dev/null; then
        rm -f "$t"; echo "⛔ selftest: an injected short did NOT change the netlist diff"; exit 4
    fi
    rm -f "$t"; echo "selftest: an injected short is caught"
}

[ "${1:-}" = "--selftest" ] && { selftest; shift; }
rc=0
while [ $# -ge 2 ]; do
    a=$1 b=$2; shift 2
    na=$(netlist "$a") || { rc=1; continue; }
    nb=$(netlist "$b") || { rc=1; continue; }
    if d=$(diff <(echo "$na") <(echo "$nb")); then
        echo "✅ $a == $b  ($(echo "$na" | wc -l | tr -d ' ') devices)"
    else
        echo "❌ $a != $b"; echo "$d" | head -20; rc=1
    fi
done
exit $rc
