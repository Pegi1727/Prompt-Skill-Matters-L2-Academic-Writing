# Statistical Test Results

All tests computed in Python with `scipy.stats` on `processed_interaction_data.csv` (N = 22). Two-sided α = .05. Groups: STEM (n = 11) vs Social Science (n = 11).

## 1. Pearson correlation: Avg_PSI × Final_Quality

| Sample | n | Pearson r | r² | p-value | 95% CI for r |
|---|---:|---:|---:|---:|---|
| Overall | 22 | 0.902518 | 0.814539 | 9.304e-09 | [0.776, 0.959] |
| STEM | 11 | 0.922168 | 0.850394 | 5.352e-05 | — |
| Social Science | 11 | 0.891098 | 0.794056 | 2.317e-04 | — |

- **Interpretation (overall):** Strong positive linear association. Higher average PSI co-occurs with higher final quality. The relationship is statistically significant (p < .001) and explains about 81.5% of variance in Final_Quality.
- **95% CI** for the overall Pearson r uses Fisher's z transformation.
- **Robustness:** Spearman ρ = 0.932108, p = 2.832e-10 (same direction, also p < .001).

## 2. Independent-samples t-tests: STEM vs Social Science

Assumptions checked before pooling variances:

| Outcome | Shapiro–Wilk STEM (W, p) | Shapiro–Wilk Social Science (W, p) | Levene (W, p) |
|---|---|---|---|
| Avg_PSI | 0.884, .117 | 0.884, .117 | 0.000, 1.000 |
| Final_Quality | 0.983, .979 | 0.966, .847 | 0.015, .904 |

Normality and homogeneity of variance were not rejected at α = .05, so Student's t (equal variances) is reported. Welch's t is shown for completeness and is essentially identical.

### Avg_PSI

| Statistic | Value |
|---|---|
| STEM mean (SD) | 3.291 (0.611) |
| Social Science mean (SD) | 3.341 (0.611) |
| Mean difference (STEM − Social Science) | −0.050 |
| 95% CI for mean difference | [−0.593, 0.493] |
| Student's t (df = 20) | t = −0.192, p = .850 |
| Welch's t (df = 20) | t = −0.192, p = .850 |
| Cohen's d | −0.082 |
| Hedges' g | −0.079 |

**Result:** No statistically significant difference in PSI between disciplines. The effect size is negligible.

### Final_Quality

| Statistic | Value |
|---|---|
| STEM mean (SD) | 3.536 (0.594) |
| Social Science mean (SD) | 3.700 (0.608) |
| Mean difference (STEM − Social Science) | −0.164 |
| 95% CI for mean difference | [−0.698, 0.371] |
| Student's t (df = 20) | t = −0.638, p = .530 |
| Welch's t (df ≈ 19.99) | t = −0.638, p = .530 |
| Cohen's d | −0.272 |
| Hedges' g | −0.262 |

**Result:** No statistically significant difference in final quality between disciplines. The effect size is small, with Social Science slightly higher on average.

## Effect-size conventions (Cohen, 1988; Hedges' g is bias-corrected d)

- |d| ≈ 0.20 small, 0.50 medium, 0.80 large
- |r| ≈ 0.10 small, 0.30 medium, 0.50 large
