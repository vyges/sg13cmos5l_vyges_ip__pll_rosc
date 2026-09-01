v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {loop_filter -- type-II RC loop filter (Rz 80.7k, Cz 9.2p, Cp 0.71p)} -300 -320 0 0 0.4 0.4 {}
N 0 -220 0 -155 {lab=nz}
N 0 -155 0 -150 {lab=nz}
N 0 -150 0 -110 {lab=nz}
N 0 -280 0 -340 {lab=vctrl}
N 0 -340 260 -340 {lab=vctrl}
N 260 -340 260 -150 {lab=vctrl}
N 260 -150 260 -110 {lab=vctrl}
N 0 -50 0 15 {lab=vss}
N 0 15 0 30 {lab=vss}
N 0 30 260 30 {lab=vss}
N 260 30 260 15 {lab=vss}
N 260 15 260 -50 {lab=vss}
C {devices/lab_pin.sym} 0 -220 0 0 {name=l_net_nz sig_type=std_logic lab=nz}
C {devices/lab_pin.sym} 0 -280 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} 0 -50 0 0 {name=l_net_vss sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/rhigh.sym} 0 -250 0 0 {name=Rz w=1u l=56.9u model=rhigh body=sub! b=0 m=1 mm_ok=1 spiceprefix=X}
C {sg13cmos5l_pr/cap_cmomf.sym} 0 -80 0 0 {name=Cz model=cap_cmomf w=63u l=63u mmin=1 mmax=4 spiceprefix=X}
C {sg13cmos5l_pr/cap_cmomf.sym} 260 -80 0 0 {name=Cp model=cap_cmomf w=18u l=18u mmin=1 mmax=4 spiceprefix=X}
N 0 -280 0 -320 {lab=vctrl}
C {devices/iopin.sym} 0 -320 0 0 {name=p_vctrl lab=vctrl}
C {devices/iopin.sym} -400 -200 0 0 {name=p_vss lab=vss}
