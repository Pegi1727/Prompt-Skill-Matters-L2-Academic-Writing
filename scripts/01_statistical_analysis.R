#!/usr/bin/env Rscript
# =====================================================================
#  01_statistical_analysis.R
# ---------------------------------------------------------------------
#  Purpose : Full descriptive and inferential statistical analysis of
#            human-AI interaction data (Avg_PSI vs Final_Quality).
#
#  Analyses performed
#    1. Descriptive statistics (Mean, SD, Median, IQR, Min, Max)
#       -- overall and split by Discipline (STEM / Social Science)
#    2. Shapiro-Wilk normality tests
#    3. Levene's test for homogeneity of variance (car::leveneTest)
#    4. Independent-samples Welch t-tests + Cohen's d / Hedges' g
#    5. Pearson (with 95% CI) and Spearman rank correlations
#
#  Inputs  : processed_interaction_data.csv
#            Columns: Participant_ID | Discipline | Avg_PSI | Final_Quality
#  Outputs (written to a "results/" sub-folder next to the data file):
#            results/descriptive_statistics.csv
#            results/normality_and_variance_tests.csv
#            results/t_test_results.csv
#            results/correlation_results.csv
#            results/statistical_analysis_full_report.txt
#            results/statistical_results.rds
#
#  Notes   : Fully deterministic (no randomness). Run with:
#              Rscript 01_statistical_analysis.R
#            or: source("01_statistical_analysis.R")
# =====================================================================

## ---------------------------------------------------------------------
## 0. SETUP: packages, options, flexible path handling
## ---------------------------------------------------------------------

# Install missing packages on first run only (uncomment if needed):
# install.packages(c("tidyverse", "car"))

suppressPackageStartupMessages({
  library(tidyverse)   # data wrangling + ggplot2
  library(car)         # Levene's test for homogeneity of variance
})

options(scipen = 999)

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# Locate the CSV robustly: env var -> cwd -> data/ -> /mnt/data
find_data_file <- function(filename = "processed_interaction_data.csv") {
  candidates <- unique(c(
    Sys.getenv("DATA_FILE"),                     # 1. explicit override
    file.path(getwd(), filename),                # 2. current directory
    file.path(getwd(), "data", filename),        # 3. ./data/
    file.path("/mnt/data", filename),            # 4. sandbox fallback
    filename                                     # 5. as-given path
  ))
  candidates <- candidates[nzchar(candidates)]
  hit <- candidates[file.exists(candidates)]
  if (length(hit) == 0L) {
    stop("Could not locate '", filename,
         "'. Set env var DATA_FILE to its full path and re-run.",
         call. = FALSE)
  }
  hit[1]
}

DATA_FILE <- find_data_file()

# Output folder lives next to the data file (never overwrite the input)
OUT_DIR <- file.path(dirname(DATA_FILE), "results")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------
## 1. LOAD AND VALIDATE DATA
## ---------------------------------------------------------------------

df <- read_csv(DATA_FILE, show_col_types = FALSE)

required_cols <- c("Participant_ID", "Discipline", "Avg_PSI", "Final_Quality")
stopifnot("Required columns missing from input file" =
            all(required_cols %in% names(df)))

df <- df %>%
  mutate(
    Discipline    = factor(Discipline),
    Avg_PSI       = as.numeric(Avg_PSI),
    Final_Quality = as.numeric(Final_Quality)
  )

cat(sprintf("Loaded %d observations from: %s\n", nrow(df), DATA_FILE))
cat("Groups:", paste(levels(df$Discipline), collapse = " / "), "\n\n")

## ---------------------------------------------------------------------
## 2. DESCRIPTIVE STATISTICS
## ---------------------------------------------------------------------

# Bias-corrected Fisher-Pearson skewness (base R, no extra packages)
moments_skew <- function(x) {
  n <- length(x); m <- mean(x); s <- sqrt(sum((x - m)^2) / n)
  (n / ((n - 1) * (n - 2))) * sum(((x - m) / s)^3)
}

# Full descriptive battery for a numeric vector (NAs removed)
describe <- function(x) {
  x <- x[!is.na(x)]
  tibble(
    N        = length(x),
    Mean     = mean(x),
    SD       = sd(x),
    Median   = median(x),
    IQR      = IQR(x, type = 7),
    Min      = min(x),
    Max      = max(x),
    Skewness = if (length(x) > 2) moments_skew(x) else NA_real_
  )
}

# 2a. By discipline group ------------------------------------------------
desc_by_group <- df %>%
  group_by(Discipline) %>%
  summarise(
    Variable = c("Avg_PSI", "Final_Quality"),
    bind_rows(
      tibble(describe(Avg_PSI)),
      tibble(describe(Final_Quality))
    ),
    .groups = "drop"
  ) %>%
  rename(Group = Discipline) %>%
  mutate(Group = as.character(Group))

# 2b. Overall ------------------------------------------------------------
desc_overall <- bind_rows(
  describe(df$Avg_PSI)       %>% mutate(Variable = "Avg_PSI",       Group = "Overall"),
  describe(df$Final_Quality) %>% mutate(Variable = "Final_Quality", Group = "Overall")
)

# 2c. Combine and export -------------------------------------------------
desc_table <- bind_rows(desc_by_group, desc_overall) %>%
  select(Group, Variable, everything()) %>%
  mutate(across(where(is.numeric), ~ round(.x, 3)))

write_csv(desc_table, file.path(OUT_DIR, "descriptive_statistics.csv"))
cat("== DESCRIPTIVE STATISTICS ==\n")
print(as.data.frame(desc_table), row.names = FALSE)
cat("\n")

## ---------------------------------------------------------------------
## 3. NORMALITY (SHAPIRO-WILK) AND HOMOGENEITY OF VARIANCE (LEVENe)
## ---------------------------------------------------------------------

shapiro_row <- function(x, label) {
  sw <- shapiro.test(x)
  tibble(
    Test = "Shapiro-Wilk", Variable = label,
    Statistic = unname(sw$statistic),
    df  = sw$parameter, df2 = NA_integer_,
    p_value = sw$p.value,
    Interpretation = if (sw$p.value > .05) "Normal (p > .05)" else "Non-normal (p <= .05)"
  )
}

lv <- levels(df$Discipline)
g1 <- df$Discipline == lv[1]
g2 <- df$Discipline == lv[2]

normality_tbl <- bind_rows(
  shapiro_row(df$Avg_PSI,                  "Avg_PSI (overall)"),
  shapiro_row(df$Final_Quality,            "Final_Quality (overall)"),
  shapiro_row(df$Avg_PSI[g1],              sprintf("Avg_PSI (%s)", lv[1])),
  shapiro_row(df$Avg_PSI[g2],              sprintf("Avg_PSI (%s)", lv[2])),
  shapiro_row(df$Final_Quality[g1],        sprintf("Final_Quality (%s)", lv[1])),
  shapiro_row(df$Final_Quality[g2],        sprintf("Final_Quality (%s)", lv[2]))
)

# Levene's test (median-centred: robust to non-normality)
levene_psi <- leveneTest(Avg_PSI        ~ Discipline, data = df, center = median)
levene_qty <- leveneTest(Final_Quality  ~ Discipline, data = df, center = median)

variance_tbl <- bind_rows(
  tibble(Test = "Levene (median-centered)", Variable = "Avg_PSI",
         Statistic = levene_psi$`F value`[1],
         df = levene_psi$Df[1], df2 = levene_psi$Df[2],
         p_value = levene_psi$`Pr(>F)`[1],
         Interpretation = if (levene_psi$`Pr(>F)`[1] > .05)
           "Equal variances (p > .05)" else "Unequal variances (p <= .05)"),
  tibble(Test = "Levene (median-centered)", Variable = "Final_Quality",
         Statistic = levene_qty$`F value`[1],
         df = levene_qty$Df[1], df2 = levene_qty$Df[2],
         p_value = levene_qty$`Pr(>F)`[1],
         Interpretation = if (levene_qty$`Pr(>F)`[1] > .05)
           "Equal variances (p > .05)" else "Unequal variances (p <= .05)")
)

norm_var_tbl <- bind_rows(normality_tbl, variance_tbl) %>%
  mutate(across(c(Statistic, p_value), ~ round(.x, 4)))

write_csv(norm_var_tbl, file.path(OUT_DIR, "normality_and_variance_tests.csv"))
cat("== NORMALITY & VARIANCE TESTS ==\n")
print(as.data.frame(norm_var_tbl), row.names = FALSE)
cat("\n")

## ---------------------------------------------------------------------
## 4. INDEPENDENT-SAMPLES T-TESTS (Welch) + EFFECT SIZES
## ---------------------------------------------------------------------

# Welch's t-test: default choice, robust when variances are unequal
tt_psi <- t.test(Avg_PSI        ~ Discipline, data = df, var.equal = FALSE)
tt_qty <- t.test(Final_Quality  ~ Discipline, data = df, var.equal = FALSE)

# Cohen's d (pooled SD) + Hedges' g small-sample correction
cohens_d_manual <- function(x, group) {
  ok  <- !is.na(x) & !is.na(group)
  m   <- split(x[ok], droplevels(group[ok]))
  n1  <- length(m[[1]]); n2 <- length(m[[2]])
  s_pool <- sqrt(((n1 - 1) * var(m[[1]]) + (n2 - 1) * var(m[[2]])) / (n1 + n2 - 2))
  d  <- (mean(m[[1]]) - mean(m[[2]])) / s_pool
  g  <- d * (1 - 3 / (4 * (n1 + n2) - 9))
  tibble(Cohens_d = round(d, 3), Hedges_g = round(g, 3))
}

tt_row <- function(tt, variable) {
  tibble(
    Variable    = variable,
    t_statistic = round(unname(tt$statistic), 3),
    df          = round(unname(tt$parameter), 2),
    p_value     = signif(tt$p.value, 4),
    Mean_diff   = round(tt$estimate[1] - tt$estimate[2], 3),
    CI95_low    = round(tt$conf.int[1], 3),
    CI95_high   = round(tt$conf.int[2], 3),
    Significant = ifelse(tt$p.value < .05, "Yes (*)", "No (ns)")
  )
}

ttest_tbl <- bind_rows(
  tt_row(tt_psi, "Avg_PSI")       %>% bind_cols(cohens_d_manual(df$Avg_PSI,       df$Discipline)),
  tt_row(tt_qty, "Final_Quality") %>% bind_cols(cohens_d_manual(df$Final_Quality, df$Discipline))
)

write_csv(ttest_tbl, file.path(OUT_DIR, "t_test_results.csv"))
cat("== WELCH INDEPENDENT-SAMPLES T-TESTS ==\n")
print(as.data.frame(ttest_tbl), row.names = FALSE)
cat("\n")

## ---------------------------------------------------------------------
## 5. CORRELATIONS: PEARSON & SPEARMAN (Avg_PSI vs Final_Quality)
## ---------------------------------------------------------------------

pearson_ct  <- cor.test(df$Avg_PSI, df$Final_Quality, method = "pearson")
spearman_ct <- cor.test(df$Avg_PSI, df$Final_Quality, method = "spearman",
                        exact = FALSE)

strength <- function(r) {
  a <- abs(r)
  if (a >= .7) "strong" else if (a >= .4) "moderate" else "weak"
}
signess <- function(p) if (p < .05) "significant" else "non-significant"

corr_tbl <- tibble(
  Method    = c("Pearson r", "Spearman rho"),
  Estimate  = c(unname(pearson_ct$estimate),  unname(spearman_ct$estimate)),
  CI95_low  = c(pearson_ct$conf.int[1],       NA_real_),
  CI95_high = c(pearson_ct$conf.int[2],       NA_real_),
  Statistic = c(unname(pearson_ct$statistic), unname(spearman_ct$statistic)),
  p_value   = c(pearson_ct$p.value,           spearman_ct$p.value),
  N         = nrow(df),
  Interpretation = c(
    paste(strength(unname(pearson_ct$estimate)),  signess(pearson_ct$p.value)),
    paste(strength(unname(spearman_ct$estimate)), signess(spearman_ct$p.value))
  )
) %>%
  mutate(across(c(Estimate, CI95_low, CI95_high, p_value), ~ round(.x, 4)))

write_csv(corr_tbl, file.path(OUT_DIR, "correlation_results.csv"))
cat("== CORRELATION ANALYSIS (Avg_PSI vs Final_Quality) ==\n")
print(as.data.frame(corr_tbl), row.names = FALSE)
cat("\n")

## ---------------------------------------------------------------------
## 6. HUMAN-READABLE FULL REPORT + RDS EXPORT
## ---------------------------------------------------------------------

report_path <- file.path(OUT_DIR, "statistical_analysis_full_report.txt")
sink(report_path)
cat("=================================================================\n")
cat(" STATISTICAL ANALYSIS REPORT\n")
cat(" Data     :", basename(DATA_FILE), "\n")
cat(" N        :", nrow(df), "\n")
cat(" Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("=================================================================\n\n")

cat("--- 1. DESCRIPTIVE STATISTICS -----------------------------------\n")
print(as.data.frame(desc_table), row.names = FALSE)
cat("\n--- 2. NORMALITY (SHAPIRO-WILK) & HOMOGENEITY (LEVENe) ----------\n")
print(as.data.frame(norm_var_tbl), row.names = FALSE)
cat("\n--- 3. INDEPENDENT-SAMPLES T-TESTS (Welch) ----------------------\n")
print(as.data.frame(ttest_tbl), row.names = FALSE)
cat("\n--- 4. CORRELATIONS (Avg_PSI vs Final_Quality) ------------------\n")
print(as.data.frame(corr_tbl), row.names = FALSE)
cat("\n=================================================================\n")
cat(" End of report\n")
sink()

saveRDS(
  list(data         = df,
       descriptives = desc_table,
       norm_var     = norm_var_tbl,
       ttests       = ttest_tbl,
       correlations = corr_tbl,
       data_file    = DATA_FILE),
  file.path(OUT_DIR, "statistical_results.rds")
)

cat("All statistical outputs written to:", OUT_DIR, "\n")
cat("  - descriptive_statistics.csv\n")
cat("  - normality_and_variance_tests.csv\n")
cat("  - t_test_results.csv\n")
cat("  - correlation_results.csv\n")
cat("  - statistical_analysis_full_report.txt\n")
cat("  - statistical_results.rds (for downstream scripts)\n")
