#!/usr/bin/env Rscript
# =====================================================================
#  02_publication_figures.R
# ---------------------------------------------------------------------
#  Purpose : Publication-quality figures for the Avg_PSI vs
#            Final_Quality analysis.
#  Inputs  : processed_interaction_data.csv
#            results/statistical_results.rds (produced by script 01)
#  Outputs : results/fig1_group_boxplot.png
#            results/fig2_scatter_regression.png
#            results/fig3_means_ci.png
#            results/fig_composite.png
#
#  Notes   : Built with ggplot2; the composite figure uses patchwork
#            if installed, otherwise cowplot, otherwise the three
#            panels are exported individually as a base fallback.
# =====================================================================

suppressPackageStartupMessages({
  library(tidyverse)
})

# ---- Optional composition packages (graceful fallback) -------------
HAVE_COWPLOT   <- requireNamespace("cowplot",   quietly = TRUE)
HAVE_PATCHWORK <- requireNamespace("patchwork", quietly = TRUE)

# ---- Locate data (same logic as script 01) --------------------------
find_data_file <- function(filename = "processed_interaction_data.csv") {
  candidates <- unique(c(
    Sys.getenv("DATA_FILE"),
    file.path(getwd(), filename),
    file.path(getwd(), "data", filename),
    file.path("/mnt/data", filename),
    filename
  ))
  candidates <- candidates[nzchar(candidates)]
  hit <- candidates[file.exists(candidates)]
  if (length(hit) == 0L) {
    stop("Could not locate '", filename, "'.", call. = FALSE)
  }
  hit[1]
}

DATA_FILE <- find_data_file()
OUT_DIR   <- file.path(dirname(DATA_FILE), "results")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# ---- Load data: prefer the RDS produced by script 01 ----------------
rds_path <- file.path(OUT_DIR, "statistical_results.rds")
if (file.exists(rds_path)) {
  res <- readRDS(rds_path)
  df  <- res$data
} else {
  df <- read_csv(DATA_FILE, show_col_types = FALSE) %>%
    mutate(Discipline    = factor(Discipline),
           Avg_PSI       = as.numeric(Avg_PSI),
           Final_Quality = as.numeric(Final_Quality))
}

# ---- Publication theme ----------------------------------------------
theme_pub <- theme_bw(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(linewidth = 0.3, colour = "grey85"),
    strip.background = element_rect(fill = "grey92", colour = NA),
    legend.position  = "top"
  )

pal <- c("#2C7BB6", "#D7191C")   # colour-blind safe pair

# =====================================================================
# FIGURE 1 : Boxplots + jittered points of both variables by group
# =====================================================================
df_long <- df %>%
  select(Discipline, Avg_P%
  select(Discipline, Avg_P pivot_longer(-Discipline, names_to = "Variable", values_to = "Value") %>%
  mutate(Variable = recode(Variable,
                           Avg_PSI       = "Avg. Prompt-Style Index",
                           Final_Quality = "Final Quality"))

p1 <- ggplot(df_long, aes(Discipline, Value, fill = Discipline)) +
  geom_boxplot(width = 0.45, alpha = 0.85, outlier.shape = NA,
               colour = "grey25") +
  geom_jitter(width = 0.12, size = 1.6, alpha = 0.75,
              shape = 21, colour = "grey25") +
  facet_wrap(~ Variable, scales = "free_y") +
  scale_fill_manual(values = pal, name = "Discipline") +
  labs(x = NULL, y = "Score (arb. units)",
       title = "A. Group distributions") +
  theme_pub +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# =====================================================================
# FIGURE 2 : Scatter + OLS trend of Quality vs Avg_PSI
# =====================================================================
p2 <- ggplot(df, aes(Avg_PSI, Final_Quality)) +
  geom_point(shape = 21, size = 2.6, alpha = 0.85,
             aes(fill = Discipline), colour = "grey25") +
  geom_smooth(method = "lm", se = TRUE, colour = "grey20",
              fill = "grey60", linewidth = 0.7) +
  scale_fill_manual(values = pal, name = "Discipline") +
  labs(x = "Average Prompt-Style Index (Avg_PSI)",
       y = ")") +
  theme_pub = "B. Association (OLS fit, 95% CI ribbon)") +
  theme_pub

# =====================================================================
# FIGURE 3 : Means with 95% CI per group per variable
# =====================================================================
t_crit <- qt(0.975, df = max(sum(!is.na(df$Avg_PSI)), 2) - 1)

ci_summ <- df_long %>%
  group_by(Variable, Discipline) %>%
  summarise(
    Mean = mean(Value, na.rm = TRUE),
    SE   = sd(Value, na.rm = TRUE) / sqrt(sum(!is.na(Value))),
    .groups = "drop"
  ) %>%
  mutate(lo = Mean - t_crit * SE,
         hi = Mean + t_crit * SE)

p3 <- ggplot(ci_summ, aes(Discipline, Mean, colour = Discipline)) +
  geom_errorbar(aes(ymin = lo, ymax = hi),
                width = 0.18, linewidth = 0.7) +
  geom_point(aes(fill = Discipline), shape = 21, size = 3,
             colour = "grey25", show.legend = FALSE) +
  facet_wrap(~ Variable, scales = "free_y") +
  scale_colour_manual(values = pal, guide = "none") +
  scale_fill_manual(values = pal, guide = "none") +
  labs(x = NULL, y = "Mean with 95% CI",
       title = "C. Group means") +
  theme_pub +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

# =====================================================================
# EXPORT each panel at 300 dpi
# =====================================================================
ggsave(file.path(OUT_DIR, "fig1_group_boxplot.png"),      p1,
       width = 7, height = 5, dpi = 300, bg = "white")
ggsave(file.path(OUT_DIR, "fig2_scatter_regression.png"), p2,
       width = 7, height = 5, dpi = 300, bg = "white")
ggsave(file.path(OUT_DIR, "fig3_means_ci.png"),           p3,
       width = 7, height = 5, dpi = 300, bg = "white")

# =====================================================================
# COMPOSITE figure: patchwork -> cowplot -> individual-panel fallback
# =====================================================================
if (HAVE_PATCHWORK) {
  suppressPackageStartupMessages(library(patchwork))
  comp <- (p1 | p2) / p3 + plot_annotation(tag_levels = "I")
  ggsave(file.path(OUT_DIR, "fig_composite.png"), comp,
         width = 10, height = 8, dpi = 300, bg = "white")
  cat("Composite assembled with patchwork.\n")
} else suppressPackageStartupMessages(library(cowplot {
  suppressPackageStartupMessages(library(cowplot))
  comp <- plot_grid(p1, p2, p3, ncol = 2, labels = "AUTO")
  ggsave(file.path(OUT_DIR, "fig_composite.png"), comp,
         width = 10, height = 8, dpi = 300, bg = "white")
  cat("Composite assembled with cowplot.\n")
} else {
  cat("patchwork/cowplot not installed; exporting panels individually.\n")
  ggsave(file.path(OUT_DIR, "fig_composite_p1.png"), p1,
         width = 7, height = 5, dpi = 300, bg = "white")
  ggsave(file.path(OUT_DIR, "fig_composite_p2.png"), p2,
         width = 7, height = 5, dpi = 300, bg = "white")
  ggsave(file.path(OUT_DIR, "fig_composite_p3.png"), p3,
         width = 7, height = 5, dpi = 300, bg = "white")
}

cat("All figures written to:", OUT_DIR, "\n")
cat("  - fig1_group_boxplot.png\n")
cat("  - fig2_scatter_regression.png\n")
cat("  - fig3_means_ci.png\n")
cat("  - fig_composite.png (or individual panel fallbacks)\n")
