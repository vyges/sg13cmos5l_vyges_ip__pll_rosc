v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {pfd -- tri-state phase-frequency detector} -560 -460 0 0 0.4 0.4 {}
N -200 -80 -160 -80 {lab=dhi}
N -160 -80 -155 -80 {lab=dhi}
N -155 -80 -155 -220 {lab=dhi}
N -155 -220 -90 -220 {lab=dhi}
N -200 -80 -160 -80 {lab=dhi}
N -160 -80 -155 -80 {lab=dhi}
N -155 -80 -155 60 {lab=dhi}
N -155 60 -90 60 {lab=dhi}
N 90 -240 205 -240 {lab=up}
N 205 -240 300 -240 {lab=up}
N 300 -240 300 240 {lab=up}
N 300 240 320 240 {lab=up}
N 320 240 360 240 {lab=up}
N 90 40 205 40 {lab=dn}
N 205 40 260 40 {lab=dn}
N 260 40 260 280 {lab=dn}
N 260 280 295 280 {lab=dn}
N 295 280 360 280 {lab=dn}
N 480 260 540 260 {lab=nout}
N 540 260 540 360 {lab=nout}
N 540 360 320 360 {lab=nout}
N 320 360 320 420 {lab=nout}
N 320 420 360 420 {lab=nout}
N 480 440 600 440 {lab=rstb}
N 600 440 600 560 {lab=rstb}
N 600 560 -260 560 {lab=rstb}
N -260 560 -260 -200 {lab=rstb}
N -260 -200 -180 -200 {lab=rstb}
N -180 -200 -90 -200 {lab=rstb}
N 480 440 600 440 {lab=rstb}
N 600 440 600 560 {lab=rstb}
N 600 560 -260 560 {lab=rstb}
N -260 560 -260 80 {lab=rstb}
N -260 80 -180 80 {lab=rstb}
N -180 80 -90 80 {lab=rstb}
N -480 -320 -520 -320 {lab=ref}
N -520 -320 -520 -240 {lab=ref}
N -520 -240 -130 -240 {lab=ref}
N -130 -240 -90 -240 {lab=ref}
N -480 380 -520 380 {lab=porb}
N -520 380 -520 460 {lab=porb}
N -520 460 295 460 {lab=porb}
N 295 460 360 460 {lab=porb}
N -560 -240 -130 -240 {lab=ref}
N -130 -240 -90 -240 {lab=ref}
N -560 40 -130 40 {lab=div}
N -130 40 -90 40 {lab=div}
N -560 460 295 460 {lab=porb}
N 295 460 360 460 {lab=porb}
N 640 -240 205 -240 {lab=up}
N 205 -240 90 -240 {lab=up}
N 640 40 205 40 {lab=dn}
N 205 40 90 40 {lab=dn}
C {devices/lab_pin.sym} -200 -80 0 0 {name=l_net_dhi sig_type=std_logic lab=dhi}
C {devices/lab_pin.sym} 480 260 0 0 {name=l_net_nout sig_type=std_logic lab=nout}
C {devices/lab_pin.sym} 480 440 0 0 {name=l_net_rstb sig_type=std_logic lab=rstb}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 -220 0 0 {name=Xup VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 -220 160 -220 {lab=upn}
C {devices/lab_pin.sym} 160 -220 0 0 {name=l_Xup_Q_N sig_type=std_logic lab=upn}
C {sg13cmos5l_stdcells/sg13cmos5l_dfrbp_1.sym} 0 60 0 0 {name=Xdn VDD=vdd VSS=vss prefix=sg13cmos5l_}
N 90 60 160 60 {lab=dnn}
C {devices/lab_pin.sym} 160 60 0 0 {name=l_Xdn_Q_N sig_type=std_logic lab=dnn}
C {vyges_tiehi.sym} -200 -80 0 0 {name=Xtiehi VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_nand2_1.sym} 420 260 0 0 {name=Xnand VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_and2_1.sym} 420 440 0 0 {name=Xand VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_antennanp.sym} -390 -320 0 0 {name=Xantref VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {sg13cmos5l_stdcells/sg13cmos5l_antennanp.sym} -390 380 0 0 {name=Xantporb VDD=vdd VSS=vss prefix=sg13cmos5l_}
C {devices/ipin.sym} -560 -240 0 0 {name=p_ref lab=ref}
C {devices/ipin.sym} -560 40 0 0 {name=p_div lab=div}
C {devices/ipin.sym} -560 460 0 0 {name=p_porb lab=porb}
C {devices/opin.sym} 640 -240 0 0 {name=p_up lab=up}
C {devices/opin.sym} 640 40 0 0 {name=p_dn lab=dn}
C {devices/iopin.sym} -560 -400 0 0 {name=p_vdd lab=vdd}
C {devices/iopin.sym} -560 640 0 0 {name=p_vss lab=vss}
L 4 -520 -380 -250 -380 {dash=8}
L 4 -250 -380 -250 -280 {dash=8}
L 4 -250 -280 -520 -280 {dash=8}
L 4 -520 -280 -520 -380 {dash=8}
T {ANTENNA DIODE} -514 -406 0 0 0.3 0.3 {layer=4}
L 4 -220 -300 150 -300 {dash=8}
L 4 150 -300 150 130 {dash=8}
L 4 150 130 -220 130 {dash=8}
L 4 -220 130 -220 -300 {dash=8}
T {PHASE DETECTOR FLOPS} -214 -326 0 0 0.3 0.3 {layer=4}
L 4 330 200 620 200 {dash=8}
L 4 620 200 620 500 {dash=8}
L 4 620 500 330 500 {dash=8}
L 4 330 500 330 200 {dash=8}
T {RESET} 336 174 0 0 0.3 0.3 {layer=4}
L 4 -520 330 -250 330 {dash=8}
L 4 -250 330 -250 420 {dash=8}
L 4 -250 420 -520 420 {dash=8}
L 4 -520 420 -520 330 {dash=8}
T {ANTENNA DIODE} -514 304 0 0 0.3 0.3 {layer=4}
