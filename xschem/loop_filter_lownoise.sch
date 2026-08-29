v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {loop_filter_lownoise -- dual-path loop filter (small-cap, low-noise)} -460 -360 0 0 0.4 0.4 {}
T {Dual-path alternative to the baseline RC filter. The series resistor is replaced by a
proportional voltage source (pd_prop, buffered) in series with a small capacitor Cser.
The capacitive divider reproduces the resistive step, while noise injected by the
voltage source is attenuated by the capacitor ratio instead of reaching vctrl -- so the
whole filter scales down provided the charge-pump current scales with it.} -460 -320 0 0 0.25 0.25 {layer=15}
T {Cint is a MOS capacitor held in INVERSION: far denser than MOM, and the only capacitor
form this PDK models (no accumulation varactor, no native device). L = 2.25u is 5x hv
L_min -- long enough that source/drain contacts do not waste area, short enough to keep
channel resistance down.
CONSTRAINT THAT LEAVES THIS CELL: vctrl must stay ABOVE the hv threshold (~0.7 V) or the
channel is not formed and Cint collapses. Swapping this filter in requires re-centring
the VCO band; it is not a drop-in replacement for the RC baseline.} -460 -230 0 0 0.25 0.25 {layer=15}
T {OPEN: the capacitor ratio, and generation of pd_prop from the phase-detector outputs.
Ratio error moves loop SHAPE (peaking, lock time, jitter transfer) rather than noise, so
it is settled by a Monte-Carlo of the closed-loop response over mismatch -- budgeting
phase margin rather than chasing MOM matching. Vary the MOS and MOM capacitors
INDEPENDENTLY there: a mixed-type divider mismatches systematically, not as a pair.} -460 -110 0 0 0.25 0.25 {layer=15}
N -20 -110 -20 -200 {lab=vctrl}
N -20 -200 340 -200 {lab=vctrl}
N 340 -200 340 -180 {lab=vctrl}
N 340 -180 340 -140 {lab=vctrl}
N 380 160 445 160 {lab=propn}
N 445 160 480 160 {lab=propn}
N 480 160 520 160 {lab=propn}
N 600 160 720 160 {lab=vprop}
N 720 160 720 -15 {lab=vprop}
N 720 -15 340 -15 {lab=vprop}
N 340 -15 340 -80 {lab=vprop}
C {devices/lab_pin.sym} -20 -110 0 0 {name=l_net_vctrl sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} 380 160 0 0 {name=l_net_propn sig_type=std_logic lab=propn}
C {devices/lab_pin.sym} 600 160 0 0 {name=l_net_vprop sig_type=std_logic lab=vprop}
C {sg13cmos5l_pr/sg13_hv_nmos.sym} 0 -110 0 0 {name=Mcint l=2.25u w=50u ng=1 m=20 model=sg13_hv_nmos spiceprefix=X}
N 20 -140 20 -180 {lab=vss}
C {devices/lab_pin.sym} 20 -180 0 0 {name=l_Mcint_D sig_type=std_logic lab=vss}
N 20 -80 20 -40 {lab=vss}
C {devices/lab_pin.sym} 20 -40 0 0 {name=l_Mcint_S sig_type=std_logic lab=vss}
N 20 -110 90 -110 {lab=vss}
C {devices/lab_pin.sym} 90 -110 0 0 {name=l_Mcint_B sig_type=std_logic lab=vss}
C {sg13cmos5l_pr/cap_mfringe.sym} 340 -110 0 0 {name=Cser model=cap_mfringe w=10u l=10u mmin=1 mmax=4 spiceprefix=X}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 340 160 0 0 {name=Xd1 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 300 160 250 160 {lab=pd_prop}
C {devices/lab_pin.sym} 250 160 0 1 {name=l_Xd1_A sig_type=std_logic lab=pd_prop}
C {sg13cmos5l_stdcells/sg13cmos5l_inv_1.sym} 560 160 0 0 {name=Xd2 VDD=vdd VSS=vss prefix=sg13cmos5l_}
N -20 -110 -70 -110 {lab=vctrl}
C {devices/iopin.sym} -70 -110 0 1 {name=p_vctrl lab=vctrl}
N 300 160 250 160 {lab=pd_prop}
C {devices/ipin.sym} 250 160 0 1 {name=p_pd_prop lab=pd_prop}
C {devices/iopin.sym} -560 -240 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -560 -180 0 0 {name=p_vss lab=vss}
