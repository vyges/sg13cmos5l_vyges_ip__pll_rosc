#!/bin/sh
# PLL PVT -- part 2: the charge pump's output current over the control range.
#
# 🔑 WHAT THIS IS FOR. The loop filter is designed against Icp and Kvco, and until this
# bench existed only one of the two was ever measured. Icp was carried as 1 uA on the
# strength of a 1:1 device ratio. This sweep measures it, and it measures the other half
# of the same question: over how much of the control range the pump can deliver it at all.
# A control voltage the pump cannot drive is not an operating point the loop can hold, so
# the tuning-curve segments there are not corners to design for -- they are fiction, and
# designing the filter to cover them costs capacitor area for nothing.
set -e
cd "$(dirname "$0")"
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
PDK="${PDK:-ihp-sg13g2}"
export PDK_ROOT PDK
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"
  export SPICE_USERINIT_DIR
fi
for d in ihp-sg13cmos5l "$PDK"; do
  if [ ! -d "$PDK_ROOT/$d" ]; then
    echo "FAILED: no $d under PDK_ROOT=$PDK_ROOT (need the overlay AND the base)" >&2
    exit 2
  fi
done
[ -s pll_cells.spice ] || { echo "FAILED: no pll_cells.spice -- run sim/run.sh first" >&2; exit 2; }
M="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models"
JOBS="${PVT_JOBS:-8}"
mkdir -p pvt
rm -f pvt/cp_*.csv pvt/_cp_*

# Same corner set as the tuning sweep, and for the same reason: the two are multiplied
# together in the loop gain, so they have to be evaluated at the same corner rather than
# one at nominal against the other at its extremes.
: > pvt/_cporder
for corner in tt ss ff; do
  case $corner in
    tt) mos=mos_tt ;;
    ss) mos=mos_ss ;;
    ff) mos=mos_ff ;;
  esac
  for temp in -40 27 110; do
    for vdd in 0.98 1.20 1.50; do
      echo "$corner $mos $temp $vdd" >> pvt/_cporder
    done
  done
done

n=0
while read -r corner mos temp vdd; do
  tag="cp_${corner}_${temp}_${vdd}"
  (
    sed -e "s|@MOS@|$mos|g" -e "s|@RES@|res_typ|g" -e "s|@TEMP@|$temp|g" \
        -e "s|@VDD@|$vdd|g" -e "s|@M@|$M|g" -e "s|@TAG@|$tag|g" \
        tb_cp_compliance.tpl > "pvt/_cp_$tag.spice"
    ngspice -b "pvt/_cp_$tag.spice" > "pvt/_cp_$tag.log" 2>&1 || true
  ) &
  n=$((n + 1))
  if [ $((n % JOBS)) -eq 0 ]; then wait || true; fi
done < pvt/_cporder
wait || true

missing=0
while read -r corner mos temp vdd; do
  [ -s "pvt/cp_${corner}_${temp}_${vdd}.csv" ] || {
    echo "MISSING cp $corner $temp $vdd" >&2; missing=$((missing + 1)); }
done < pvt/_cporder
want=$(wc -l < pvt/_cporder)
rm -f pvt/_cp_*
if [ "$missing" -ne 0 ]; then
  rm -f pvt/cp_*.csv
  echo "FAILED: $missing of $want charge-pump sweeps produced no output (pvt/cp_*.csv removed)" >&2
  exit 2
fi
echo "measured $want charge-pump compliance sweeps ($JOBS at a time)"
