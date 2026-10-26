v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {divn -- programmable feedback divider /2 /4 /8 /16} -1000 -400 0 0 0.4 0.4 {}
N -510 -60 -480 -60 {lab=q1b}
N -480 -60 -480 40 {lab=q1b}
N -480 40 -755 40 {lab=q1b}
N -755 40 -755 -60 {lab=q1b}
N -755 -60 -690 -60 {lab=q1b}
N -510 -80 -395 -80 {lab=q1}
N -395 -80 -290 -80 {lab=q1}
N -290 -80 -250 -80 {lab=q1}
N -690 -40 -780 -40 {lab=rstb}
N -780 -40 -780 100 {lab=rstb}
N -780 100 -340 100 {lab=rstb}
N -340 100 -340 -40 {lab=rstb}
N -340 -40 -250 -40 {lab=rstb}
N -510 -80 -395 -80 {lab=q1}
N -395 -80 -395 180 {lab=q1}
N -395 180 1120 180 {lab=q1}
N 1120 180 1120 340 {lab=q1}
N 1120 340 1160 340 {lab=q1}
N -70 -60 -40 -60 {lab=q2b}
N -40 -60 -40 40 {lab=q2b}
N -40 40 -315 40 {lab=q2b}
N -315 40 -315 -60 {lab=q2b}
N -315 -60 -250 -60 {lab=q2b}
N -70 -80 45 -80 {lab=q2}
N 45 -80 150 -80 {lab=q2}
N 150 -80 190 -80 {lab=q2}
N -250 -40 -340 -40 {lab=rstb}
N -340 -40 -340 100 {lab=rstb}
N -340 100 100 100 {lab=rstb}
N 100 100 100 -40 {lab=rstb}
N 100 -40 190 -40 {lab=rstb}
N -70 -80 45 -80 {lab=q2}
N 45 -80 45 220 {lab=q2}
N 45 220 1095 220 {lab=q2}
N 1095 220 1095 380 {lab=q2}
N 1095 380 1160 380 {lab=q2}
N 370 -60 400 -60 {lab=q3b}
N 400 -60 400 40 {lab=q3b}
N 400 40 125 40 {lab=q3b}
N 125 40 125 -60 {lab=q3b}
N 125 -60 190 -60 {lab=q3b}
N 370 -80 485 -80 {lab=q3}
N 485 -80 590 -80 {lab=q3}
N 590 -80 630 -80 {lab=q3}
N 190 -40 100 -40 {lab=rstb}
N 100 -40 100 100 {lab=rstb}
N 100 100 540 100 {lab=rstb}
N 540 100 540 -40 {lab=rstb}
N 540 -40 630 -40 {lab=rstb}
N 370 -80 485 -80 {lab=q3}
N 485 -80 485 260 {lab=q3}
N 485 260 1070 260 {lab=q3}
N 1070 260 1070 420 {lab=q3}
N 1070 420 1160 420 {lab=q3}
N 810 -60 840 -60 {lab=q4b}
N 840 -60 840 40 {lab=q4b}
N 840 40 565 40 {lab=q4b}
N 565 40 565 -60 {lab=q4b}
N 565 -60 630 -60 {lab=q4b}
N 810 -80 925 -80 {lab=q4}
N 925 -80 925 300 {lab=q4}
N 925 300 1045 300 {lab=q4}
N 1045 300 1045 460 {lab=q4}
N 1045 460 1160 460 {lab=q4}
N -1000 -80 -730 -80 {lab=clk}
N -730 -80 -690 -80 {lab=clk}
N -1000 100 -780 100 {lab=rstb}
N -780 100 -780 -40 {lab=rstb}
N -780 -40 -690 -40 {lab=rstb}
N -1000 500 1160 500 {lab=nsel0}
N -1000 530 1160 530 {lab=nsel1}
N 1500 400 1430 400 {lab=div_out}
N 1430 400 1240 400 {lab=div_out}
C {devices/lab_pin.sym} -510 -60 0 0 {name=l_net_q1b sig_type=std_logic lab=q1b}
C {devices/lab_pin.sym} -510 -80 0 0 {name=l_net_q1 sig_type=std_logic lab=q1}
C {devices/lab_pin.sym} -70 -60 0 0 {name=l_net_q2b sig_type=std_logic lab=q2b}
C {devices/lab_pin.sym} -70 -80 0 0 {name=l_net_q2 sig_type=std_logic lab=q2}
C {devices/lab_pin.sym} 370 -60 0 0 {name=l_net_q3b sig_type=std_logic lab=q3b}
C {devices/lab_pin.sym} 370 -80 0 0 {name=l_net_q3 sig_type=std_logic lab=q3}
C {devices/lab_pin.sym} 810 -60 0 0 {name=l_net_q4b sig_type=std_logic lab=q4b}
C {devices/lab_pin.sym} 810 -80 0 0 {name=l_net_q4 sig_type=std_logic lab=q4}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -600 -60 0 0 {name=Xd1 VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} -160 -60 0 0 {name=Xd2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 280 -60 0 0 {name=Xd3 VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 720 -60 0 0 {name=Xd4 VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_mux4_1.sym} 1200 400 0 0 {name=Xmux VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {devices/ipin.sym} -1000 -80 0 0 {name=p_clk lab=clk}
C {devices/ipin.sym} -1000 100 0 0 {name=p_rstb lab=rstb}
C {devices/ipin.sym} -1000 500 0 0 {name=p_nsel0 lab=nsel0}
C {devices/ipin.sym} -1000 530 0 0 {name=p_nsel1 lab=nsel1}
C {devices/opin.sym} 1500 400 0 0 {name=p_div_out lab=div_out}
C {devices/iopin.sym} -1000 -300 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1000 640 0 0 {name=p_vss lab=vss}
L 4 -840 -180 900 -180 {dash=8}
L 4 900 -180 900 340 {dash=8}
L 4 900 340 -840 340 {dash=8}
L 4 -840 340 -840 -180 {dash=8}
T {RIPPLE CHAIN (four toggle flops)} -834 -206 0 0 0.3 0.3 {layer=4}
L 4 980 300 1340 300 {dash=8}
L 4 1340 300 1340 580 {dash=8}
L 4 1340 580 980 580 {dash=8}
L 4 980 580 980 300 {dash=8}
T {TAP SELECT} 986 274 0 0 0.3 0.3 {layer=4}
