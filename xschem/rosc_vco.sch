v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {rosc_vco -- 7-stage current-starved ring VCO} -520 -320 0 0 0.4 0.4 {}
T {vctrl sets the tail current through Mnr, mirrored to the PMOS head bias vbp, which
starves all seven stages equally.
TUNING-RANGE CONSTRAINT: if the low-noise loop filter is used, its integrating capacitor
is a MOS cap that only has its capacitance while held in inversion, so vctrl must stay
above the hv threshold (~0.7 V). The usable band is therefore narrower than the raw
sweep suggests and must be re-centred to sit above it. Design this in here -- do not
discover it during loop closure.} -520 -280 0 0 0.25 0.25 {layer=15}
T {Every stage carries a matched dummy inverter and the output is tapped through a small
one. A ring is only as symmetric as its loading: tapping one stage with a large buffer
and leaving the rest unloaded slows that stage, and the stage-to-stage delay that Kvco
is derived from stops being uniform. Loaded, this ring runs 115.4 MHz at vctrl 0.6 V
against 155.7 MHz for a bare unloaded ring -- so the tuning curve must be characterised
WITH the tap present, not inherited from an unloaded measurement.} -520 -170 0 0 0.25 0.25 {layer=15}
N -540 -120 -540 -80 {lab=vbp}
N -540 -80 -540 10 {lab=vbp}
N -540 10 -540 50 {lab=vbp}
N -580 -150 -650 -150 {lab=vbp}
N -650 -150 -650 -80 {lab=vbp}
N -650 -80 -540 -80 {lab=vbp}
N -540 -80 -540 -120 {lab=vbp}
N -30 -60 -130 -60 {lab=n2}
N -130 -60 -90 -60 {lab=n2}
N 250 -60 150 -60 {lab=n3}
N 150 -60 190 -60 {lab=n3}
N 530 -60 430 -60 {lab=n4}
N 430 -60 470 -60 {lab=n4}
N 810 -60 710 -60 {lab=n5}
N 710 -60 750 -60 {lab=n5}
N 1090 -60 990 -60 {lab=n6}
N 990 -60 1030 -60 {lab=n6}
N 1370 -60 1270 -60 {lab=n7}
N 1270 -60 1310 -60 {lab=n7}
N 1650 -60 1700 -60 {lab=n1}
N 1700 -60 1740 -60 {lab=n1}
N 1820 -60 1885 -60 {lab=vco_outn}
N 1885 -60 1900 -60 {lab=vco_outn}
N 1900 -60 1940 -60 {lab=vco_outn}
N 1650 -60 1720 640 {lab=n1}
N 1720 640 -500 640 {lab=n1}
N -500 640 -500 -140 {lab=n1}
N -500 -140 -410 -60 {lab=n1}
N -410 -60 -370 -60 {lab=n1}
N -30 -60 -30 230 {lab=n2}
N -30 230 -280 230 {lab=n2}
N -280 230 -280 520 {lab=n2}
N -280 520 -240 520 {lab=n2}
N 250 -60 250 264 {lab=n3}
N 250 264 0 264 {lab=n3}
N 0 264 0 520 {lab=n3}
N 0 520 40 520 {lab=n3}
N 530 -60 530 298 {lab=n4}
N 530 298 280 298 {lab=n4}
N 280 298 280 520 {lab=n4}
N 280 520 320 520 {lab=n4}
N 810 -60 810 332 {lab=n5}
N 810 332 560 332 {lab=n5}
N 560 332 560 520 {lab=n5}
N 560 520 600 520 {lab=n5}
N 1090 -60 1090 366 {lab=n6}
N 1090 366 840 366 {lab=n6}
N 840 366 840 520 {lab=n6}
N 840 520 880 520 {lab=n6}
N 1370 -60 1370 400 {lab=n7}
N 1370 400 1120 400 {lab=n7}
N 1120 400 1120 520 {lab=n7}
N 1120 520 1160 520 {lab=n7}
C {devices/lab_pin.sym} -540 -120 0 0 {name=l_net_vbp sig_type=std_logic lab=vbp}
C {devices/lab_pin.sym} -30 -60 0 0 {name=l_net_n2 sig_type=std_logic lab=n2}
C {devices/lab_pin.sym} 250 -60 0 0 {name=l_net_n3 sig_type=std_logic lab=n3}
C {devices/lab_pin.sym} 530 -60 0 0 {name=l_net_n4 sig_type=std_logic lab=n4}
C {devices/lab_pin.sym} 810 -60 0 0 {name=l_net_n5 sig_type=std_logic lab=n5}
C {devices/lab_pin.sym} 1090 -60 0 0 {name=l_net_n6 sig_type=std_logic lab=n6}
C {devices/lab_pin.sym} 1370 -60 0 0 {name=l_net_n7 sig_type=std_logic lab=n7}
C {devices/lab_pin.sym} 1650 -60 0 0 {name=l_net_n1 sig_type=std_logic lab=n1}
C {devices/lab_pin.sym} 1820 -60 0 0 {name=l_net_vco_outn sig_type=std_logic lab=vco_outn}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -560 -150 0 0 {name=Mpr l=0.13u w=1u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X}
N -540 -180 -540 -220 {lab=vdd}
C {devices/lab_pin.sym} -540 -220 0 0 {name=l_Mpr_S sig_type=std_logic lab=vdd}
N -540 -150 -470 -150 {lab=vdd}
C {devices/lab_pin.sym} -470 -150 0 0 {name=l_Mpr_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -560 80 0 0 {name=Mnr l=0.13u w=1u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N -580 80 -630 80 {lab=vctrl}
C {devices/lab_pin.sym} -630 80 0 1 {name=l_Mnr_G sig_type=std_logic lab=vctrl}
N -540 110 -540 150 {lab=vss}
C {devices/lab_pin.sym} -540 150 0 0 {name=l_Mnr_S sig_type=std_logic lab=vss}
N -540 80 -470 80 {lab=vss}
C {devices/lab_pin.sym} -470 80 0 0 {name=l_Mnr_B sig_type=std_logic lab=vss}
C {cs_inv.sym} -200 -60 0 0 {name=X1 }
N -280 30 -280 70 {lab=vbp}
C {devices/lab_pin.sym} -280 70 0 0 {name=l_X1_vbp sig_type=std_logic lab=vbp}
N -200 30 -200 70 {lab=vctrl}
C {devices/lab_pin.sym} -200 70 0 0 {name=l_X1_vctrl sig_type=std_logic lab=vctrl}
N -200 -150 -200 -190 {lab=vdd}
C {devices/lab_pin.sym} -200 -190 0 0 {name=l_X1_vdd sig_type=std_logic lab=vdd}
N -120 30 -120 70 {lab=vss}
C {devices/lab_pin.sym} -120 70 0 0 {name=l_X1_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 80 -60 0 0 {name=X2 }
N 0 30 0 70 {lab=vbp}
C {devices/lab_pin.sym} 0 70 0 0 {name=l_X2_vbp sig_type=std_logic lab=vbp}
N 80 30 80 70 {lab=vctrl}
C {devices/lab_pin.sym} 80 70 0 0 {name=l_X2_vctrl sig_type=std_logic lab=vctrl}
N 80 -150 80 -190 {lab=vdd}
C {devices/lab_pin.sym} 80 -190 0 0 {name=l_X2_vdd sig_type=std_logic lab=vdd}
N 160 30 160 70 {lab=vss}
C {devices/lab_pin.sym} 160 70 0 0 {name=l_X2_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 360 -60 0 0 {name=X3 }
N 280 30 280 70 {lab=vbp}
C {devices/lab_pin.sym} 280 70 0 0 {name=l_X3_vbp sig_type=std_logic lab=vbp}
N 360 30 360 70 {lab=vctrl}
C {devices/lab_pin.sym} 360 70 0 0 {name=l_X3_vctrl sig_type=std_logic lab=vctrl}
N 360 -150 360 -190 {lab=vdd}
C {devices/lab_pin.sym} 360 -190 0 0 {name=l_X3_vdd sig_type=std_logic lab=vdd}
N 440 30 440 70 {lab=vss}
C {devices/lab_pin.sym} 440 70 0 0 {name=l_X3_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 640 -60 0 0 {name=X4 }
N 560 30 560 70 {lab=vbp}
C {devices/lab_pin.sym} 560 70 0 0 {name=l_X4_vbp sig_type=std_logic lab=vbp}
N 640 30 640 70 {lab=vctrl}
C {devices/lab_pin.sym} 640 70 0 0 {name=l_X4_vctrl sig_type=std_logic lab=vctrl}
N 640 -150 640 -190 {lab=vdd}
C {devices/lab_pin.sym} 640 -190 0 0 {name=l_X4_vdd sig_type=std_logic lab=vdd}
N 720 30 720 70 {lab=vss}
C {devices/lab_pin.sym} 720 70 0 0 {name=l_X4_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 920 -60 0 0 {name=X5 }
N 840 30 840 70 {lab=vbp}
C {devices/lab_pin.sym} 840 70 0 0 {name=l_X5_vbp sig_type=std_logic lab=vbp}
N 920 30 920 70 {lab=vctrl}
C {devices/lab_pin.sym} 920 70 0 0 {name=l_X5_vctrl sig_type=std_logic lab=vctrl}
N 920 -150 920 -190 {lab=vdd}
C {devices/lab_pin.sym} 920 -190 0 0 {name=l_X5_vdd sig_type=std_logic lab=vdd}
N 1000 30 1000 70 {lab=vss}
C {devices/lab_pin.sym} 1000 70 0 0 {name=l_X5_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1200 -60 0 0 {name=X6 }
N 1120 30 1120 70 {lab=vbp}
C {devices/lab_pin.sym} 1120 70 0 0 {name=l_X6_vbp sig_type=std_logic lab=vbp}
N 1200 30 1200 70 {lab=vctrl}
C {devices/lab_pin.sym} 1200 70 0 0 {name=l_X6_vctrl sig_type=std_logic lab=vctrl}
N 1200 -150 1200 -190 {lab=vdd}
C {devices/lab_pin.sym} 1200 -190 0 0 {name=l_X6_vdd sig_type=std_logic lab=vdd}
N 1280 30 1280 70 {lab=vss}
C {devices/lab_pin.sym} 1280 70 0 0 {name=l_X6_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1480 -60 0 0 {name=X7 }
N 1400 30 1400 70 {lab=vbp}
C {devices/lab_pin.sym} 1400 70 0 0 {name=l_X7_vbp sig_type=std_logic lab=vbp}
N 1480 30 1480 70 {lab=vctrl}
C {devices/lab_pin.sym} 1480 70 0 0 {name=l_X7_vctrl sig_type=std_logic lab=vctrl}
N 1480 -150 1480 -190 {lab=vdd}
C {devices/lab_pin.sym} 1480 -190 0 0 {name=l_X7_vdd sig_type=std_logic lab=vdd}
N 1560 30 1560 70 {lab=vss}
C {devices/lab_pin.sym} 1560 70 0 0 {name=l_X7_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 1780 -60 0 0 {name=Xtap VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_4.sym} 1980 -60 0 0 {name=Xbuf VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2020 -60 2090 -60 {lab=vco_out}
C {devices/lab_pin.sym} 2090 -60 0 0 {name=l_Xbuf_Y sig_type=std_logic lab=vco_out}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} -200 520 0 0 {name=Xdum2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -160 520 -90 520 {lab=ndum2}
C {devices/lab_pin.sym} -90 520 0 0 {name=l_Xdum2_Y sig_type=std_logic lab=ndum2}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 80 520 0 0 {name=Xdum3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 120 520 190 520 {lab=ndum3}
C {devices/lab_pin.sym} 190 520 0 0 {name=l_Xdum3_Y sig_type=std_logic lab=ndum3}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 360 520 0 0 {name=Xdum4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 400 520 470 520 {lab=ndum4}
C {devices/lab_pin.sym} 470 520 0 0 {name=l_Xdum4_Y sig_type=std_logic lab=ndum4}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 640 520 0 0 {name=Xdum5 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 680 520 750 520 {lab=ndum5}
C {devices/lab_pin.sym} 750 520 0 0 {name=l_Xdum5_Y sig_type=std_logic lab=ndum5}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 920 520 0 0 {name=Xdum6 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 960 520 1030 520 {lab=ndum6}
C {devices/lab_pin.sym} 1030 520 0 0 {name=l_Xdum6_Y sig_type=std_logic lab=ndum6}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 1200 520 0 0 {name=Xdum7 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 1240 520 1310 520 {lab=ndum7}
C {devices/lab_pin.sym} 1310 520 0 0 {name=l_Xdum7_Y sig_type=std_logic lab=ndum7}
N -580 80 -630 80 {lab=vctrl}
C {devices/ipin.sym} -630 80 0 1 {name=p_vctrl lab=vctrl}
N 2020 -60 2090 -60 {lab=vco_out}
C {devices/opin.sym} 2090 -60 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -620 -220 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -620 -160 0 0 {name=p_vss lab=vss}
