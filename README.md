# masld-cvd-risk-prediction
EHR-based ML pipeline for MACE risk prediction in MASLD — OMOP CDM ETL, cohort construction, XGBoost, SHAP
# Code Sample — Rong-Dong-Qing Shi

Prepared for confidential PhD application review.

---

## Overview

This folder contains representative code from two interconnected research
projects:

1. **OMOP CDM ETL and OHDSI platform deployment** — translating multi-centre
   Chinese EHR data into a locally-hosted OMOP CDM v5.4 instance via Broadsea
   (Docker), with full data quality assessment using DQD and ACHILLES.
2. **EHR-based machine learning for cardiometabolic risk prediction** —
   developing and interpreting an XGBoost model for MACE risk stratification
   in patients with metabolic dysfunction-associated steatotic liver disease
   (MASLD), including calibration, decision curve analysis, and SHAP-based
   responsible AI interpretation.

**No patient-level data are included.** All file paths reference a secure
local mount (`data/secure_ehr/`). A self-contained synthetic dataset is
provided inside `03_ml_prediction_pipeline/masld_cvd_risk_prediction.py`
(function `generate_mock_dataset()`) so the Python pipeline can be run
end-to-end without access to real data.

---

## Folder Structure

```text
Rong-Dong-Qing_Shi_Code_Sample/
│
├── README.md
├── requirements.txt
│
├── 01_omop_cdm_etl/
│   ├── etl_person_observation_period.R     # ETL: person + observation_period tables
│   ├── stage_diag.R                        # Stage raw diagnosis records → Postgres
│   ├── stage_lab.R                         # Stage lab measurement records
│   ├── stage_visit.R                       # Stage visit records
│   ├── stage_atc.R                         # Stage ATC-coded drug prescription records
│   ├── build_condition_occurrence.sql      # Map staged diagnoses → condition_occurrence
│   ├── build_drug_exposure_fixed.sql       # Map ATC medications → drug_exposure
│   ├── build_measurement_occurrence.sql    # Map lab records → measurement table
│   ├── build_visit_occurrence_fixed.sql    # Map visits → visit_occurrence
│   ├── t2d_cdm_build.sql                   # Full CDM build script (T2DM cohort)
│   ├── run_achilles_t2d.R                  # Run ACHILLES characterisation
│   └── run_dqd.R                           # Run Data Quality Dashboard (DQD)
│
├── 02_ehr_cohort_construction/
│   ├── masld_cohort_construction.R         # MASLD cohort definition + feature matrix
│   └── missing_value_assessment.R          # Missingness profiling + winsorisation
│
└── 03_ml_prediction_pipeline/
    ├── masld_cvd_risk_prediction.py        # Complete ML pipeline (main script)
    └── shap_model_interpretation.py        # SHAP global + patient-level explanations
```

---

## 01 — OMOP CDM ETL (`01_omop_cdm_etl/`)

Implemented a local OMOP CDM (v5.4) using Broadsea (Docker Compose) with
PostgreSQL as the backend. ATLAS/WebAPI served as the cohort definition and
characterisation front-end; vocabulary management used White Rabbit,
Rabbit-in-a-Hat, and Usagi.

### Staging scripts (`stage_*.R`)

| Script          | Content                                                      |
| --------------- | ------------------------------------------------------------ |
| `stage_diag.R`  | Flattens list-of-list ICD-10 diagnosis RDS structures into a relational staging table; handles nested visit-level coding |
| `stage_lab.R`   | Extracts lab measurements from wide-format EHR export, pivots to long format, attaches local lab codes for Usagi mapping |
| `stage_visit.R` | Extracts inpatient/outpatient visit records; derives earliest/latest visit dates per patient for observation period construction |
| `stage_atc.R`   | Combines per-ATC-code prescription sub-tables into a single staging table; standardises dose units and administration routes; memory-efficient via `data.table::rbindlist` |

### ETL scripts (R + SQL)

| Script                             | Content                                                      |
| ---------------------------------- | ------------------------------------------------------------ |
| `etl_person_observation_period.R`  | Source-to-CDM mapping for `person`, `care_site`, and `observation_period`; gender vocabulary mapping (Chinese source → OMOP standard concepts) |
| `build_condition_occurrence.sql`   | Joins staged diagnoses to OMOP `concept` table for standard concept assignment; constructs `condition_type_concept_id` and visit linkage |
| `build_drug_exposure_fixed.sql`    | Maps ATC-coded prescriptions to OMOP drug concepts; handles dose era logic and route standardisation |
| `build_measurement_occurrence.sql` | Maps local lab codes (post-Usagi) to OMOP measurement concepts; preserves unit concepts and range flags |
| `t2d_cdm_build.sql`                | End-to-end CDM population script for the T2DM cohort; demonstrates transaction-level rebuild pattern |

### Quality assessment

| Script               | Content                                                      |
| -------------------- | ------------------------------------------------------------ |
| `run_achilles_t2d.R` | Runs ACHILLES characterisation to generate ARES data quality dashboards; stores results in `results` schema |
| `run_dqd.R`          | Executes all ~3 500 DQD checks (TABLE / FIELD / CONCEPT level); exports pass/fail JSON for ARES viewer; summarises top failing checks |

---

## 02 — EHR Cohort Construction (`02_ehr_cohort_construction/`)

Defines the MASLD study cohort from multi-centre EHR data and engineers the
baseline feature matrix for machine learning.

### `masld_cohort_construction.R`

- **MASLD identification**: text-pattern detection of hepatic steatosis /
  fatty liver in radiology/ultrasound imaging reports, combined with metabolic
  dysfunction criteria (obesity, T2DM, hypertension, dyslipidaemia) consistent
  with the 2023 MASLD nomenclature consensus.
- **Outcome definition**: ICD-10-coded MACE — coronary heart disease (I20–I25),
  stroke (I60–I64, G45), and heart failure hospitalisation (I50).
- **Feature extraction**: ~80 baseline variables across demographics, obesity
  indices, glycaemic markers, lipid profiles, liver and renal function,
  haematological and inflammatory markers, cardiovascular biomarkers
  (NT-proBNP, cTnT), and ATC-coded medication flags.
- **Temporal alignment**: restricts lab measurements to the ±30-day window
  around the MASLD index date and selects the measurement closest to index.

### `missing_value_assessment.R`

- Computes per-variable missingness rate; categorises features as
  high-miss (>50%), moderate-miss (20–50%), low-miss, or complete.
- Winsorises continuous features at the 1st/99th percentile to handle
  EHR data-entry outliers without patient exclusion.
- Outputs a missingness report table and the preprocessed feature matrix
  for the downstream Python ML pipeline.

---

## 03 — Machine Learning Pipeline (`03_ml_prediction_pipeline/`)

### `masld_cvd_risk_prediction.py` — main pipeline

End-to-end prediction pipeline in Python / scikit-learn:

| Step                  | Detail                                                       |
| --------------------- | ------------------------------------------------------------ |
| **Imputation**        | `IterativeImputer` (MICE-style) for continuous features; zero-fill for binary medication / comorbidity flags |
| **Feature selection** | RFECV with XGBoost estimator, 5-fold stratified CV, AUROC scoring |
| **Model comparison**  | 10-fold stratified CV across 9 models: Logistic Regression, Random Forest, XGBoost, LightGBM, Extra Trees, AdaBoost, Decision Tree, Gradient Boosting, SVM |
| **Tuning**            | `RandomizedSearchCV` (50 iterations) over XGBoost hyperparameter space |
| **Calibration**       | Isotonic regression post-hoc calibration on a held-out validation fold |
| **Evaluation**        | AUROC, AUPRC, Brier score, sensitivity, specificity, PPV, NPV, F1; calibration curve; decision curve analysis (DCA) |

A **synthetic dataset generator** (`generate_mock_dataset()`) is included so
the full pipeline can be run without access to patient data — realistic
feature distributions, ~18% MACE event rate, and structured missingness
patterns (HbA1c 25%, Cystatin C 30%, uACR 40%, NT-proBNP 45%, cTnT 50%).

### `shap_model_interpretation.py` — responsible AI interpretation

- **Global explanations**: beeswarm summary plot (feature value vs SHAP
  contribution) and mean |SHAP| bar chart with clinically labelled features.
- **Dependence plots**: SHAP value vs feature value for the top 6 features,
  revealing non-linear effects and automatic interaction detection.
- **Patient-level explanations**: waterfall plots for correctly classified
  high-risk (TP) and low-risk (TN) patients, demonstrating individual-level
  interpretability.
- **Responsible AI caveat**: the script explicitly documents that high SHAP
  importance for medication features (statins, antiplatelets) reflects
  *confounding by indication* — a known pitfall in observational EHR-based
  models that should inform any clinical deployment decision.

---

## Privacy and Data Governance

- No patient-level EHR data, raw data files, `.env` credentials, or hospital
  data dictionaries are included.
- All file paths use the placeholder prefix `data/secure_ehr/`.
- Database connection credentials are read from environment variables
  (`Sys.getenv()` in R; the equivalent in Python) — no hard-coded passwords.
- The original study was conducted under institutional data governance approval
  at Anhui Provincial Hospital / University of Science and Technology of China.

---

## Running the Demonstration Pipeline

```bash
# 1. Install Python dependencies
pip install -r requirements.txt

# 2. Run end-to-end on synthetic data (no real patient data required)
python 03_ml_prediction_pipeline/masld_cvd_risk_prediction.py

# 3. Run SHAP interpretation (loads model saved by step 2)
python 03_ml_prediction_pipeline/shap_model_interpretation.py
```

R scripts require R ≥ 4.3 with the packages listed in `requirements.txt`.
The OHDSI ETL scripts additionally require a running PostgreSQL instance with
OMOP CDM schema; see the Broadsea README for Docker-based setup.

---

## Contact

Rong-Dong-Qing Shi  
Master of Medicine Candidate — University of Science and Technology of China  
Email: <srdqdoctor@gmail.com>
