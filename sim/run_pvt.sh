#!/bin/sh
# PLL PVT -- part 1: measure the VCO tuning curve at each corner.
#
# The loop's stability follows Kvco, so the corner question for a PLL is "what does the
# tuning curve do over PVT", not "does one bias point still work". Nine control voltages
# per corner give the band and the LOCAL slope everywhere along it -- both ends of which
# matter, see the fraction list below.
set -e
cd "$(dirname "$0")"
# PDK location -- see sim/run.sh for why BOTH the overlay and the base are needed.
# Exported because the generated deck reaches the stdcell library through $PDK_ROOT
# directly, not through @M@.
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
M="$PDK_ROOT/ihp-sg13cmos5l/libs.tech/ngspice/models"
# Points are independent runs, so they go in parallel. Serially this sweep is 189 x ~23 s,
# an hour and a quarter, which is long enough that a design question gets ANSWERED BY
# ARGUMENT instead of by running it -- the expensive failure mode this whole harness exists
# to avoid. ngspice already threads within a point, so the default stays modest.
JOBS="${PVT_JOBS:-8}"
mkdir -p pvt
rm -f pvt/_pt_*

# The sweep is enumerated first and executed second, so the output file is written in a
# fixed order no matter which point finishes when. A parallel sweep that appends as results
# arrive produces a file that diffs against itself.
: > pvt/_order
for corner in tt ss ff; do
  case $corner in
    tt) mos=mos_tt ;;
    ss) mos=mos_ss ;;
    ff) mos=mos_ff ;;
  esac
  # res_typ only: this sweep measures the VCO tuning curve, and the ring's frequency does
  # not depend on rhigh -- nothing in the oscillator is a poly resistor. The resistor corner
  # enters through the LOOP FILTER instead, where Rz sets the zero, and that is swept
  # analytically against these Kvco values in the reporting script. Pairing a resistor
  # corner with the MOS corner here would have implied a dependence that does not exist.
  res=res_typ
  for temp in -40 27 110; do
   # Supply corners for the 1.2 V rail. Not the +/-10 % a digital rail would get: the
   # reviewer's sketch at the 2026-09-01 review was ~0.98 / 1.2 / 1.5, which is what an
   # on-slot pMOS power switch actually delivers into a varying load. The oscillator's
   # frequency depends on it directly, so it belongs in the corner set.
   # ⛔ FIVE RAILS, AND THE OUTER TWO ARE NOT A SPECIFICATION. 0.98 / 1.20 / 1.50 came from
   # a sketch at the 2026-09-01 review, recorded only in this comment: "what an on-slot pMOS
   # power switch delivers into a varying load". That cannot be right for this block. The
   # harness README gives a pallet ONE supply, 3.3 V through a pMOS switch; the 1.2 V the
   # whole block runs from is the CORE/DIGITAL rail, confirmed distributed at the same
   # review. A series pMOS switch can only DROP its input, so a 1.2 V rail cannot arrive at
   # 1.50 V, and +/-25 % is not a digital rail tolerance -- +/-10 % is 1.08-1.32 V.
   # ⟹ 1.08 and 1.32 are swept alongside the original three rather than replacing them, so
   # the two answers can be compared instead of one being asserted. It matters: 0.98 V is
   # the sole cause of the acquisition-time failure and 1.50 V drives most of the crossover
   # violations, and neither is inside a +/-10 % digital rail.
   for vdd in 0.98 1.08 1.20 1.32 1.50; do
    # ⛔ THE CONTROL VOLTAGE COMES FROM THIS RAIL, so it is swept as a FRACTION of it.
    # Crossing a fixed 0.70/0.80/1.20 V control with the rail produced points the loop
    # cannot reach and missed points it can: the charge pump's PMOS sources sit on the same
    # single `vdd` net as the ring, so vctrl <= vdd always. At 0.98 V the old ceiling was
    # read at vctrl = 1.20 V -- above its own supply, so OPTIMISTIC -- and at 1.50 V vctrl
    # never went above 1.20 V, leaving that rail UNDERSTATED at both ends of the error.
    # The fractions are chosen so the 1.20 V column is unchanged: 0.5833/0.6667/1.0 x 1.20
    # is 0.70/0.80/1.20 exactly. That column is the control on this change -- if it moves,
    # something other than the pairing moved.
    #
    # ⛔ NINE FRACTIONS, NOT THREE, AND THE REASON IS THE FLAT TOP OF THE CURVE.
    # Three points give two slopes per rail, and the phase-margin derivation took only the
    # LOWEST pair -- on the assumption that the worst case for loop stability is the
    # STEEPEST part of the tuning curve. It is not. A type-II loop loses margin at BOTH
    # ends of the Kvco spread: high Kvco pushes the crossover up toward the filter pole,
    # low Kvco lets it fall back toward the zero. The low-Kvco end is the FLAT TOP of this
    # ring's curve -- 346 MHz/V between 1.1 and 1.2 V where the bottom reads 1650 -- and it
    # is a reachable operating point, not an artifact. Resolving it needs points there, so
    # the sweep now covers 0.35 to 1.0 x vdd in equal steps. 0.5833/0.6667/1.0 are retained
    # exactly so every previously published row is still a row here.
    #
    # ⛔ AND IT STARTS AT 0.35, NOT 0.5, BECAUSE THE ENVELOPE DOES. The loop settles where
    # f_out = N * f_ref, so the lowest output the part can be asked for is 8 x 16 MHz =
    # 128 MHz. On a 1.50 V rail 0.5 x vdd is 0.75 V and the ring is already past 400 MHz
    # there -- the whole bottom half of the specified band sat below the sweep, so no phase
    # margin was ever computed for it and the acquisition bench called those corners
    # unreachable when it was the SWEEP that could not reach them. Points below the band
    # simply do not oscillate and record fail, which costs nothing.
    for frac in 0.3500 0.4167 0.5000 0.5833 0.6667 0.7500 0.8333 0.9167 1.0000; do
      vc=$(awk -v d="$vdd" -v f="$frac" 'BEGIN{ printf "%.2f", d*f }')
      echo "$corner $mos $temp $vdd $vc" >> pvt/_order
    done
   done
  done
done

n=0
while read -r corner mos temp vdd vc; do
  tag="${corner}_${temp}_${vdd}_${vc}"
  (
    sed -e "s|@MOS@|$mos|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" -e "s|@VDD@|$vdd|g" \
        -e "s|@VC@|$vc|g" -e "s|@M@|$M|g" tb_vco_pvt.tpl > "pvt/_pt_$tag.spice"
    ngspice -b "pvt/_pt_$tag.spice" > "pvt/_pt_$tag.log" 2>&1 || true
    # ⛔ `|| true` IS LOAD-BEARING, and it was missing until a point failed to oscillate.
    # grep exits 1 when it matches nothing, which is exactly what a corner that does not
    # oscillate produces -- and under `set -e` that killed the run instead of recording
    # "fail". Serially that would have truncated pvt/vco.txt mid-sweep and left a file that
    # still looks like a result; here it lost two points. The awk below has always had a
    # "fail" branch for this case and it had never once been reachable.
    p=$(grep -oE "^per4 *= *[0-9.e+-]+" "pvt/_pt_$tag.log" | grep -oE "[0-9.e+-]+$" || true)
    f=$(awk -v p="$p" 'BEGIN{ if (p+0>0) printf "%.4g", 4/p; else print "fail" }')
    echo "$corner $temp $vdd $vc $f" > "pvt/_pt_$tag.txt"
  ) &
  n=$((n + 1))
  if [ $((n % JOBS)) -eq 0 ]; then wait || true; fi
done < pvt/_order
wait || true

# ⛔ A POINT THAT PRODUCED NO FILE IS NOT A POINT THAT DID NOT OSCILLATE. A run killed by
# the OOM killer, or a subshell that died before ngspice started, leaves no file at all --
# and a sweep that silently reports 188 of 189 points reads exactly like a sweep that
# reported 189. Every enumerated point must come back with a line or this sweep failed.
: > pvt/vco.txt
missing=0
while read -r corner mos temp vdd vc; do
  ptf="pvt/_pt_${corner}_${temp}_${vdd}_${vc}.txt"
  if [ -s "$ptf" ]; then
    cat "$ptf" >> pvt/vco.txt
  else
    echo "MISSING $corner $temp $vdd $vc" >&2
    missing=$((missing + 1))
  fi
done < pvt/_order
want=$(wc -l < pvt/_order)
got=$(wc -l < pvt/vco.txt)
rm -f pvt/_pt_*
if [ "$missing" -ne 0 ]; then
  # ⛔ AND THE PARTIAL FILE GOES WITH IT. A vco.txt holding 187 of 189 points is not a
  # smaller result, it is a wrong one: every consumer here reads whatever rows are present
  # and reports a worst case over them, with nothing to say a corner was never measured.
  rm -f pvt/vco.txt
  echo "FAILED: $missing of $want sweep points produced no result (pvt/vco.txt removed)" >&2
  exit 2
fi
echo "measured $got points (of $want enumerated, $JOBS at a time)"
