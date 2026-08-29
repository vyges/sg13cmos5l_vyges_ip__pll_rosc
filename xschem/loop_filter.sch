v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {loop_filter -- type-II RC loop filter (baseline)} -300 -320 0 0 0.4 0.4 {}
C {sg13cmos5l_pr/rhigh.sym} 0 -320 0 0 {name=Rz w=1u l=35u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
N 0 -350 0 -390 {lab=vctrl}
C {devices/lab_pin.sym} 0 -390 0 0 {name=l_Rz_P sig_type=std_logic lab=vctrl}
N 0 -290 0 -250 {lab=nz}
C {devices/lab_pin.sym} 0 -250 0 0 {name=l_Rz_M sig_type=std_logic lab=nz}
C {sg13cmos5l_pr/cap_mfringe.sym} 0 -70 0 0 {name=Cz model=cap_mfringe w=93u l=93u mmin=1 mmax=4 spiceprefix=X}
N 0 -100 0 -140 {lab=nz}
C {devices/lab_pin.sym} 0 -140 0 0 {name=l_Cz_c1 sig_type=std_logic lab=nz}
N 0 -40 0 0 {lab=vss}
C {devices/lab_pin.sym} 0 0 0 0 {name=l_Cz_c2 sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_mfringe.sym} 430 -70 0 0 {name=Cp model=cap_mfringe w=30u l=30u mmin=1 mmax=4 spiceprefix=X}
N 430 -100 430 -140 {lab=vctrl}
C {devices/lab_pin.sym} 430 -140 0 0 {name=l_Cp_c1 sig_type=std_logic lab=vctrl}
N 430 -40 430 0 {lab=vss}
C {devices/lab_pin.sym} 430 0 0 0 {name=l_Cp_c2 sig_type=std_logic lab=vss}
C {devices/iopin.sym} -720 -360 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -720 -300 0 0 {name=p_vss lab=vss}
