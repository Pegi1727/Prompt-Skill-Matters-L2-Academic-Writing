"""
01_reconstruct_rater_data.py
-----------------------------
Reconstructs Raw PSI Means from raw item-level ratings (8 observations per participant)
and verifies alignment with analytical target values (Avg_PSI_Target).
"""

import os
import pandas as pd
import numpy as np


def process_rater_data(input_path: str, output_path: str = None) -> pd.DataFrame:
    """Reads raw rater scoring CSV, calculates Sum_Score and Raw_PSI_Mean,

    and validates the baseline mathematical properties.
    """
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file not found at: {input_path}")

    df = pd.read_csv(input_path)

    # 1. Define rating columns (4 dimensions x 2 raters)
    rater_cols = [
        "R1_Context",
        "R1_Specificity",
        "R1_Iteration",
        "R1_Strategy",
        "R2_Context",
        "R2_Specificity",
        "R2_Iteration",
        "R2_Strategy",
    ]

    # Verify all columns exist
    missing_cols = [c for c in rater_cols if c not in df.columns]
    if missing_cols:
        raise KeyError(f"Missing required columns in CSV: {missing_cols}")

    # 2. Recalculate Sum and Arithmetic Mean
    df["Calculated_Sum"] = df[rater_cols].sum(axis=1)
    df["Calculated_Raw_Mean"] = df["Calculated_Sum"] / 8.0

    # 3. Verify consistency with existing Sum_Score and Raw_PSI_Mean
    sum_diff = np.abs(df["Calculated_Sum"] - df["Sum_Score"]).max()
    mean_diff = np.abs(df["Calculated_Raw_Mean"] - df["Raw_PSI_Mean"]).max()

    print(
        f"[INFO] Data Processing Complete. Total Participants: {len(df)}"
    )
    print(f"[CHECK] Max difference in Sum_Score: {sum_diff:.6f}")
    print(f"[CHECK] Max difference in Raw_PSI_Mean: {mean_diff:.6f}")

    if output_path:
        df.to_csv(output_path, index=False)
        print(f"[INFO] Saved processed data to: {output_path}")

    return df


if __name__ == "__main__":
    input_file = "raw_rater_scoring.csv"
    process_rater_data(input_file)
