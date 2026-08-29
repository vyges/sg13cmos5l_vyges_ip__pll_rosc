v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pfd -- tri-state phase-frequency detector} -400 -300 0 0 0.4 0.4 {}
N 90 -240 205 -240 {lab=up}
N 205 -240 280 -240 {lab=up}
N 280 -240 280 -100 {lab=up}
N 280 -100 320 -100 {lab=up}
N 320 -100 360 -100 {lab=up}
N 90 40 205 40 {lab=dn}
N 205 40 240 40 {lab=dn}
N 240 40 240 -60 {lab=dn}
N 240 -60 295 -60 {lab=dn}
N 295 -60 360 -60 {lab=dn}
N 480 -80 560 -80 {lab=nout}
N 560 -80 560 160 {lab=nout}
N 560 160 320 160 {lab=nout}
N 320 160 360 160 {lab=nout}
N 480 180 560 180 {lab=rstb}
N 560 180 560 320 {lab=rstb}
N 560 320 -260 320 {lab=rstb}
N -260 320 -260 -200 {lab=rstb}
N -260 -200 -180 -200 {lab=rstb}
N -180 -200 -90 -200 {lab=rstb}
N 480 180 560 180 {lab=rstb}
N 560 180 560 320 {lab=rstb}
N 560 320 -260 320 {lab=rstb}
N -260 320 -260 80 {lab=rstb}
N -260 80 -180 80 {lab=rstb}
N -180 80 -90 80 {lab=rstb}
C {devices/lab_pin.sym} 90 -240 0 0 {name=l_net_up sig_type=std_logic lab=up}
C {devices/lab_pin.sym} 90 40 0 0 {name=l_net_dn sig_type=std_logic lab=dn}
C {devices/lab_pin.sym} 480 -80 0 0 {name=l_net_nout sig_type=std_logic lab=nout}
C {devices/lab_pin.sym} 480 180 0 0 {name=l_net_rstb sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 -220 0 0 {name=Xup VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 -220 160 -220 {lab=upn}
C {devices/lab_pin.sym} 160 -220 0 0 {name=l_Xup_Q_N sig_type=std_logic lab=upn}
N -90 -240 -90 -280 {lab=ref}
C {devices/lab_pin.sym} -90 -280 0 0 {name=l_Xup_CLK sig_type=std_logic lab=ref}
N -90 -220 -140 -220 {lab=vdd}
C {devices/lab_pin.sym} -140 -220 0 1 {name=l_Xup_D sig_type=std_logic lab=vdd}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 60 0 0 {name=Xdn VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 60 160 60 {lab=dnn}
C {devices/lab_pin.sym} 160 60 0 0 {name=l_Xdn_Q_N sig_type=std_logic lab=dnn}
N -90 40 -90 0 {lab=div}
C {devices/lab_pin.sym} -90 0 0 0 {name=l_Xdn_CLK sig_type=std_logic lab=div}
N -90 60 -140 60 {lab=vdd}
C {devices/lab_pin.sym} -140 60 0 1 {name=l_Xdn_D sig_type=std_logic lab=vdd}
C {sg13cmos5l_stdcells/sg13cmos5l_nand2_1.sym} 420 -80 0 0 {name=Xnand VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 420 180 0 0 {name=Xand VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 360 200 360 240 {lab=porb}
C {devices/lab_pin.sym} 360 240 0 0 {name=l_Xand_B sig_type=std_logic lab=porb}
N -90 -240 -90 -280 {lab=ref}
C {devices/ipin.sym} -90 -280 0 0 {name=p_ref lab=ref}
N -90 40 -90 0 {lab=div}
C {devices/ipin.sym} -90 0 0 0 {name=p_div lab=div}
N 360 200 360 240 {lab=porb}
C {devices/ipin.sym} 360 240 0 0 {name=p_porb lab=porb}
N 90 -240 90 -280 {lab=up}
C {devices/opin.sym} 90 -280 0 0 {name=p_up lab=up}
N 90 40 90 0 {lab=dn}
C {devices/opin.sym} 90 0 0 0 {name=p_dn lab=dn}
C {devices/iopin.sym} -520 -200 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -520 -140 0 0 {name=p_vss lab=vss}
