import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

df = pd.read_csv("src/correction_top/tb/correction_sim_results_8bit.csv")

ch0 = df[df["ch"] == 0].reset_index(drop=True)
ch1 = df[df["ch"] == 1].reset_index(drop=True)

# Windowed (rolling) mean absolute error, computed separately per channel
WIN = 300
ch0["mae_roll"] = ch0["error"].abs().rolling(WIN, min_periods=30).mean()
ch1["mae_roll"] = ch1["error"].abs().rolling(WIN, min_periods=30).mean()

fig = plt.figure(figsize=(13, 11))
gs = fig.add_gridspec(3, 2, height_ratios=[1.1, 1.1, 1.3], hspace=0.42, wspace=0.28)

# --- Panel A: waveform snapshot near the start (mismatch still present) ---
axA = fig.add_subplot(gs[0, 0])
n_show = 60
d0 = df.iloc[:n_show]
axA.plot(d0["idx"], d0["expected"], "k--", lw=1.3, label="Ideal (Mismatch-Free)")
axA.plot(d0["idx"], d0["actual"], color="#d62728", lw=1.4, marker="o", ms=3,
         label="Corrected Output")
axA.set_title("Output vs. Ideal — Early Samples\n(Loops Not Yet Converged)")
axA.set_xlabel("Output Sample Index")
axA.set_ylabel("Code")
axA.legend(fontsize=8, loc="upper right")
axA.grid(alpha=0.3)

# --- Panel B: waveform snapshot near the end (converged) ---
axB = fig.add_subplot(gs[0, 1])
d1 = df.iloc[-n_show:]
axB.plot(d1["idx"], d1["expected"], "k--", lw=1.3, label="Ideal (Mismatch-Free)")
axB.plot(d1["idx"], d1["actual"], color="#2ca02c", lw=1.4, marker="o", ms=3,
         label="Corrected Output")
axB.set_title("Output vs. Ideal — Late Samples\n(After Convergence)")
axB.set_xlabel("Output Sample Index")
axB.set_ylabel("Code")
axB.legend(fontsize=8, loc="upper right")
axB.grid(alpha=0.3)

# --- Panel C: gain_coeff convergence ---
axC = fig.add_subplot(gs[1, 0])
axC.plot(ch0["idx"], ch0["gain_coeff"], color="#1f77b4", lw=1.3)
axC.axhline(1.0 / 0.85, color="gray", ls=":", lw=1.2, label="True Target (1/0.85 = 1.176)")
axC.set_title("Gain Coefficient Convergence (gain_correction)")
axC.set_xlabel("Output Sample Index")
axC.set_ylabel("Gain Coefficient")
axC.legend(fontsize=8)
axC.grid(alpha=0.3)

# --- Panel D: offset_reg convergence ---
axD = fig.add_subplot(gs[1, 1])
axD.plot(ch1["idx"], ch1["offset_reg"], color="#ff7f0e", lw=1.3)
axD.set_title("Offset Register Convergence (offset_correction)")
axD.set_xlabel("Output Sample Index")
axD.set_ylabel("Offset (Code Units)")
axD.grid(alpha=0.3)

# --- Panel E: the headline plot -- error vs time, both channels ---
axE = fig.add_subplot(gs[2, :])
axE.plot(ch1["idx"], ch1["error"].abs(), color="#d62728", alpha=0.18, lw=0.6,
         label="CH1 |Error| (Per-Sample)")
axE.plot(ch1["idx"], ch1["mae_roll"], color="#d62728", lw=2.2,
         label=f"CH1 Rolling Mean |Error| (Window={WIN})")
axE.plot(ch0["idx"], ch0["mae_roll"], color="#1f77b4", lw=1.6, ls="--",
         label=f"CH0 Rolling Mean |Error| (Reference Channel, Window={WIN})")
axE.set_title("Correction Error vs. Time — Gain + Offset Mismatch Converging Out")
axE.set_xlabel("Output Sample Index")
axE.set_ylabel("|Error| (Code Units)")
axE.legend(fontsize=9)
axE.grid(alpha=0.3)
axE.set_ylim(bottom=0)

fig.suptitle(
    "correction_top (8-Bit Datapath): Combined Gain + Offset LMS Calibration Converging on a\n"
    "15% Gain Mismatch + 4-Code Offset Mismatch Injected on ADC1",
    fontsize=13, y=0.995
)

fig.savefig("correction_convergence_8bit.png", dpi=150, bbox_inches="tight")
print("saved.")
print("Final rolling MAE, ch1:", ch1["mae_roll"].iloc[-1])
print("Final rolling MAE, ch0:", ch0["mae_roll"].iloc[-1])
print("Final gain_coeff:", ch0["gain_coeff"].iloc[-1], " target:", 1/0.85)
print("Final offset_reg:", ch1["offset_reg"].iloc[-1])
