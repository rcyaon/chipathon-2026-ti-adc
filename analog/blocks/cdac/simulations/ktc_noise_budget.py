#!/usr/bin/env python3
"""
kT/C sample-and-hold noise budget for the split-array CDAC in caps.spice.

The CDAC array capacitors (C1-C11) ARE the sample-and-hold capacitors --
there is no separate S/H cap in this design. Every code redistribution
happens on the same caps that sampled Vin during phi_s=1 (see
transistors.spice for the two-phase sample/hold description).

This script re-derives:
  1. The unit cap value Cu from the GF180MCU cap_mim_2f0fF model equations
     (reproducing what ngspice computes internally), for a given W/L.
  2. The effective total sampling capacitance seen at the Vx (output) node,
     accounting for the split-array bridge-cap attenuation.
  3. kT/C sampled-noise voltage referred to that node.
  4. Comparison against 10-bit quantization noise (LSB/sqrt(12)) to check
     that kT/C noise is NOT the dominant noise source, with a stated
     safety margin.

Usage:
    python3 ktc_noise_budget.py
    (no external dependencies -- stdlib only)

Edit the CONFIG block below if array weights, unit size, VREF, or
temperature change.
"""
import math

# ============================================================
# CONFIG -- keep these in sync with caps.spice / caps_tb.spice
# ============================================================
k = 1.380649e-23     # Boltzmann constant, J/K
T = 300               # Kelvin. Use your worst-case (hottest) sim corner if different.

VREF = 1.8            # V, per caps_tb.spice V4
N_BITS = 10           # resolution, per Dx<0:9>/Dx_b<0:9>

# cap_mim_2f0fF model constants (GF180MCU sm141064.ngspice, "cap_mim" .lib),
# reproduced from mim_cap_only.spice around .subckt cap_mim_2f0fF:
#   c_cox    = 1.99e-3 * mim_corner_2p0fF
#   c_capsw  = 2.383e-10 * mim_corner_2p0fF
#   c_c0     = (c_cox*c_AREA + c_capsw*c_PERI) * (1 + mc_c_cox_2p0fF)
# Nominal (non-Monte-Carlo) corner: mim_corner_2p0fF=1, mc_c_cox_2p0fF=0
# (matches the .param lines at the top of caps_tb.spice).
MIM_COX = 1.99e-3
MIM_CAPSW = 2.383e-10

# Unit cell geometry, per caps.spice (C1-C10 all use c_width=c_length=4e-6)
UNIT_L = 4e-6         # m
UNIT_W = 4e-6         # m

# Bridge cap geometry, per caps.spice (C11 uses 4.13e-6 x 4.13e-6)
BRIDGE_L = 4.13e-6    # m
BRIDGE_W = 4.13e-6    # m

# Array bit weights, per caps.spice instance multipliers (m=...)
# LSB array (node Vx_lsb): C1 C2 C3 C4 C5
LSB_WEIGHTS = [1, 1, 2, 4, 8]
# MSB array (node Vx): C6 C7 C8 C9 C10
MSB_WEIGHTS = [1, 1, 2, 4, 8]

# Safety margin target: quantization noise should be at least this many
# times larger than kT/C noise, so kT/C isn't the dominant noise term.
MARGIN_TARGET = 3.0


def cap_mim_2f0fF(length_m, width_m):
    """Reproduce ngspice's c_c0 computation for cap_mim_2f0fF, nominal corner."""
    area = length_m * width_m
    peri = 2 * (length_m + width_m)
    return (MIM_COX * area + MIM_CAPSW * peri)  # F


def main():
    Cu = cap_mim_2f0fF(UNIT_L, UNIT_W)
    C_bridge = cap_mim_2f0fF(BRIDGE_L, BRIDGE_W)

    C_lsb_array = sum(LSB_WEIGHTS) * Cu
    C_msb_array = sum(MSB_WEIGHTS) * Cu

    # As seen from the Vx (top-plate/output) node, the LSB array sits in
    # series with the bridge cap (classic split-array topology).
    C_lsb_series = (C_lsb_array * C_bridge) / (C_lsb_array + C_bridge)
    C_total_at_Vx = C_msb_array + C_lsb_series

    v_n_rms = math.sqrt(k * T / C_total_at_Vx)

    LSB_V = VREF / (2 ** N_BITS)
    q_noise_rms = LSB_V / math.sqrt(12)

    margin = q_noise_rms / v_n_rms
    C_needed_for_margin = k * T / ((q_noise_rms / MARGIN_TARGET) ** 2)

    print("=" * 60)
    print("CDAC kT/C SAMPLE-AND-HOLD NOISE BUDGET")
    print("=" * 60)
    print(f"Temperature                    : {T} K")
    print(f"Unit cap Cu ({UNIT_W*1e6:.2f}um x {UNIT_L*1e6:.2f}um)   : {Cu*1e15:.4f} fF")
    print(f"Bridge cap C11 ({BRIDGE_W*1e6:.2f}um x {BRIDGE_L*1e6:.2f}um): {C_bridge*1e15:.4f} fF")
    print()
    print(f"LSB array total ({sum(LSB_WEIGHTS)} units)   : {C_lsb_array*1e15:.4f} fF")
    print(f"MSB array total ({sum(MSB_WEIGHTS)} units)   : {C_msb_array*1e15:.4f} fF")
    print(f"LSB array in series w/ bridge   : {C_lsb_series*1e15:.4f} fF")
    print(f"Effective total cap at Vx       : {C_total_at_Vx*1e15:.4f} fF")
    print()
    print(f"kT/C noise (referred to Vx)     : {v_n_rms*1e6:.3f} uVrms")
    print()
    print(f"Resolution                      : {N_BITS}-bit, VREF = {VREF} V")
    print(f"1 LSB                            : {LSB_V*1e6:.3f} uV")
    print(f"Quantization noise (LSB/sqrt12)  : {q_noise_rms*1e6:.3f} uVrms")
    print()
    print(f"Margin (q_noise / kTC_noise)     : {margin:.2f}x")
    if margin >= MARGIN_TARGET:
        print(f"  -> PASS: exceeds {MARGIN_TARGET}x target; kT/C noise is not dominant.")
    else:
        print(f"  -> FAIL: below {MARGIN_TARGET}x target; consider upsizing unit caps.")
    print()
    print(f"Min. effective cap for {MARGIN_TARGET}x margin : {C_needed_for_margin*1e15:.2f} fF")
    print(f"Current effective cap            : {C_total_at_Vx*1e15:.2f} fF "
          f"({C_total_at_Vx/C_needed_for_margin:.2f}x the minimum)")
    print()
    print("Note: this budget covers thermal (kT/C) sampling noise only.")
    print("It does not include comparator noise, switch charge injection,")
    print("clock jitter, or reference noise -- those are separate budget")
    print("items and should be added for a full input-referred noise spec.")


if __name__ == "__main__":
    main()
