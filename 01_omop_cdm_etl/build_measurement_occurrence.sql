DROP TABLE IF EXISTS t2d_cdm.lab_concept_xwalk;
CREATE TABLE t2d_cdm.lab_concept_xwalk (
  lab_code varchar(50) PRIMARY KEY,
  measurement_concept_id integer NOT NULL,
  unit_concept_id integer
);

INSERT INTO t2d_cdm.lab_concept_xwalk (lab_code, measurement_concept_id, unit_concept_id) VALUES
('ag', 3020509, 8523),
('alb', 3024561, 8636),
('alp', 3035995, 8923),
('alt', 3006923, 8923),
('ast', 3013721, 8923),
('b2mg', 3013201, 8751),
('bun', 3013682, 8753),
('bun/cr', 3018311, NULL),
('cr', 3016723, 8749),
('cysc', 3030366, 8751),
('dbil', 3027597, 8749),
('ggt', 3026910, 8923),
('glu', 3004501, 8753),
('hba1', 3005446, 8554),
('hba1a', 0, 8554),
('hba1b', 0, 8554),
('hba1c', 3004410, 8554),
('hcy', 3037585, 8749),
('hdl', 3007070, 8753),
('ibil', 3007359, 8749),
('ldl', 3028437, 8753),
('nh3', 3036887, 8749),
('pa', 3013742, 8636),
('pth', 3000067, 8845),
('tba', 3028110, 8749),
('tbil', 3024128, 8749),
('tcho', 3027114, 8753),
('tg', 3022192, 8753),
('tp', 3020630, 8636),
('uV24h', 3012565, 8519),
('ua', 3037556, 8749),
('uaer', 40761549, 8774),
('uaer24h', 40761549, 8774),
('ualb', 3012516, 8751),
('ualb24h', 3027035, 8909),
('ub2mg', 3018081, 8751),
('ubun', 3011965, 8753),
('ucr', 3017250, 8749),
('ucr24h', 3001349, 8749),
('umalb/ucr', 3034485, 8723),
('upro24h', 3020876, 8807),
('upro_c', 3037121, 8751),
('utp/ucr', 3001582, 8723),
('uua', 3033526, 8749);

TRUNCATE TABLE t2d_cdm.measurement;

INSERT INTO t2d_cdm.measurement (
  measurement_id, person_id, measurement_concept_id,
  measurement_date, measurement_datetime, measurement_type_concept_id,
  value_as_number, value_as_concept_id, unit_concept_id,
  measurement_source_value, measurement_source_concept_id,
  unit_source_value, value_source_value
)
SELECT
  row_number() OVER (ORDER BY p.person_id, s.detect_time) AS measurement_id,
  p.person_id,
  COALESCE(x.measurement_concept_id, 0) AS measurement_concept_id,
  s.detect_time::date,
  s.detect_time,
  44818702 AS measurement_type_concept_id,   -- Lab result
  s.value_as_number_new,
  NULL AS value_as_concept_id,
  x.unit_concept_id,
  s.lab_code AS measurement_source_value,
  0 AS measurement_source_concept_id,
  s.unit_new AS unit_source_value,
  s.value_as_category_new AS value_source_value
FROM t2d_cdm.stg_lab_raw s
JOIN t2d_cdm.person p ON p.person_source_value = s.person_id_new
LEFT JOIN t2d_cdm.lab_concept_xwalk x ON x.lab_code = s.lab_code;


