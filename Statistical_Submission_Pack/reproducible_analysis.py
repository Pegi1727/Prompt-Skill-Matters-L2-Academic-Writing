# Reproducible Statistical Analysis Script
# Project: Prompt Skill Matters: Examining GenAI Interaction and Writing Quality in L2 Academic Writing
# Author: Pegah Merrikhi

import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm

# Load participant-level data
df = pd.read_csv('participant_level_data.csv')

print("=== Descriptive Statistics ===")
print(df.describe())

print("
=== Pearson Correlation ===")
r, p_val = stats.pearsonr(df['Avg_PSI'], df['Final_Quality_Score'])
print(f"Pearson r(20) = {r:.4f}, p-value = {p_val:.4e}")

print("
=== Spearman Rank Correlation ===")
rho, rho_p = stats.spearmanr(df['Avg_PSI'], df['Final_Quality_Score'])
print(f"Spearman rho(20) = {rho:.4f}, p-value = {rho_p:.4e}")

print("
=== Simple OLS Regression ===")
X = sm.add_constant(df['Avg_PSI'])
y = df['Final_Quality_Score']
model = sm.OLS(y, X).fit()
print(model.summary())

print("
=== Multivariable Regression (Including Disciplinary Field) ===")
# Convert Disciplinary_Field to dummy variable (STEM = 1, Social Science = 0)
df['Is_STEM'] = (df['Disciplinary_Field'] == 'STEM').astype(int)
X_multi = sm.add_constant(df[['Avg_PSI', 'Is_STEM']])
model_multi = sm.OLS(y, X_multi).fit()
print(model_multi.summary())
