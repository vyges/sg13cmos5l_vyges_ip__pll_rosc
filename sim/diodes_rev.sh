#!/bin/sh
# diodes_rev.sh -- write sim/diodes_rev.lib: the PDK's diodes.lib with the transit time AND the
# series resistance of the n-side antenna diode (darea, dperim) removed. Every bench that holds
# the PFD includes it.
#
# Why: the PFD's antenna diodes (sg13cmos5l_antennanp on ref and porb) put the PDK dantenna on
# a pin driven by a clock edge. Its darea model carries tt = 700 ns behind rs = 219 kohm (per
# um2, on a 0.6 um2 device), and ngspice cannot integrate that internal node: the transient
# aborts with "Timestep too small ... trouble with node d...xd1.d1#internal" at 8.8 ns. It
# reproduces with a pulse source and the diode alone, so it is the model, not the PLL. Setting
# tt = 0 (or dropping rs) is enough there; Gear integration, gmin, rshunt and reltol are not.
# ⛔ tt = 0 ALONE WAS NOT ENOUGH for the full lock bench (2026-10-19): the PFD's up flop then
# aborted at 13-21 us ("trouble with node xpfd.xup.net11"), on a run that completed before the
# diodes went in. Dropping rs as well completes it, and v(vctrl) agrees with the same bench with
# NO antenna diodes to 0.8 mV at every sample (Gear integration did not; a 50 ps step did, at
# twice the cost).
#
# Why that is not a change of circuit: tt is the diffusion charge of FORWARD conduction, and rs
# only drops a voltage when current flows. These diodes sit reverse-biased between vss and the
# 1.2 V rail for the whole run, where the diffusion charge is tt times a femtoamp leakage and the
# drop across rs (about 0.36 Mohm on this device) is nanovolts. The PDK header itself says the model "is
# designed for reverse direction". Junction capacitance, leakage and breakdown are untouched.
# Reported upstream: https://github.com/IHP-GmbH/IHP-Open-PDK/issues/1288
#
# Exactly two lines must change, or this exits 2: a PDK update that renames the models or
# the value would otherwise leave the benches including an unmodified copy.
set -u
cd "$(dirname "$0")" || exit 2
SRC="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models/diodes.lib"
[ -s "$SRC" ] || { echo "FAILED: no $SRC" >&2; exit 2; }
sed -E -e '/^\.MODEL (darea|dperim) D/s/tt=7\.009E-007/tt=0/' \
         -e '/^\.MODEL (darea|dperim) D/s/ rs=[0-9.]+E[+-][0-9]+//' "$SRC" > diodes_rev.lib
n=$(diff "$SRC" diodes_rev.lib | grep -c '^>')
if [ "$n" -ne 2 ]; then
  echo "FAILED: diodes_rev.lib changed $n lines of $SRC, expected 2 (darea, dperim)" >&2
  rm -f diodes_rev.lib; exit 2
fi
# and both edits must have landed on both lines
for m in darea dperim; do
  line=$(grep -E "^\.MODEL $m D" diodes_rev.lib)
  case $line in *" tt=0"*) ;; *) echo "FAILED: $m kept its tt" >&2; rm -f diodes_rev.lib; exit 2 ;; esac
  case $line in *" rs="*) echo "FAILED: $m kept its rs" >&2; rm -f diodes_rev.lib; exit 2 ;; esac
done
