## Stage diag.icd.rds + diag.reg.rds (both: list of phenotype sub-tables) into Postgres
## t2d_cdm.stg_diag_raw, for downstream SQL-side dedup + concept mapping.
library(DBI)
library(RPostgres)
library(data.table)

con <- dbConnect(RPostgres::Postgres(),
                  host = "broadsea-atlasdb", port = 5432,
                  dbname = "postgres", user = Sys.getenv("BROADSEA_POSTGRES_USER", "postgres"), password = Sys.getenv("BROADSEA_POSTGRES_PASSWORD"))

load_and_bind <- function(path, source_label) {
  lst <- readRDS(path)
  dt <- rbindlist(lst, idcol = "phenotype", fill = TRUE)
  dt[, source_file := source_label]
  dt[, .(PERSON_ID_NEW, phenotype, CONDITION_NAME, CONDITION_CODE,
         CONDITION_START_DATE, CONDITION_TYPE, DIAGNOSIS_TYPE, source_file)]
}

icd <- load_and_bind("/data/cleandata/diag.icd.rds", "icd")
reg <- load_and_bind("/data/cleandata/diag.reg.rds", "reg")
all_diag <- rbindlist(list(icd, reg), use.names = TRUE)
cat("combined rows (before dedup):", nrow(all_diag), "\n")

setnames(all_diag, c("person_id_new", "phenotype", "condition_name", "condition_code",
                      "condition_start_datetime", "condition_type_raw", "diagnosis_type_raw", "source_file"))

dbExecute(con, "DROP TABLE IF EXISTS t2d_cdm.stg_diag_raw")
dbExecute(con, "
  CREATE TABLE t2d_cdm.stg_diag_raw (
    person_id_new varchar(50),
    phenotype varchar(100),
    condition_name varchar(500),
    condition_code varchar(50),
    condition_start_datetime timestamp,
    condition_type_raw varchar(50),
    diagnosis_type_raw varchar(50),
    source_file varchar(10)
  )")

dbWriteTable(con, DBI::Id(schema = "t2d_cdm", table = "stg_diag_raw"), all_diag, append = TRUE, row.names = FALSE)
cat("staged rows:", nrow(all_diag), "\n")
dbDisconnect(con)


