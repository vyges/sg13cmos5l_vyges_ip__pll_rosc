#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
# Needs xschem, ngspice and the ihp-sg13cmos5l PDK under $PDK_ROOT (default /foss/pdks).
#
#   sh sim/run.sh
#
# Exit status is the verdict: 0 every bench ran, non-zero one or more failed.
cd "$(dirname "$0")/.." || exit 2

# PDK location. Every testbench references `$PDK_ROOT` rather than a fixed path, and
# ngspice expands environment variables in .include/.lib itself -- so this has to be
# EXPORTED, not merely set, and it has to be the bare `$PDK_ROOT` form: ngspice reads
# `${PDK_ROOT}` as a variable literally named `{PDK_ROOT}` and fails.
#
#   sh sim/run.sh                              # /foss/pdks, any IIC-OSIC-TOOLS container
#   PDK_ROOT=/path/to/pdks sh sim/run.sh       # anywhere else
#
# 🔑 TWO PDKs have to sit under the same root, and this is not obvious from our netlists:
# the models and stdcells come from the ihp-sg13cmos5l OVERLAY, but the compiled OSDI
# models (psp103, r3_cmc, mosvar) live in the ihp-sg13g2 BASE and reach the overlay as
# symlinks. The PDK's own .spiceinit resolves them as `$PDK_ROOT/$PDK`, and ngspice finds
# that file through SPICE_USERINIT_DIR. Point PDK_ROOT at a tree holding only the overlay
# and those links dangle -- observed as `Error opening osdi lib
# "$PDK_ROOT/ihp-sg13g2/.../psp103.osdi"` followed by every bench aborting. The check
# below catches it first and says which PDK is missing.
#
# ℹ️ $PDK may be EITHER variant since the CMOS5L migration into IHP-Open-PDK (2026-09-01):
# the overlay now carries all six OSDI files -- two of its own and four symlinked into the
# base -- so they resolve whichever variant $PDK names, which is what upstream means by
# "use $PDK to switch between the PDKs". Verified at dev@17dc8dc: PDK=ihp-sg13cmos5l runs
# this suite with no OSDI errors and byte-identical measurements. It was NOT true before
# the merge, when neither directory held all six. The default below stays on the base
# because that is what every published number here was measured with.
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
PDK="${PDK:-ihp-sg13g2}"
export PDK_ROOT PDK
# Set only if the caller has not: outside IIC-OSIC-TOOLS nothing else points ngspice at
# the .spiceinit that loads the OSDI libraries.
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"
  export SPICE_USERINIT_DIR
fi
for d in ihp-sg13cmos5l "$PDK"; do
  if [ ! -d "$PDK_ROOT/$d" ]; then
    echo "FAILED: no $d under PDK_ROOT=$PDK_ROOT" >&2
    echo "        PDK_ROOT must contain BOTH the ihp-sg13cmos5l overlay (models," >&2
    echo "        stdcells) and the $PDK base (compiled OSDI models)" >&2
    exit 2
  fi
done
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
