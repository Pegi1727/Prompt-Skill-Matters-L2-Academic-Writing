# Statistical Analysis Report

**Dataset:** `processed_interaction_data.csv`  
**N:** 22 participants (11 STEM, 11 Social Science)  
**Variables:** `Avg_PSI` (average Prompt Specificity Index), `Final_Quality` (final output quality), `Discipline`  
**Software:** Python (`pandas`, `scipy.stats`)  
**Missing data:** none  

This report documents descriptive statistics, the Pearson correlation between prompt specificity and output quality, and independent-samples comparisons of STEM versus Social Science. Effect sizes and assumption checks are included for a research repository.

---

## 1. Research questions

1. How do PSI and final quality vary by discipline?
2. Is average PSI associated with final quality?
3. Do STEM and Social Science participants differ on PSI or final quality?

---

## 2. Sample and descriptives

Both disciplines are balanced (n = 11). Scores occupy a roughly 2–5 range. Discipline means are close; Social Science is slightly higher on both outcomes.

### Table 1. Summary statistics by discipline

| Discipline | n | PSI Mean | PSI SD | PSI Min | PSI Max | Quality Mean | Quality SD | Quality Min | Quality Max |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| STEM | 11 | 3.291 | 0.611 | 2.10 | 3.90 | 3.536 | 0.594 | 2.40 | 4.40 |
| Social Science | 11 | 3.341 | 0.611 | 2.15 | 3.95 | 3.700 | 0.608 | 2.60 | 4.60 |
| Overall | 22 | 3.316 | 0.596 | 2.10 | 3.95 | 3.618 | 0.593 | 2.40 | 4.60 |

### Table 2. Extended descriptives (six-decimal precision)

| Discipline | Variable | n | Mean | SD | Min | Median | Max |
|---|---|---:|---:|---:|---:|---:|---:|
| STEM | Avg_PSI | 11 | 3.290909 | 0.610663 | 2.10 | 3.50 | 3.90 |
| STEM | Final_Quality | 11 | 3.536364 | 0.593755 | 2.40 | 3.60 | 4.40 |
| Social Science | Avg_PSI | 11 | 3.340909 | 0.610663 | 2.15 | 3.55 | 3.95 |
| Social Science | Final_Quality | 11 | 3.700000 | 0.608276 | 2.60 | 3.80 | 4.60 |
| Overall | Avg_PSI | 22 | 3.315909 | 0.596495 | 2.10 | 3.525 | 3.95 |
| Overall | Final_Quality | 22 | 3.618182 | 0.592522 | 2.40 | 3.65 | 4.60 |

SD is the sample standard deviation (n − 1). The two groups have identical PSI SDs (0.610663), which is consistent with a designed or tightly matched sample.

---

## 3. Correlation: Avg_PSI and Final_Quality

### Table 3. Pearson product–moment correlation

| Sample | n | r | r² | p (two-sided) | 95% CI (Fisher z) |
|---|---:|---:|---:|---:|---|
| Overall | 22 | 0.902518 | 0.814539 | 9.304 × 10⁻⁹ | [0.776, 0.959] |
| STEM only | 11 | 0.922168 | 0.850394 | 5.352 × 10⁻⁵ | — |
| Social Science only | 11 | 0.891098 | 0.794056 | 2.317 × 10⁻⁴ | — |

**Finding.** There is a **strong, statistically significant positive correlation** between average PSI and final quality, *r*(20) = .90, *p* < .001, 95% CI [.78, .96], *r*² = .81. The association is also strong within each discipline (STEM *r* = .92; Social Science *r* = .89).

**Robustness.** Spearman rank correlation: ρ = 0.932, *p* = 2.83 × 10⁻¹⁰. The monotonic association is at least as strong as the linear one, so the result is not an artifact of a few extreme points.

**Interpretation.** Participants who wrote more specific prompts received higher-quality final outputs. This is the primary inferential result in this dataset. Causal claims are not warranted from a cross-sectional correlation (quality ratings, task type, or expertise could jointly influence both scores).

---

## 4. Group comparisons: STEM vs Social Science

Independent-samples tests compare the two disciplines on each outcome.

### 4.1 Assumption checks

| Outcome | Shapiro–Wilk STEM | Shapiro–Wilk Social Science | Levene equality of variances |
|---|---|---|---|
| Avg_PSI | W = 0.884, p = .117 | W = 0.884, p = .117 | W = 0.000, p = 1.000 |
| Final_Quality | W = 0.983, p = .979 | W = 0.966, p = .847 | W = 0.015, p = .904 |

Neither normality nor variance homogeneity was rejected (α = .05). Student's *t* (equal variances, df = 20) is therefore the primary test. Welch's *t* is reported as a sensitivity check and does not change any decision.

Cohen's *d* uses the pooled SD. Hedges' *g* applies the small-sample correction *J* = 1 − 3 / (4*N* − 9) = 0.962.

### 4.2 Avg_PSI

| Estimate | Value |
|---|---|
| STEM M (SD) | 3.291 (0.611) |
| Social Science M (SD) | 3.341 (0.611) |
| Mean difference (STEM − SS) | −0.050 |
| 95% CI of the difference | [−0.593, 0.493] |
| Student's *t* | *t*(20) = −0.192, *p* = .850 |
| Welch's *t* | *t*(20) = −0.192, *p* = .850 |
| Cohen's *d* | −0.082 (negligible) |
| Hedges' *g* | −0.079 |

**Finding.** Discipline is **not** associated with a detectable difference in PSI. The observed gap is 0.05 points on a multi-point scale, with a confidence interval that includes zero and a negligible effect size.

### 4.3 Final_Quality

| Estimate | Value |
|---|---|
| STEM M (SD) | 3.536 (0.594) |
| Social Science M (SD) | 3.700 (0.608) |
| Mean difference (STEM − SS) | −0.164 |
| 95% CI of the difference | [−0.698, 0.371] |
| Student's *t* | *t*(20) = −0.638, *p* = .530 |
| Welch's *t* | *t*(19.99) = −0.638, *p* = .530 |
| Cohen's *d* | −0.272 (small) |
| Hedges' *g* | −0.262 |

**Finding.** Discipline is **not** associated with a statistically significant difference in final quality. Social Science scored 0.16 points higher on average (small effect), but the interval includes zero and *p* = .53.

---

## 5. Combined interpretation

| Question | Result | Effect | Decision (α = .05) |
|---|---|---|---|
| PSI ~ Quality (overall) | *r* = .903, *p* = 9.30 × 10⁻⁹ | large (*r*² = .81) | Significant positive association |
| PSI: STEM vs Social Science | *t*(20) = −0.19, *p* = .850 | negligible (*d* = −0.08) | No group difference |
| Quality: STEM vs Social Science | *t*(20) = −0.64, *p* = .530 | small (*d* = −0.27) | No group difference |

The data support a **within-sample coupling of prompt specificity and output quality**, not a **between-discipline gap**. With n = 11 per group, the t-tests are underpowered for small effects; a true quality difference of about *d* = 0.27 would require a substantially larger sample to detect reliably. The correlation, by contrast, is large enough that N = 22 is sufficient.

---

## 6. Method notes and caveats

1. **Sample size.** N = 22 is small. Correlation CIs are wide at the lower bound (.78 is still large, but precision is limited). Null t-tests should be read as *failure to detect*, not as proof of equivalence.
2. **Independence.** Tests assume one row per independent participant. If sessions or raters are nested, SEs would be underestimated.
3. **Multiple testing.** Three focal tests (one correlation, two t-tests) were pre-specified by the analysis request. No family-wise correction was applied; the correlation would survive Bonferroni (α = .017).
4. **Measurement.** PSI and quality appear to be bounded rating-like scores. Pearson *r* is still appropriate given the strong linear pattern and the matching Spearman result.
5. **Causality.** Raising PSI might improve quality, but this file alone cannot separate that from reverse or third-variable explanations.
6. **Reproducibility.** Figures can be regenerated locally with `analysis_plots.py`. Companion tables: `summary_statistics.md`, `statistical_test_results.md`.

---

## 7. Repository files

| File | Contents |
|---|---|
| `processed_interaction_data.csv` | Analysis-ready data |
| `summary_statistics.md` | Descriptive table by discipline |
| `statistical_test_results.md` | Correlation and t-test output |
| `analysis_plots.py` | Boxplots and correlation heatmap (run locally) |
| `statistical_analysis_report.md` | This report |

---

## References (methods)

- Cohen, J. (1988). *Statistical power analysis for the behavioral sciences* (2nd ed.).
- Hedges, L. V. (1981). Distribution theory for Glass's estimator of effect size and related estimators.
- Pearson, K. (1896). Mathematical contributions to the theory of evolution. III.
- Student. (1908). The probable error of a mean.
- Welch, B. L. (1947). The generalization of "Student's" problem when several different population variances are involved.
