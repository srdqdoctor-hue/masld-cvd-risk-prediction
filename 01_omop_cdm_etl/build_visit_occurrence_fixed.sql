-- Step 1: add department-level care_site rows (keyed by discharge department, the
-- field used as the visit's responsible department), continuing care_site_id sequence.
INSERT INTO t2d_cdm.care_site (care_site_id, care_site_name, care_site_source_value)
SELECT
  (SELECT max(care_site_id) FROM t2d_cdm.care_site) + row_number() OVER (ORDER BY dept_discharge_from_new),
  dept_discharge_from_new,
  dept_discharge_from_new
FROM (SELECT DISTINCT dept_discharge_from_new FROM t2d_cdm.stg_visit_raw WHERE dept_discharge_from_new IS NOT NULL) d;

-- Step 2: build visit_occurrence
TRUNCATE TABLE t2d_cdm.visit_occurrence CASCADE;

INSERT INTO t2d_cdm.visit_occurrence (
  visit_occurrence_id, person_id, visit_concept_id,
  visit_start_date, visit_start_datetime, visit_end_date, visit_end_datetime,
  visit_type_concept_id, care_site_id,
  visit_source_value, discharged_to_concept_id, discharged_to_source_value
)
SELECT
  row_number() OVER (ORDER BY p.person_id, v.visit_start_date) AS visit_occurrence_id,
  p.person_id,
  9201 AS visit_concept_id,                -- Inpatient Visit (VISIT_TYPE is uniformly 住院)
  v.visit_start_date::date,
  v.visit_start_date,
  v.visit_end_date::date,
  v.visit_end_date,
  32035 AS visit_type_concept_id,           -- Visit derived from EHR encounter record
  cs.care_site_id,
  v.department_id_new AS visit_source_value,  -- admitting department kept as source value
  CASE v.out_condition
    WHEN '医嘱离院' THEN 44814696            -- Home / self care
    WHEN '非医嘱离院' THEN 44814692          -- Against medical advice
    WHEN '死亡' THEN 44814694                -- Expired
    WHEN '医嘱转院' THEN 44814698            -- Other acute inpatient hospital
    WHEN '医嘱转社区卫生服务机构/乡镇卫生院' THEN 44814695  -- Home health
    ELSE NULL
  END AS discharged_to_concept_id,
  v.out_condition AS discharged_to_source_value
FROM t2d_cdm.stg_visit_raw v
JOIN t2d_cdm.person p ON p.person_source_value = v.person_id_new
LEFT JOIN t2d_cdm.care_site cs ON cs.care_site_source_value = v.dept_discharge_from_new;


