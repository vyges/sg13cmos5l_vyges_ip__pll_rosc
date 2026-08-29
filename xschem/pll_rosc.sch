v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pll_rosc -- self-biased ring-oscillator PLL, programmable /N} -560 -360 0 0 0.4 0.4 {}
N -610 -155 -495 -155 {lab=up}
N -495 -155 -415 -155 {lab=up}
N -415 -155 -415 -180 {lab=up}
N -415 -180 -375 -180 {lab=up}
N -610 -45 -470 -45 {lab=dn}
N -470 -45 -440 -45 {lab=dn}
N -440 -45 -440 -100 {lab=dn}
N -440 -100 -375 -100 {lab=dn}
N -25 -100 25 -100 {lab=vctrl}
N 25 -100 25 160 {lab=vctrl}
N 25 160 65 160 {lab=vctrl}
N 65 160 530 160 {lab=vctrl}
N 530 160 530 -100 {lab=vctrl}
N 530 -100 570 -100 {lab=vctrl}
N 830 -100 830 320 {lab=vco_out}
N 830 320 110 320 {lab=vco_out}
N 110 320 110 360 {lab=vco_out}
N 290 480 290 760 {lab=div_out}
N 290 760 -855 760 {lab=div_out}
N -855 760 -855 -100 {lab=div_out}
N -855 -100 -790 -100 {lab=div_out}
C {devices/lab_pin.sym} -610 -155 0 0 {name=l_net_up sig_type=std_logic lab=up}
C {devices/lab_pin.sym} -610 -45 0 0 {name=l_net_dn sig_type=std_logic lab=dn}
C {devices/lab_pin.sym} -25 -100 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} 830 -100 0 0 {name=l_net_vco_out sig_type=std_logic lab=vco_out}
C {devices/lab_pin.sym} 290 480 0 0 {name=l_net_div_out sig_type=std_logic lab=div_out}
C {pfd.sym} -700 -100 0 0 {name=Xpfd }
N -790 -180 -790 -220 {lab=ref}
C {devices/lab_pin.sym} -790 -220 0 0 {name=l_Xpfd_ref sig_type=std_logic lab=ref}
N -790 -20 -790 20 {lab=porb}
C {devices/lab_pin.sym} -790 20 0 0 {name=l_Xpfd_porb sig_type=std_logic lab=porb}
N -700 -270 -700 -310 {lab=vdd}
C {devices/lab_pin.sym} -700 -310 0 0 {name=l_Xpfd_vdd sig_type=std_logic lab=vdd}
N -700 70 -700 110 {lab=vss}
C {devices/lab_pin.sym} -700 110 0 0 {name=l_Xpfd_vss sig_type=std_logic lab=vss}
C {charge_pump.sym} -200 -100 0 0 {name=Xcp }
N -375 -20 -375 20 {lab=ibias}
C {devices/lab_pin.sym} -375 20 0 0 {name=l_Xcp_ibias sig_type=std_logic lab=ibias}
N -200 -270 -200 -310 {lab=vdd}
C {devices/lab_pin.sym} -200 -310 0 0 {name=l_Xcp_vdd sig_type=std_logic lab=vdd}
N -200 70 -200 110 {lab=vss}
C {devices/lab_pin.sym} -200 110 0 0 {name=l_Xcp_vss sig_type=std_logic lab=vss}
C {loop_filter.sym} 240 160 0 0 {name=Xlf }
N 240 250 240 290 {lab=vss}
C {devices/lab_pin.sym} 240 290 0 0 {name=l_Xlf_vss sig_type=std_logic lab=vss}
C {rosc_vco.sym} 700 -100 0 0 {name=Xvco }
N 700 -190 700 -230 {lab=vdd}
C {devices/lab_pin.sym} 700 -230 0 0 {name=l_Xvco_vdd sig_type=std_logic lab=vdd}
N 700 -10 700 30 {lab=vss}
C {devices/lab_pin.sym} 700 30 0 0 {name=l_Xvco_vss sig_type=std_logic lab=vss}
C {divn.sym} 200 480 0 0 {name=Xdiv }
N 110 440 110 400 {lab=rstb}
C {devices/lab_pin.sym} 110 400 0 0 {name=l_Xdiv_rstb sig_type=std_logic lab=rstb}
N 110 520 110 560 {lab=nsel0}
C {devices/lab_pin.sym} 110 560 0 0 {name=l_Xdiv_nsel0 sig_type=std_logic lab=nsel0}
N 110 600 110 640 {lab=nsel1}
C {devices/lab_pin.sym} 110 640 0 0 {name=l_Xdiv_nsel1 sig_type=std_logic lab=nsel1}
N 200 270 200 230 {lab=vdd}
C {devices/lab_pin.sym} 200 230 0 0 {name=l_Xdiv_vdd sig_type=std_logic lab=vdd}
N 200 690 200 730 {lab=vss}
C {devices/lab_pin.sym} 200 730 0 0 {name=l_Xdiv_vss sig_type=std_logic lab=vss}
N -790 -180 -790 -220 {lab=ref}
C {devices/ipin.sym} -790 -220 0 0 {name=p_ref lab=ref}
C {devices/ipin.sym} -680 -280 0 0 {name=p_porb lab=porb}
C {devices/ipin.sym} -680 -220 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -680 -160 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -680 -100 0 0 {name=p_nsel1 lab=nsel1}
N -375 -20 -375 20 {lab=ibias}
C {devices/ipin.sym} -375 20 0 0 {name=p_ibias lab=ibias}
N 830 -100 900 -100 {lab=vco_out}
C {devices/opin.sym} 900 -100 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -680 -40 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -680 20 0 0 {name=p_vss lab=vss}
