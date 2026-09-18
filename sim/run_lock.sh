#!/bin/sh
# PLL PVT -- part 3: acquisition time at every corner, not just the typical one.
#
# 🔑 WHY THIS EXISTS. Lock time was measured at one corner and published as the block's
# figure, which was defensible while it read 4 us against a 20 us limit: no corner spread
# was going to close a 5x gap. Sizing the loop filter to respect its own fc <= f_ref/10
# bound spent most of that margin -- the old loop was fast precisely BECAUSE its crossover
# sat at twice the bound it claimed -- so the corner spread is now the question rather than
# a detail, and a single-corner figure is no longer an answer.
#
# The operating point per corner comes from tools/datasheet.py --lock-points, which places
# each one at the SLOWEST output the part can be asked for (N x f_ref at the bottom of the
# specified reference range) using the local Kvco measured there. Corners that cannot reach
# it inside the charge pump's compliance are reported as unreachable rather than skipped.
set -e
cd "$(dirname "$0")"
PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
PDK="${PDK:-ihp-sg13g2}"
export PDK_ROOT PDK
if [ -z "${SPICE_USERINIT_DIR:-}" ]; then
  SPICE_USERINIT_DIR="$PDK_ROOT/$PDK/libs.tech/ngspice"
  export SPICE_USERINIT_DIR
fi
[ -s pll_cells.spice ] || { echo "FAILED: no pll_cells.spice -- run sim/run.sh first" >&2; exit 2; }
M="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models"
JOBS="${PVT_JOBS:-8}"
mkdir -p pvt
rm -f pvt/lock_*.csv pvt/_lk_*

python3 ../tools/datasheet.py --lock-points > pvt/_lkpoints || {
  echo "FAILED: could not derive the per-corner operating points" >&2; exit 2; }

# ⛔ VALIDATE THE CHEAP SETTING BEFORE TRUSTING IT. 100 ps is ~4 hours a corner, which is
# why this sweep did not exist; 250 ps is ~2.5x cheaper and has to be shown to give the
# same answer on a corner whose answer is already known before it is used anywhere else.
# LOCK_CORNERS restricts the run to named corners -- acquisition tracks Icp*Kvco/N at the
# lock point, so the slowest corners bound the result and the rest are inference from them.
TSTEP="${LOCK_TSTEP:-250p}"
WANT="${LOCK_CORNERS:-}"

n=0
unreach=0
while read -r corner temp vdd f0 kvco vc0; do
  case $f0 in
    below-sweep|above-compliance|no-compliant-points)
      echo "$f0 $corner $temp $vdd"
      unreach=$((unreach + 1)); continue ;;
  esac
  key="${corner}_${temp}_${vdd}"
  if [ -n "$WANT" ]; then
    case " $WANT " in *" $key "*) ;; *) continue ;; esac
  fi
  case $corner in
    tt) mos=mos_tt ;;
    ss) mos=mos_ss ;;
    ff) mos=mos_ff ;;
  esac
  tag="lock_$key"
  # The window scales with the loop gain: a corner half as fast needs twice as long, and a
  # window that ends before the loop settles still returns a number at every sample in it.
  tstop="${LOCK_TSTOP:-24u}"
  vcs=$(awk -v v="$vc0" 'BEGIN{ printf "%.4f", (v-0.10 > 0.05 ? v-0.10 : 0.05) }')
  fmax=$(awk -v f="$f0" -v k="$kvco" -v v="$vc0" -v d="$vdd" 'BEGIN{ printf "%.6g", f + k*(d-v) }')
  vhalf=$(awk -v d="$vdd" 'BEGIN{ printf "%.4f", d/2 }')
  set -- $(awk -v t="$tstop" 'BEGIN{ sub(/u$/,"",t); for(i=1;i<=8;i++) printf "%.4gu ", t*i/8 }')
  (
    sed -e "s|@MOS@|$mos|g" -e "s|@RES@|res_typ|g" -e "s|@TEMP@|$temp|g" -e "s|@VDD@|$vdd|g" \
        -e "s|@F0@|$f0|g" -e "s|@KVCO@|$kvco|g" -e "s|@VC0@|$vc0|g" -e "s|@VCSTART@|$vcs|g" \
        -e "s|@FMAX@|$fmax|g" -e "s|@VHALF@|$vhalf|g" -e "s|@M@|$M|g" -e "s|@TAG@|$tag|g" \
        -e "s|@TSTEP@|$TSTEP|g" -e "s|@TSTOP@|$tstop|g" \
        -e "s|@T1@|$1|g" -e "s|@T2@|$2|g" -e "s|@T3@|$3|g" -e "s|@T4@|$4|g" \
        -e "s|@T5@|$5|g" -e "s|@T6@|$6|g" -e "s|@T7@|$7|g" -e "s|@T8@|$8|g" \
        tb_pll_lock.tpl > "pvt/_lk_$tag.spice"
    ngspice -b "pvt/_lk_$tag.spice" > "pvt/_lk_$tag.log" 2>&1 || true
    printf '%s %s %s %s' "$corner" "$temp" "$vdd" "$tstop" > "pvt/_lk_$tag.txt"
    for s in vs1 vs2 vs3 vs4 vs5 vs6 vs7 vs8; do
      v=$(grep -oE "^$s *= *[-0-9.e+]+" "pvt/_lk_$tag.log" | grep -oE "[-0-9.e+]+$" || true)
      printf ' %s' "${v:-fail}" >> "pvt/_lk_$tag.txt"
    done
    printf '\n' >> "pvt/_lk_$tag.txt"
  ) &
  n=$((n + 1))
  if [ $((n % JOBS)) -eq 0 ]; then wait || true; fi
done < pvt/_lkpoints
wait || true

: > pvt/lock.txt
missing=0
while read -r corner temp vdd f0 kvco vc0; do
  case $f0 in below-sweep|above-compliance|no-compliant-points) continue ;; esac
  key="${corner}_${temp}_${vdd}"
  if [ -n "$WANT" ]; then case " $WANT " in *" $key "*) ;; *) continue ;; esac; fi
  f="pvt/_lk_lock_${key}.txt"
  if [ -s "$f" ]; then cat "$f" >> pvt/lock.txt; else
    echo "MISSING lock $corner $temp $vdd" >&2; missing=$((missing + 1)); fi
done < pvt/_lkpoints
rm -f pvt/_lk_*
if [ "$missing" -ne 0 ]; then
  rm -f pvt/lock.txt
  echo "FAILED: $missing acquisition runs produced no result (pvt/lock.txt removed)" >&2
  exit 2
fi
echo "measured $(wc -l < pvt/lock.txt) acquisition corners, $unreach unreachable ($JOBS at a time)"
