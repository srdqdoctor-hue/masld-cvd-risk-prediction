-- Step 1: persistent ICD code -> standard concept crosswalk (cascading prefix match)
DROP TABLE IF EXISTS t2d_cdm.icd_concept_xwalk;

CREATE TABLE t2d_cdm.icd_concept_xwalk AS
WITH src AS (
  SELECT DISTINCT condition_code,
         regexp_replace(condition_code, 'x[0-9]+$', '') AS stripped
  FROM t2d_cdm.stg_diag_raw
  WHERE condition_code IS NOT NULL
),
candidates AS (
  SELECT s.condition_code, s.stripped, n,
         CASE WHEN n >= length(s.stripped) THEN s.stripped ELSE left(s.stripped, n) END AS cand,
         length(s.stripped) - n AS chars_dropped
  FROM src s, generate_series(length(s.stripped), 3, -1) AS n
),
ranked AS (
  SELECT c.condition_code, c.cand, c.chars_dropped, v.concept_id, v.concept_name,
         row_number() OVER (PARTITION BY c.condition_code ORDER BY c.chars_dropped ASC) AS rn
  FROM candidates c
  JOIN omop_vocab.concept v ON v.concept_code = c.cand AND v.vocabulary_id IN ('ICD10','ICD10CM')
),
best AS (
  SELECT condition_code, cand AS matched_code, chars_dropped, concept_id AS source_concept_id
  FROM ranked WHERE rn = 1
)
SELECT
  s.condition_code,
  b.matched_code,
  b.chars_dropped,
  b.source_concept_id,
  m.concept_id_2 AS condition_concept_id,
  c2.concept_name AS condition_concept_name
FROM src s
LEFT JOIN best b ON b.condition_code = s.condition_code
LEFT JOIN omop_vocab.concept_relationship m
  ON m.concept_id_1 = b.source_concept_id AND m.relationship_id = 'Maps to'
LEFT JOIN omop_vocab.concept c2 ON c2.concept_id = m.concept_id_2;

CREATE INDEX idx_icd_xwalk_code ON t2d_cdm.icd_concept_xwalk(condition_code);

-- Step 2: dedup raw diagnosis events
DROP TABLE IF EXISTS t2d_cdm.stg_diag_dedup;
CREATE TABLE t2d_cdm.stg_diag_dedup AS
SELECT DISTINCT ON (person_id_new, condition_code, condition_start_datetime, condition_type_raw, diagnosis_type_raw)
  person_id_new, condition_name, condition_code, condition_start_datetime, condition_type_raw, diagnosis_type_raw
FROM t2d_cdm.stg_diag_raw;

-- Step 3: build condition_occurrence
TRUNCATE TABLE t2d_cdm.condition_occurrence;

INSERT INTO t2d_cdm.condition_occurrence (
  condition_occurrence_id, person_id, condition_concept_id,
  condition_start_date, condition_start_datetime,
  condition_type_concept_id, condition_status_concept_id,
  condition_source_value, condition_source_concept_id, condition_status_source_value
)
SELECT
  row_number() OVER (ORDER BY p.person_id, d.condition_start_datetime) AS condition_occurrence_id,
  p.person_id,
  COALESCE(x.condition_concept_id, 0) AS condition_concept_id,
  d.condition_start_datetime::date AS condition_start_date,
  d.condition_start_datetime,
  CASE d.condition_type_raw
    WHEN '入院诊断' THEN 32829   -- EHR inpatient note
    WHEN '出院诊断' THEN 32824   -- EHR discharge summary
    WHEN '门诊诊断' THEN 32834   -- EHR outpatient note
    ELSE 32817                   -- EHR (generic)
  END AS condition_type_concept_id,
  CASE
    WHEN d.condition_type_raw = '入院诊断' AND d.diagnosis_type_raw = '主要诊断' THEN 32901
    WHEN d.condition_type_raw = '入院诊断' AND d.diagnosis_type_raw = '次要诊断' THEN 32907
    WHEN d.condition_type_raw = '出院诊断' AND d.diagnosis_type_raw = '主要诊断' THEN 32903
    WHEN d.condition_type_raw = '出院诊断' AND d.diagnosis_type_raw = '次要诊断' THEN 32909
    WHEN d.diagnosis_type_raw = '主要诊断' THEN 32902
    WHEN d.diagnosis_type_raw = '次要诊断' THEN 32908
    ELSE NULL
  END AS condition_status_concept_id,
  d.condition_code AS condition_source_value,
  COALESCE(x.source_concept_id, 0) AS condition_source_concept_id,
  d.condition_type_raw || '/' || d.diagnosis_type_raw AS condition_status_source_value
FROM t2d_cdm.stg_diag_dedup d
JOIN t2d_cdm.person p ON p.person_source_value = d.person_id_new
LEFT JOIN t2d_cdm.icd_concept_xwalk x ON x.condition_code = d.condition_code;


