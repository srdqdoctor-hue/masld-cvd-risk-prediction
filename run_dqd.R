# Data Quality Dashboard (DQD) — standalone execution script
# Runs the OHDSI DataQualityDashboard against a local OMOP CDM instance
# and exports results as JSON for the ARES browser dashboard.
#
# Prerequisites (CRAN / OHDSI GitHub):
#   install.packages("DatabaseConnector")
#   remotes::install_github("OHDSI/DataQualityDashboard")
#   remotes::install_github("OHDSI/Achilles")          # needed for some DQD checks
#
# Connection credentials should be stored in a .Renviron file, never hard-coded:
#   PG_HOST, PG_PORT, PG_DB, PG_USER, PG_PASSWORD

suppressPackageStartupMessages({
  library(DatabaseConnector)
  library(DataQualityDashboard)
})

# ---------------------------------------------------------------------------
# 1. Connection
# ---------------------------------------------------------------------------

connectionDetails <- createConnectionDetails(
  dbms       = "postgresql",
  server     = paste0(Sys.getenv("PG_HOST"), "/", Sys.getenv("PG_DB")),
  port       = as.integer(Sys.getenv("PG_PORT", "5432")),
  user       = Sys.getenv("PG_USER"),
  password   = Sys.getenv("PG_PASSWORD")
)

CDM_SCHEMA     <- "omop_cdm"
RESULTS_SCHEMA <- "omop_results"
VOCAB_SCHEMA   <- "omop_cdm"      # vocabulary tables co-located with CDM tables
CDM_SOURCE     <- "LOCAL-T2D-OMOP-v5.4"
OUTPUT_DIR     <- file.path("data", "secure_ehr", "dqd_output")

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# ---------------------------------------------------------------------------
# 2. Execute DQD checks
# ---------------------------------------------------------------------------
# DQD runs ~3 500 data quality checks organised in three levels:
#   TABLE   – row counts, expected table presence
#   FIELD   – completeness, conformance, plausibility per column
#   CONCEPT – standard concept usage, unmapped source codes

message("[DQD] Starting checks on schema: ", CDM_SCHEMA)

result <- executeDqChecks(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = CDM_SCHEMA,
  resultsDatabaseSchema = RESULTS_SCHEMA,
  vocabDatabaseSchema   = VOCAB_SCHEMA,
  cdmSourceName         = CDM_SOURCE,
  cdmVersion            = "5.4",
  numThreads            = 4L,           # parallel SQL execution
  sqlOnly               = FALSE,        # TRUE to generate SQL without running
  outputFolder          = OUTPUT_DIR,
  outputFile            = "dq_result.json",
  verboseMode           = FALSE,
  writeToTable          = TRUE,
  writeTableName        = "dqdashboard_results",
  writeToCsv            = TRUE,
  csvFile               = file.path(OUTPUT_DIR, "dq_result.csv"),
  checkLevels           = c("TABLE", "FIELD", "CONCEPT"),
  checkNames            = c(),           # empty = all checks
  tablesToExclude       = c("CONCEPT", "VOCABULARY", "CONCEPT_ANCESTOR",
                             "CONCEPT_RELATIONSHIP", "CONCEPT_CLASS",
                             "CONCEPT_SYNONYM", "RELATIONSHIP",
                             "DOMAIN", "DRUG_STRENGTH")
)

# ---------------------------------------------------------------------------
# 3. Summarise pass / fail
# ---------------------------------------------------------------------------

if (!is.null(result) && nrow(result$CheckResults) > 0) {
  checks <- result$CheckResults
  total  <- nrow(checks)
  passed <- sum(checks$passed == 1L, na.rm = TRUE)
  failed <- sum(checks$failed == 1L, na.rm = TRUE)
  thresh <- sum(checks$isError == 1L, na.rm = TRUE)

  message(sprintf(
    "[DQD] Completed: %d checks | %d passed (%.1f%%) | %d failed | %d threshold errors",
    total, passed, 100 * passed / total, failed, thresh
  ))

  # Top failing checks by category
  top_fails <- checks[checks$failed == 1L, ]
  top_fails <- top_fails[order(top_fails$numViolatedRows, decreasing = TRUE), ]
  top_show  <- head(top_fails[, c("checkName", "cdmTableName", "cdmFieldName",
                                   "numViolatedRows", "pctViolatedRows")], 20)
  message("[DQD] Top failing checks:")
  print(top_show, row.names = FALSE)
} else {
  message("[DQD] No results returned; check connection and schema names.")
}

# ---------------------------------------------------------------------------
# 4. Export JSON for ARES viewer
# ---------------------------------------------------------------------------

json_path <- file.path(OUTPUT_DIR, "dq_result.json")
if (file.exists(json_path)) {
  message("[DQD] Results written to: ", json_path)
  message("[DQD] Open in ARES: http://localhost/ares  (after running aresIndexer)")
} else {
  message("[DQD] JSON file not found; DQD may have failed. Review logs above.")
}
