# =============================================================================
# MASLD Cohort Construction and Feature Engineering
# =============================================================================
# Purpose:
#   Define the MASLD index cohort from multi-centre EHR data, merge imaging,
#   laboratory, medication, and vital-sign records, and engineer the baseline
#   feature matrix used for cardiovascular risk prediction.
#
# Data sources (loaded from secure local mounts; no patient data included here):
#   person.rds        – demographic records
#   visit.rds         – inpatient / outpatient visit records
#   diag.icd.rds      – ICD-coded diagnosis lists (phenotype sub-tables)
#   diag.reg.rds      – registry-style diagnosis records
#   lab.rds           – laboratory measurement lists (analyte sub-tables)
#   atc.rds           – ATC-coded medication exposure records
#   imaging.rds       – radiology / ultrasound structured reports
#
# Output:
#   masld_baseline_features.csv  – one row per eligible patient, columns = features
# =============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(stringr)
  library(lubridate)
})

DATA_DIR   <- "data/secure_ehr/cleandata"
OUTPUT_DIR <- "data/secure_ehr/outputs"

# -----------------------------------------------------------------------------
# 1. Load source tables
# -----------------------------------------------------------------------------
person  <- readRDS(file.path(DATA_DIR, "person.rds"))
visit   <- readRDS(file.path(DATA_DIR, "visit.rds"))
lab     <- readRDS(file.path(DATA_DIR, "lab.rds"))
atc     <- readRDS(file.path(DATA_DIR, "atc.rds"))
imaging <- readRDS(file.path(DATA_DIR, "imaging.rds"))

setDT(person); setDT(visit)

# -----------------------------------------------------------------------------
# 2. Identify MASLD patients from imaging reports
# -----------------------------------------------------------------------------
# MASLD (Metabolic dysfunction-Associated Steatotic Liver Disease) requires:
#   (a) hepatic steatosis on imaging AND
#   (b) at least one metabolic dysfunction criterion
#
# Step 2a: text-pattern detection of hepatic steatosis in imaging reports
steatosis_pattern  <- "hepatic steatosis|fatty liver|steatohepatitis|fat deposition"
position_pattern   <- "liver|abdomen|hepatic"
fat_deposit_pattern <- "lipid deposit|fat deposit"

setDT(imaging)
imaging[, has_steatosis := (
  str_detect(tolower(REPORT_TEXT),      steatosis_pattern) |
  str_detect(tolower(FINDINGS),         steatosis_pattern) |
  str_detect(tolower(DOCTOR_DESC),      steatosis_pattern) |
  (str_detect(tolower(REPORT_TEXT), fat_deposit_pattern) &
     str_detect(tolower(EXAM_SITE),   position_pattern))
)]

fatty_liver_list <- imaging[has_steatosis == TRUE,
                            .(PERSON_ID_NEW, IMAGING_DATE = as.Date(IMAGING_DATE))]

# Keep earliest steatosis record per patient (index date)
setorder(fatty_liver_list, PERSON_ID_NEW, IMAGING_DATE)
fatty_liver_index <- unique(fatty_liver_list, by = "PERSON_ID_NEW")
setnames(fatty_liver_index, "IMAGING_DATE", "MASLD_INDEX_DATE")

cat("Patients with imaging-confirmed hepatic steatosis:", nrow(fatty_liver_index), "\n")

# -----------------------------------------------------------------------------
# 3. Apply MASLD metabolic dysfunction criteria
# -----------------------------------------------------------------------------
# Requires >= 1 of: overweight/obesity, T2DM, hypertension, dyslipidaemia,
# or other metabolic risk factor
# These flags are derived from diagnosis codes and lab thresholds in a
# separate phenotyping step (see stage_diagnoses.R / build_condition_occurrence.sql).
metabolic_phenotypes <- readRDS(file.path(DATA_DIR, "metabolic_phenotype_flags.rds"))
setDT(metabolic_phenotypes)

masld_eligible <- merge(fatty_liver_index, metabolic_phenotypes,
                        by = "PERSON_ID_NEW", all.x = TRUE)
masld_eligible[, n_metabolic_criteria :=
                 rowSums(.SD, na.rm = TRUE),
               .SDcols = c("flag_obesity", "flag_t2dm", "flag_hypertension",
                           "flag_dyslipidaemia", "flag_other_metabolic")]

masld_eligible <- masld_eligible[n_metabolic_criteria >= 1]
cat("Patients meeting MASLD criteria (steatosis + >= 1 metabolic factor):",
    nrow(masld_eligible), "\n")

# -----------------------------------------------------------------------------
# 4. Link visits to align index date with hospitalisation window
# -----------------------------------------------------------------------------
visit_nafld <- merge(masld_eligible[, .(PERSON_ID_NEW, MASLD_INDEX_DATE)],
                     visit, by = "PERSON_ID_NEW")

# Retain only visits where MASLD diagnosis falls within the admission window
visit_index <- visit_nafld[
  as.Date(MASLD_INDEX_DATE) >= as.Date(VISIT_START_DATE) &
    as.Date(MASLD_INDEX_DATE) <= as.Date(VISIT_END_DATE)
]

eligible_ids <- unique(visit_index$PERSON_ID_NEW)
cat("Patients with valid index admission:", length(eligible_ids), "\n")

# -----------------------------------------------------------------------------
# 5. Define MACE outcome (Major Adverse Cardiovascular Events)
# -----------------------------------------------------------------------------
# MACE = first occurrence of: coronary heart disease (CHD), stroke, or
# hospitalisation for heart failure (HF), defined by ICD-10 codes.
#
# ICD-10 code groups:
#   CHD:    I20-I25
#   Stroke: I60-I64, G45
#   HF:     I50
icd_mace_pattern <- "^(I2[0-5]|I[6][0-4]|G45|I50)"

diag_icd <- readRDS(file.path(DATA_DIR, "diag.icd.rds"))
diag_reg <- readRDS(file.path(DATA_DIR, "diag.reg.rds"))

bind_diag <- function(lst, source_label) {
  dt <- rbindlist(lapply(names(lst), function(nm) {
    d <- as.data.table(lst[[nm]])
    d[, phenotype := nm]
    d
  }), fill = TRUE)
  dt[, source := source_label]
  dt
}

all_diag <- rbindlist(list(
  bind_diag(diag_icd, "icd"),
  bind_diag(diag_reg, "reg")
), use.names = TRUE, fill = TRUE)

mace_records <- all_diag[str_detect(CONDITION_CODE, icd_mace_pattern) &
                           PERSON_ID_NEW %in% eligible_ids]

mace_records[, event_date := as.Date(CONDITION_START_DATE)]
setorder(mace_records, PERSON_ID_NEW, event_date)
first_mace <- unique(mace_records[, .(PERSON_ID_NEW, MACE_DATE = event_date)],
                     by = "PERSON_ID_NEW")

# -----------------------------------------------------------------------------
# 6. Merge laboratory features at index visit
# -----------------------------------------------------------------------------
# Key analytes: glycaemic, lipid, liver, renal, haematological, inflammatory
TARGET_ANALYTES <- c(
  # Glycaemic
  "glu", "hba1c",
  # Lipid
  "tcho", "hdl", "ldl", "tg",
  # Liver
  "alt", "ast", "ggt", "tbil", "dbil", "alb", "alp",
  # Renal
  "cr", "bun", "cysc", "ua", "umalb_ucr",
  # Haematological
  "hb", "wbc", "plt", "lymph2", "gran2",
  # Inflammatory
  "hscrp", "crp",
  # Cardiac
  "ntprobnp", "ctnt",
  # Other
  "hcy", "inr", "fib"
)

# Flatten list-of-analyte-tables into long format, then pivot wide
lab_long <- rbindlist(lapply(names(lab), function(nm) {
  if (!nm %in% TARGET_ANALYTES) return(NULL)
  dt <- as.data.table(lab[[nm]])
  dt[, analyte := nm]
  dt[PERSON_ID_NEW %in% eligible_ids]
}), fill = TRUE)

# Retain only measurements within [-30, +7] days of MASLD index date
lab_long <- merge(lab_long, masld_eligible[, .(PERSON_ID_NEW, MASLD_INDEX_DATE)],
                  by = "PERSON_ID_NEW")
lab_long[, days_from_index :=
           as.numeric(as.Date(TEST_DATE) - as.Date(MASLD_INDEX_DATE))]
lab_index <- lab_long[days_from_index >= -30 & days_from_index <= 7]

# For each analyte, take the value closest to index date
setorder(lab_index, PERSON_ID_NEW, analyte, abs(days_from_index))
lab_index_closest <- unique(lab_index, by = c("PERSON_ID_NEW", "analyte"))

# Pivot to wide format: one row per patient
lab_wide <- dcast(lab_index_closest,
                  PERSON_ID_NEW ~ analyte,
                  value.var = "TEST_VALUE",
                  fun.aggregate = function(x) x[1])

# Compute AST/ALT ratio (MASLD-specific feature)
lab_wide[, ast_alt_ratio := as.numeric(ast) / as.numeric(alt)]

# -----------------------------------------------------------------------------
# 7. Merge medication exposure at index (binary flags)
# -----------------------------------------------------------------------------
# ATC code groups of clinical interest
MED_GROUPS <- list(
  antiplatelet  = c("B01AC06", "N02BA01", "B01AC04"),   # aspirin, clopidogrel
  statin        = c("C10AA"),                            # HMG-CoA reductase inhibitors
  antihtn       = c("C02", "C03", "C07", "C08", "C09"), # antihypertensives
  glucose_lower = c("A10BA", "A10BB", "A10BG", "A10BH",
                    "A10BK", "A10BJ"),                   # metformin, glitazones, SGLT2i, GLP-1
  insulin       = c("A10A")                              # insulins
)

# Flatten ATC sub-tables
sub_atc_long <- rbindlist(lapply(names(atc$sub.atc), function(nm) {
  dt <- as.data.table(atc$sub.atc[[nm]])
  dt[, med_class := nm]
  dt[PERSON_ID_NEW %in% eligible_ids]
}), fill = TRUE)

# Flag each medication group
for (grp in names(MED_GROUPS)) {
  codes <- MED_GROUPS[[grp]]
  pattern <- paste(codes, collapse = "|")
  med_flag <- sub_atc_long[str_detect(ATC_CODE, pattern),
                            .(PERSON_ID_NEW, flag = 1L)] |>
    unique(by = "PERSON_ID_NEW")
  setnames(med_flag, "flag", paste0("med_", grp))
  masld_eligible <- merge(masld_eligible, med_flag, by = "PERSON_ID_NEW", all.x = TRUE)
  set(masld_eligible, j = paste0("med_", grp),
      value = fifelse(is.na(masld_eligible[[paste0("med_", grp)]]), 0L,
                      masld_eligible[[paste0("med_", grp)]]))
}

# -----------------------------------------------------------------------------
# 8. Assemble baseline feature matrix
# -----------------------------------------------------------------------------
person_features <- person[PERSON_ID_NEW %in% eligible_ids,
                           .(PERSON_ID_NEW, AGE, SEX, BMI)]

baseline <- Reduce(function(a, b) merge(a, b, by = "PERSON_ID_NEW", all.x = TRUE),
                   list(person_features,
                        masld_eligible,
                        lab_wide,
                        first_mace))

# Derive MACE outcome relative to index date
baseline[, MACE_occurred := as.integer(!is.na(MACE_DATE))]
baseline[, days_to_MACE  := as.numeric(as.Date(MACE_DATE) - as.Date(MASLD_INDEX_DATE))]

# Exclude patients with MACE prior to index (prevalent CVD)
n_before <- nrow(baseline)
baseline <- baseline[is.na(MACE_DATE) | days_to_MACE > 0]
cat("Excluded", n_before - nrow(baseline), "patients with pre-existing MACE\n")

cat("\nFinal eligible cohort:", nrow(baseline), "patients\n")
cat("MACE events:", sum(baseline$MACE_occurred), "\n")
cat("MACE rate:", round(mean(baseline$MACE_occurred) * 100, 1), "%\n")

fwrite(baseline, file.path(OUTPUT_DIR, "masld_baseline_features.csv"))
cat("\nFeature matrix saved to:", file.path(OUTPUT_DIR, "masld_baseline_features.csv"), "\n")
