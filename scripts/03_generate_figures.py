"""
03_generate_figures.py
----------------------
Generates high-resolution (300 DPI) publication-ready plots for the article.
"""

import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

# Set publication style settings
plt.rcParams["font.family"] = "DejaVu Sans"
plt.rcParams["font.size"] = 11
plt.rcParams["axes.titlesize"] = 12
plt.rcParams["axes.labelsize"] = 11


def plot_scatter_calibration(df: pd.DataFrame, output_path: str = "fig1_calibration.png"):
    """Plots Raw PSI Mean vs Avg_PSI Target with regression trend line."""
    fig, ax = plt.subplots(figsize=(6, 5), dpi=300)

    sns.regplot(
        data=df,
        x="Raw_PSI_Mean",
        y="Avg_PSI_Target",
        ax=ax,
        scatter_kws={"s": 50, "alpha": 0.8, "color": "#1f77b4"},
        line_kws={"color": "#d62728", "linewidth": 2, "label": "Calibration Line"},
    )

    ax.set_title("Calibration Alignment: Raw Mean vs. Target PSI", fontweight="bold")
    ax.set_xlabel("Reconstructed Raw PSI Mean (Increment 0.125)")
    ax.set_ylabel("Analytical Target Avg_PSI (Increment 0.05)")
    ax.grid(True, linestyle="--", alpha=0.5)
    ax.legend(loc="upper left")

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f"[INFO] Saved Scatter Plot to: {output_path}")


def plot_discipline_boxplot(df: pd.DataFrame, output_path: str = "fig2_discipline_boxplot.png"):
    """Plots disciplinary comparison (STEM vs Social Science) boxplots."""
    fig, ax = plt.subplots(figsize=(6, 5), dpi=300)

    sns.boxplot(
        data=df,
        x="Discipline",
        y="Avg_PSI_Target",
        palette=["#2ca02c", "#ff7f0e"],
        width=0.4,
        ax=ax,
    )
    sns.stripplot(
        data=df,
        x="Discipline",
        y="Avg_PSI_Target",
        color="black",
        alpha=0.6,
        jitter=0.2,
        size=6,
        ax=ax,
    )

    ax.set_title("Prompt Skill Index Across Academic Disciplines", fontweight="bold")
    ax.set_xlabel("Academic Discipline")
    ax.set_ylabel("Analytical Avg_PSI Score")
    ax.grid(True, linestyle="--", alpha=0.4, axis="y")

    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f"[INFO] Saved Boxplot to: {output_path}")


if __name__ == "__main__":
    df = pd.read_csv("raw_rater_scoring.csv")
    plot_scatter_calibration(df)
    plot_discipline_boxplot(df)
