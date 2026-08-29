#!/bin/sh
# PLL PVT -- part 1: measure the VCO band and Kvco at each corner.
#
# The loop's stability follows Kvco, so the corner question for a PLL is "what does the
# tuning curve do over PVT", not "does one bias point still work". Two control voltages
# per corner give the band and the local slope at the high-gain end, which is the corner
# that sets the phase-margin worst case.
set -e
cd "$(dirname "$0")"
M=/foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models
mkdir -p pvt
: > pvt/vco.txt
for corner in tt ss ff; do
  case $corner in
    tt) mos=mos_tt; res=res_typ ;;
    ss) mos=mos_ss; res=res_wcs ;;
    ff) mos=mos_ff; res=res_bcs ;;
  esac
  for temp in -40 27 110; do
    for vc in 0.70 0.80 1.20; do
      sed -e "s|@MOS@|$mos|g" -e "s|@RES@|$res|g" -e "s|@TEMP@|$temp|g" \
          -e "s|@VC@|$vc|g" -e "s|@M@|$M|g" tb_vco_pvt.tpl > _v.spice
      ngspice -b _v.spice > _v.log 2>&1 || true
      p=$(grep -oE "^per4 *= *[0-9.e+-]+" _v.log | grep -oE "[0-9.e+-]+$")
      f=$(awk -v p="$p" 'BEGIN{ if (p+0>0) printf "%.4g", 4/p; else print "fail" }')
      echo "$corner $temp $vc $f" >> pvt/vco.txt
    done
  done
done
rm -f _v.spice _v.log
echo "measured $(wc -l < pvt/vco.txt) points"
