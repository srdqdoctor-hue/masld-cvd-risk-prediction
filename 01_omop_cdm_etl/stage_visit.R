library(DBI)
library(RPostgres)
library(data.table)

con <- dbConnect(RPostgres::Postgres(),
                  host = "broadsea-atlasdb", port = 5432,
                  dbname = "postgres", user = Sys.getenv("BROADSEA_POSTGRES_USER", "postgres"), password = Sys.getenv("BROADSEA_POSTGRES_PASSWORD"))

v <- readRDS('/data/cleandata/visit.rds')
setDT(v)
v <- v[, .(UNIQ_ID, PERSON_ID_NEW, VISIT_START_DATE, VISIT_END_DATE, OUT_CONDITION,
           DEPARTMENT_ID_NEW, DEPT_DISCHARGE_FROM_NEW, TOTAL_COSTS)]
setnames(v, tolower(names(v)))

dbExecute(con, "DROP TABLE IF EXISTS t2d_cdm.stg_visit_raw")
dbExecute(con, "
  CREATE TABLE t2d_cdm.stg_visit_raw (
    uniq_id varchar(80),
    person_id_new varchar(50),
    visit_start_date timestamp,
    visit_end_date timestamp,
    out_condition varchar(100),
    department_id_new varchar(100),
    dept_discharge_from_new varchar(100),
    total_costs numeric
  )")

dbWriteTable(con, DBI::Id(schema = "t2d_cdm", table = "stg_visit_raw"), v, append = TRUE, row.names = FALSE)
cat("staged visit rows:", nrow(v), "\n")
dbDisconnect(con)


