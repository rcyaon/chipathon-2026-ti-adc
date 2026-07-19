v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -220 -340 -180 -340 {lab=#net1}
N -370 -420 -370 -390 {lab=VDD}
N -220 -300 -180 -300 {lab=VSS}
N -220 -120 -180 -120 {lab=VDD}
N -550 -360 -520 -360 {lab=CLK}
N -550 -340 -520 -340 {lab=Vin}
N -220 -220 -180 -220 {lab=VRef}
N -220 -180 -180 -180 {lab=CLK}
N 120 -420 160 -420 {lab=#net2}
N 120 -400 140 -400 {lab=#net3}
N 140 -400 140 -390 {lab=#net3}
N 320 -260 320 -240 {lab=VSS}
N 280 -520 280 -500 {lab=CLK}
N 320 -500 320 -480 {lab=VDD}
N 450 -390 490 -390 {lab=OUTP}
N 450 -350 490 -350 {lab=OUTN}
N 140 -390 140 -330 {lab=#net3}
N 140 -330 160 -330 {lab=#net3}
N 490 -370 590 -370 {lab=vOUT}
N -370 -290 -370 -260 {lab=VSS}
C {lab_wire.sym} -370 -420 0 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_wire.sym} -220 -120 0 0 {name=p2 sig_type=std_logic lab=VDD}
C {lab_wire.sym} -220 -300 0 0 {name=p3 sig_type=std_logic lab=VSS}
C {ipin.sym} -550 -340 0 0 {name=p4 lab=Vin
}
C {ipin.sym} -550 -360 0 0 {name=p6 lab=CLK}
C {ipin.sym} -220 -220 0 0 {name=p7 lab=VRef}
C {lab_wire.sym} -220 -180 0 0 {name=p8 sig_type=std_logic lab=CLK}
C {lab_wire.sym} 320 -500 0 0 {name=p9 sig_type=std_logic lab=VDD}
C {lab_wire.sym} 320 -240 2 0 {name=p11 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 280 -520 0 0 {name=p12 sig_type=std_logic lab=CLK}
C {opin.sym} 490 -390 0 0 {name=p14 lab=OUTP}
C {opin.sym} 490 -350 0 0 {name=p15 lab=OUTN}
C {/foss/designs/ti-blocks/cdac/caps.sym} -30 -180 0 0 {name=x4}
C {/foss/designs/ti-blocks/IDcomparator/IDcomparator.sym} 100 -370 0 0 {name=X5 model=comp_ideal}
C {opin.sym} 590 -370 0 0 {name=p10 lab=vOUT}
C {/foss/designs/ti-blocks/transmission_gate/transmission_gate.sym} -370 -340 0 0 {name=x1}
C {lab_wire.sym} -370 -260 0 0 {name=p13 sig_type=std_logic lab=VSS}
