v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {rosc_vco -- 7-stage current-starved ring VCO} -1200 -760 0 0 0.4 0.4 {}
T {vctrl sets the tail current through Mnr, mirrored to the PMOS head bias vbp, which
starves all seven stages equally.
TUNING-RANGE CONSTRAINT: if the low-noise loop filter is used, its integrating capacitor
is a MOS cap that only has its capacitance while held in inversion, so vctrl must stay
above the hv threshold (~0.7 V). The usable band is therefore narrower than the raw
sweep suggests and must be re-centred to sit above it. Design this in here -- do not
discover it during loop closure.} -1200 -700 0 0 0.25 0.25 {layer=15}
T {Every stage carries a matched dummy inverter and the output is tapped through a small
one. A ring is only as symmetric as its loading: tapping one stage with a large buffer
and leaving the rest unloaded slows that stage, and the stage-to-stage delay that Kvco
is derived from stops being uniform. Loaded, this ring runs 115.4 MHz at vctrl 0.6 V
against 155.7 MHz for a bare unloaded ring -- so the tuning curve must be characterised
WITH the tap present, not inherited from an unloaded measurement.} -400 -700 0 0 0.25 0.25 {layer=15}
N -980 -70 -980 -30 {lab=vbp}
N -980 -30 -980 -10 {lab=vbp}
N -980 -10 -980 30 {lab=vbp}
N -1020 -100 -1080 -100 {lab=vbp}
N -1080 -100 -1080 -30 {lab=vbp}
N -1080 -30 -980 -30 {lab=vbp}
N -980 -30 -980 -70 {lab=vbp}
N -980 -70 -980 -30 {lab=vbp}
N -980 -30 -900 -30 {lab=vbp}
N -900 -30 -900 205 {lab=vbp}
N -900 205 -680 205 {lab=vbp}
N -680 205 -680 90 {lab=vbp}
N -1020 60 -1050 60 {lab=vctrl}
N -1050 60 -1050 230 {lab=vctrl}
N -1050 230 -600 230 {lab=vctrl}
N -600 230 -600 90 {lab=vctrl}
N -680 90 -680 205 {lab=vbp}
N -680 205 -180 205 {lab=vbp}
N -180 205 -180 90 {lab=vbp}
N -180 90 -180 205 {lab=vbp}
N -180 205 320 205 {lab=vbp}
N 320 205 320 90 {lab=vbp}
N 320 90 320 205 {lab=vbp}
N 320 205 820 205 {lab=vbp}
N 820 205 820 90 {lab=vbp}
N 820 90 820 205 {lab=vbp}
N 820 205 1320 205 {lab=vbp}
N 1320 205 1320 90 {lab=vbp}
N 1320 90 1320 205 {lab=vbp}
N 1320 205 1820 205 {lab=vbp}
N 1820 205 1820 90 {lab=vbp}
N 1820 90 1820 205 {lab=vbp}
N 1820 205 2320 205 {lab=vbp}
N 2320 205 2320 90 {lab=vbp}
N -600 90 -600 230 {lab=vctrl}
N -600 230 -100 230 {lab=vctrl}
N -100 230 -100 90 {lab=vctrl}
N -100 90 -100 230 {lab=vctrl}
N -100 230 400 230 {lab=vctrl}
N 400 230 400 90 {lab=vctrl}
N 400 90 400 230 {lab=vctrl}
N 400 230 900 230 {lab=vctrl}
N 900 230 900 90 {lab=vctrl}
N 900 90 900 230 {lab=vctrl}
N 900 230 1400 230 {lab=vctrl}
N 1400 230 1400 90 {lab=vctrl}
N 1400 90 1400 230 {lab=vctrl}
N 1400 230 1900 230 {lab=vctrl}
N 1900 230 1900 90 {lab=vctrl}
N 1900 90 1900 230 {lab=vctrl}
N 1900 230 2400 230 {lab=vctrl}
N 2400 230 2400 90 {lab=vctrl}
N -430 0 -365 0 {lab=n2}
N -365 0 -310 0 {lab=n2}
N -310 0 -270 0 {lab=n2}
N 70 0 135 0 {lab=n3}
N 135 0 190 0 {lab=n3}
N 190 0 230 0 {lab=n3}
N 570 0 635 0 {lab=n4}
N 635 0 690 0 {lab=n4}
N 690 0 730 0 {lab=n4}
N 1070 0 1135 0 {lab=n5}
N 1135 0 1190 0 {lab=n5}
N 1190 0 1230 0 {lab=n5}
N 1570 0 1635 0 {lab=n6}
N 1635 0 1690 0 {lab=n6}
N 1690 0 1730 0 {lab=n6}
N 2070 0 2135 0 {lab=n7}
N 2135 0 2190 0 {lab=n7}
N 2190 0 2230 0 {lab=n7}
N 2570 0 2635 0 {lab=n1}
N 2635 0 2680 0 {lab=n1}
N 2680 0 2720 0 {lab=n1}
N 2800 0 2865 0 {lab=vco_outn}
N 2865 0 2880 0 {lab=vco_outn}
N 2880 0 2920 0 {lab=vco_outn}
N 2570 0 2635 0 {lab=n1}
N 2635 0 2635 -400 {lab=n1}
N 2635 -400 -810 -400 {lab=n1}
N -810 -400 -810 0 {lab=n1}
N -810 0 -770 0 {lab=n1}
N -430 0 -365 0 {lab=n2}
N -365 0 -365 -260 {lab=n2}
N -365 -260 -340 -260 {lab=n2}
N -340 -260 -300 -260 {lab=n2}
N 70 0 135 0 {lab=n3}
N 135 0 135 -260 {lab=n3}
N 135 -260 160 -260 {lab=n3}
N 160 -260 200 -260 {lab=n3}
N 570 0 635 0 {lab=n4}
N 635 0 635 -260 {lab=n4}
N 635 -260 660 -260 {lab=n4}
N 660 -260 700 -260 {lab=n4}
N 1070 0 1135 0 {lab=n5}
N 1135 0 1135 -260 {lab=n5}
N 1135 -260 1160 -260 {lab=n5}
N 1160 -260 1200 -260 {lab=n5}
N 1570 0 1635 0 {lab=n6}
N 1635 0 1635 -260 {lab=n6}
N 1635 -260 1660 -260 {lab=n6}
N 1660 -260 1700 -260 {lab=n6}
N 2070 0 2135 0 {lab=n7}
N 2135 0 2135 -260 {lab=n7}
N 2135 -260 2160 -260 {lab=n7}
N 2160 -260 2200 -260 {lab=n7}
N -1200 60 -1085 60 {lab=vctrl}
N -1085 60 -1020 60 {lab=vctrl}
N 3200 0 3065 0 {lab=vco_out}
N 3065 0 3000 0 {lab=vco_out}
C {devices/lab_pin.sym} -980 -70 0 0 {name=l_net_vbp sig_type=std_logic lab=vbp}
C {devices/lab_pin.sym} -430 0 0 0 {name=l_net_n2 sig_type=std_logic lab=n2}
C {devices/lab_pin.sym} 70 0 0 0 {name=l_net_n3 sig_type=std_logic lab=n3}
C {devices/lab_pin.sym} 570 0 0 0 {name=l_net_n4 sig_type=std_logic lab=n4}
C {devices/lab_pin.sym} 1070 0 0 0 {name=l_net_n5 sig_type=std_logic lab=n5}
C {devices/lab_pin.sym} 1570 0 0 0 {name=l_net_n6 sig_type=std_logic lab=n6}
C {devices/lab_pin.sym} 2070 0 0 0 {name=l_net_n7 sig_type=std_logic lab=n7}
C {devices/lab_pin.sym} 2570 0 0 0 {name=l_net_n1 sig_type=std_logic lab=n1}
C {devices/lab_pin.sym} 2800 0 0 0 {name=l_net_vco_outn sig_type=std_logic lab=vco_outn}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -1000 -100 0 0 {name=Mpr l=0.13u w=1u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X}
N -980 -130 -980 -170 {lab=vdd}
C {devices/lab_pin.sym} -980 -170 0 0 {name=l_Mpr_S sig_type=std_logic lab=vdd}
N -980 -100 -910 -100 {lab=vdd}
C {devices/lab_pin.sym} -910 -100 0 0 {name=l_Mpr_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -1000 60 0 0 {name=Mnr l=0.13u w=1u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N -980 90 -980 130 {lab=vss}
C {devices/lab_pin.sym} -980 130 0 0 {name=l_Mnr_S sig_type=std_logic lab=vss}
N -980 60 -910 60 {lab=vss}
C {devices/lab_pin.sym} -910 60 0 0 {name=l_Mnr_B sig_type=std_logic lab=vss}
C {cs_inv.sym} -600 0 0 0 {name=X1 }
N -600 -90 -600 -130 {lab=vdd}
C {devices/lab_pin.sym} -600 -130 0 0 {name=l_X1_vdd sig_type=std_logic lab=vdd}
N -520 90 -520 130 {lab=vss}
C {devices/lab_pin.sym} -520 130 0 0 {name=l_X1_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} -100 0 0 0 {name=X2 }
N -100 -90 -100 -130 {lab=vdd}
C {devices/lab_pin.sym} -100 -130 0 0 {name=l_X2_vdd sig_type=std_logic lab=vdd}
N -20 90 -20 130 {lab=vss}
C {devices/lab_pin.sym} -20 130 0 0 {name=l_X2_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 400 0 0 0 {name=X3 }
N 400 -90 400 -130 {lab=vdd}
C {devices/lab_pin.sym} 400 -130 0 0 {name=l_X3_vdd sig_type=std_logic lab=vdd}
N 480 90 480 130 {lab=vss}
C {devices/lab_pin.sym} 480 130 0 0 {name=l_X3_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 900 0 0 0 {name=X4 }
N 900 -90 900 -130 {lab=vdd}
C {devices/lab_pin.sym} 900 -130 0 0 {name=l_X4_vdd sig_type=std_logic lab=vdd}
N 980 90 980 130 {lab=vss}
C {devices/lab_pin.sym} 980 130 0 0 {name=l_X4_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1400 0 0 0 {name=X5 }
N 1400 -90 1400 -130 {lab=vdd}
C {devices/lab_pin.sym} 1400 -130 0 0 {name=l_X5_vdd sig_type=std_logic lab=vdd}
N 1480 90 1480 130 {lab=vss}
C {devices/lab_pin.sym} 1480 130 0 0 {name=l_X5_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1900 0 0 0 {name=X6 }
N 1900 -90 1900 -130 {lab=vdd}
C {devices/lab_pin.sym} 1900 -130 0 0 {name=l_X6_vdd sig_type=std_logic lab=vdd}
N 1980 90 1980 130 {lab=vss}
C {devices/lab_pin.sym} 1980 130 0 0 {name=l_X6_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 2400 0 0 0 {name=X7 }
N 2400 -90 2400 -130 {lab=vdd}
C {devices/lab_pin.sym} 2400 -130 0 0 {name=l_X7_vdd sig_type=std_logic lab=vdd}
N 2480 90 2480 130 {lab=vss}
C {devices/lab_pin.sym} 2480 130 0 0 {name=l_X7_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2760 0 0 0 {name=Xtap VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_4.sym} 2960 0 0 0 {name=Xbuf VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -260 -260 0 0 {name=Xdum2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -220 -260 -150 -260 {lab=ndum2}
C {devices/lab_pin.sym} -150 -260 0 0 {name=l_Xdum2_Y sig_type=std_logic lab=ndum2}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 240 -260 0 0 {name=Xdum3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 280 -260 350 -260 {lab=ndum3}
C {devices/lab_pin.sym} 350 -260 0 0 {name=l_Xdum3_Y sig_type=std_logic lab=ndum3}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 740 -260 0 0 {name=Xdum4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 780 -260 850 -260 {lab=ndum4}
C {devices/lab_pin.sym} 850 -260 0 0 {name=l_Xdum4_Y sig_type=std_logic lab=ndum4}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 1240 -260 0 0 {name=Xdum5 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 1280 -260 1350 -260 {lab=ndum5}
C {devices/lab_pin.sym} 1350 -260 0 0 {name=l_Xdum5_Y sig_type=std_logic lab=ndum5}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 1740 -260 0 0 {name=Xdum6 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 1780 -260 1850 -260 {lab=ndum6}
C {devices/lab_pin.sym} 1850 -260 0 0 {name=l_Xdum6_Y sig_type=std_logic lab=ndum6}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2240 -260 0 0 {name=Xdum7 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2280 -260 2350 -260 {lab=ndum7}
C {devices/lab_pin.sym} 2350 -260 0 0 {name=l_Xdum7_Y sig_type=std_logic lab=ndum7}
C {devices/ipin.sym} -1200 60 0 0 {name=p_vctrl lab=vctrl}
C {devices/opin.sym} 3200 0 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -1200 -300 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1200 450 0 0 {name=p_vss lab=vss}
L 4 -1130 -180 -850 -180 {dash=8}
L 4 -850 -180 -850 150 {dash=8}
L 4 -850 150 -1130 150 {dash=8}
L 4 -1130 150 -1130 -180 {dash=8}
T {BIAS} -1124 -206 0 0 0.3 0.3 {layer=4}
L 4 -800 -170 2650 -170 {dash=8}
L 4 2650 -170 2650 280 {dash=8}
L 4 2650 280 -800 280 {dash=8}
L 4 -800 280 -800 -170 {dash=8}
T {RING (seven current-starved stages)} -794 -196 0 0 0.3 0.3 {layer=4}
L 4 -340 -320 2430 -320 {dash=8}
L 4 2430 -320 2430 -200 {dash=8}
L 4 2430 -200 -340 -200 {dash=8}
L 4 -340 -200 -340 -320 {dash=8}
T {MATCHED DUMMY LOADS} -334 -346 0 0 0.3 0.3 {layer=4}
L 4 2690 -80 3060 -80 {dash=8}
L 4 3060 -80 3060 80 {dash=8}
L 4 3060 80 2690 80 {dash=8}
L 4 2690 80 2690 -80 {dash=8}
T {OUTPUT TAP} 2696 -106 0 0 0.3 0.3 {layer=4}
