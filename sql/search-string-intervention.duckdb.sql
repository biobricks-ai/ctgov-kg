-- SQL dialect: DuckDB
-- DuckDB query to find trials with a particular intervention across several
-- text columns in the AACT database:

ATTACH '' AS pg (TYPE postgres);

-- https://pubchem.ncbi.nlm.nih.gov/compound/15951529#section=ClinicalTrials-gov&fullscreen=true
-- PubChem: 266 records
-- AACT   : 274 records
WITH
search_string AS (
	-- NOTE using % on each side is a non-strict search
	SELECT '%enzalutamide%' AS search_term
),
interventions_ids AS (
	SELECT DISTINCT interventions.nct_id AS id
	FROM pg.ctgov.interventions, search_string
	WHERE
		lower(name) LIKE search_string.search_term
),
intervention_other_names_ids AS (
	SELECT DISTINCT intervention_other_names.nct_id AS id
	FROM pg.ctgov.intervention_other_names, search_string
	WHERE
		lower(name) LIKE search_string.search_term
),
browse_interventions_ids AS (
	SELECT DISTINCT browse_interventions.nct_id AS id
	FROM pg.ctgov.browse_interventions, search_string
	WHERE
		downcase_mesh_term like search_string.search_term
),
detailed_descriptions_ids AS (
	select distinct detailed_descriptions.nct_id AS id
	FROM pg.ctgov.detailed_descriptions, search_string
	WHERE
		lower(description) LIKE search_string.search_term
),
studies_ids AS (
	SELECT DISTINCT studies.nct_id AS id
	FROM pg.ctgov.studies, search_string
	WHERE
		lower(official_title) LIKE search_string.search_term
)
SELECT DISTINCT id
FROM (
    SELECT id FROM interventions_ids
    -- UNION
    -- SELECT id FROM intervention_other_names_ids
    -- UNION
    -- SELECT id FROM browse_interventions_ids
    -- UNION
    -- SELECT id FROM detailed_descriptions_ids
    -- UNION
    -- SELECT id FROM studies_ids
) AS combined_ids;
