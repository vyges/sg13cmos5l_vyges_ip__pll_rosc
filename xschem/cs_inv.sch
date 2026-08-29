v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {cs_inv -- current-starved inverter stage} -320 -300 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 0 -400 0 0 {name=Mps l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=1u}
N 20 -370 20 -330 {lab=nph}
C {devices/lab_pin.sym} 20 -330 0 0 {name=l_Mps_D sig_type=std_logic lab=nph}
N -20 -400 -70 -400 {lab=vbp}
C {devices/lab_pin.sym} -70 -400 0 1 {name=l_Mps_G sig_type=std_logic lab=vbp}
N 20 -430 20 -470 {lab=vdd}
C {devices/lab_pin.sym} 20 -470 0 0 {name=l_Mps_S sig_type=std_logic lab=vdd}
N 20 -400 170 -400 {lab=vdd}
C {devices/lab_pin.sym} 170 -400 0 0 {name=l_Mps_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 0 -180 0 0 {name=Mpu l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=2u}
N 20 -150 20 -110 {lab=out}
C {devices/lab_pin.sym} 20 -110 0 0 {name=l_Mpu_D sig_type=std_logic lab=out}
N -20 -180 -70 -180 {lab=in}
C {devices/lab_pin.sym} -70 -180 0 1 {name=l_Mpu_G sig_type=std_logic lab=in}
N 20 -210 20 -250 {lab=nph}
C {devices/lab_pin.sym} 20 -250 0 0 {name=l_Mpu_S sig_type=std_logic lab=nph}
N 20 -180 170 -180 {lab=vdd}
C {devices/lab_pin.sym} 170 -180 0 0 {name=l_Mpu_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 70 0 0 {name=Mnd l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 20 40 20 0 {lab=out}
C {devices/lab_pin.sym} 20 0 0 0 {name=l_Mnd_D sig_type=std_logic lab=out}
N -20 70 -70 70 {lab=in}
C {devices/lab_pin.sym} -70 70 0 1 {name=l_Mnd_G sig_type=std_logic lab=in}
N 20 100 20 140 {lab=npl}
C {devices/lab_pin.sym} 20 140 0 0 {name=l_Mnd_S sig_type=std_logic lab=npl}
N 20 70 170 70 {lab=vss}
C {devices/lab_pin.sym} 170 70 0 0 {name=l_Mnd_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 290 0 0 {name=Mns l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=1u}
N 20 260 20 220 {lab=npl}
C {devices/lab_pin.sym} 20 220 0 0 {name=l_Mns_D sig_type=std_logic lab=npl}
N -20 290 -70 290 {lab=vctrl}
C {devices/lab_pin.sym} -70 290 0 1 {name=l_Mns_G sig_type=std_logic lab=vctrl}
N 20 320 20 360 {lab=vss}
C {devices/lab_pin.sym} 20 360 0 0 {name=l_Mns_S sig_type=std_logic lab=vss}
N 20 290 170 290 {lab=vss}
C {devices/lab_pin.sym} 170 290 0 0 {name=l_Mns_B sig_type=std_logic lab=vss}
C {devices/ipin.sym} -760 -360 0 0 {name=p_in lab=in}
C {devices/opin.sym} -760 -300 0 0 {name=p_out lab=out}
C {devices/ipin.sym} -760 -240 0 0 {name=p_vbp lab=vbp}
C {devices/ipin.sym} -760 -180 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -760 -120 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -760 -60 0 0 {name=p_vss lab=vss}
