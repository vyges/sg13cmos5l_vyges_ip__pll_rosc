v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pfd -- tri-state phase-frequency detector} -400 -300 0 0 0.4 0.4 {}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 -290 0 0 {name=Xup VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 -310 90 -350 {lab=up}
C {devices/lab_pin.sym} 90 -350 0 0 {name=l_Xup_Q sig_type=std_logic lab=up}
N 90 -290 240 -290 {lab=upn}
C {devices/lab_pin.sym} 240 -290 0 0 {name=l_Xup_Q_N sig_type=std_logic lab=upn}
N -90 -310 -90 -350 {lab=ref}
C {devices/lab_pin.sym} -90 -350 0 0 {name=l_Xup_CLK sig_type=std_logic lab=ref}
N -90 -290 -140 -290 {lab=vdd}
C {devices/lab_pin.sym} -140 -290 0 1 {name=l_Xup_D sig_type=std_logic lab=vdd}
N -90 -270 -90 -230 {lab=rstb}
C {devices/lab_pin.sym} -90 -230 0 0 {name=l_Xup_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 70 0 0 {name=Xdn VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 50 90 10 {lab=dn}
C {devices/lab_pin.sym} 90 10 0 0 {name=l_Xdn_Q sig_type=std_logic lab=dn}
N 90 70 240 70 {lab=dnn}
C {devices/lab_pin.sym} 240 70 0 0 {name=l_Xdn_Q_N sig_type=std_logic lab=dnn}
N -90 50 -90 10 {lab=div}
C {devices/lab_pin.sym} -90 10 0 0 {name=l_Xdn_CLK sig_type=std_logic lab=div}
N -90 70 -140 70 {lab=vdd}
C {devices/lab_pin.sym} -140 70 0 1 {name=l_Xdn_D sig_type=std_logic lab=vdd}
N -90 90 -90 130 {lab=rstb}
C {devices/lab_pin.sym} -90 130 0 0 {name=l_Xdn_RESET_B sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_nand2_1.sym} 580 -110 0 0 {name=Xnand VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 520 -130 520 -170 {lab=up}
C {devices/lab_pin.sym} 520 -170 0 0 {name=l_Xnand_A sig_type=std_logic lab=up}
N 520 -90 520 -50 {lab=dn}
C {devices/lab_pin.sym} 520 -50 0 0 {name=l_Xnand_B sig_type=std_logic lab=dn}
N 640 -110 790 -110 {lab=nout}
C {devices/lab_pin.sym} 790 -110 0 0 {name=l_Xnand_Y sig_type=std_logic lab=nout}
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 580 250 0 0 {name=Xand VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 520 230 520 190 {lab=nout}
C {devices/lab_pin.sym} 520 190 0 0 {name=l_Xand_A sig_type=std_logic lab=nout}
N 520 270 520 310 {lab=porb}
C {devices/lab_pin.sym} 520 310 0 0 {name=l_Xand_B sig_type=std_logic lab=porb}
N 640 250 790 250 {lab=rstb}
C {devices/lab_pin.sym} 790 250 0 0 {name=l_Xand_X sig_type=std_logic lab=rstb}
C {devices/ipin.sym} -940 -360 0 0 {name=p_ref lab=ref}
C {devices/ipin.sym} -940 -300 0 0 {name=p_div lab=div}
C {devices/ipin.sym} -940 -240 0 0 {name=p_porb lab=porb}
C {devices/opin.sym} -940 -180 0 0 {name=p_up lab=up}
C {devices/opin.sym} -940 -120 0 0 {name=p_dn lab=dn}
C {devices/iopin.sym} -940 -60 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -940 0 0 0 {name=p_vss lab=vss}
