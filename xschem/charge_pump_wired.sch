v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {charge_pump -- current-steering charge pump} -560 -460 0 0 0.4 0.4 {}
N -320 140 -370 140 {lab=ibias}
N -370 140 -370 70 {lab=ibias}
N -370 70 -280 70 {lab=ibias}
N -280 70 -280 110 {lab=ibias}
N -320 140 -320 250 {lab=ibias}
N -320 250 -125 250 {lab=ibias}
N -125 250 -125 140 {lab=ibias}
N -125 140 -60 140 {lab=ibias}
N -60 140 -60 250 {lab=ibias}
N -60 250 155 250 {lab=ibias}
N 155 250 155 140 {lab=ibias}
N 155 140 220 140 {lab=ibias}
N -20 110 -20 70 {lab=vbp}
N -20 70 -20 -190 {lab=vbp}
N -20 -190 -20 -230 {lab=vbp}
N -60 -260 -110 -260 {lab=vbp}
N -110 -260 -110 -190 {lab=vbp}
N -110 -190 -20 -190 {lab=vbp}
N -20 -190 -20 -230 {lab=vbp}
N -60 -260 -60 -390 {lab=vbp}
N -60 -390 155 -390 {lab=vbp}
N 155 -390 155 -260 {lab=vbp}
N 155 -260 220 -260 {lab=vbp}
N 260 -230 260 -240 {lab=a}
N 260 -240 260 -150 {lab=a}
N 260 110 260 100 {lab=b}
N 260 100 260 10 {lab=b}
N 260 -90 260 -50 {lab=vctrl}
N -480 -90 -480 -50 {lab=upb}
N -520 -120 -585 -120 {lab=up}
N -585 -120 -585 -20 {lab=up}
N -585 -20 -520 -20 {lab=up}
C {devices/lab_pin.sym} -20 110 0 0 {name=l_net_vbp sig_type=std_logic lab=vbp}
C {devices/lab_pin.sym} 260 -230 0 0 {name=l_net_a sig_type=std_logic lab=a}
C {devices/lab_pin.sym} 260 110 0 0 {name=l_net_b sig_type=std_logic lab=b}
C {devices/lab_pin.sym} 260 -90 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} -480 -90 0 0 {name=l_net_upb sig_type=std_logic lab=upb}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -300 140 0 0 {name=Mn0 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N -280 170 -280 210 {lab=vss}
C {devices/lab_pin.sym} -280 210 0 0 {name=l_Mn0_S sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -40 140 0 0 {name=Mn1 l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -40 -260 0 0 {name=Mp0 l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N -20 -290 -20 -330 {lab=vdd}
C {devices/lab_pin.sym} -20 -330 0 0 {name=l_Mp0_S sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 240 -260 0 0 {name=Mpsrc l=0.5u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 260 -290 260 -330 {lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 240 140 0 0 {name=Mnsnk l=0.5u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -500 -120 0 0 {name=Mpi l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=2u}
N -480 -120 -410 -120 {lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} -500 -20 0 0 {name=Mni l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=1u}
N -480 10 -480 50 {lab=vss}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 240 -120 0 0 {name=Mswup l=0.13u ng=1 m=1 model=sg13_lv_pmos spiceprefix=X w=4u}
N 220 -120 170 -120 {lab=upb}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 240 -20 0 0 {name=Mswdn l=0.13u ng=1 m=1 model=sg13_lv_nmos spiceprefix=X w=2u}
N 220 -20 170 -20 {lab=dn}
N -520 -120 -570 -120 {lab=up}
C {devices/ipin.sym} -570 -120 0 1 {name=p_up lab=up}
N 220 -20 170 -20 {lab=dn}
C {devices/ipin.sym} 170 -20 0 1 {name=p_dn lab=dn}
N -280 110 -280 70 {lab=ibias}
C {devices/ipin.sym} -280 70 0 0 {name=p_ibias lab=ibias}
C {devices/iopin.sym} 380 -70 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -560 -400 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -560 300 0 0 {name=p_vss lab=vss}
L 4 -580 -200 -420 -200 {dash=8}
L 4 -420 -200 -420 70 {dash=8}
L 4 -420 70 -580 70 {dash=8}
L 4 -580 70 -580 -200 {dash=8}
T {UP INVERTER} -574 -226 0 0 0.3 0.3 {layer=4}
L 4 -400 -330 60 -330 {dash=8}
L 4 60 -330 60 210 {dash=8}
L 4 60 210 -400 210 {dash=8}
L 4 -400 210 -400 -330 {dash=8}
T {BIAS MIRROR} -394 -356 0 0 0.3 0.3 {layer=4}
L 4 140 -330 340 -330 {dash=8}
L 4 340 -330 340 210 {dash=8}
L 4 340 210 140 210 {dash=8}
L 4 140 210 140 -330 {dash=8}
T {OUTPUT STACK} 146 -356 0 0 0.3 0.3 {layer=4}
N -280 140 -270 140 {lab=vss}
N -20 -260 -10 -260 {lab=vdd}
N 260 -260 270 -260 {lab=vdd}
N 260 140 270 140 {lab=vss}
N 260 -120 270 -120 {lab=vdd}
N 260 -20 270 -20 {lab=vss}
N 170 -120 170 -90 {lab=upb}
N 170 -90 -480 -90 {lab=upb}
N -20 -260 -20 -290 {lab=vdd}
N -20 -330 260 -330 {lab=vdd}
N 260 -290 260 -260 {lab=vdd}
N 270 -260 270 -120 {lab=vdd}
N -10 -260 -10 -120 {lab=vdd}
N -10 -120 -410 -120 {lab=vdd}
N -480 -120 -480 -150 {lab=vdd}
N -280 140 -280 170 {lab=vss}
N -270 140 -270 50 {lab=vss}
N -270 50 -480 50 {lab=vss}
N -480 10 -480 -20 {lab=vss}
N -280 170 -20 170 {lab=vss}
N -20 170 -20 140 {lab=vss}
N -20 170 260 170 {lab=vss}
N 260 170 260 140 {lab=vss}
N 270 140 270 -20 {lab=vss}
