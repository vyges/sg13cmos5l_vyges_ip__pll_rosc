v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {cs_inv -- current-starved inverter stage} -320 -300 0 0 0.4 0.4 {}
N 20 -270 20 -180 {lab=nph}
N 20 -120 20 -80 {lab=out}
N 20 -80 20 -20 {lab=out}
N 20 -20 20 20 {lab=out}
N 20 80 20 130 {lab=npl}
N 20 130 20 170 {lab=npl}
N -20 -150 -85 -150 {lab=in}
N -85 -150 -90 -150 {lab=in}
N -90 -150 -90 50 {lab=in}
N -90 50 -85 50 {lab=in}
N -85 50 -20 50 {lab=in}
C {devices/lab_pin.sym} 20 -270 0 0 {name=l_net_nph sig_type=std_logic lab=nph}
C {devices/lab_pin.sym} 20 -120 0 0 {name=l_net_out sig_type=std_logic lab=out}
C {devices/lab_pin.sym} 20 80 0 0 {name=l_net_npl sig_type=std_logic lab=npl}
C {devices/lab_pin.sym} -20 -150 0 0 {name=l_net_in sig_type=std_logic lab=in}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 0 -300 0 0 {name=Mps l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=1u}
N -20 -300 -70 -300 {lab=vbp}
C {devices/lab_pin.sym} -70 -300 0 1 {name=l_Mps_G sig_type=std_logic lab=vbp}
N 20 -330 20 -370 {lab=vdd}
C {devices/lab_pin.sym} 20 -370 0 0 {name=l_Mps_S sig_type=std_logic lab=vdd}
N 20 -300 90 -300 {lab=vdd}
C {devices/lab_pin.sym} 90 -300 0 0 {name=l_Mps_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 0 -150 0 0 {name=Mpu l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=2u}
N 20 -150 90 -150 {lab=vdd}
C {devices/lab_pin.sym} 90 -150 0 0 {name=l_Mpu_B sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 50 0 0 {name=Mnd l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 20 50 90 50 {lab=vss}
C {devices/lab_pin.sym} 90 50 0 0 {name=l_Mnd_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 0 200 0 0 {name=Mns l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=1u}
N -20 200 -70 200 {lab=vctrl}
C {devices/lab_pin.sym} -70 200 0 1 {name=l_Mns_G sig_type=std_logic lab=vctrl}
N 20 230 20 270 {lab=vss}
C {devices/lab_pin.sym} 20 270 0 0 {name=l_Mns_S sig_type=std_logic lab=vss}
N 20 200 90 200 {lab=vss}
C {devices/lab_pin.sym} 90 200 0 0 {name=l_Mns_B sig_type=std_logic lab=vss}
N -20 -150 -70 -150 {lab=in}
C {devices/ipin.sym} -70 -150 0 1 {name=p_in lab=in}
N 20 20 20 -20 {lab=out}
C {devices/opin.sym} 20 -20 0 0 {name=p_out lab=out}
N -20 -300 -70 -300 {lab=vbp}
C {devices/ipin.sym} -70 -300 0 1 {name=p_vbp lab=vbp}
N -20 200 -70 200 {lab=vctrl}
C {devices/ipin.sym} -70 200 0 1 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -420 -200 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -420 -140 0 0 {name=p_vss lab=vss}
