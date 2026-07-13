-- Step 1: ATC -> Ingredient crosswalk (validated via concept_ancestor, prefers Ingredient/standard)
DROP TABLE IF EXISTS t2d_cdm.atc_concept_xwalk;
CREATE TABLE t2d_cdm.atc_concept_xwalk AS
WITH src AS (
  SELECT DISTINCT atc_code FROM t2d_cdm.stg_atc_raw
),
candidates AS (
  SELECT s.atc_code, atc.concept_id AS atc_concept_id, ing.concept_id AS drug_concept_id, ing.concept_name
  FROM src s
  JOIN omop_vocab.concept atc ON atc.concept_code = s.atc_code AND atc.vocabulary_id = 'ATC'
  JOIN omop_vocab.concept_ancestor ca ON ca.ancestor_concept_id = atc.concept_id
  JOIN omop_vocab.concept ing ON ing.concept_id = ca.descendant_concept_id
  WHERE ing.concept_class_id = 'Ingredient' AND ing.standard_concept = 'S'
),
best AS (
  SELECT DISTINCT ON (atc_code) atc_code, atc_concept_id, drug_concept_id, concept_name
  FROM candidates
  ORDER BY atc_code, drug_concept_id
)
SELECT * FROM best;

CREATE INDEX idx_atc_xwalk_code ON t2d_cdm.atc_concept_xwalk(atc_code);

-- Step 2: route crosswalk (manual, covers >99% of volume; rare/non-route values left NULL)
DROP TABLE IF EXISTS t2d_cdm.route_concept_xwalk;
CREATE TABLE t2d_cdm.route_concept_xwalk (
  route_raw varchar(50) PRIMARY KEY,
  route_concept_id integer
);
INSERT INTO t2d_cdm.route_concept_xwalk VALUES
('vd', 4171047), ('iv', 4171047), ('po', 4132161),
('ih', 40486069), ('inh', 40486069),
('im', 4302612), ('ext', 4263689),
('pr', 4290759), ('肛用', 4290759),
('滴眼', 4184451), ('含服', 4292110),
('ig', 40492301), ('ip', 4243022),
('鞘内注射', 4217202), ('阴道用药', 4057765),
('肠管注入', 4167540), ('营养管注入', 4167540),
('关节腔注射', 4006860), ('气管注入', 4303263),
('瘤体注射', 40491322), ('泵入', 4171047),
('血液净化', 35624178), ('透析', 35624178),
('id', 4156706);

-- Step 3: drug_exposure
TRUNCATE TABLE t2d_cdm.drug_exposure;

INSERT INTO t2d_cdm.drug_exposure (
  drug_exposure_id, person_id, drug_concept_id,
  drug_exposure_start_date, drug_exposure_start_datetime,
  drug_exposure_end_date, drug_exposure_end_datetime,
  drug_type_concept_id, route_concept_id,
  drug_source_value, drug_source_concept_id,
  route_source_value, dose_unit_source_value
)
SELECT
  row_number() OVER () AS drug_exposure_id,
  p.person_id,
  COALESCE(x.drug_concept_id, 0) AS drug_concept_id,
  s.drug_start_date::date,
  s.drug_start_date,
  COALESCE(s.drug_end_date::date, s.drug_start_date::date),
  s.drug_end_date,
  32818 AS drug_type_concept_id,   -- EHR administration record
  r.route_concept_id,
  s.atc_code,
  COALESCE(x.atc_concept_id, 0),
  s.route_new,
  s.dose_unit_new
FROM t2d_cdm.stg_atc_raw s
JOIN t2d_cdm.person p ON p.person_source_value = s.person_id_new
LEFT JOIN t2d_cdm.atc_concept_xwalk x ON x.atc_code = s.atc_code
LEFT JOIN t2d_cdm.route_concept_xwalk r ON r.route_raw = s.route_new;


