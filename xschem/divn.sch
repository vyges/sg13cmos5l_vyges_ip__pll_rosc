v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {divn -- programmable feedback divider /2 /4 /8 /16} -460 -260 0 0 0.4 0.4 {}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -540 -110 0 0 {name=Xd1 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -450 -130 -450 -170 {lab=q1}
C {devices/lab_pin.sym} -450 -170 0 0 {name=l_Xd1_Q sig_type=std_logic lab=q1}
N -450 -110 -300 -110 {lab=q1b}
C {devices/lab_pin.sym} -300 -110 0 0 {name=l_Xd1_Q_N sig_type=std_logic lab=q1b}
N -630 -130 -630 -170 {lab=clk}
C {devices/lab_pin.sym} -630 -170 0 0 {name=l_Xd1_CLK sig_type=std_logic lab=clk}
N -630 -110 -680 -110 {lab=q1b}
C {devices/lab_pin.sym} -680 -110 0 1 {name=l_Xd1_D sig_type=std_logic lab=q1b}
N -630 -90 -630 -50 {lab=rstb}
C {devices/lab_pin.sym} -630 -50 0 0 {name=l_Xd1_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -70 -110 0 0 {name=Xd2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 20 -130 20 -170 {lab=q2}
C {devices/lab_pin.sym} 20 -170 0 0 {name=l_Xd2_Q sig_type=std_logic lab=q2}
N 20 -110 170 -110 {lab=q2b}
C {devices/lab_pin.sym} 170 -110 0 0 {name=l_Xd2_Q_N sig_type=std_logic lab=q2b}
N -160 -130 -160 -170 {lab=q1}
C {devices/lab_pin.sym} -160 -170 0 0 {name=l_Xd2_CLK sig_type=std_logic lab=q1}
N -160 -110 -210 -110 {lab=q2b}
C {devices/lab_pin.sym} -210 -110 0 1 {name=l_Xd2_D sig_type=std_logic lab=q2b}
N -160 -90 -160 -50 {lab=rstb}
C {devices/lab_pin.sym} -160 -50 0 0 {name=l_Xd2_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 400 -110 0 0 {name=Xd3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 490 -130 490 -170 {lab=q3}
C {devices/lab_pin.sym} 490 -170 0 0 {name=l_Xd3_Q sig_type=std_logic lab=q3}
N 490 -110 640 -110 {lab=q3b}
C {devices/lab_pin.sym} 640 -110 0 0 {name=l_Xd3_Q_N sig_type=std_logic lab=q3b}
N 310 -130 310 -170 {lab=q2}
C {devices/lab_pin.sym} 310 -170 0 0 {name=l_Xd3_CLK sig_type=std_logic lab=q2}
N 310 -110 260 -110 {lab=q3b}
C {devices/lab_pin.sym} 260 -110 0 1 {name=l_Xd3_D sig_type=std_logic lab=q3b}
N 310 -90 310 -50 {lab=rstb}
C {devices/lab_pin.sym} 310 -50 0 0 {name=l_Xd3_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 860 -110 0 0 {name=Xd4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 950 -130 950 -170 {lab=q4}
C {devices/lab_pin.sym} 950 -170 0 0 {name=l_Xd4_Q sig_type=std_logic lab=q4}
N 950 -110 1100 -110 {lab=q4b}
C {devices/lab_pin.sym} 1100 -110 0 0 {name=l_Xd4_Q_N sig_type=std_logic lab=q4b}
N 770 -130 770 -170 {lab=q3}
C {devices/lab_pin.sym} 770 -170 0 0 {name=l_Xd4_CLK sig_type=std_logic lab=q3}
N 770 -110 720 -110 {lab=q4b}
C {devices/lab_pin.sym} 720 -110 0 1 {name=l_Xd4_D sig_type=std_logic lab=q4b}
N 770 -90 770 -50 {lab=rstb}
C {devices/lab_pin.sym} 770 -50 0 0 {name=l_Xd4_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_mux4_1.sym} 1370 290 0 0 {name=Xmux VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 1330 230 1330 190 {lab=q1}
C {devices/lab_pin.sym} 1330 190 0 0 {name=l_Xmux_A0 sig_type=std_logic lab=q1}
N 1330 270 1330 230 {lab=q2}
C {devices/lab_pin.sym} 1330 230 0 0 {name=l_Xmux_A1 sig_type=std_logic lab=q2}
N 1330 310 1330 350 {lab=q3}
C {devices/lab_pin.sym} 1330 350 0 0 {name=l_Xmux_A2 sig_type=std_logic lab=q3}
N 1330 350 1330 390 {lab=q4}
C {devices/lab_pin.sym} 1330 390 0 0 {name=l_Xmux_A3 sig_type=std_logic lab=q4}
N 1330 390 1330 430 {lab=nsel0}
C {devices/lab_pin.sym} 1330 430 0 0 {name=l_Xmux_S0 sig_type=std_logic lab=nsel0}
N 1330 420 1330 460 {lab=nsel1}
C {devices/lab_pin.sym} 1330 460 0 0 {name=l_Xmux_S1 sig_type=std_logic lab=nsel1}
N 1410 290 1560 290 {lab=div_out}
C {devices/lab_pin.sym} 1560 290 0 0 {name=l_Xmux_X sig_type=std_logic lab=div_out}
C {devices/ipin.sym} -1010 -320 0 0 {name=p_clk lab=clk}
C {devices/ipin.sym} -1010 -260 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -1010 -200 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -1010 -140 0 0 {name=p_nsel1 lab=nsel1}
C {devices/opin.sym} -1010 -80 0 0 {name=p_div_out lab=div_out}
C {devices/iopin.sym} -1010 -20 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1010 40 0 0 {name=p_vss lab=vss}
