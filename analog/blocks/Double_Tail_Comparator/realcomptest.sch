v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -700 10 -700 50 {lab=0}
N -640 -90 -640 -55 {lab=INP}
N -640 10 -640 50 {lab=0}
N -580 -90 -580 -50 {lab=INN}
N -580 10 -580 50 {lab=0}
N -640 -55 -640 -50 {lab=INP}
N -525 -90 -525 -50 {lab=nCLK}
N -525 10 -525 50 {lab=0}
N -525 230 -525 270 {lab=0}
N -525 130 -525 170 {lab=CLK}
N -700 -90 -700 -50 {lab=VDD}
N -10 -130 -10 -90 {lab=CLK}
N 10 -130 10 -90 {lab=VDD}
N -10 90 -10 130 {lab=nCLK}
N 10 90 10 120 {lab=0}
N 120 -30 140 -60 {lab=fp}
N 120 30 140 60 {lab=fn}
C {vsource.sym} -700 -20 0 0 {name=V1 
value=3.3
savecurrent=false}
C {vsource.sym} -640 -20 0 0 {name=V2 
value="sin(2 1 25MEG)"
savecurrent=false}
C {vsource.sym} -580 -20 0 0 {name=V3 
value="sin(2 1 25MEG 5n)"
savecurrent=false}
C {lab_pin.sym} -640 -90 1 0 {name=p2 sig_type=std_logic lab=INP}
C {lab_pin.sym} -580 -90 1 0 {name=p3 sig_type=std_logic lab=INN}
C {gnd.sym} -700 50 0 0 {name=l1 lab=0}
C {gnd.sym} -640 50 0 0 {name=l2 lab=0}
C {gnd.sym} -580 50 0 0 {name=l3 lab=0}
C {vsource.sym} -525 -20 0 0 {name=V4 
value= "PULSE(0 3.3 0 50p 50p 2.5n 5n)"
savecurrent=false}
C {lab_pin.sym} -525 130 1 0 {name=p5 sig_type=std_logic lab=CLK}
C {gnd.sym} -525 50 0 0 {name=l5 lab=0}
C {vsource.sym} -525 200 0 0 {name=V5 
value= "PULSE(0 3.3 2.5n 50p 50p 2.5n 5n)"
savecurrent=false}
C {gnd.sym} -525 270 0 0 {name=l4 lab=0}
C {code_shown.sym} -1540 -400 0 0 {name=s1 only_toplevel=true value="* ============================================================
* double_tail_comparator_corners_simplified.spice
* Clean, streamlined general process plot for GF180nm corners
* ============================================================

* --- 1. CORNER SELECTOR (Uncomment ONLY the one you want to view) ---
* tt: Typical
.lib '/usr/share/pdk/gf180mcuC/libs.tech/ngspice/gf180mcu.model.ngspice' tt
* ff: Fast NMOS + Fast PMOS
*.lib '/usr/share/pdk/gf180mcuC/libs.tech/ngspice/gf180mcu.model.ngspice' ff
* ss: Slow NMOS + Slow PMOS
*.lib '/usr/share/pdk/gf180mcuC/libs.tech/ngspice/gf180mcu.model.ngspice' ss
* sf: Slow NMOS + Fast PMOS
*.lib '/usr/share/pdk/gf180mcuC/libs.tech/ngspice/gf180mcu.model.ngspice' sf
* fs: Fast NMOS + Slow PMOS
*.lib '/usr/share/pdk/gf180mcuC/libs.tech/ngspice/gf180mcu.model.ngspice' fs

* --- 2. GLOBAL PARAMETERS ---
.temp 27
.param VDD_VAL = 3.3
.param CLK_PER = 5n
.param CLK_RISE = 100p
.param CLK_FALL = 100p
.param CLK_HI   = '0.5*CLK_PER - CLK_RISE'
.param CLK_LO   = '0.5*CLK_PER - CLK_FALL'

* --- 3. STIMULUS GENERATION ---
Vdd  VDD  0  DC \{VDD_VAL\}
Vss  VSS  0  DC 0

* Clock signals
Vclk CLK 0 PULSE(0 \{VDD_VAL\} 0 \{CLK_RISE\} \{CLK_FALL\} \{CLK_HI\} \{CLK_PER\})
Vnclk ~CLK 0 PULSE(\{VDD_VAL\} 0 0 \{CLK_RISE\} \{CLK_FALL\} \{CLK_LO\} \{CLK_PER\})

* Differential inputs
.param VCM = '0.5*VDD_VAL'
Vinp INP 0 SIN(\{VCM\} 2.5m 1MEG)
Vinn INN 0 SIN(\{VCM\} -2.5m 1MEG)

* --- 4. DUT & LOAD INSTANTIATION ---
XDUT ~CLK outn outp CLK VDD VSS INP INN double_tailed_comparator
Cload_p outp 0 20f
Cload_n outn 0 20f

* --- 5. TRANSIENT RUN COMMAND ---
.tran 10p 15n

* --- 6. SIMPLIFIED PLOT ENGINE ---
.control
  run
  
  echo \\"=== SIMULATION COMPLETE ===\\"
  
  * Pop open a single clean window tracking the core process
  plot v(clk) v(inp) v(inn) v(outp) v(outn)
.endc
.end\\"}
C {lab_pin.sym} -525 -90 1 0 {name=p1 sig_type=std_logic lab=nCLK}
C {lab_pin.sym} -700 -90 1 0 {name=p11 sig_type=std_logic lab=VDD}
C {lab_pin.sym} 10 -130 1 0 {name=p4 sig_type=std_logic lab=VDD}
C {lab_pin.sym} -10 -130 1 0 {name=p6 sig_type=std_logic lab=CLK}
C {lab_pin.sym} -10 130 3 0 {name=p12 sig_type=std_logic lab=nCLK}
C {gnd.sym} 10 120 0 0 {name=l6 lab=0}
C {lab_pin.sym} -80 10 0 0 {name=p7 sig_type=std_logic lab=INN}
C {lab_pin.sym} -80 -20 0 0 {name=p8 sig_type=std_logic lab=INP}
C {lab_pin.sym} 140 -20 2 0 {name=p9 sig_type=std_logic lab=OUTP}
C {lab_pin.sym} 140 20 2 0 {name=p10 sig_type=std_logic lab=OUTN}
C {code_shown.sym} -1160 -360 0 0 {name=MODELS only_toplevel=true
format="tcleval( @value )"
value="
.include $::180MCU_MODELS/design.ngspice
.lib $::180MCU_MODELS/sm141064.ngspice typical
.lib $::180MCU_MODELS/smbb000149.ngspice typical
"}
C {realcomp.sym} 40 0 0 0 {name=x1}
C {lab_pin.sym} 140 -60 2 0 {name=p13 sig_type=std_logic lab=fp}
C {lab_pin.sym} 140 60 2 0 {name=p14 sig_type=std_logic lab=fn}
