#!/bin/sh
# Reproduce every simulated number in this repository from a clean clone.
# Needs xschem, ngspice and the ihp-sg13cmos5l PDK at /foss/pdks.
set -e
cd "$(dirname "$0")/.."
mkdir -p sim/netlist
for cell in cs_inv rosc_vco pfd charge_pump loop_filter loop_filter_lownoise divn pll_rosc; do
  echo "netlist: $cell"
  (cd xschem && xschem --rcfile ./xschemrc -n -q -s "$cell.sch" >/dev/null 2>&1)
done
for tb in sim/tb_*.spice; do
  echo "=== $(basename "$tb") ==="
  (cd sim && ngspice -b "$(basename "$tb")")
done
