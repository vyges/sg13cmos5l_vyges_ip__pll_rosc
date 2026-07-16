#!/usr/bin/env bash
# Ring-VCO tuning sweep — IHP SG13G2. Requires ngspice with OSDI v0.4 support
# (IIC-OSIC-TOOLS container, or ngspice >= 46). Ubuntu apt ngspice-42 = OSDI
# v0.3 → too old ("Unknown model type psp103va").
#
# Native:     PDK_ROOT=~/.ciel/ihp-sg13g2 ./run_tuning_sweep.sh
# Container:  docker run --rm --entrypoint bash -v "$PWD":/work \
#               -v ~/.ciel/ihp-sg13g2:/foss/pdks/ihp-sg13g2 \
#               hpretl/iic-osic-tools:latest -lc \
#               'cd /work && PDK_ROOT=/foss/pdks/ihp-sg13g2 ./run_tuning_sweep.sh'
set -eu
P="${PDK_ROOT:-$HOME/.ciel/ihp-sg13g2}"
printf 'osdi %s/libs.tech/ngspice/osdi/psp103.osdi\n' "$P" > .spiceinit
echo "VCTRL(V)  freq(MHz)   (SG13G2 5-stage ring VCO, tt, 3.3V, 27C)"
for v in 1.4 1.7 2.0 2.3 2.6 2.9 3.1 3.3; do
  sed "s|PDKROOT|$P|; s|.param VCTRL=3.3|.param VCTRL=$v|" ringvco_feasibility.spice > /tmp/rv_$v.spice
  # deck prints "freq = <sci>"; take that number only (ignore container INFO noise)
  f=$(ngspice -b /tmp/rv_$v.spice 2>/dev/null \
        | grep -E '^freq =' | grep -oE '[0-9]+\.[0-9]+e[+-][0-9]+' | tail -1)
  if [ -n "$f" ]; then printf '  %s      %.1f\n' "$v" "$(echo "$f/1e6" | bc -l)"
  else echo "  $v      (no osc / measure fail)"; fi
done
