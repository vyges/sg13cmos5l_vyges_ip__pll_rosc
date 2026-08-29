v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {charge_pump -- current-steering charge pump} -460 -400 0 0 0.4 0.4 {}
N -380 140 -430 140 {lab=ibias}
N -430 140 -430 70 {lab=ibias}
N -430 70 -340 70 {lab=ibias}
N -340 70 -340 110 {lab=ibias}
N -380 140 -380 250 {lab=ibias}
N -380 250 -225 250 {lab=ibias}
N -225 250 -225 140 {lab=ibias}
N -225 140 -160 140 {lab=ibias}
N -160 140 -160 250 {lab=ibias}
N -160 250 75 250 {lab=ibias}
N 75 250 75 140 {lab=ibias}
N 75 140 140 140 {lab=ibias}
N -120 110 -120 70 {lab=vbp}
N -120 70 -120 -190 {lab=vbp}
N -120 -190 -120 -230 {lab=vbp}
N -160 -260 -210 -260 {lab=vbp}
N -210 -260 -210 -190 {lab=vbp}
N -210 -190 -120 -190 {lab=vbp}
N -120 -190 -120 -230 {lab=vbp}
N -160 -260 -160 -350 {lab=vbp}
N -160 -350 75 -350 {lab=vbp}
N 75 -350 75 -260 {lab=vbp}
N 75 -260 140 -260 {lab=vbp}
N 180 -230 180 -240 {lab=a}
N 180 -240 180 -150 {lab=a}
N 180 110 180 100 {lab=b}
N 180 100 180 10 {lab=b}
N 180 -90 180 -50 {lab=vctrl}
N -440 -90 -440 -50 {lab=upb}
N -480 -120 -545 -120 {lab=up}
N -545 -120 -545 -20 {lab=up}
N -545 -20 -480 -20 {lab=up}
C {devices/lab_pin.sym} -380 140 0 0 {name=l_net_ibias sig_type=std_logic lab=ibias}
C {devices/lab_pin.sym} -120 110 0 0 {name=l_net_vbp sig_type=std_logic lab=vbp}
C {devices/lab_pin.sym} 180 -230 0 0 {name=l_net_a sig_type=std_logic lab=a}
C {devices/lab_pin.sym} 180 110 0 0 {name=l_net_b sig_type=std_logic lab=b}
C {devices/lab_pin.sym} 180 -90 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} -440 -90 0 0 {name=l_net_upb sig_type=std_logic lab=upb}
C {devices/lab_pin.sym} -480 -120 0 0 {name=l_net_up sig_type=std_logic lab=up}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -360 140 0 0 {name=Mn0 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N -340 170 -340 210 {lab=vss}
C {devices/lab_pin.sym} -340 210 0 0 {name=l_Mn0_S sig_type=std_logic lab=vss}
N -340 140 -270 140 {lab=vss}
C {devices/lab_pin.sym} -270 140 0 0 {name=l_Mn0_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -140 140 0 0 {name=Mn1 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N -120 170 -120 210 {lab=vss}
C {devices/lab_pin.sym} -120 210 0 0 {name=l_Mn1_S sig_type=std_logic lab=vss}
N -120 140 -50 140 {lab=vss}
C {devices/lab_pin.sym} -50 140 0 0 {name=l_Mn1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -140 -260 0 0 {name=Mp0 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N -120 -290 -120 -330 {lab=vdd}
C {devices/lab_pin.sym} -120 -330 0 0 {name=l_Mp0_S sig_type=std_logic lab=vdd}
N -120 -260 -50 -260 {lab=vdd}
C {devices/lab_pin.sym} -50 -260 0 0 {name=l_Mp0_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 160 -260 0 0 {name=Mpsrc l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 180 -290 180 -330 {lab=vdd}
C {devices/lab_pin.sym} 180 -330 0 0 {name=l_Mpsrc_S sig_type=std_logic lab=vdd}
N 180 -260 250 -260 {lab=vdd}
C {devices/lab_pin.sym} 250 -260 0 0 {name=l_Mpsrc_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 160 140 0 0 {name=Mnsnk l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 180 170 180 210 {lab=vss}
C {devices/lab_pin.sym} 180 210 0 0 {name=l_Mnsnk_S sig_type=std_logic lab=vss}
N 180 140 250 140 {lab=vss}
C {devices/lab_pin.sym} 250 140 0 0 {name=l_Mnsnk_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -460 -120 0 0 {name=Mpi l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=2u}
N -440 -150 -440 -190 {lab=vdd}
C {devices/lab_pin.sym} -440 -190 0 0 {name=l_Mpi_S sig_type=std_logic lab=vdd}
N -440 -120 -370 -120 {lab=vdd}
C {devices/lab_pin.sym} -370 -120 0 0 {name=l_Mpi_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -460 -20 0 0 {name=Mni l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=1u}
N -440 10 -440 50 {lab=vss}
C {devices/lab_pin.sym} -440 50 0 0 {name=l_Mni_S sig_type=std_logic lab=vss}
N -440 -20 -370 -20 {lab=vss}
C {devices/lab_pin.sym} -370 -20 0 0 {name=l_Mni_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 160 -120 0 0 {name=Mswup l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 140 -120 90 -120 {lab=upb}
C {devices/lab_pin.sym} 90 -120 0 1 {name=l_Mswup_G sig_type=std_logic lab=upb}
N 180 -120 250 -120 {lab=vdd}
C {devices/lab_pin.sym} 250 -120 0 0 {name=l_Mswup_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 160 -20 0 0 {name=Mswdn l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 140 -20 90 -20 {lab=dn}
C {devices/lab_pin.sym} 90 -20 0 1 {name=l_Mswdn_G sig_type=std_logic lab=dn}
N 180 -20 250 -20 {lab=vss}
C {devices/lab_pin.sym} 250 -20 0 0 {name=l_Mswdn_B sig_type=std_logic lab=vss}
N -480 -120 -530 -120 {lab=up}
C {devices/ipin.sym} -530 -120 0 1 {name=p_up lab=up}
N 140 -20 90 -20 {lab=dn}
C {devices/ipin.sym} 90 -20 0 1 {name=p_dn lab=dn}
N -340 110 -340 70 {lab=ibias}
C {devices/ipin.sym} -340 70 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -580 -300 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -580 -240 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -580 -180 0 0 {name=p_vss lab=vss}
