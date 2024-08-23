-- SQL dialect: DuckDB
-- Query to get the coverage of MeSH terms in AACT for conditions and
-- interventions:

ATTACH '' AS pg (TYPE postgres);

WITH
total_studies AS (
	SELECT
		COUNT(nct_id) AS total_count
	FROM pg.ctgov.studies
),
intervention_studies AS (
	SELECT
		COUNT(DISTINCT nct_id) AS intervention_count
	FROM pg.ctgov.browse_interventions
	-- WHERE mesh_type = 'mesh-list'
),
condition_studies AS (
	SELECT
		COUNT(DISTINCT nct_id) AS condition_count
	FROM pg.ctgov.browse_conditions
	-- WHERE mesh_type = 'mesh-list'
)
SELECT
	intervention_studies.intervention_count / total_studies.total_count AS derived_intervention_ratio,
	condition_studies.condition_count       / total_studies.total_count AS derived_condition_ratio
FROM
	total_studies,
	intervention_studies,
	condition_studies
;
