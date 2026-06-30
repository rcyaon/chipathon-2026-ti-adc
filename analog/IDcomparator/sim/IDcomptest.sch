v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 940 180 940 220 {lab=VDD}
N 940 280 940 320 {lab=0}
N 1000 180 1000 215 {lab=INP}
N 1000 280 1000 320 {lab=0}
N 1060 180 1060 220 {lab=INN}
N 1060 280 1060 320 {lab=0}
N 1450 65 1450 100 {lab=CLK}
N 1490 65 1490 115 {lab=VDD}
N 1490 340 1490 390 {lab=0}
N 1275 180 1330 180 {lab=INP}
N 1275 270 1330 270 {lab=INN}
N 1000 215 1000 220 {lab=INP}
N 1490 115 1490 120 {lab=VDD}
N 1115 180 1115 220 {lab=CLK}
N 1115 280 1115 320 {lab=0}
N 1660 160 1730 160 {lab=vOUTP}
N 1620 210 1660 160 {lab=vOUTP}
N 1660 300 1730 300 {lab=vOUTN}
N 1620 250 1660 300 {lab=vOUTN}
N 1660 230 1710 230 {lab=vOUT}
C {code_shown.sym} -10 10 0 0 {name=s1 only_toplevel=false 
value="
.subckt comp_ideal INP INN CLK VDD VSS vOUTP vOUTN vOUT
+ PARAMS:
+ av     = 1e5
+ vos    = 0
+ tau    = 50p
+ vclkth = 0.5
+ vhys   = 10m
+ vth    = 0.5

* --- 1) unclamped linear decision target ---
Btgt vtgt 0 V = 'av*(V(INP)-V(INN)-vos)'

* --- 2) single-pole lag: R=1 ohm so that R*C = tau directly ---
Rlag vtgt dec 1
Clag dec 0 \{tau\}

* --- 3) rail-to-rail saturation ---
Bclamp clamped 0 V = 'min(V(VDD),max(V(VSS),V(dec)))'

* --- 4) clock-gated sample & hold ---
.model swmod SW(Ron=1 Roff=1e9 Vt=\{vclkth\} Vh=\{vhys\})
S1 clamped held CLK VSS swmod
Chold held 0 1p

* --- differential analog outputs (already rail-clamped via 'held') ---
Boutp vOUTP 0 V = 'V(held)'
Boutn vOUTN 0 V = 'V(VDD)+V(VSS)-V(held)'

* --- clean single-ended digital output for ideal SAR logic ---
Bout vOUT 0 V = 'ternary_fcn(V(held) > (V(VDD)+V(VSS))*vth, V(VDD), V(VSS))'

.ends comp_ideal

.tran 10n 200n
.control
run
plot v(voutp) v(clk) v(INN) v(INP)
.endc
.end
"}
C {vsource.sym} 940 250 0 0 {name=V1 value=3.3 savecurrent=false}
C {vsource.sym} 1000 250 0 0 {name=V2 
value="sin(0 1 150MEG)"
savecurrent=false}
C {vsource.sym} 1060 250 0 0 {name=V3 
value="sin(0 1 150MEG 3.33n)"
savecurrent=false}
C {lab_pin.sym} 940 180 1 0 {name=p1 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 1000 180 1 0 {name=p2 sig_type=std_logic lab=INP}
C {lab_pin.sym} 1060 180 1 0 {name=p3 sig_type=std_logic lab=INN}
C {lab_pin.sym} 1490 65 1 0 {name=p4 sig_type=std_logic lab=VDD}
C {gnd.sym} 940 320 0 0 {name=l1 lab=0}
C {gnd.sym} 1000 320 0 0 {name=l2 lab=0}
C {gnd.sym} 1060 320 0 0 {name=l3 lab=0}
C {gnd.sym} 1490 390 0 0 {name=l4 lab=0}
C {vsource.sym} 1115 250 0 0 {name=V4 
value= "PULSE(0 3.3 0 50p 50p 10n 20n)"
savecurrent=false}
C {lab_pin.sym} 1115 180 1 0 {name=p5 sig_type=std_logic lab=CLK}
C {gnd.sym} 1115 320 0 0 {name=l5 lab=0}
C {lab_pin.sym} 1275 180 0 0 {name=p6 sig_type=std_logic lab=INP}
C {lab_pin.sym} 1275 270 0 0 {name=p7 sig_type=std_logic lab=INN}
C {lab_pin.sym} 1450 65 1 0 {name=p8 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 1730 160 2 0 {name=p9 sig_type=std_logic lab=vOUTP}
C {lab_pin.sym} 1710 230 2 0 {name=p10 sig_type=std_logic lab=vOUT}
C {lab_pin.sym} 1730 300 2 0 {name=p11 sig_type=std_logic lab=vOUTN}
C {IDcomparator.sym} 1270 230 0 0 {name=X1 model=comp_ideal}
