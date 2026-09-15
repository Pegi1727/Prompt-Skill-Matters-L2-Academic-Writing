"""
run_pipeline.py
---------------
Master driver script to execute the complete replication workflow.
"""

import os
import sys

from scripts.01_reconstruct_rater_data import process_rater_data
from scripts.02_statistical_analysis import run_statistical_pipeline
from scripts.03_generate_figures import (
    plot_discipline_boxplot,
    plot_scatter_calibration,
)


def main():
    print("==================================================")
    print("   EXECUTING REPLICATION PIPELINE FOR PSI PAPER   ")
    print("==================================================")

    data_file = "raw_rater_scoring.csv"

    if not os.path.exists(data_file):
        print(f"[ERROR] Required dataset '{data_file}' not found.")
        sys.exit(1)

    print("\n--> Step 1: Processing Raw Ratings & Reconstructing Means...")
    process_rater_data(data_file)

    print("\n--> Step 2: Running Statistical Analysis & Hypothesis Tests...")
    run_statistical_pipeline(data_file)

    print("\n--> Step 3: Generating Publication Figures...")
    plot_scatter_calibration(pd.read_csv(data_file))
    plot_discipline_boxplot(pd.read_csv(data_file))

    print("\n[SUCCESS] Entire replication pipeline completed successfully!")


if __name__ == "__main__":
    import pandas as pd

    main()
