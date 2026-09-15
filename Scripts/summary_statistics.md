# Summary Statistics by Discipline

Descriptive statistics for **Avg_PSI** (average Prompt Specificity Index) and **Final_Quality** (final output quality), grouped by academic discipline. Source: `processed_interaction_data.csv` (N = 22; 11 STEM, 11 Social Science). No missing values.

## Grouped summary (mean, SD, min, max)

| Discipline | n | PSI Mean | PSI SD | PSI Min | PSI Max | Quality Mean | Quality SD | Quality Min | Quality Max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| STEM | 11 | 3.291 | 0.611 | 2.10 | 3.90 | 3.536 | 0.594 | 2.40 | 4.40 |
| Social Science | 11 | 3.341 | 0.611 | 2.15 | 3.95 | 3.700 | 0.608 | 2.60 | 4.60 |
| Overall | 22 | 3.316 | 0.596 | 2.10 | 3.95 | 3.618 | 0.593 | 2.40 | 4.60 |

## Extended descriptives

| Discipline | Variable | n | Mean | SD | Min | Median | Max |
|---|---|---:|---:|---:|---:|---:|---:|
| STEM | Avg_PSI | 11 | 3.290909 | 0.610663 | 2.10 | 3.50 | 3.90 |
| STEM | Final_Quality | 11 | 3.536364 | 0.593755 | 2.40 | 3.60 | 4.40 |
| Social Science | Avg_PSI | 11 | 3.340909 | 0.610663 | 2.15 | 3.55 | 3.95 |
| Social Science | Final_Quality | 11 | 3.700000 | 0.608276 | 2.60 | 3.80 | 4.60 |
| Overall | Avg_PSI | 22 | 3.315909 | 0.596495 | 2.10 | 3.525 | 3.95 |
| Overall | Final_Quality | 22 | 3.618182 | 0.592522 | 2.40 | 3.65 | 4.60 |

**Notes**

- SD is sample standard deviation (ddof = 1).
- Values are reported to three decimals in the compact table and to six decimals in the extended table (matching pandas/scipy computation).
- The two groups have nearly identical PSI dispersion (both SD = 0.610663).
