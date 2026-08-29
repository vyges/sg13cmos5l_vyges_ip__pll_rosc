v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pll_rosc -- self-biased ring-oscillator PLL, programmable /N} -560 -360 0 0 0.4 0.4 {}
C {pfd.sym} -540 -180 0 0 {name=Xpfd }
N -630 -260 -630 -300 {lab=ref}
C {devices/lab_pin.sym} -630 -300 0 0 {name=l_Xpfd_ref sig_type=std_logic lab=ref}
N -630 -180 -680 -180 {lab=div_out}
C {devices/lab_pin.sym} -680 -180 0 1 {name=l_Xpfd_div sig_type=std_logic lab=div_out}
N -630 -100 -630 -60 {lab=porb}
C {devices/lab_pin.sym} -630 -60 0 0 {name=l_Xpfd_porb sig_type=std_logic lab=porb}
N -450 -235 -450 -275 {lab=up}
C {devices/lab_pin.sym} -450 -275 0 0 {name=l_Xpfd_up sig_type=std_logic lab=up}
N -450 -125 -450 -85 {lab=dn}
C {devices/lab_pin.sym} -450 -85 0 0 {name=l_Xpfd_dn sig_type=std_logic lab=dn}
N -540 -350 -540 -390 {lab=vdd}
C {devices/lab_pin.sym} -540 -390 0 0 {name=l_Xpfd_vdd sig_type=std_logic lab=vdd}
N -540 -10 -540 30 {lab=vss}
C {devices/lab_pin.sym} -540 30 0 0 {name=l_Xpfd_vss sig_type=std_logic lab=vss}
C {charge_pump.sym} 0 -180 0 0 {name=Xcp }
N -175 -260 -175 -300 {lab=up}
C {devices/lab_pin.sym} -175 -300 0 0 {name=l_Xcp_up sig_type=std_logic lab=up}
N -175 -180 -225 -180 {lab=dn}
C {devices/lab_pin.sym} -225 -180 0 1 {name=l_Xcp_dn sig_type=std_logic lab=dn}
N -175 -100 -175 -60 {lab=ibias}
C {devices/lab_pin.sym} -175 -60 0 0 {name=l_Xcp_ibias sig_type=std_logic lab=ibias}
N 175 -180 325 -180 {lab=vctrl}
C {devices/lab_pin.sym} 325 -180 0 0 {name=l_Xcp_vctrl sig_type=std_logic lab=vctrl}
N 0 -350 0 -390 {lab=vdd}
C {devices/lab_pin.sym} 0 -390 0 0 {name=l_Xcp_vdd sig_type=std_logic lab=vdd}
N 0 -10 0 30 {lab=vss}
C {devices/lab_pin.sym} 0 30 0 0 {name=l_Xcp_vss sig_type=std_logic lab=vss}
C {loop_filter.sym} 430 110 0 0 {name=Xlf }
N 255 110 205 110 {lab=vctrl}
C {devices/lab_pin.sym} 205 110 0 1 {name=l_Xlf_vctrl sig_type=std_logic lab=vctrl}
N 430 200 430 240 {lab=vss}
C {devices/lab_pin.sym} 430 240 0 0 {name=l_Xlf_vss sig_type=std_logic lab=vss}
C {rosc_vco.sym} 830 -180 0 0 {name=Xvco }
N 700 -180 650 -180 {lab=vctrl}
C {devices/lab_pin.sym} 650 -180 0 1 {name=l_Xvco_vctrl sig_type=std_logic lab=vctrl}
N 960 -180 1110 -180 {lab=vco_out}
C {devices/lab_pin.sym} 1110 -180 0 0 {name=l_Xvco_vco_out sig_type=std_logic lab=vco_out}
N 830 -270 830 -310 {lab=vdd}
C {devices/lab_pin.sym} 830 -310 0 0 {name=l_Xvco_vdd sig_type=std_logic lab=vdd}
N 830 -90 830 -50 {lab=vss}
C {devices/lab_pin.sym} 830 -50 0 0 {name=l_Xvco_vss sig_type=std_logic lab=vss}
C {divn.sym} 360 540 0 0 {name=Xdiv }
N 270 420 270 380 {lab=vco_out}
C {devices/lab_pin.sym} 270 380 0 0 {name=l_Xdiv_clk sig_type=std_logic lab=vco_out}
N 270 500 270 460 {lab=rstb}
C {devices/lab_pin.sym} 270 460 0 0 {name=l_Xdiv_rstb sig_type=std_logic lab=rstb}
N 270 580 270 620 {lab=nsel0}
C {devices/lab_pin.sym} 270 620 0 0 {name=l_Xdiv_nsel0 sig_type=std_logic lab=nsel0}
N 270 660 270 700 {lab=nsel1}
C {devices/lab_pin.sym} 270 700 0 0 {name=l_Xdiv_nsel1 sig_type=std_logic lab=nsel1}
N 450 540 600 540 {lab=div_out}
C {devices/lab_pin.sym} 600 540 0 0 {name=l_Xdiv_div_out sig_type=std_logic lab=div_out}
N 360 330 360 290 {lab=vdd}
C {devices/lab_pin.sym} 360 290 0 0 {name=l_Xdiv_vdd sig_type=std_logic lab=vdd}
N 360 750 360 790 {lab=vss}
C {devices/lab_pin.sym} 360 790 0 0 {name=l_Xdiv_vss sig_type=std_logic lab=vss}
C {devices/ipin.sym} -1220 -500 0 0 {name=p_ref lab=ref}
C {devices/ipin.sym} -1220 -440 0 0 {name=p_porb lab=porb}
C {devices/ipin.sym} -1220 -380 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -1220 -320 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -1220 -260 0 0 {name=p_nsel1 lab=nsel1}
C {devices/ipin.sym} -1220 -200 0 0 {name=p_ibias lab=ibias}
C {devices/opin.sym} -1220 -140 0 0 {name=p_vco_out lab=vco_out}
C {devices/iopin.sym} -1220 -80 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1220 -20 0 0 {name=p_vss lab=vss}
