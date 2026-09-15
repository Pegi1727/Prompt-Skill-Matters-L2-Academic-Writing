"""
02_statistical_analysis.py
--------------------------
Performs inferential statistics, independent samples t-tests (STEM vs. Social Sciences),
correlation analysis, and calibration regression between Raw and Target PSI.
"""

import os
import numpy as np
import pandas as pd
from scipy import stats
import statsmodels.api as sm


def run_statistical_pipeline(data_path: str):
    """Runs all primary statistical tests and prints formatted summary results."""
    df = pd.read_csv(data_path)

    print("=" * 60)
    print(" 1. DESCRIPTIVE STATISTICS")
    print("=" * 60)
    desc = df.groupby("Discipline")[
        ["Raw_PSI_Mean", "Avg_PSI_Target"]
    ].agg(["mean", "std", "min", "max"])
    print(desc.round(3))

    print("\n" + "=" * 60)
    print(" 2. CALIBRATION REGRESSION (Target vs. Raw Mean)")
    print("=" * 60)
    X = sm.add_constant(df["Raw_PSI_Mean"])
    y = df["Avg_PSI_Target"]
    model = sm.OLS(y, X).fit()

    r_val, p_val = stats.pearsonr(df["Raw_PSI_Mean"], df["Avg_PSI_Target"])
    print(f"Slope (b1):     {model.params['Raw_PSI_Mean']:.4f}")
    print(f"Intercept (b0): {model.params['const']:.4f}")
    print(f"R-squared:      {model.rsquared:.4f}")
    print(f"Pearson r:      {r_val:.4f} (p = {p_val:.4e})")

    print("\n" + "=" * 60)
    print(" 3. DISCIPLINARY COMPARISON (Independent Samples t-test)")
    print("=" * 60)
    stem_scores = df[df["Discipline"] == "STEM"]["Avg_PSI_Target"]
    soc_scores = df[df["Discipline"] == "Social Science"]["Avg_PSI_Target"]

    t_stat, p_val_t = stats.ttest_ind(
        stem_scores, soc_scores, equal_var=False
    )
    print(f"STEM Mean: {stem_scores.mean():.3f} (SD={stem_scores.std():.3f})")
    print(f"Soc  Mean: {soc_scores.mean():.3f} (SD={soc_scores.std():.3f})")
    print(f"Welch's t-statistic: {t_stat:.3f}")
    print(f"p-value:             {p_val_t:.4f}")


if __name__ == "__main__":
    run_statistical_pipeline("raw_rater_scoring.csv")
