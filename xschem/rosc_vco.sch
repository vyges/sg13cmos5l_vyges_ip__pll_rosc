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
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -720 -180 0 0 {name=Mpr l=0.13u w=1u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X}
N -700 -150 -700 -110 {lab=vbp}
C {devices/lab_pin.sym} -700 -110 0 0 {name=l_Mpr_D sig_type=std_logic lab=vbp}
N -740 -180 -790 -180 {lab=vbp}
C {devices/lab_pin.sym} -790 -180 0 1 {name=l_Mpr_G sig_type=std_logic lab=vbp}
N -700 -210 -700 -250 {lab=vdd}
C {devices/lab_pin.sym} -700 -250 0 0 {name=l_Mpr_S sig_type=std_logic lab=vdd}
N -700 -180 -550 -180 {lab=vdd}
C {devices/lab_pin.sym} -550 -180 0 0 {name=l_Mpr_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -720 110 0 0 {name=Mnr l=0.13u w=1u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X}
N -700 80 -700 40 {lab=vbp}
C {devices/lab_pin.sym} -700 40 0 0 {name=l_Mnr_D sig_type=std_logic lab=vbp}
N -740 110 -790 110 {lab=vctrl}
C {devices/lab_pin.sym} -790 110 0 1 {name=l_Mnr_G sig_type=std_logic lab=vctrl}
N -700 140 -700 180 {lab=vss}
C {devices/lab_pin.sym} -700 180 0 0 {name=l_Mnr_S sig_type=std_logic lab=vss}
N -700 110 -550 110 {lab=vss}
C {devices/lab_pin.sym} -550 110 0 0 {name=l_Mnr_B sig_type=std_logic lab=vss}
C {cs_inv.sym} -180 -110 0 0 {name=X1 }
N -280 -190 -280 -230 {lab=n1}
C {devices/lab_pin.sym} -280 -230 0 0 {name=l_X1_in sig_type=std_logic lab=n1}
N -80 -110 70 -110 {lab=n2}
C {devices/lab_pin.sym} 70 -110 0 0 {name=l_X1_out sig_type=std_logic lab=n2}
N -280 -110 -330 -110 {lab=vbp}
C {devices/lab_pin.sym} -330 -110 0 1 {name=l_X1_vbp sig_type=std_logic lab=vbp}
N -280 -30 -280 10 {lab=vctrl}
C {devices/lab_pin.sym} -280 10 0 0 {name=l_X1_vctrl sig_type=std_logic lab=vctrl}
N -180 -280 -180 -320 {lab=vdd}
C {devices/lab_pin.sym} -180 -320 0 0 {name=l_X1_vdd sig_type=std_logic lab=vdd}
N -180 60 -180 100 {lab=vss}
C {devices/lab_pin.sym} -180 100 0 0 {name=l_X1_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 140 -110 0 0 {name=X2 }
N 40 -190 40 -230 {lab=n2}
C {devices/lab_pin.sym} 40 -230 0 0 {name=l_X2_in sig_type=std_logic lab=n2}
N 240 -110 390 -110 {lab=n3}
C {devices/lab_pin.sym} 390 -110 0 0 {name=l_X2_out sig_type=std_logic lab=n3}
N 40 -110 -10 -110 {lab=vbp}
C {devices/lab_pin.sym} -10 -110 0 1 {name=l_X2_vbp sig_type=std_logic lab=vbp}
N 40 -30 40 10 {lab=vctrl}
C {devices/lab_pin.sym} 40 10 0 0 {name=l_X2_vctrl sig_type=std_logic lab=vctrl}
N 140 -280 140 -320 {lab=vdd}
C {devices/lab_pin.sym} 140 -320 0 0 {name=l_X2_vdd sig_type=std_logic lab=vdd}
N 140 60 140 100 {lab=vss}
C {devices/lab_pin.sym} 140 100 0 0 {name=l_X2_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 470 -110 0 0 {name=X3 }
N 370 -190 370 -230 {lab=n3}
C {devices/lab_pin.sym} 370 -230 0 0 {name=l_X3_in sig_type=std_logic lab=n3}
N 570 -110 720 -110 {lab=n4}
C {devices/lab_pin.sym} 720 -110 0 0 {name=l_X3_out sig_type=std_logic lab=n4}
N 370 -110 320 -110 {lab=vbp}
C {devices/lab_pin.sym} 320 -110 0 1 {name=l_X3_vbp sig_type=std_logic lab=vbp}
N 370 -30 370 10 {lab=vctrl}
C {devices/lab_pin.sym} 370 10 0 0 {name=l_X3_vctrl sig_type=std_logic lab=vctrl}
N 470 -280 470 -320 {lab=vdd}
C {devices/lab_pin.sym} 470 -320 0 0 {name=l_X3_vdd sig_type=std_logic lab=vdd}
N 470 60 470 100 {lab=vss}
C {devices/lab_pin.sym} 470 100 0 0 {name=l_X3_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 790 -110 0 0 {name=X4 }
N 690 -190 690 -230 {lab=n4}
C {devices/lab_pin.sym} 690 -230 0 0 {name=l_X4_in sig_type=std_logic lab=n4}
N 890 -110 1040 -110 {lab=n5}
C {devices/lab_pin.sym} 1040 -110 0 0 {name=l_X4_out sig_type=std_logic lab=n5}
N 690 -110 640 -110 {lab=vbp}
C {devices/lab_pin.sym} 640 -110 0 1 {name=l_X4_vbp sig_type=std_logic lab=vbp}
N 690 -30 690 10 {lab=vctrl}
C {devices/lab_pin.sym} 690 10 0 0 {name=l_X4_vctrl sig_type=std_logic lab=vctrl}
N 790 -280 790 -320 {lab=vdd}
C {devices/lab_pin.sym} 790 -320 0 0 {name=l_X4_vdd sig_type=std_logic lab=vdd}
N 790 60 790 100 {lab=vss}
C {devices/lab_pin.sym} 790 100 0 0 {name=l_X4_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1120 -110 0 0 {name=X5 }
N 1020 -190 1020 -230 {lab=n5}
C {devices/lab_pin.sym} 1020 -230 0 0 {name=l_X5_in sig_type=std_logic lab=n5}
N 1220 -110 1370 -110 {lab=n6}
C {devices/lab_pin.sym} 1370 -110 0 0 {name=l_X5_out sig_type=std_logic lab=n6}
N 1020 -110 970 -110 {lab=vbp}
C {devices/lab_pin.sym} 970 -110 0 1 {name=l_X5_vbp sig_type=std_logic lab=vbp}
N 1020 -30 1020 10 {lab=vctrl}
C {devices/lab_pin.sym} 1020 10 0 0 {name=l_X5_vctrl sig_type=std_logic lab=vctrl}
N 1120 -280 1120 -320 {lab=vdd}
C {devices/lab_pin.sym} 1120 -320 0 0 {name=l_X5_vdd sig_type=std_logic lab=vdd}
N 1120 60 1120 100 {lab=vss}
C {devices/lab_pin.sym} 1120 100 0 0 {name=l_X5_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1440 -110 0 0 {name=X6 }
N 1340 -190 1340 -230 {lab=n6}
C {devices/lab_pin.sym} 1340 -230 0 0 {name=l_X6_in sig_type=std_logic lab=n6}
N 1540 -110 1690 -110 {lab=n7}
C {devices/lab_pin.sym} 1690 -110 0 0 {name=l_X6_out sig_type=std_logic lab=n7}
N 1340 -110 1290 -110 {lab=vbp}
C {devices/lab_pin.sym} 1290 -110 0 1 {name=l_X6_vbp sig_type=std_logic lab=vbp}
N 1340 -30 1340 10 {lab=vctrl}
C {devices/lab_pin.sym} 1340 10 0 0 {name=l_X6_vctrl sig_type=std_logic lab=vctrl}
N 1440 -280 1440 -320 {lab=vdd}
C {devices/lab_pin.sym} 1440 -320 0 0 {name=l_X6_vdd sig_type=std_logic lab=vdd}
N 1440 60 1440 100 {lab=vss}
C {devices/lab_pin.sym} 1440 100 0 0 {name=l_X6_vss sig_type=std_logic lab=vss}
C {cs_inv.sym} 1760 -110 0 0 {name=X7 }
N 1660 -190 1660 -230 {lab=n7}
C {devices/lab_pin.sym} 1660 -230 0 0 {name=l_X7_in sig_type=std_logic lab=n7}
N 1860 -110 2010 -110 {lab=n1}
C {devices/lab_pin.sym} 2010 -110 0 0 {name=l_X7_out sig_type=std_logic lab=n1}
N 1660 -110 1610 -110 {lab=vbp}
C {devices/lab_pin.sym} 1610 -110 0 1 {name=l_X7_vbp sig_type=std_logic lab=vbp}
N 1660 -30 1660 10 {lab=vctrl}
C {devices/lab_pin.sym} 1660 10 0 0 {name=l_X7_vctrl sig_type=std_logic lab=vctrl}
N 1760 -280 1760 -320 {lab=vdd}
C {devices/lab_pin.sym} 1760 -320 0 0 {name=l_X7_vdd sig_type=std_logic lab=vdd}
N 1760 60 1760 100 {lab=vss}
C {devices/lab_pin.sym} 1760 100 0 0 {name=l_X7_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 -110 0 0 {name=Xtap VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 -110 2030 -110 {lab=n1}
C {devices/lab_pin.sym} 2030 -110 0 1 {name=l_Xtap_A sig_type=std_logic lab=n1}
N 2160 -110 2310 -110 {lab=vco_outn}
C {devices/lab_pin.sym} 2310 -110 0 0 {name=l_Xtap_Y sig_type=std_logic lab=vco_outn}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_4.sym} 2450 -110 0 0 {name=Xbuf VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2410 -110 2360 -110 {lab=vco_outn}
C {devices/lab_pin.sym} 2360 -110 0 1 {name=l_Xbuf_A sig_type=std_logic lab=vco_outn}
N 2490 -110 2640 -110 {lab=vco_out}
C {devices/lab_pin.sym} 2640 -110 0 0 {name=l_Xbuf_Y sig_type=std_logic lab=vco_out}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 220 0 0 {name=Xdum2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 220 2030 220 {lab=n2}
C {devices/lab_pin.sym} 2030 220 0 1 {name=l_Xdum2_A sig_type=std_logic lab=n2}
N 2160 220 2310 220 {lab=ndum2}
C {devices/lab_pin.sym} 2310 220 0 0 {name=l_Xdum2_Y sig_type=std_logic lab=ndum2}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 380 0 0 {name=Xdum3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 380 2030 380 {lab=n3}
C {devices/lab_pin.sym} 2030 380 0 1 {name=l_Xdum3_A sig_type=std_logic lab=n3}
N 2160 380 2310 380 {lab=ndum3}
C {devices/lab_pin.sym} 2310 380 0 0 {name=l_Xdum3_Y sig_type=std_logic lab=ndum3}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 540 0 0 {name=Xdum4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 540 2030 540 {lab=n4}
C {devices/lab_pin.sym} 2030 540 0 1 {name=l_Xdum4_A sig_type=std_logic lab=n4}
N 2160 540 2310 540 {lab=ndum4}
C {devices/lab_pin.sym} 2310 540 0 0 {name=l_Xdum4_Y sig_type=std_logic lab=ndum4}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 700 0 0 {name=Xdum5 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 700 2030 700 {lab=n5}
C {devices/lab_pin.sym} 2030 700 0 1 {name=l_Xdum5_A sig_type=std_logic lab=n5}
N 2160 700 2310 700 {lab=ndum5}
C {devices/lab_pin.sym} 2310 700 0 0 {name=l_Xdum5_Y sig_type=std_logic lab=ndum5}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 860 0 0 {name=Xdum6 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 860 2030 860 {lab=n6}
C {devices/lab_pin.sym} 2030 860 0 1 {name=l_Xdum6_A sig_type=std_logic lab=n6}
N 2160 860 2310 860 {lab=ndum6}
C {devices/lab_pin.sym} 2310 860 0 0 {name=l_Xdum6_Y sig_type=std_logic lab=ndum6}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 2120 1030 0 0 {name=Xdum7 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 2080 1030 2030 1030 {lab=n7}
C {devices/lab_pin.sym} 2030 1030 0 1 {name=l_Xdum7_A sig_type=std_logic lab=n7}
N 2160 1030 2310 1030 {lab=ndum7}
C {devices/lab_pin.sym} 2310 1030 0 0 {name=l_Xdum7_Y sig_type=std_logic lab=ndum7}
C {devices/ipin.sym} -1120 -400 0 0 {name=p_vctrl lab=vctrl}
C {devices/opin.sym} -1120 -340 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -1120 -280 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1120 -220 0 0 {name=p_vss lab=vss}
