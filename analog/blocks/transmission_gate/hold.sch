v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 0 30 0 50 {lab=#net1}
N -40 30 -40 80 {lab=vclk}
N 0 30 140 30 {lab=#net1}
N -0 -0 0 30 {lab=#net1}
N 140 30 140 140 {lab=#net1}
N -140 30 -140 140 {lab=vclk}
N -140 30 -40 30 {lab=vclk}
N -40 -30 -40 30 {lab=vclk}
N -0 80 10 80 {lab=0}
N 10 80 10 110 {lab=0}
N 0 110 10 110 {lab=0}
N -0 -30 10 -30 {lab=vdd}
N 10 -60 10 -30 {lab=vdd}
N 0 -60 10 -60 {lab=vdd}
N -220 180 -170 180 {lab=vin}
N 80 180 110 180 {lab=vout}
N 80 180 80 210 {lab=vout}
N 140 210 190 210 {lab=vout}
N 190 180 190 210 {lab=vout}
N 170 180 190 180 {lab=vout}
N -110 180 10 180 {lab=vout}
N 10 180 10 250 {lab=vout}
N 220 250 240 250 {lab=vout}
N 140 210 140 250 {lab=vout}
N 80 210 140 210 {lab=vout}
N 10 250 140 250 {lab=vout}
N 220 250 220 280 {lab=vout}
N 140 250 220 250 {lab=vout}
N 220 340 220 370 {lab=0}
N -200 30 -140 30 {lab=vclk}
N 0 -90 0 -60 {lab=vdd}
N -150 -90 0 -90 {lab=vdd}
N 0 110 -0 130 {lab=0}
N 140 180 140 190 {lab=0}
N -140 180 -140 190 {lab=0}
C {symbols/pfet_03v3.sym} -20 -30 0 0 {name=M1
L=0.28u
W=7.5u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -20 80 0 0 {name=M2
L=0.28u
W=3u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} 140 160 1 0 {name=M3
L=0.28u
W=12u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {symbols/nfet_03v3.sym} -140 160 1 0 {name=M4
L=0.28u
W=24u
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {ipin.sym} -220 180 0 0 {name=p1 lab=vin}
C {capa.sym} 220 310 0 0 {name=C1
m=1
value=0.3p
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 370 0 0 {name=l1 lab=0}
C {opin.sym} 240 250 0 0 {name=p2 lab=vout}
C {ipin.sym} -200 30 0 0 {name=p3 lab=vclk}
C {ipin.sym} -150 -90 0 0 {name=p4 lab=vdd}
C {gnd.sym} 0 130 0 0 {name=l2 lab=0}
C {gnd.sym} -140 190 0 0 {name=l3 lab=0}
C {gnd.sym} 140 190 0 0 {name=l4 lab=0}
