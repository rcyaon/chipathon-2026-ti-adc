v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 360 -620 360 -600 {lab=#net1}
N 270 -600 360 -600 {lab=#net1}
N 270 -600 270 -550 {lab=#net1}
N 360 -600 430 -600 {lab=#net1}
N 430 -600 430 -550 {lab=#net1}
N 380 -520 390 -520 {lab=OUTN}
N 380 -520 380 -350 {lab=OUTN}
N 380 -350 390 -350 {lab=OUTN}
N 310 -350 320 -350 {lab=OUTP}
N 320 -520 320 -350 {lab=OUTP}
N 310 -520 320 -520 {lab=OUTP}
N 430 -490 430 -380 {lab=OUTP}
N 320 -460 430 -460 {lab=OUTP}
N 270 -490 270 -380 {lab=OUTN}
N 270 -420 380 -420 {lab=OUTN}
N 120 -380 270 -380 {lab=OUTN}
N 430 -380 590 -380 {lab=OUTP}
N 0 -350 80 -350 {lab=fp}
N 0 -350 0 -50 {lab=fp}
N 0 -50 270 -50 {lab=fp}
N 270 -100 270 -50 {lab=fp}
N 120 -100 120 -50 {lab=fp}
N 120 -190 120 -160 {lab=VDD}
N 120 -190 590 -190 {lab=VDD}
N 590 -190 590 -160 {lab=VDD}
N 440 -190 440 -160 {lab=VDD}
N 270 -190 270 -160 {lab=VDD}
N 270 -50 330 -50 {lab=fp}
N 330 -50 380 -130 {lab=fp}
N 380 -130 400 -130 {lab=fp}
N 630 -350 700 -350 {lab=fn}
N 700 -350 700 -50 {lab=fn}
N 440 -50 700 -50 {lab=fn}
N 440 -100 440 -50 {lab=fn}
N 590 -100 590 -50 {lab=fn}
N 380 -50 440 -50 {lab=fn}
N 330 -130 380 -50 {lab=fn}
N 310 -130 330 -130 {lab=fn}
N 270 -50 270 10 {lab=fp}
N 440 -50 440 0 {lab=fn}
N 440 0 440 10 {lab=fn}
N 270 70 270 140 {lab=#net2}
N 440 70 440 140 {lab=#net3}
N 270 200 270 230 {lab=#net4}
N 270 230 440 230 {lab=#net4}
N 440 200 440 230 {lab=#net4}
N 360 230 360 280 {lab=#net4}
N 480 170 520 170 {lab=fp}
N 190 170 230 170 {lab=fn}
N 180 40 230 40 {lab=INN}
N 480 40 550 40 {lab=INP}
N -300 -270 -300 -210 {lab=CLK}
N 270 310 320 310 {lab=CLK}
N 360 340 360 380 {lab=VSS}
N 630 -130 650 -130 {lab=CLK}
N 60 -130 80 -130 {lab=CLK}
N 360 -220 360 -190 {lab=VDD}
N -240 -270 -240 -210 {lab=VDD}
N 120 -320 120 -300 {lab=VSS}
N 120 -300 590 -300 {lab=VSS}
N 590 -320 590 -300 {lab=VSS}
N 430 -320 430 -300 {lab=VSS}
N 270 -320 270 -300 {lab=VSS}
N -180 -270 -180 -210 {lab=VSS}
N 360 -300 360 -270 {lab=VSS}
N 430 -440 470 -440 {lab=OUTP}
N 230 -440 270 -440 {lab=OUTN}
N 360 -710 360 -680 {lab=VDD}
N 260 -650 320 -650 {lab=~CLK}
N 360 -650 390 -650 {lab=VDD}
N 430 -520 460 -520 {lab=VDD}
N 440 -130 470 -130 {lab=VDD}
N 120 -130 150 -130 {lab=VDD}
N 240 -130 270 -130 {lab=VDD}
N 560 -130 590 -130 {lab=VDD}
N 240 -520 270 -520 {lab=VDD}
N 120 -350 150 -350 {lab=VSS}
N 430 -350 460 -350 {lab=VSS}
N 240 -350 270 -350 {lab=VSS}
N 560 -350 590 -350 {lab=VSS}
N 270 40 300 40 {lab=VSS}
N 410 40 440 40 {lab=VSS}
N 410 170 440 170 {lab=VSS}
N 270 170 300 170 {lab=VSS}
N 360 310 390 310 {lab=VSS}
N -390 -270 -390 -210 {lab=fn}
N -440 -270 -440 -210 {lab=fp}
C {ipin.sym} 180 40 0 0 {name=p1 lab=INN}
C {ipin.sym} 550 40 2 0 {name=p2 lab=INP}
C {ipin.sym} -300 -270 1 0 {name=p3 lab=CLK}
C {lab_pin.sym} -300 -210 0 0 {name=p4 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 270 310 0 0 {name=p5 sig_type=std_logic lab=CLK}
C {iopin.sym} -180 -270 3 0 {name=p6 lab=VSS}
C {lab_pin.sym} 190 170 0 0 {name=p7 sig_type=std_logic lab=fn}
C {lab_pin.sym} 520 170 2 0 {name=p8 sig_type=std_logic lab=fp}
C {lab_pin.sym} 440 -70 0 0 {name=p9 sig_type=std_logic lab=fn}
C {lab_pin.sym} 270 -70 2 0 {name=p10 sig_type=std_logic lab=fp}
C {lab_pin.sym} 60 -130 0 0 {name=p11 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 650 -130 2 0 {name=p12 sig_type=std_logic lab=CLK}
C {lab_pin.sym} 360 -220 2 0 {name=p13 sig_type=std_logic lab=VDD}
C {iopin.sym} -240 -270 3 0 {name=p14 lab=VDD}
C {lab_pin.sym} -240 -210 0 0 {name=p15 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -180 -210 0 0 {name=p16 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 360 380 0 0 {name=p17 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 360 -270 0 0 {name=p18 sig_type=std_logic lab=VSS}
C {opin.sym} 470 -440 0 0 {name=p19 lab=OUTP}
C {opin.sym} 230 -440 2 0 {name=p20 lab=OUTN}
C {lab_pin.sym} 360 -710 2 0 {name=p21 sig_type=std_logic lab=VDD}
C {ipin.sym} 260 -650 0 0 {name=p23 lab=~CLK}
C {lab_pin.sym} 390 -650 2 0 {name=p22 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 460 -520 2 0 {name=p24 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 470 -130 2 0 {name=p25 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 150 -130 2 0 {name=p26 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 240 -130 0 0 {name=p27 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 560 -130 0 0 {name=p28 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 240 -520 0 0 {name=p29 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 150 -350 2 0 {name=p30 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 460 -350 2 0 {name=p31 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 240 -350 0 0 {name=p32 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 560 -350 0 0 {name=p33 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 300 40 2 0 {name=p34 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 410 40 0 0 {name=p35 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 410 170 0 0 {name=p36 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 300 170 2 0 {name=p37 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 390 310 2 0 {name=p38 sig_type=std_logic lab=VSS}
C {symbols/pfet_03v3.sym} 340 -650 0 0 {name=M1
L=0.28u
W=1.1u
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
C {symbols/pfet_03v3.sym} 410 -520 0 0 {name=M2
L=0.28u
W=0.44u
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
C {symbols/pfet_03v3.sym} 420 -130 0 0 {name=M3
L=0.28u
W=0.66u
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
C {symbols/pfet_03v3.sym} 100 -130 0 0 {name=M4
L=0.28u
W=0.22u
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
C {symbols/pfet_03v3.sym} 290 -520 0 1 {name=M5
L=0.28u
W=0.44u
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
C {symbols/nfet_03v3.sym} 410 -350 0 0 {name=M8
L=0.28u
W=0.44u
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
C {symbols/nfet_03v3.sym} 100 -350 0 0 {name=M15
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 610 -350 0 1 {name=M11
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 250 40 0 0 {name=M13
L=0.28u
W=2.1u
nf1=
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
C {symbols/nfet_03v3.sym} 250 170 0 0 {name=M14
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 340 310 0 0 {name=M16
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 290 -350 0 1 {name=M9
L=0.28u
W=0.44u
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
C {symbols/pfet_03v3.sym} 290 -130 0 1 {name=M6
L=0.28u
W=0.66u
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
C {symbols/pfet_03v3.sym} 610 -130 0 1 {name=M7
L=0.28u
W=0.22u
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
C {symbols/nfet_03v3.sym} 460 40 0 1 {name=M10
L=0.28u
W=2.1u
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
C {symbols/nfet_03v3.sym} 460 170 0 1 {name=M12
L=0.28u
W=0.22u
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
C {opin.sym} -390 -270 3 0 {name=p39 lab=fn}
C {opin.sym} -440 -270 3 0 {name=p40 lab=fp}
C {lab_pin.sym} -440 -210 2 0 {name=p41 sig_type=std_logic lab=fp}
C {lab_pin.sym} -390 -210 2 0 {name=p42 sig_type=std_logic lab=fn}
