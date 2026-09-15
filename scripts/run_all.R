#!/usr/bin/env Rscript
# =====================================================================
#  run_all.R
# ---------------------------------------------------------------------
#  Master driver: runs the full pipeline in order
#    1. 01_statistical_analysis.R  -> statistics + CSV/TXT/RDS outputs
#    2. 02_publication_figures.R   -> publication-quality PNG figures
#
#  Usage:
#    Rscript run_all.R
#  Optional:
#    DATA_FILE=/path/to/data.csv Rscript run_all.R
# =====================================================================

t0 <- Sys.time()
script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  fa <- grep("^--file=", args, value = TRUE)
  if (length(fa) > 0) return(dirname(normalizePath(sub("^--file=", "", fa[1]))))
  getwd()
}

setwd(script_dir())

steps <- c("01_statistical_analysis.R", "02_publication_figures.R")

ok <- TRUE
for (s in steps) {
  if (!file.exists(s)) {
    message("ERROR: script not found: ", s)
    ok <- FALSE
    next
  }
  cat("\n=====================================================\n")
  cat(">> Running:", s, "\n")
  cat("=====================================================\n")
  res <- tryCatch(
    { source(s, echo = FALSE, local = new.env()); "OK" },
    error = function(e) { message("FAILED in ", s, ": ", conditionMessage(e)); "FAIL" }
  )
  if (!identical(res, "OK")) ok <- FALSE
}

cat("\n=====================================================\n")
cat("Pipeline finished in",
    round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1),
    "seconds\n")
cat("Overall status:", if (ok) "SUCCESS" else "COMPLETED WITH ERRORS", "\n")
cat("Outputs are in: results/ (next to the data file)\n")
cat("=====================================================\n")
