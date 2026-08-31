#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
# Needs xschem, ngspice and the ihp-sg13cmos5l PDK at /foss/pdks.
#
#   sh sim/run.sh
#
# Exit status is the verdict: 0 every bench ran, non-zero one or more failed.
cd "$(dirname "$0")/.." || exit 2
mkdir -p sim/netlist

# ⚠️ No `set -e` around the netlist step: xschem returns non-zero on a perfectly clean
# netlist, so aborting on its status skips everything after it and the benches then read
# whatever was already on disk.
for cell in cs_inv rosc_vco pfd charge_pump loop_filter loop_filter_lownoise divn pll_rosc; do
  echo "netlist: $cell"
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
  if [ ! -s "sim/netlist/$cell.spice" ]; then
    echo "FAILED: xschem produced no netlist for $cell" >&2
    exit 2
  fi
done

# 🔑 The sub-cell .subckt definitions come from the TOP-LEVEL netlist, not from netlisting
# each cell on its own: xschem comments out a cell's own .subckt line when that cell is the
# top, so including one of those puts its devices at top scope instead of defining a
# subcircuit. tb_pll_lock.spice says the same thing at its include.
# ⛔ This step used to live only in a private runner, so `sim/run.sh` could not reproduce a
# single number from a clean clone -- it stopped at "Could not find include file
# pll_cells.spice". Build it here, where the benches that need it can actually get it.
awk '/^\.subckt/{p=1} p' sim/netlist/pll_rosc.spice > sim/pll_cells.spice
if ! grep -q '^\.subckt' sim/pll_cells.spice; then
  echo "FAILED: no .subckt definitions extracted from sim/netlist/pll_rosc.spice" >&2
  exit 2
fi
echo "cells:   $(grep -c '^\.subckt' sim/pll_cells.spice) subcircuits -> sim/pll_cells.spice"

# Run every bench and report a verdict for each. ⚠️ Stopping at the first failure hides the
# state of all the others, which is how a single missing include masked five untested benches.
rc=0
for tb in sim/tb_*.spice; do
  echo "=== $(basename "$tb") ==="
  if (cd sim && ngspice -b "$(basename "$tb")"); then :; else
    echo "FAILED: $(basename "$tb")" >&2
    rc=1
  fi
done
exit $rc
