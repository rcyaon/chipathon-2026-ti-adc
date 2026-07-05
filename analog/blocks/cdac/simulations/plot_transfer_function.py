#!/usr/bin/env python3
"""
Generate a clean DAC transfer-function chart (+ INL/DNL) from
inl_dnl_results.csv (produced by compute_inl_dnl_full.py).

Usage:
    python3 plot_transfer_function.py inl_dnl_results.csv
    (requires matplotlib: pip install matplotlib)

Produces:
    transfer_function.png  -- code vs Vx, with ideal line overlay
    inl_dnl.png            -- gain-corrected INL and DNL vs code
"""
import sys
import csv

import matplotlib.pyplot as plt

def load_csv(path):
    codes, vx, inl_ideal, dnl_ideal, inl_fit, dnl_fit = [], [], [], [], [], []
    with open(path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            codes.append(int(row["code"]))
            vx.append(float(row["Vx"]))
            inl_ideal.append(float(row["INL_ideal_LSB"]))
            dnl_ideal.append(float(row["DNL_ideal_LSB"]))
            inl_fit.append(float(row["INL_fit_LSB"]))
            dnl_fit.append(float(row["DNL_fit_LSB"]))
    return codes, vx, inl_ideal, dnl_ideal, inl_fit, dnl_fit

def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)

    codes, vx, inl_ideal, dnl_ideal, inl_fit, dnl_fit = load_csv(sys.argv[1])

    # ---- Chart 1: transfer function ----
    v0, v_last = vx[0], vx[-1]
    ideal_line = [v0 + (v_last - v0) * k / (len(codes) - 1) for k in codes]

    plt.figure(figsize=(8, 5))
    plt.plot(codes, vx, color="#d62728", linewidth=1.5, label="Measured (net17)")
    plt.plot(codes, ideal_line, color="gray", linestyle="--", linewidth=1,
              label="Ideal (endpoint-fit line)")
    plt.xlabel("Digital code")
    plt.ylabel("Vx (V)")
    plt.title("CDAC Transfer Function")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("transfer_function.png", dpi=200)
    print("Wrote transfer_function.png")

    # ---- Chart 2: gain-corrected INL/DNL ----
    fig, axes = plt.subplots(2, 1, figsize=(8, 6), sharex=True)
    axes[0].plot(codes, inl_fit, color="#1f77b4", linewidth=1)
    axes[0].axhline(0, color="black", linewidth=0.5)
    axes[0].set_ylabel("INL (LSB)")
    axes[0].set_title("Gain-Corrected INL / DNL")
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(codes, dnl_fit, color="#2ca02c", linewidth=1)
    axes[1].axhline(0, color="black", linewidth=0.5)
    axes[1].axhline(-1, color="red", linestyle="--", linewidth=0.8,
                     label="-1 LSB (missing code threshold)")
    axes[1].set_xlabel("Digital code")
    axes[1].set_ylabel("DNL (LSB)")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("inl_dnl.png", dpi=200)
    print("Wrote inl_dnl.png")

if __name__ == "__main__":
    main()
