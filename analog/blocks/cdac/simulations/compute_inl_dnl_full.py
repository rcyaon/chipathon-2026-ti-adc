#!/usr/bin/env python3
"""
Compute INL/DNL from the FULL 256-code sweep produced by the upgraded
caps_tb.spice (T_HOLD=300ns/code, 76.8us total).

Usage:
    python3 compute_inl_dnl_full.py dac_transfer.txt
"""
import sys

VREF = 1.8
LSB_IDEAL = VREF / 256
T_HOLD_NS = 300
N_CODES = 256
SAMPLE_OFFSET_NS = 270   # sample near end of each 300ns plateau

def load_wrdata(path):
    pts = []
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) < 2:
                continue
            try:
                t = float(parts[0])
                v = float(parts[1])
            except ValueError:
                continue
            pts.append((t, v))
    return pts

def sample_at(pts, t_target_s):
    best = min(pts, key=lambda p: abs(p[0] - t_target_s))
    return best[1]

def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)

    pts = load_wrdata(sys.argv[1])
    if not pts:
        print("No data parsed -- check the file format.")
        sys.exit(1)

    codes = []
    for k in range(N_CODES):
        t_ns = k * T_HOLD_NS + SAMPLE_OFFSET_NS
        v = sample_at(pts, t_ns * 1e-9)
        codes.append(v)

    v0 = codes[0]
    v_last = codes[N_CODES - 1]

    # ---- ideal-LSB INL/DNL (assumes full-scale = VREF/256 exactly) ----
    inl_ideal = [(v - v0) / LSB_IDEAL - k for k, v in enumerate(codes)]
    dnl_ideal = [0.0] + [(codes[k] - codes[k-1]) / LSB_IDEAL - 1 for k in range(1, N_CODES)]

    # ---- endpoint-fit (gain-corrected) INL/DNL ----
    # Uses the DAC's own measured code0->code255 span as the reference LSB,
    # which separates real switched-cap nonlinearity from a systematic
    # full-scale gain error (parasitic loading, bridge-cap mis-scaling, etc).
    lsb_actual = (v_last - v0) / (N_CODES - 1)
    gain_error_pct = (lsb_actual / LSB_IDEAL - 1) * 100

    inl_fit = [(v - v0) / lsb_actual - k for k, v in enumerate(codes)]
    dnl_fit = [0.0] + [(codes[k] - codes[k-1]) / lsb_actual - 1 for k in range(1, N_CODES)]

    print(f"Ideal LSB (VREF/256)      = {LSB_IDEAL:.6e} V")
    print(f"Actual endpoint-fit LSB   = {lsb_actual:.6e} V")
    print(f"Full-scale gain error     = {gain_error_pct:+.2f}%\n")

    print(f"{'code':>5} {'Vx':>12} {'INL_ideal':>10} {'DNL_ideal':>10} "
          f"{'INL_fit':>10} {'DNL_fit':>10}")
    for k in range(N_CODES):
        print(f"{k:5d} {codes[k]:12.6f} {inl_ideal[k]:10.4f} {dnl_ideal[k]:10.4f} "
              f"{inl_fit[k]:10.4f} {dnl_fit[k]:10.4f}")

    print(f"\n--- vs ideal VREF/256 (dominated by the {gain_error_pct:+.2f}% gain error) ---")
    print(f"max INL = {max(inl_ideal):.4f} LSB   min INL = {min(inl_ideal):.4f} LSB")
    print(f"max DNL = {max(dnl_ideal):.4f} LSB   min DNL = {min(dnl_ideal):.4f} LSB")

    print(f"\n--- endpoint-fit / gain-corrected (real switched-cap linearity) ---")
    print(f"max INL = {max(inl_fit):.4f} LSB   min INL = {min(inl_fit):.4f} LSB")
    print(f"max DNL = {max(dnl_fit):.4f} LSB   min DNL = {min(dnl_fit):.4f} LSB")
    print("(DNL < -1 LSB anywhere would mean a missing code / non-monotonic step)")

    csv_path = "inl_dnl_results.csv"
    with open(csv_path, "w") as f:
        f.write("code,Vx,INL_ideal_LSB,DNL_ideal_LSB,INL_fit_LSB,DNL_fit_LSB\n")
        for k in range(N_CODES):
            f.write(f"{k},{codes[k]:.6f},{inl_ideal[k]:.4f},{dnl_ideal[k]:.4f},"
                    f"{inl_fit[k]:.4f},{dnl_fit[k]:.4f}\n")
    print(f"\nWrote {csv_path} (all 256 codes, both INL/DNL variants) -- good for slide plots.")

if __name__ == "__main__":
    main()
