v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {divn -- programmable feedback divider /2 /4 /8 /16} -460 -260 0 0 0.4 0.4 {}
N -510 -80 -410 -80 {lab=q1}
N -410 -80 -370 -80 {lab=q1}
N -190 -80 -90 -80 {lab=q2}
N -90 -80 -50 -80 {lab=q2}
N 130 -80 230 -80 {lab=q3}
N 230 -80 270 -80 {lab=q3}
C {devices/lab_pin.sym} -510 -80 0 0 {name=l_net_q1 sig_type=std_logic lab=q1}
C {devices/lab_pin.sym} -190 -80 0 0 {name=l_net_q2 sig_type=std_logic lab=q2}
C {devices/lab_pin.sym} 130 -80 0 0 {name=l_net_q3 sig_type=std_logic lab=q3}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -600 -60 0 0 {name=Xd1 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -510 -60 -440 -60 {lab=q1b}
C {devices/lab_pin.sym} -440 -60 0 0 {name=l_Xd1_Q_N sig_type=std_logic lab=q1b}
N -690 -80 -690 -120 {lab=clk}
N -690 -40 -690 0 {lab=rstb}
C {devices/lab_pin.sym} -690 0 0 0 {name=l_Xd1_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -280 -60 0 0 {name=Xd2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -190 -60 -120 -60 {lab=q2b}
C {devices/lab_pin.sym} -120 -60 0 0 {name=l_Xd2_Q_N sig_type=std_logic lab=q2b}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 40 -60 0 0 {name=Xd3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 130 -60 200 -60 {lab=q3b}
C {devices/lab_pin.sym} 200 -60 0 0 {name=l_Xd3_Q_N sig_type=std_logic lab=q3b}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 360 -60 0 0 {name=Xd4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 450 -80 450 -120 {lab=q4}
C {devices/lab_pin.sym} 450 -120 0 0 {name=l_Xd4_Q sig_type=std_logic lab=q4}
N 450 -60 520 -60 {lab=q4b}
C {devices/lab_pin.sym} 520 -60 0 0 {name=l_Xd4_Q_N sig_type=std_logic lab=q4b}
C {sg13cmos5l_stdcells/sg13cmos5l_mux4_1.sym} 820 260 0 0 {name=Xmux VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 780 200 780 160 {lab=q1}
N 780 240 730 240 {lab=q2}
N 780 280 730 280 {lab=q3}
N 780 360 730 360 {lab=nsel0}
C {devices/lab_pin.sym} 730 360 0 1 {name=l_Xmux_S0 sig_type=std_logic lab=nsel0}
N 780 390 780 430 {lab=nsel1}
C {devices/lab_pin.sym} 780 430 0 0 {name=l_Xmux_S1 sig_type=std_logic lab=nsel1}
N 860 260 930 260 {lab=div_out}
N -690 -80 -690 -120 {lab=clk}
C {devices/ipin.sym} -690 -120 0 0 {name=p_clk lab=clk}
C {devices/ipin.sym} -560 -180 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -560 -120 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -560 -60 0 0 {name=p_nsel1 lab=nsel1}
N 860 260 930 260 {lab=div_out}
C {devices/opin.sym} 930 260 0 0 {name=p_div_out lab=div_out}
C {devices/iopin.sym} -560 0 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -560 60 0 0 {name=p_vss lab=vss}
N -690 -60 -700 -60 {lab=q1b}
N -370 -60 -380 -60 {lab=q2b}
N -370 -40 -370 -30 {lab=rstb}
N -50 -60 -60 -60 {lab=q3b}
N -50 -40 -50 -30 {lab=rstb}
N 270 -60 260 -60 {lab=q4b}
N 270 -40 270 -30 {lab=rstb}
N 780 320 740 320 {lab=q4}
N -430 -80 -430 160 {lab=q1}
N -430 160 780 160 {lab=q1}
N -510 -60 -510 10 {lab=q1b}
N -510 10 -700 10 {lab=q1b}
N -700 10 -700 -60 {lab=q1b}
N -110 -80 -110 240 {lab=q2}
N -110 240 730 240 {lab=q2}
N -190 -60 -190 10 {lab=q2b}
N -190 10 -380 10 {lab=q2b}
N -380 10 -380 -60 {lab=q2b}
N 210 -80 210 280 {lab=q3}
N 210 280 730 280 {lab=q3}
N 130 -60 130 10 {lab=q3b}
N 130 10 -60 10 {lab=q3b}
N -60 10 -60 -60 {lab=q3b}
N 740 320 740 -80 {lab=q4}
N 740 -80 450 -80 {lab=q4}
N 450 -60 450 10 {lab=q4b}
N 450 10 260 10 {lab=q4b}
N 260 10 260 -60 {lab=q4b}
N -690 -30 -370 -30 {lab=rstb}
N -370 -30 -50 -30 {lab=rstb}
N -50 -30 270 -30 {lab=rstb}
