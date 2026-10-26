v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pll_rosc -- self-biased ring-oscillator PLL, programmable /N} -1000 -500 0 0 0.4 0.4 {}
N -610 -155 -495 -155 {lab=up}
N -495 -155 -465 -155 {lab=up}
N -465 -155 -465 -180 {lab=up}
N -465 -180 -425 -180 {lab=up}
N -610 -45 -540 -45 {lab=dn}
N -540 -45 -540 -100 {lab=dn}
N -540 -100 -490 -100 {lab=dn}
N -490 -100 -425 -100 {lab=dn}
N -75 -100 40 -100 {lab=vctrl}
N 40 -100 430 -100 {lab=vctrl}
N 430 -100 470 -100 {lab=vctrl}
N -75 -100 40 -100 {lab=vctrl}
N 40 -100 40 220 {lab=vctrl}
N 40 220 85 220 {lab=vctrl}
N 85 220 125 220 {lab=vctrl}
N 730 -100 820 -100 {lab=vco_out}
N 820 -100 820 500 {lab=vco_out}
N 820 500 630 500 {lab=vco_out}
N 630 500 590 500 {lab=vco_out}
N 410 620 270 620 {lab=div_out}
N 270 620 -855 620 {lab=div_out}
N -855 620 -855 -100 {lab=div_out}
N -855 -100 -790 -100 {lab=div_out}
N -1000 -180 -830 -180 {lab=ref}
N -830 -180 -790 -180 {lab=ref}
N -1000 -20 -880 -20 {lab=porb}
N -880 -20 -790 -20 {lab=porb}
N -1000 160 -515 160 {lab=ibias}
N -515 160 -515 -20 {lab=ibias}
N -515 -20 -425 -20 {lab=ibias}
N 1000 -100 795 -100 {lab=vco_out}
N 795 -100 730 -100 {lab=vco_out}
C {devices/lab_pin.sym} -610 -155 0 0 {name=l_net_up sig_type=std_logic lab=up}
C {devices/lab_pin.sym} -610 -45 0 0 {name=l_net_dn sig_type=std_logic lab=dn}
C {devices/lab_pin.sym} -75 -100 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} 410 620 0 0 {name=l_net_div_out sig_type=std_logic lab=div_out}
C {pfd.sym} -700 -100 0 0 {name=Xpfd }
N -700 -270 -700 -310 {lab=vdd}
C {devices/lab_pin.sym} -700 -310 0 0 {name=l_Xpfd_vdd sig_type=std_logic lab=vdd}
N -700 70 -700 110 {lab=vss}
C {devices/lab_pin.sym} -700 110 0 0 {name=l_Xpfd_vss sig_type=std_logic lab=vss}
C {charge_pump.sym} -250 -100 0 0 {name=Xcp }
N -250 -270 -250 -310 {lab=vdd}
C {devices/lab_pin.sym} -250 -310 0 0 {name=l_Xcp_vdd sig_type=std_logic lab=vdd}
N -250 70 -250 110 {lab=vss}
C {devices/lab_pin.sym} -250 110 0 0 {name=l_Xcp_vss sig_type=std_logic lab=vss}
C {loop_filter.sym} 300 220 0 0 {name=Xlf }
N 300 310 300 350 {lab=vss}
C {devices/lab_pin.sym} 300 350 0 0 {name=l_Xlf_vss sig_type=std_logic lab=vss}
C {rosc_vco.sym} 600 -100 0 0 {name=Xvco }
N 600 -190 600 -230 {lab=vdd}
C {devices/lab_pin.sym} 600 -230 0 0 {name=l_Xvco_vdd sig_type=std_logic lab=vdd}
N 600 -10 600 30 {lab=vss}
C {devices/lab_pin.sym} 600 30 0 0 {name=l_Xvco_vss sig_type=std_logic lab=vss}
C {divn.sym} 500 620 0 1 {name=Xdiv }
N 590 580 590 540 {lab=rstb}
C {devices/lab_pin.sym} 590 540 0 0 {name=l_Xdiv_rstb sig_type=std_logic lab=rstb}
N 590 660 590 700 {lab=nsel0}
C {devices/lab_pin.sym} 590 700 0 0 {name=l_Xdiv_nsel0 sig_type=std_logic lab=nsel0}
N 590 740 590 780 {lab=nsel1}
C {devices/lab_pin.sym} 590 780 0 0 {name=l_Xdiv_nsel1 sig_type=std_logic lab=nsel1}
N 500 410 500 370 {lab=vdd}
C {devices/lab_pin.sym} 500 370 0 0 {name=l_Xdiv_vdd sig_type=std_logic lab=vdd}
N 500 830 500 870 {lab=vss}
C {devices/lab_pin.sym} 500 870 0 0 {name=l_Xdiv_vss sig_type=std_logic lab=vss}
C {devices/ipin.sym} -1000 -180 0 0 {name=p_ref lab=ref}
C {devices/ipin.sym} -1000 -20 0 0 {name=p_porb lab=porb}
C {devices/ipin.sym} -1000 700 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -1000 740 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -1000 780 0 0 {name=p_nsel1 lab=nsel1}
C {devices/ipin.sym} -1000 160 0 0 {name=p_ibias lab=ibias}
C {devices/opin.sym} 1000 -100 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -1000 -400 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1000 860 0 0 {name=p_vss lab=vss}
L 4 -920 -330 900 -330 {dash=8}
L 4 900 -330 900 380 {dash=8}
L 4 900 380 -920 380 {dash=8}
L 4 -920 380 -920 -330 {dash=8}
T {FORWARD PATH} -914 -356 0 0 0.3 0.3 {layer=4}
L 4 -920 420 900 420 {dash=8}
L 4 900 420 900 880 {dash=8}
L 4 900 880 -920 880 {dash=8}
L 4 -920 880 -920 420 {dash=8}
T {FEEDBACK DIVIDER} -914 394 0 0 0.3 0.3 {layer=4}
