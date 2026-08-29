v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {charge_pump -- current-steering charge pump} -460 -400 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -540 180 0 0 {name=Mn0 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N -520 150 -520 110 {lab=ibias}
C {devices/lab_pin.sym} -520 110 0 0 {name=l_Mn0_D sig_type=std_logic lab=ibias}
N -560 180 -610 180 {lab=ibias}
C {devices/lab_pin.sym} -610 180 0 1 {name=l_Mn0_G sig_type=std_logic lab=ibias}
N -520 210 -520 250 {lab=vss}
C {devices/lab_pin.sym} -520 250 0 0 {name=l_Mn0_S sig_type=std_logic lab=vss}
N -520 180 -370 180 {lab=vss}
C {devices/lab_pin.sym} -370 180 0 0 {name=l_Mn0_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -220 180 0 0 {name=Mn1 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N -200 150 -200 110 {lab=vbp}
C {devices/lab_pin.sym} -200 110 0 0 {name=l_Mn1_D sig_type=std_logic lab=vbp}
N -240 180 -290 180 {lab=ibias}
C {devices/lab_pin.sym} -290 180 0 1 {name=l_Mn1_G sig_type=std_logic lab=ibias}
N -200 210 -200 250 {lab=vss}
C {devices/lab_pin.sym} -200 250 0 0 {name=l_Mn1_S sig_type=std_logic lab=vss}
N -200 180 -50 180 {lab=vss}
C {devices/lab_pin.sym} -50 180 0 0 {name=l_Mn1_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -220 -400 0 0 {name=Mp0 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N -200 -370 -200 -330 {lab=vbp}
C {devices/lab_pin.sym} -200 -330 0 0 {name=l_Mp0_D sig_type=std_logic lab=vbp}
N -240 -400 -290 -400 {lab=vbp}
C {devices/lab_pin.sym} -290 -400 0 1 {name=l_Mp0_G sig_type=std_logic lab=vbp}
N -200 -430 -200 -470 {lab=vdd}
C {devices/lab_pin.sym} -200 -470 0 0 {name=l_Mp0_S sig_type=std_logic lab=vdd}
N -200 -400 -50 -400 {lab=vdd}
C {devices/lab_pin.sym} -50 -400 0 0 {name=l_Mp0_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 220 -400 0 0 {name=Mpsrc l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 240 -370 240 -330 {lab=a}
C {devices/lab_pin.sym} 240 -330 0 0 {name=l_Mpsrc_D sig_type=std_logic lab=a}
N 200 -400 150 -400 {lab=vbp}
C {devices/lab_pin.sym} 150 -400 0 1 {name=l_Mpsrc_G sig_type=std_logic lab=vbp}
N 240 -430 240 -470 {lab=vdd}
C {devices/lab_pin.sym} 240 -470 0 0 {name=l_Mpsrc_S sig_type=std_logic lab=vdd}
N 240 -400 390 -400 {lab=vdd}
C {devices/lab_pin.sym} 390 -400 0 0 {name=l_Mpsrc_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 220 180 0 0 {name=Mnsnk l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 240 150 240 110 {lab=b}
C {devices/lab_pin.sym} 240 110 0 0 {name=l_Mnsnk_D sig_type=std_logic lab=b}
N 200 180 150 180 {lab=ibias}
C {devices/lab_pin.sym} 150 180 0 1 {name=l_Mnsnk_G sig_type=std_logic lab=ibias}
N 240 210 240 250 {lab=vss}
C {devices/lab_pin.sym} 240 250 0 0 {name=l_Mnsnk_S sig_type=std_logic lab=vss}
N 240 180 390 180 {lab=vss}
C {devices/lab_pin.sym} 390 180 0 0 {name=l_Mnsnk_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -720 -180 0 0 {name=Mpi l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=2u}
N -700 -150 -700 -110 {lab=upb}
C {devices/lab_pin.sym} -700 -110 0 0 {name=l_Mpi_D sig_type=std_logic lab=upb}
N -740 -180 -790 -180 {lab=up}
C {devices/lab_pin.sym} -790 -180 0 1 {name=l_Mpi_G sig_type=std_logic lab=up}
N -700 -210 -700 -250 {lab=vdd}
C {devices/lab_pin.sym} -700 -250 0 0 {name=l_Mpi_S sig_type=std_logic lab=vdd}
N -700 -180 -550 -180 {lab=vdd}
C {devices/lab_pin.sym} -550 -180 0 0 {name=l_Mpi_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -720 -40 0 0 {name=Mni l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=1u}
N -700 -70 -700 -110 {lab=upb}
C {devices/lab_pin.sym} -700 -110 0 0 {name=l_Mni_D sig_type=std_logic lab=upb}
N -740 -40 -790 -40 {lab=up}
C {devices/lab_pin.sym} -790 -40 0 1 {name=l_Mni_G sig_type=std_logic lab=up}
N -700 -10 -700 30 {lab=vss}
C {devices/lab_pin.sym} -700 30 0 0 {name=l_Mni_S sig_type=std_logic lab=vss}
N -700 -40 -550 -40 {lab=vss}
C {devices/lab_pin.sym} -550 -40 0 0 {name=l_Mni_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 220 -180 0 0 {name=Mswup l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 240 -150 240 -110 {lab=vctrl}
C {devices/lab_pin.sym} 240 -110 0 0 {name=l_Mswup_D sig_type=std_logic lab=vctrl}
N 200 -180 150 -180 {lab=upb}
C {devices/lab_pin.sym} 150 -180 0 1 {name=l_Mswup_G sig_type=std_logic lab=upb}
N 240 -210 240 -250 {lab=a}
C {devices/lab_pin.sym} 240 -250 0 0 {name=l_Mswup_S sig_type=std_logic lab=a}
N 240 -180 390 -180 {lab=vdd}
C {devices/lab_pin.sym} 390 -180 0 0 {name=l_Mswup_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 220 -40 0 0 {name=Mswdn l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 240 -70 240 -110 {lab=vctrl}
C {devices/lab_pin.sym} 240 -110 0 0 {name=l_Mswdn_D sig_type=std_logic lab=vctrl}
N 200 -40 150 -40 {lab=dn}
C {devices/lab_pin.sym} 150 -40 0 1 {name=l_Mswdn_G sig_type=std_logic lab=dn}
N 240 -10 240 30 {lab=b}
C {devices/lab_pin.sym} 240 30 0 0 {name=l_Mswdn_S sig_type=std_logic lab=b}
N 240 -40 390 -40 {lab=vss}
C {devices/lab_pin.sym} 390 -40 0 0 {name=l_Mswdn_B sig_type=std_logic lab=vss}
C {devices/ipin.sym} -1040 -540 0 0 {name=p_up lab=up}
C {devices/ipin.sym} -1040 -480 0 0 {name=p_dn lab=dn}
C {devices/ipin.sym} -1040 -420 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} -1040 -360 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -1040 -300 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -1040 -240 0 0 {name=p_vss lab=vss}
