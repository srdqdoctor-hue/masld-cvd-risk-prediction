# =============================================================================
# Missing Value Assessment and Outlier Detection
# =============================================================================
# Purpose:
#   Summarise missingness rates across all baseline features and flag analytes
#   with excessive missingness for exclusion or imputation decisions.
#   Performs winsorisation of numerical outliers at clinical and statistical
#   thresholds before the machine learning pipeline.
#
# Input:  masld_baseline_features.csv
# Output: missingness_report.csv, baseline_features_winsorised.csv
# =============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})

DATA_DIR   <- "data/secure_ehr/outputs"
OUTPUT_DIR <- "data/secure_ehr/outputs"

baseline <- fread(file.path(DATA_DIR, "masld_baseline_features.csv"))
cat("Loaded feature matrix:", nrow(baseline), "patients,",
    ncol(baseline), "variables\n")

# Numerical laboratory and clinical variables to assess
NUM_VARS <- c(
  "AGE", "BMI", "SBP", "DBP", "HR",
  "glu", "hba1c",
  "tcho", "hdl", "ldl", "tg",
  "alt", "ast", "ast_alt_ratio", "ggt", "tbil", "dbil", "alb", "alp",
  "cr", "bun", "cysc", "ua", "umalb_ucr", "eGFR",
  "hb", "wbc", "plt", "lymph2", "gran2",
  "hscrp", "crp", "hcy",
  "ntprobnp", "ctnt",
  "inr", "fib"
)
NUM_VARS <- intersect(NUM_VARS, colnames(baseline))

# Force numeric conversion (EHR text fields may have stray characters)
for (v in NUM_VARS) {
  set(baseline, j = v, value = suppressWarnings(as.numeric(baseline[[v]])))
}

# -----------------------------------------------------------------------------
# 1. Missingness summary
# -----------------------------------------------------------------------------
miss_summary <- rbindlist(lapply(NUM_VARS, function(v) {
  n_miss <- sum(is.na(baseline[[v]]))
  data.table(
    variable       = v,
    n_total        = nrow(baseline),
    n_missing      = n_miss,
    pct_missing    = round(n_miss / nrow(baseline) * 100, 2),
    n_observed     = nrow(baseline) - n_miss,
    median_val     = round(median(baseline[[v]], na.rm = TRUE), 3),
    p25            = round(quantile(baseline[[v]], 0.25, na.rm = TRUE), 3),
    p75            = round(quantile(baseline[[v]], 0.75, na.rm = TRUE), 3)
  )
}))

setorder(miss_summary, -pct_missing)

cat("\n--- Missingness Summary (sorted by % missing) ---\n")
print(miss_summary[pct_missing > 0])

# Flag variables exceeding missingness thresholds
HIGH_MISS_THRESHOLD <- 50   # > 50%: consider excluding
MOD_MISS_THRESHOLD  <- 20   # 20-50%: requires careful imputation strategy

miss_summary[, missingness_category := fcase(
  pct_missing > HIGH_MISS_THRESHOLD, "high_exclude_consider",
  pct_missing > MOD_MISS_THRESHOLD,  "moderate_impute_carefully",
  pct_missing > 0,                   "low_impute_ok",
  default =                          "complete"
)]

fwrite(miss_summary, file.path(OUTPUT_DIR, "missingness_report.csv"))
cat("\nMissingness report saved to: missingness_report.csv\n")

# Variables with acceptable missingness (< 50%) for imputation
vars_to_impute <- miss_summary[pct_missing < HIGH_MISS_THRESHOLD]$variable
cat("\nVariables retained for imputation:", length(vars_to_impute), "\n")

# Variables flagged for exclusion
vars_high_miss <- miss_summary[pct_missing >= HIGH_MISS_THRESHOLD]$variable
if (length(vars_high_miss) > 0) {
  cat("Variables with >50% missingness (consider excluding):\n",
      paste(vars_high_miss, collapse = ", "), "\n")
}

# -----------------------------------------------------------------------------
# 2. Winsorisation at 1st and 99th percentiles
# -----------------------------------------------------------------------------
# Clinical outliers in EHR data often reflect data entry errors rather than
# true extreme values. Winsorisation caps extreme values at percentile bounds
# without removing patients.
winsorise <- function(x, lo = 0.01, hi = 0.99) {
  qs <- quantile(x, probs = c(lo, hi), na.rm = TRUE)
  pmax(pmin(x, qs[2]), qs[1])
}

baseline_winsorised <- copy(baseline)
for (v in vars_to_impute) {
  n_before <- sum(!is.na(baseline_winsorised[[v]]))
  baseline_winsorised[, (v) := winsorise(.SD[[v]]), .SDcols = v]
}

cat("\nWinsorisation applied to", length(vars_to_impute), "variables.\n")

# -----------------------------------------------------------------------------
# 3. Distribution summary after winsorisation
# -----------------------------------------------------------------------------
dist_summary <- rbindlist(lapply(vars_to_impute, function(v) {
  x <- baseline_winsorised[[v]]
  data.table(
    variable = v,
    mean     = round(mean(x, na.rm = TRUE), 3),
    sd       = round(sd(x, na.rm = TRUE), 3),
    p25      = round(quantile(x, 0.25, na.rm = TRUE), 3),
    median   = round(median(x, na.rm = TRUE), 3),
    p75      = round(quantile(x, 0.75, na.rm = TRUE), 3)
  )
}))

fwrite(baseline_winsorised,
       file.path(OUTPUT_DIR, "baseline_features_winsorised.csv"))
fwrite(dist_summary,
       file.path(OUTPUT_DIR, "variable_distribution_summary.csv"))

cat("Winsorised feature matrix saved to: baseline_features_winsorised.csv\n")
cat("Distribution summary saved to: variable_distribution_summary.csv\n")
