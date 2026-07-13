CREATE SCHEMA IF NOT EXISTS t2d_cdm;

--postgresql CDM DDL Specification for OMOP Common Data Model 5.4
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.person (
			person_id integer NOT NULL,
			gender_concept_id integer NOT NULL,
			year_of_birth integer NOT NULL,
			month_of_birth integer NULL,
			day_of_birth integer NULL,
			birth_datetime TIMESTAMP NULL,
			race_concept_id integer NOT NULL,
			ethnicity_concept_id integer NOT NULL,
			location_id integer NULL,
			provider_id integer NULL,
			care_site_id integer NULL,
			person_source_value varchar(50) NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id integer NULL,
			race_source_value varchar(50) NULL,
			race_source_concept_id integer NULL,
			ethnicity_source_value varchar(50) NULL,
			ethnicity_source_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.observation_period (
			observation_period_id integer NOT NULL,
			person_id integer NOT NULL,
			observation_period_start_date date NOT NULL,
			observation_period_end_date date NOT NULL,
			period_type_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.visit_occurrence (
			visit_occurrence_id integer NOT NULL,
			person_id integer NOT NULL,
			visit_concept_id integer NOT NULL,
			visit_start_date date NOT NULL,
			visit_start_datetime TIMESTAMP NULL,
			visit_end_date date NOT NULL,
			visit_end_datetime TIMESTAMP NULL,
			visit_type_concept_id Integer NOT NULL,
			provider_id integer NULL,
			care_site_id integer NULL,
			visit_source_value varchar(50) NULL,
			visit_source_concept_id integer NULL,
			admitted_from_concept_id integer NULL,
			admitted_from_source_value varchar(50) NULL,
			discharged_to_concept_id integer NULL,
			discharged_to_source_value varchar(50) NULL,
			preceding_visit_occurrence_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.visit_detail (
			visit_detail_id integer NOT NULL,
			person_id integer NOT NULL,
			visit_detail_concept_id integer NOT NULL,
			visit_detail_start_date date NOT NULL,
			visit_detail_start_datetime TIMESTAMP NULL,
			visit_detail_end_date date NOT NULL,
			visit_detail_end_datetime TIMESTAMP NULL,
			visit_detail_type_concept_id integer NOT NULL,
			provider_id integer NULL,
			care_site_id integer NULL,
			visit_detail_source_value varchar(50) NULL,
			visit_detail_source_concept_id Integer NULL,
			admitted_from_concept_id Integer NULL,
			admitted_from_source_value varchar(50) NULL,
			discharged_to_source_value varchar(50) NULL,
			discharged_to_concept_id integer NULL,
			preceding_visit_detail_id integer NULL,
			parent_visit_detail_id integer NULL,
			visit_occurrence_id integer NOT NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.condition_occurrence (
			condition_occurrence_id integer NOT NULL,
			person_id integer NOT NULL,
			condition_concept_id integer NOT NULL,
			condition_start_date date NOT NULL,
			condition_start_datetime TIMESTAMP NULL,
			condition_end_date date NULL,
			condition_end_datetime TIMESTAMP NULL,
			condition_type_concept_id integer NOT NULL,
			condition_status_concept_id integer NULL,
			stop_reason varchar(20) NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			condition_source_value varchar(50) NULL,
			condition_source_concept_id integer NULL,
			condition_status_source_value varchar(50) NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.drug_exposure (
			drug_exposure_id integer NOT NULL,
			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_exposure_start_date date NOT NULL,
			drug_exposure_start_datetime TIMESTAMP NULL,
			drug_exposure_end_date date NOT NULL,
			drug_exposure_end_datetime TIMESTAMP NULL,
			verbatim_end_date date NULL,
			drug_type_concept_id integer NOT NULL,
			stop_reason varchar(20) NULL,
			refills integer NULL,
			quantity NUMERIC NULL,
			days_supply integer NULL,
			sig TEXT NULL,
			route_concept_id integer NULL,
			lot_number varchar(50) NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			drug_source_value varchar(50) NULL,
			drug_source_concept_id integer NULL,
			route_source_value varchar(50) NULL,
			dose_unit_source_value varchar(50) NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.procedure_occurrence (
			procedure_occurrence_id integer NOT NULL,
			person_id integer NOT NULL,
			procedure_concept_id integer NOT NULL,
			procedure_date date NOT NULL,
			procedure_datetime TIMESTAMP NULL,
			procedure_end_date date NULL,
			procedure_end_datetime TIMESTAMP NULL,
			procedure_type_concept_id integer NOT NULL,
			modifier_concept_id integer NULL,
			quantity integer NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			procedure_source_value varchar(50) NULL,
			procedure_source_concept_id integer NULL,
			modifier_source_value varchar(50) NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.device_exposure (
			device_exposure_id integer NOT NULL,
			person_id integer NOT NULL,
			device_concept_id integer NOT NULL,
			device_exposure_start_date date NOT NULL,
			device_exposure_start_datetime TIMESTAMP NULL,
			device_exposure_end_date date NULL,
			device_exposure_end_datetime TIMESTAMP NULL,
			device_type_concept_id integer NOT NULL,
			unique_device_id varchar(255) NULL,
			production_id varchar(255) NULL,
			quantity integer NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			device_source_value varchar(50) NULL,
			device_source_concept_id integer NULL,
			unit_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			unit_source_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.measurement (
			measurement_id integer NOT NULL,
			person_id integer NOT NULL,
			measurement_concept_id integer NOT NULL,
			measurement_date date NOT NULL,
			measurement_datetime TIMESTAMP NULL,
			measurement_time varchar(10) NULL,
			measurement_type_concept_id integer NOT NULL,
			operator_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			value_as_concept_id integer NULL,
			unit_concept_id integer NULL,
			range_low NUMERIC NULL,
			range_high NUMERIC NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			measurement_source_value varchar(50) NULL,
			measurement_source_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			unit_source_concept_id integer NULL,
			value_source_value varchar(50) NULL,
			measurement_event_id integer NULL,
			meas_event_field_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.observation (
			observation_id integer NOT NULL,
			person_id integer NOT NULL,
			observation_concept_id integer NOT NULL,
			observation_date date NOT NULL,
			observation_datetime TIMESTAMP NULL,
			observation_type_concept_id integer NOT NULL,
			value_as_number NUMERIC NULL,
			value_as_string varchar(60) NULL,
			value_as_concept_id Integer NULL,
			qualifier_concept_id integer NULL,
			unit_concept_id integer NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			observation_source_value varchar(50) NULL,
			observation_source_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			qualifier_source_value varchar(50) NULL,
			value_source_value varchar(50) NULL,
			observation_event_id integer NULL,
			obs_event_field_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.death (
			person_id integer NOT NULL,
			death_date date NOT NULL,
			death_datetime TIMESTAMP NULL,
			death_type_concept_id integer NULL,
			cause_concept_id integer NULL,
			cause_source_value varchar(50) NULL,
			cause_source_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.note (
			note_id integer NOT NULL,
			person_id integer NOT NULL,
			note_date date NOT NULL,
			note_datetime TIMESTAMP NULL,
			note_type_concept_id integer NOT NULL,
			note_class_concept_id integer NOT NULL,
			note_title varchar(250) NULL,
			note_text TEXT NOT NULL,
			encoding_concept_id integer NOT NULL,
			language_concept_id integer NOT NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			note_source_value varchar(50) NULL,
			note_event_id integer NULL,
			note_event_field_concept_id integer NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.note_nlp (
			note_nlp_id integer NOT NULL,
			note_id integer NOT NULL,
			section_concept_id integer NULL,
			snippet varchar(250) NULL,
			"offset" varchar(50) NULL,
			lexical_variant varchar(250) NOT NULL,
			note_nlp_concept_id integer NULL,
			note_nlp_source_concept_id integer NULL,
			nlp_system varchar(250) NULL,
			nlp_date date NOT NULL,
			nlp_datetime TIMESTAMP NULL,
			term_exists varchar(1) NULL,
			term_temporal varchar(50) NULL,
			term_modifiers varchar(2000) NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.specimen (
			specimen_id integer NOT NULL,
			person_id integer NOT NULL,
			specimen_concept_id integer NOT NULL,
			specimen_type_concept_id integer NOT NULL,
			specimen_date date NOT NULL,
			specimen_datetime TIMESTAMP NULL,
			quantity NUMERIC NULL,
			unit_concept_id integer NULL,
			anatomic_site_concept_id integer NULL,
			disease_status_concept_id integer NULL,
			specimen_source_id varchar(50) NULL,
			specimen_source_value varchar(50) NULL,
			unit_source_value varchar(50) NULL,
			anatomic_site_source_value varchar(50) NULL,
			disease_status_source_value varchar(50) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.fact_relationship (
			domain_concept_id_1 integer NOT NULL,
			fact_id_1 integer NOT NULL,
			domain_concept_id_2 integer NOT NULL,
			fact_id_2 integer NOT NULL,
			relationship_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.location (
			location_id integer NOT NULL,
			address_1 varchar(50) NULL,
			address_2 varchar(50) NULL,
			city varchar(50) NULL,
			state varchar(2) NULL,
			zip varchar(9) NULL,
			county varchar(20) NULL,
			location_source_value varchar(50) NULL,
			country_concept_id integer NULL,
			country_source_value varchar(80) NULL,
			latitude NUMERIC NULL,
			longitude NUMERIC NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.care_site (
			care_site_id integer NOT NULL,
			care_site_name varchar(255) NULL,
			place_of_service_concept_id integer NULL,
			location_id integer NULL,
			care_site_source_value varchar(50) NULL,
			place_of_service_source_value varchar(50) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.provider (
			provider_id integer NOT NULL,
			provider_name varchar(255) NULL,
			npi varchar(20) NULL,
			dea varchar(20) NULL,
			specialty_concept_id integer NULL,
			care_site_id integer NULL,
			year_of_birth integer NULL,
			gender_concept_id integer NULL,
			provider_source_value varchar(50) NULL,
			specialty_source_value varchar(50) NULL,
			specialty_source_concept_id integer NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.payer_plan_period (
			payer_plan_period_id integer NOT NULL,
			person_id integer NOT NULL,
			payer_plan_period_start_date date NOT NULL,
			payer_plan_period_end_date date NOT NULL,
			payer_concept_id integer NULL,
			payer_source_value varchar(50) NULL,
			payer_source_concept_id integer NULL,
			plan_concept_id integer NULL,
			plan_source_value varchar(50) NULL,
			plan_source_concept_id integer NULL,
			sponsor_concept_id integer NULL,
			sponsor_source_value varchar(50) NULL,
			sponsor_source_concept_id integer NULL,
			family_source_value varchar(50) NULL,
			stop_reason_concept_id integer NULL,
			stop_reason_source_value varchar(50) NULL,
			stop_reason_source_concept_id integer NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.cost (
			cost_id integer NOT NULL,
			cost_event_id integer NOT NULL,
			cost_domain_id varchar(20) NOT NULL,
			cost_type_concept_id integer NOT NULL,
			currency_concept_id integer NULL,
			total_charge NUMERIC NULL,
			total_cost NUMERIC NULL,
			total_paid NUMERIC NULL,
			paid_by_payer NUMERIC NULL,
			paid_by_patient NUMERIC NULL,
			paid_patient_copay NUMERIC NULL,
			paid_patient_coinsurance NUMERIC NULL,
			paid_patient_deductible NUMERIC NULL,
			paid_by_primary NUMERIC NULL,
			paid_ingredient_cost NUMERIC NULL,
			paid_dispensing_fee NUMERIC NULL,
			payer_plan_period_id integer NULL,
			amount_allowed NUMERIC NULL,
			revenue_code_concept_id integer NULL,
			revenue_code_source_value varchar(50) NULL,
			drg_concept_id integer NULL,
			drg_source_value varchar(3) NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.drug_era (
			drug_era_id integer NOT NULL,
			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_era_start_date date NOT NULL,
			drug_era_end_date date NOT NULL,
			drug_exposure_count integer NULL,
			gap_days integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.dose_era (
			dose_era_id integer NOT NULL,
			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			unit_concept_id integer NOT NULL,
			dose_value NUMERIC NOT NULL,
			dose_era_start_date date NOT NULL,
			dose_era_end_date date NOT NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.condition_era (
			condition_era_id integer NOT NULL,
			person_id integer NOT NULL,
			condition_concept_id integer NOT NULL,
			condition_era_start_date date NOT NULL,
			condition_era_end_date date NOT NULL,
			condition_occurrence_count integer NULL );
--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE t2d_cdm.episode (
			episode_id integer NOT NULL,
			person_id integer NOT NULL,
			episode_concept_id integer NOT NULL,
			episode_start_date date NOT NULL,
			episode_start_datetime TIMESTAMP NULL,
			episode_end_date date NULL,
			episode_end_datetime TIMESTAMP NULL,
			episode_parent_id integer NULL,
			episode_number integer NULL,
			episode_object_concept_id integer NOT NULL,
			episode_type_concept_id integer NOT NULL,
			episode_source_value varchar(50) NULL,
			episode_source_concept_id integer NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.episode_event (
			episode_id integer NOT NULL,
			event_id integer NOT NULL,
			episode_event_field_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.metadata (
			metadata_id integer NOT NULL,
			metadata_concept_id integer NOT NULL,
			metadata_type_concept_id integer NOT NULL,
			name varchar(250) NOT NULL,
			value_as_string varchar(250) NULL,
			value_as_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			metadata_date date NULL,
			metadata_datetime TIMESTAMP NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.cdm_source (
			cdm_source_name varchar(255) NOT NULL,
			cdm_source_abbreviation varchar(25) NOT NULL,
			cdm_holder varchar(255) NOT NULL,
			source_description TEXT NULL,
			source_documentation_reference varchar(255) NULL,
			cdm_etl_reference varchar(255) NULL,
			source_release_date date NOT NULL,
			cdm_release_date date NOT NULL,
			cdm_version varchar(10) NULL,
			cdm_version_concept_id integer NOT NULL,
			vocabulary_version varchar(20) NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.concept (
			concept_id integer NOT NULL,
			concept_name varchar(255) NOT NULL,
			domain_id varchar(20) NOT NULL,
			vocabulary_id varchar(20) NOT NULL,
			concept_class_id varchar(20) NOT NULL,
			standard_concept varchar(1) NULL,
			concept_code varchar(50) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.vocabulary (
			vocabulary_id varchar(20) NOT NULL,
			vocabulary_name varchar(255) NOT NULL,
			vocabulary_reference varchar(255) NULL,
			vocabulary_version varchar(255) NULL,
			vocabulary_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.domain (
			domain_id varchar(20) NOT NULL,
			domain_name varchar(255) NOT NULL,
			domain_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.concept_class (
			concept_class_id varchar(20) NOT NULL,
			concept_class_name varchar(255) NOT NULL,
			concept_class_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.concept_relationship (
			concept_id_1 integer NOT NULL,
			concept_id_2 integer NOT NULL,
			relationship_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.relationship (
			relationship_id varchar(20) NOT NULL,
			relationship_name varchar(255) NOT NULL,
			is_hierarchical varchar(1) NOT NULL,
			defines_ancestry varchar(1) NOT NULL,
			reverse_relationship_id varchar(20) NOT NULL,
			relationship_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.concept_synonym (
			concept_id integer NOT NULL,
			concept_synonym_name varchar(1000) NOT NULL,
			language_concept_id integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.concept_ancestor (
			ancestor_concept_id integer NOT NULL,
			descendant_concept_id integer NOT NULL,
			min_levels_of_separation integer NOT NULL,
			max_levels_of_separation integer NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.source_to_concept_map (
			source_code varchar(50) NOT NULL,
			source_concept_id integer NOT NULL,
			source_vocabulary_id varchar(20) NOT NULL,
			source_code_description varchar(255) NULL,
			target_concept_id integer NOT NULL,
			target_vocabulary_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.drug_strength (
			drug_concept_id integer NOT NULL,
			ingredient_concept_id integer NOT NULL,
			amount_value NUMERIC NULL,
			amount_unit_concept_id integer NULL,
			numerator_value NUMERIC NULL,
			numerator_unit_concept_id integer NULL,
			denominator_value NUMERIC NULL,
			denominator_unit_concept_id integer NULL,
			box_size integer NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.cohort (
			cohort_definition_id integer NOT NULL,
			subject_id integer NOT NULL,
			cohort_start_date date NOT NULL,
			cohort_end_date date NOT NULL );
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE t2d_cdm.cohort_definition (
			cohort_definition_id integer NOT NULL,
			cohort_definition_name varchar(255) NOT NULL,
			cohort_definition_description TEXT NULL,
			definition_type_concept_id integer NOT NULL,
			cohort_definition_syntax TEXT NULL,
			subject_concept_id integer NOT NULL,
			cohort_initiation_date date NULL );
--postgresql CDM Primary Key Constraints for OMOP Common Data Model 5.4
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);
ALTER TABLE t2d_cdm.observation_period  ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT xpk_procedure_occurrence PRIMARY KEY (procedure_occurrence_id);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT xpk_device_exposure PRIMARY KEY (device_exposure_id);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT xpk_observation PRIMARY KEY (observation_id);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT xpk_note PRIMARY KEY (note_id);
ALTER TABLE t2d_cdm.note_nlp  ADD CONSTRAINT xpk_note_nlp PRIMARY KEY (note_nlp_id);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT xpk_specimen PRIMARY KEY (specimen_id);
ALTER TABLE t2d_cdm.location  ADD CONSTRAINT xpk_location PRIMARY KEY (location_id);
ALTER TABLE t2d_cdm.care_site  ADD CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT xpk_provider PRIMARY KEY (provider_id);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT xpk_payer_plan_period PRIMARY KEY (payer_plan_period_id);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT xpk_cost PRIMARY KEY (cost_id);
ALTER TABLE t2d_cdm.drug_era  ADD CONSTRAINT xpk_drug_era PRIMARY KEY (drug_era_id);
ALTER TABLE t2d_cdm.dose_era  ADD CONSTRAINT xpk_dose_era PRIMARY KEY (dose_era_id);
ALTER TABLE t2d_cdm.condition_era  ADD CONSTRAINT xpk_condition_era PRIMARY KEY (condition_era_id);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT xpk_episode PRIMARY KEY (episode_id);
ALTER TABLE t2d_cdm.metadata  ADD CONSTRAINT xpk_metadata PRIMARY KEY (metadata_id);
ALTER TABLE t2d_cdm.concept  ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);
ALTER TABLE t2d_cdm.vocabulary  ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id);
ALTER TABLE t2d_cdm.domain  ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id);
ALTER TABLE t2d_cdm.concept_class  ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);
ALTER TABLE t2d_cdm.relationship  ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id);

--postgresql CDM Foreign Key Constraints for OMOP Common Data Model 5.4
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_race_concept_id FOREIGN KEY (race_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_ethnicity_concept_id FOREIGN KEY (ethnicity_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_location_id FOREIGN KEY (location_id) REFERENCES t2d_cdm.LOCATION (LOCATION_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_care_site_id FOREIGN KEY (care_site_id) REFERENCES t2d_cdm.CARE_SITE (CARE_SITE_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_race_source_concept_id FOREIGN KEY (race_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.person  ADD CONSTRAINT fpk_person_ethnicity_source_concept_id FOREIGN KEY (ethnicity_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation_period  ADD CONSTRAINT fpk_observation_period_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.observation_period  ADD CONSTRAINT fpk_observation_period_period_type_concept_id FOREIGN KEY (period_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_visit_concept_id FOREIGN KEY (visit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_visit_type_concept_id FOREIGN KEY (visit_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_care_site_id FOREIGN KEY (care_site_id) REFERENCES t2d_cdm.CARE_SITE (CARE_SITE_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_visit_source_concept_id FOREIGN KEY (visit_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_occurrence  ADD CONSTRAINT fpk_visit_occurrence_preceding_visit_occurrence_id FOREIGN KEY (preceding_visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_visit_detail_concept_id FOREIGN KEY (visit_detail_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_visit_detail_type_concept_id FOREIGN KEY (visit_detail_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_care_site_id FOREIGN KEY (care_site_id) REFERENCES t2d_cdm.CARE_SITE (CARE_SITE_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_visit_detail_source_concept_id FOREIGN KEY (visit_detail_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_preceding_visit_detail_id FOREIGN KEY (preceding_visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_parent_visit_detail_id FOREIGN KEY (parent_visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.visit_detail  ADD CONSTRAINT fpk_visit_detail_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_condition_concept_id FOREIGN KEY (condition_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_condition_type_concept_id FOREIGN KEY (condition_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_condition_status_concept_id FOREIGN KEY (condition_status_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.condition_occurrence  ADD CONSTRAINT fpk_condition_occurrence_condition_source_concept_id FOREIGN KEY (condition_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_drug_type_concept_id FOREIGN KEY (drug_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_route_concept_id FOREIGN KEY (route_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.drug_exposure  ADD CONSTRAINT fpk_drug_exposure_drug_source_concept_id FOREIGN KEY (drug_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_procedure_concept_id FOREIGN KEY (procedure_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_procedure_type_concept_id FOREIGN KEY (procedure_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_modifier_concept_id FOREIGN KEY (modifier_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.procedure_occurrence  ADD CONSTRAINT fpk_procedure_occurrence_procedure_source_concept_id FOREIGN KEY (procedure_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_device_concept_id FOREIGN KEY (device_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_device_type_concept_id FOREIGN KEY (device_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_device_source_concept_id FOREIGN KEY (device_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.device_exposure  ADD CONSTRAINT fpk_device_exposure_unit_source_concept_id FOREIGN KEY (unit_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_measurement_concept_id FOREIGN KEY (measurement_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_measurement_type_concept_id FOREIGN KEY (measurement_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_operator_concept_id FOREIGN KEY (operator_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_measurement_source_concept_id FOREIGN KEY (measurement_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_unit_source_concept_id FOREIGN KEY (unit_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.measurement  ADD CONSTRAINT fpk_measurement_meas_event_field_concept_id FOREIGN KEY (meas_event_field_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_observation_concept_id FOREIGN KEY (observation_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_observation_type_concept_id FOREIGN KEY (observation_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_qualifier_concept_id FOREIGN KEY (qualifier_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_observation_source_concept_id FOREIGN KEY (observation_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.observation  ADD CONSTRAINT fpk_observation_obs_event_field_concept_id FOREIGN KEY (obs_event_field_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.death  ADD CONSTRAINT fpk_death_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.death  ADD CONSTRAINT fpk_death_death_type_concept_id FOREIGN KEY (death_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.death  ADD CONSTRAINT fpk_death_cause_concept_id FOREIGN KEY (cause_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.death  ADD CONSTRAINT fpk_death_cause_source_concept_id FOREIGN KEY (cause_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_note_type_concept_id FOREIGN KEY (note_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_note_class_concept_id FOREIGN KEY (note_class_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_encoding_concept_id FOREIGN KEY (encoding_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_language_concept_id FOREIGN KEY (language_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_provider_id FOREIGN KEY (provider_id) REFERENCES t2d_cdm.PROVIDER (PROVIDER_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES t2d_cdm.VISIT_OCCURRENCE (VISIT_OCCURRENCE_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES t2d_cdm.VISIT_DETAIL (VISIT_DETAIL_ID);
ALTER TABLE t2d_cdm.note  ADD CONSTRAINT fpk_note_note_event_field_concept_id FOREIGN KEY (note_event_field_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note_nlp  ADD CONSTRAINT fpk_note_nlp_section_concept_id FOREIGN KEY (section_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note_nlp  ADD CONSTRAINT fpk_note_nlp_note_nlp_concept_id FOREIGN KEY (note_nlp_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.note_nlp  ADD CONSTRAINT fpk_note_nlp_note_nlp_source_concept_id FOREIGN KEY (note_nlp_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_specimen_concept_id FOREIGN KEY (specimen_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_specimen_type_concept_id FOREIGN KEY (specimen_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_anatomic_site_concept_id FOREIGN KEY (anatomic_site_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.specimen  ADD CONSTRAINT fpk_specimen_disease_status_concept_id FOREIGN KEY (disease_status_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.fact_relationship  ADD CONSTRAINT fpk_fact_relationship_domain_concept_id_1 FOREIGN KEY (domain_concept_id_1) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.fact_relationship  ADD CONSTRAINT fpk_fact_relationship_domain_concept_id_2 FOREIGN KEY (domain_concept_id_2) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.fact_relationship  ADD CONSTRAINT fpk_fact_relationship_relationship_concept_id FOREIGN KEY (relationship_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.location  ADD CONSTRAINT fpk_location_country_concept_id FOREIGN KEY (country_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.care_site  ADD CONSTRAINT fpk_care_site_place_of_service_concept_id FOREIGN KEY (place_of_service_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.care_site  ADD CONSTRAINT fpk_care_site_location_id FOREIGN KEY (location_id) REFERENCES t2d_cdm.LOCATION (LOCATION_ID);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT fpk_provider_specialty_concept_id FOREIGN KEY (specialty_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT fpk_provider_care_site_id FOREIGN KEY (care_site_id) REFERENCES t2d_cdm.CARE_SITE (CARE_SITE_ID);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT fpk_provider_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT fpk_provider_specialty_source_concept_id FOREIGN KEY (specialty_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.provider  ADD CONSTRAINT fpk_provider_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_payer_concept_id FOREIGN KEY (payer_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_payer_source_concept_id FOREIGN KEY (payer_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_plan_concept_id FOREIGN KEY (plan_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_plan_source_concept_id FOREIGN KEY (plan_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_sponsor_concept_id FOREIGN KEY (sponsor_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_sponsor_source_concept_id FOREIGN KEY (sponsor_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_stop_reason_concept_id FOREIGN KEY (stop_reason_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.payer_plan_period  ADD CONSTRAINT fpk_payer_plan_period_stop_reason_source_concept_id FOREIGN KEY (stop_reason_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT fpk_cost_cost_domain_id FOREIGN KEY (cost_domain_id) REFERENCES t2d_cdm.DOMAIN (DOMAIN_ID);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT fpk_cost_cost_type_concept_id FOREIGN KEY (cost_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT fpk_cost_currency_concept_id FOREIGN KEY (currency_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT fpk_cost_revenue_code_concept_id FOREIGN KEY (revenue_code_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cost  ADD CONSTRAINT fpk_cost_drg_concept_id FOREIGN KEY (drg_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_era  ADD CONSTRAINT fpk_drug_era_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.drug_era  ADD CONSTRAINT fpk_drug_era_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.dose_era  ADD CONSTRAINT fpk_dose_era_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.dose_era  ADD CONSTRAINT fpk_dose_era_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.dose_era  ADD CONSTRAINT fpk_dose_era_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.condition_era  ADD CONSTRAINT fpk_condition_era_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.condition_era  ADD CONSTRAINT fpk_condition_era_condition_concept_id FOREIGN KEY (condition_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT fpk_episode_person_id FOREIGN KEY (person_id) REFERENCES t2d_cdm.PERSON (PERSON_ID);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT fpk_episode_episode_concept_id FOREIGN KEY (episode_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT fpk_episode_episode_object_concept_id FOREIGN KEY (episode_object_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT fpk_episode_episode_type_concept_id FOREIGN KEY (episode_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.episode  ADD CONSTRAINT fpk_episode_episode_source_concept_id FOREIGN KEY (episode_source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.episode_event  ADD CONSTRAINT fpk_episode_event_episode_id FOREIGN KEY (episode_id) REFERENCES t2d_cdm.EPISODE (EPISODE_ID);
ALTER TABLE t2d_cdm.episode_event  ADD CONSTRAINT fpk_episode_event_episode_event_field_concept_id FOREIGN KEY (episode_event_field_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.metadata  ADD CONSTRAINT fpk_metadata_metadata_concept_id FOREIGN KEY (metadata_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.metadata  ADD CONSTRAINT fpk_metadata_metadata_type_concept_id FOREIGN KEY (metadata_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.metadata  ADD CONSTRAINT fpk_metadata_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cdm_source  ADD CONSTRAINT fpk_cdm_source_cdm_version_concept_id FOREIGN KEY (cdm_version_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept  ADD CONSTRAINT fpk_concept_domain_id FOREIGN KEY (domain_id) REFERENCES t2d_cdm.DOMAIN (DOMAIN_ID);
ALTER TABLE t2d_cdm.concept  ADD CONSTRAINT fpk_concept_vocabulary_id FOREIGN KEY (vocabulary_id) REFERENCES t2d_cdm.VOCABULARY (VOCABULARY_ID);
ALTER TABLE t2d_cdm.concept  ADD CONSTRAINT fpk_concept_concept_class_id FOREIGN KEY (concept_class_id) REFERENCES t2d_cdm.CONCEPT_CLASS (CONCEPT_CLASS_ID);
ALTER TABLE t2d_cdm.vocabulary  ADD CONSTRAINT fpk_vocabulary_vocabulary_concept_id FOREIGN KEY (vocabulary_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.domain  ADD CONSTRAINT fpk_domain_domain_concept_id FOREIGN KEY (domain_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_class  ADD CONSTRAINT fpk_concept_class_concept_class_concept_id FOREIGN KEY (concept_class_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_relationship  ADD CONSTRAINT fpk_concept_relationship_concept_id_1 FOREIGN KEY (concept_id_1) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_relationship  ADD CONSTRAINT fpk_concept_relationship_concept_id_2 FOREIGN KEY (concept_id_2) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_relationship  ADD CONSTRAINT fpk_concept_relationship_relationship_id FOREIGN KEY (relationship_id) REFERENCES t2d_cdm.RELATIONSHIP (RELATIONSHIP_ID);
ALTER TABLE t2d_cdm.relationship  ADD CONSTRAINT fpk_relationship_relationship_concept_id FOREIGN KEY (relationship_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_synonym  ADD CONSTRAINT fpk_concept_synonym_concept_id FOREIGN KEY (concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_synonym  ADD CONSTRAINT fpk_concept_synonym_language_concept_id FOREIGN KEY (language_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_ancestor  ADD CONSTRAINT fpk_concept_ancestor_ancestor_concept_id FOREIGN KEY (ancestor_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.concept_ancestor  ADD CONSTRAINT fpk_concept_ancestor_descendant_concept_id FOREIGN KEY (descendant_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.source_to_concept_map  ADD CONSTRAINT fpk_source_to_concept_map_source_concept_id FOREIGN KEY (source_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.source_to_concept_map  ADD CONSTRAINT fpk_source_to_concept_map_target_concept_id FOREIGN KEY (target_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.source_to_concept_map  ADD CONSTRAINT fpk_source_to_concept_map_target_vocabulary_id FOREIGN KEY (target_vocabulary_id) REFERENCES t2d_cdm.VOCABULARY (VOCABULARY_ID);
ALTER TABLE t2d_cdm.drug_strength  ADD CONSTRAINT fpk_drug_strength_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_strength  ADD CONSTRAINT fpk_drug_strength_ingredient_concept_id FOREIGN KEY (ingredient_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_strength  ADD CONSTRAINT fpk_drug_strength_amount_unit_concept_id FOREIGN KEY (amount_unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_strength  ADD CONSTRAINT fpk_drug_strength_numerator_unit_concept_id FOREIGN KEY (numerator_unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.drug_strength  ADD CONSTRAINT fpk_drug_strength_denominator_unit_concept_id FOREIGN KEY (denominator_unit_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cohort_definition  ADD CONSTRAINT fpk_cohort_definition_definition_type_concept_id FOREIGN KEY (definition_type_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);
ALTER TABLE t2d_cdm.cohort_definition  ADD CONSTRAINT fpk_cohort_definition_subject_concept_id FOREIGN KEY (subject_concept_id) REFERENCES t2d_cdm.CONCEPT (CONCEPT_ID);

/*postgresql OMOP CDM Indices
  There are no unique indices created because it is assumed that the primary key constraints have been run prior to
  implementing indices.
*/
/************************
Standardized clinical data
************************/
CREATE INDEX idx_person_id  ON t2d_cdm.person  (person_id ASC);
CLUSTER t2d_cdm.person  USING idx_person_id ;
CREATE INDEX idx_gender ON t2d_cdm.person (gender_concept_id ASC);
CREATE INDEX idx_observation_period_id_1  ON t2d_cdm.observation_period  (person_id ASC);
CLUSTER t2d_cdm.observation_period  USING idx_observation_period_id_1 ;
CREATE INDEX idx_visit_person_id_1  ON t2d_cdm.visit_occurrence  (person_id ASC);
CLUSTER t2d_cdm.visit_occurrence  USING idx_visit_person_id_1 ;
CREATE INDEX idx_visit_concept_id_1 ON t2d_cdm.visit_occurrence (visit_concept_id ASC);
CREATE INDEX idx_visit_det_person_id_1  ON t2d_cdm.visit_detail  (person_id ASC);
CLUSTER t2d_cdm.visit_detail  USING idx_visit_det_person_id_1 ;
CREATE INDEX idx_visit_det_concept_id_1 ON t2d_cdm.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_det_occ_id ON t2d_cdm.visit_detail (visit_occurrence_id ASC);
CREATE INDEX idx_condition_person_id_1  ON t2d_cdm.condition_occurrence  (person_id ASC);
CLUSTER t2d_cdm.condition_occurrence  USING idx_condition_person_id_1 ;
CREATE INDEX idx_condition_concept_id_1 ON t2d_cdm.condition_occurrence (condition_concept_id ASC);
CREATE INDEX idx_condition_visit_id_1 ON t2d_cdm.condition_occurrence (visit_occurrence_id ASC);
CREATE INDEX idx_drug_person_id_1  ON t2d_cdm.drug_exposure  (person_id ASC);
CLUSTER t2d_cdm.drug_exposure  USING idx_drug_person_id_1 ;
CREATE INDEX idx_drug_concept_id_1 ON t2d_cdm.drug_exposure (drug_concept_id ASC);
CREATE INDEX idx_drug_visit_id_1 ON t2d_cdm.drug_exposure (visit_occurrence_id ASC);
CREATE INDEX idx_procedure_person_id_1  ON t2d_cdm.procedure_occurrence  (person_id ASC);
CLUSTER t2d_cdm.procedure_occurrence  USING idx_procedure_person_id_1 ;
CREATE INDEX idx_procedure_concept_id_1 ON t2d_cdm.procedure_occurrence (procedure_concept_id ASC);
CREATE INDEX idx_procedure_visit_id_1 ON t2d_cdm.procedure_occurrence (visit_occurrence_id ASC);
CREATE INDEX idx_device_person_id_1  ON t2d_cdm.device_exposure  (person_id ASC);
CLUSTER t2d_cdm.device_exposure  USING idx_device_person_id_1 ;
CREATE INDEX idx_device_concept_id_1 ON t2d_cdm.device_exposure (device_concept_id ASC);
CREATE INDEX idx_device_visit_id_1 ON t2d_cdm.device_exposure (visit_occurrence_id ASC);
CREATE INDEX idx_measurement_person_id_1  ON t2d_cdm.measurement  (person_id ASC);
CLUSTER t2d_cdm.measurement  USING idx_measurement_person_id_1 ;
CREATE INDEX idx_measurement_concept_id_1 ON t2d_cdm.measurement (measurement_concept_id ASC);
CREATE INDEX idx_measurement_visit_id_1 ON t2d_cdm.measurement (visit_occurrence_id ASC);
CREATE INDEX idx_observation_person_id_1  ON t2d_cdm.observation  (person_id ASC);
CLUSTER t2d_cdm.observation  USING idx_observation_person_id_1 ;
CREATE INDEX idx_observation_concept_id_1 ON t2d_cdm.observation (observation_concept_id ASC);
CREATE INDEX idx_observation_visit_id_1 ON t2d_cdm.observation (visit_occurrence_id ASC);
CREATE INDEX idx_death_person_id_1  ON t2d_cdm.death  (person_id ASC);
CLUSTER t2d_cdm.death  USING idx_death_person_id_1 ;
CREATE INDEX idx_note_person_id_1  ON t2d_cdm.note  (person_id ASC);
CLUSTER t2d_cdm.note  USING idx_note_person_id_1 ;
CREATE INDEX idx_note_concept_id_1 ON t2d_cdm.note (note_type_concept_id ASC);
CREATE INDEX idx_note_visit_id_1 ON t2d_cdm.note (visit_occurrence_id ASC);
CREATE INDEX idx_note_nlp_note_id_1  ON t2d_cdm.note_nlp  (note_id ASC);
CLUSTER t2d_cdm.note_nlp  USING idx_note_nlp_note_id_1 ;
CREATE INDEX idx_note_nlp_concept_id_1 ON t2d_cdm.note_nlp (note_nlp_concept_id ASC);
CREATE INDEX idx_specimen_person_id_1  ON t2d_cdm.specimen  (person_id ASC);
CLUSTER t2d_cdm.specimen  USING idx_specimen_person_id_1 ;
CREATE INDEX idx_specimen_concept_id_1 ON t2d_cdm.specimen (specimen_concept_id ASC);
CREATE INDEX idx_fact_relationship_id1 ON t2d_cdm.fact_relationship (domain_concept_id_1 ASC);
CREATE INDEX idx_fact_relationship_id2 ON t2d_cdm.fact_relationship (domain_concept_id_2 ASC);
CREATE INDEX idx_fact_relationship_id3 ON t2d_cdm.fact_relationship (relationship_concept_id ASC);
/************************
Standardized health system data
************************/
CREATE INDEX idx_location_id_1  ON t2d_cdm.location  (location_id ASC);
CLUSTER t2d_cdm.location  USING idx_location_id_1 ;
CREATE INDEX idx_care_site_id_1  ON t2d_cdm.care_site  (care_site_id ASC);
CLUSTER t2d_cdm.care_site  USING idx_care_site_id_1 ;
CREATE INDEX idx_provider_id_1  ON t2d_cdm.provider  (provider_id ASC);
CLUSTER t2d_cdm.provider  USING idx_provider_id_1 ;
/************************
Standardized health economics
************************/
CREATE INDEX idx_period_person_id_1  ON t2d_cdm.payer_plan_period  (person_id ASC);
CLUSTER t2d_cdm.payer_plan_period  USING idx_period_person_id_1 ;
CREATE INDEX idx_cost_event_id  ON t2d_cdm.cost (cost_event_id ASC);
/************************
Standardized derived elements
************************/
CREATE INDEX idx_drug_era_person_id_1  ON t2d_cdm.drug_era  (person_id ASC);
CLUSTER t2d_cdm.drug_era  USING idx_drug_era_person_id_1 ;
CREATE INDEX idx_drug_era_concept_id_1 ON t2d_cdm.drug_era (drug_concept_id ASC);
CREATE INDEX idx_dose_era_person_id_1  ON t2d_cdm.dose_era  (person_id ASC);
CLUSTER t2d_cdm.dose_era  USING idx_dose_era_person_id_1 ;
CREATE INDEX idx_dose_era_concept_id_1 ON t2d_cdm.dose_era (drug_concept_id ASC);
CREATE INDEX idx_condition_era_person_id_1  ON t2d_cdm.condition_era  (person_id ASC);
CLUSTER t2d_cdm.condition_era  USING idx_condition_era_person_id_1 ;
CREATE INDEX idx_condition_era_concept_id_1 ON t2d_cdm.condition_era (condition_concept_id ASC);
/**************************
Standardized meta-data
***************************/
CREATE INDEX idx_metadata_concept_id_1  ON t2d_cdm.metadata  (metadata_concept_id ASC);
CLUSTER t2d_cdm.metadata  USING idx_metadata_concept_id_1 ;
/**************************
Standardized vocabularies
***************************/
CREATE INDEX idx_concept_concept_id  ON t2d_cdm.concept  (concept_id ASC);
CLUSTER t2d_cdm.concept  USING idx_concept_concept_id ;
CREATE INDEX idx_concept_code ON t2d_cdm.concept (concept_code ASC);
CREATE INDEX idx_concept_vocabluary_id ON t2d_cdm.concept (vocabulary_id ASC);
CREATE INDEX idx_concept_domain_id ON t2d_cdm.concept (domain_id ASC);
CREATE INDEX idx_concept_class_id ON t2d_cdm.concept (concept_class_id ASC);
CREATE INDEX idx_vocabulary_vocabulary_id  ON t2d_cdm.vocabulary  (vocabulary_id ASC);
CLUSTER t2d_cdm.vocabulary  USING idx_vocabulary_vocabulary_id ;
CREATE INDEX idx_domain_domain_id  ON t2d_cdm.domain  (domain_id ASC);
CLUSTER t2d_cdm.domain  USING idx_domain_domain_id ;
CREATE INDEX idx_concept_class_class_id  ON t2d_cdm.concept_class  (concept_class_id ASC);
CLUSTER t2d_cdm.concept_class  USING idx_concept_class_class_id ;
CREATE INDEX idx_concept_relationship_id_1  ON t2d_cdm.concept_relationship  (concept_id_1 ASC);
CLUSTER t2d_cdm.concept_relationship  USING idx_concept_relationship_id_1 ;
CREATE INDEX idx_concept_relationship_id_2 ON t2d_cdm.concept_relationship (concept_id_2 ASC);
CREATE INDEX idx_concept_relationship_id_3 ON t2d_cdm.concept_relationship (relationship_id ASC);
CREATE INDEX idx_relationship_rel_id  ON t2d_cdm.relationship  (relationship_id ASC);
CLUSTER t2d_cdm.relationship  USING idx_relationship_rel_id ;
CREATE INDEX idx_concept_synonym_id  ON t2d_cdm.concept_synonym  (concept_id ASC);
CLUSTER t2d_cdm.concept_synonym  USING idx_concept_synonym_id ;
CREATE INDEX idx_concept_ancestor_id_1  ON t2d_cdm.concept_ancestor  (ancestor_concept_id ASC);
CLUSTER t2d_cdm.concept_ancestor  USING idx_concept_ancestor_id_1 ;
CREATE INDEX idx_concept_ancestor_id_2 ON t2d_cdm.concept_ancestor (descendant_concept_id ASC);
CREATE INDEX idx_source_to_concept_map_3  ON t2d_cdm.source_to_concept_map  (target_concept_id ASC);
CLUSTER t2d_cdm.source_to_concept_map  USING idx_source_to_concept_map_3 ;
CREATE INDEX idx_source_to_concept_map_1 ON t2d_cdm.source_to_concept_map (source_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_2 ON t2d_cdm.source_to_concept_map (target_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_c ON t2d_cdm.source_to_concept_map (source_code ASC);
CREATE INDEX idx_drug_strength_id_1  ON t2d_cdm.drug_strength  (drug_concept_id ASC);
CLUSTER t2d_cdm.drug_strength  USING idx_drug_strength_id_1 ;
CREATE INDEX idx_drug_strength_id_2 ON t2d_cdm.drug_strength (ingredient_concept_id ASC);
--Additional v6.0 indices
--CREATE CLUSTERED INDEX idx_survey_person_id_1 ON t2d_cdm.survey_conduct (person_id ASC);
--CREATE CLUSTERED INDEX idx_episode_person_id_1 ON t2d_cdm.episode (person_id ASC);
--CREATE INDEX idx_episode_concept_id_1 ON t2d_cdm.episode (episode_concept_id ASC);
--CREATE CLUSTERED INDEX idx_episode_event_id_1 ON t2d_cdm.episode_event (episode_id ASC);
--CREATE INDEX idx_ee_field_concept_id_1 ON t2d_cdm.episode_event (event_field_concept_id ASC);



