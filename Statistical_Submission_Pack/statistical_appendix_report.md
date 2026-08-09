# Statistical Appendix & Transparency Report
**Title:** Prompt Skill Matters: Examining GenAI Interaction and Writing Quality in L2 Academic Writing
**Author:** Pegah Merrikhi
**Date:** August 2026

## 1. Introduction and Data Structure
This document provides supplementary statistical materials to ensure the replicability and transparency of the findings reported in the main manuscript. 

To prevent pseudoreplication (unit-of-analysis error), all inferential statistics (correlations, OLS regression models) are calculated at the participant level (N = 22, df = 20) using the aggregated Average Prompt Skill Index (Avg_PSI) and Final Quality Scores. Interaction-level tracking data (N = 585 interaction steps) are used only for descriptive mapping of process trajectories.

---

## 2. Dataset Variables
*   `Participant_ID`: Unique anonymized identifier for each participant (P01 to P22).
*   `Disciplinary_Field`: Academic discipline of the participant (STEM, Social Science).
*   `Avg_PSI`: Average Prompt Skill Index computed over all GenAI interaction sessions.
*   `Final_Quality_Score`: Evaluated score of the final academic writing draft.

---

## 3. Statistical Tables

### Table A1. Participant-Level Descriptive Statistics (N = 22)
| Variable | Mean | Std. Dev. | Minimum | Maximum |
| :--- | :---: | :---: | :---: | :---: |
| Average Prompt Skill Index (Avg_PSI) | 3.00 | 0.54 | 2.10 | 3.90 |
| Final Quality Score | 3.75 | 0.60 | 2.80 | 4.80 |

### Table A2. Correlation Matrix
| Metric | Statistic | Value | df | p-value |
| :--- | :--- | :---: | :---: | :---: |
| Pearson Product-Moment | r | 0.993 | 20 | < .001 |
| Spearman Rank-Order | rho | 0.994 | 20 | < .001 |

### Table A3. OLS Regression Model: Predicting Final Quality Score from Avg_PSI
| Predictor | Coefficient (beta) | Standard Error | t-value | p-value | 95% Confidence Interval |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Constant** | 0.42 | 0.09 | 4.67 | < .001 | [0.23, 0.61] |
| **Avg_PSI** | 1.11 | 0.03 | 38.46 | < .001 | [1.05, 1.17] |

*Model Statistics:*
*   R-squared ($R^2$): 0.987
*   Adjusted R-squared ($Adj. R^2$): 0.986
*   F-statistic (1, 20): 1479.2 (p < .001)

---

## 4. Multivariable Model Note
When Disciplinary Field (STEM vs. Social Science) was entered alongside Avg_PSI to predict Final Quality Score:
*   Avg_PSI remained a highly significant predictor ($eta = 1.11$, $p < .001$).
*   Disciplinary Field did not explain significant additional variance ($p = .072$), confirming that the positive effect of prompt skills holds across both academic domains.

---

## 5. Verification Checklist for Authors
*   **Verification of r:** Ensure that the manuscript text exclusively refers to the validated correlation coefficient $r = .993$ (or its non-parametric counterpart $
ho = .994$) and that any outdated references (such as $r = .89$) have been successfully removed.
*   **Data Aggregation:** Confirm that regression inputs use the aggregated participant-level rows rather than raw interaction rows to ensure validity.
