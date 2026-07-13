## ETL Step 1: person.rds + visit.rds -> t2d_cdm.care_site / person / observation_period
## Source: /data/cleandata (data/secure_ehr/cleandata, mounted read-only)
## Target: Postgres broadsea-atlasdb, schema t2d_cdm

library(DBI)
library(RPostgres)
library(data.table)

con <- dbConnect(RPostgres::Postgres(),
                  host = "broadsea-atlasdb",
                  port = 5432,
                  dbname = "postgres",
                  user = Sys.getenv("BROADSEA_POSTGRES_USER", "postgres"),
                  password = Sys.getenv("BROADSEA_POSTGRES_PASSWORD"))

person_src <- readRDS("/data/cleandata/person.rds")
visit_src  <- readRDS("/data/cleandata/visit.rds")
setDT(person_src)
setDT(visit_src)

person_src <- unique(person_src, by = "PERSON_ID_NEW")
setorder(person_src, PERSON_ID_NEW)

## ---- hosp -> care_site ----
person_src[, hosp := sub("_.*$", "", PERSON_ID_NEW)]
hosp_levels <- sort(unique(person_src$hosp))
care_site <- data.table(
  care_site_id = seq_along(hosp_levels),
  care_site_name = NA_character_,
  place_of_service_concept_id = NA_integer_,
  location_id = NA_integer_,
  care_site_source_value = hosp_levels,
  place_of_service_source_value = NA_character_
)

## ---- person_id crosswalk (stable, source_value-keyed) ----
person_src[, person_id := .I]

## ---- gender mapping ----
gender_map <- c("男" = 8507L, "女" = 8532L)  # 男=MALE, 女=FEMALE
person_src[, gender_concept_id := gender_map[GENDER]]
unmapped <- unique(person_src$GENDER[is.na(person_src$gender_concept_id)])
if (length(unmapped) > 0) {
  warning("Unmapped GENDER values: ", paste(unmapped, collapse = ", "))
}

person_src[, `:=`(
  year_of_birth  = as.integer(format(BIRTHDAY, "%Y")),
  month_of_birth = as.integer(format(BIRTHDAY, "%m")),
  day_of_birth   = as.integer(format(BIRTHDAY, "%d")),
  birth_datetime = as.POSIXct(BIRTHDAY)
)]

person_cdm <- merge(person_src, care_site[, .(care_site_id, hosp = care_site_source_value)], by = "hosp")

person_cdm <- person_cdm[, .(
  person_id,
  gender_concept_id,
  year_of_birth,
  month_of_birth,
  day_of_birth,
  birth_datetime,
  race_concept_id = 0L,
  ethnicity_concept_id = 0L,
  location_id = NA_integer_,
  provider_id = NA_integer_,
  care_site_id,
  person_source_value = PERSON_ID_NEW,
  gender_source_value = GENDER,
  gender_source_concept_id = NA_integer_,
  race_source_value = NA_character_,
  race_source_concept_id = NA_integer_,
  ethnicity_source_value = NA_character_,
  ethnicity_source_concept_id = NA_integer_
)]
setorder(person_cdm, person_id)

## ---- observation_period from visit date range ----
crosswalk <- person_src[, .(PERSON_ID_NEW, person_id)]
visit_src <- merge(visit_src, crosswalk, by = "PERSON_ID_NEW")

obs <- visit_src[, .(
  observation_period_start_date = as.Date(min(VISIT_START_DATE, na.rm = TRUE)),
  observation_period_end_date   = as.Date(max(VISIT_END_DATE,   na.rm = TRUE))
), by = person_id]
obs[, period_type_concept_id := 32817L]  # 'EHR' - verify against omop_vocab.concept once vocab load finishes
setorder(obs, person_id)
obs[, observation_period_id := .I]
obs <- obs[, .(observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)]

## ---- load ----
dbExecute(con, "TRUNCATE TABLE t2d_cdm.care_site, t2d_cdm.person, t2d_cdm.observation_period CASCADE")

dbWriteTable(con, DBI::Id(schema = "t2d_cdm", table = "care_site"), care_site, append = TRUE, row.names = FALSE)
dbWriteTable(con, DBI::Id(schema = "t2d_cdm", table = "person"), person_cdm, append = TRUE, row.names = FALSE)
dbWriteTable(con, DBI::Id(schema = "t2d_cdm", table = "observation_period"), obs, append = TRUE, row.names = FALSE)

cat("care_site rows:", nrow(care_site), "\n")
cat("person rows:", nrow(person_cdm), "\n")
cat("observation_period rows:", nrow(obs), "\n")
cat("persons without any visit (no observation_period):", nrow(person_cdm) - nrow(obs), "\n")

dbDisconnect(con)


