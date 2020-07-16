DROP VIEW IF EXISTS species_202001.v_lt_species_countries CASCADE;
CREATE VIEW species_202001.v_lt_species_countries AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
code::text
FROM species_202001.countries
WHERE presence::text IN ('Extant','Possibly Extant')--,'Possibly Extinct')--,'Presence Uncertain')
AND origin::text IN ('Native','Reintroduced')
AND (seasonality::text IS NULL OR seasonality::text ILIKE '%Resident%' OR seasonality::text ILIKE '%Breeding Season%' OR seasonality::text ILIKE '%Non-Breeding Season%')
ORDER BY (internaltaxonid)::bigint,code::text;

------ LT_SPECIES_COUNTRIES ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_countries CASCADE; 
CREATE TABLE species.lt_species_countries AS SELECT * FROM species_202001.v_lt_species_countries
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;
---- DT_COUNTRY_ENDEMICS
DROP TABLE IF EXISTS species.dt_country_endemics CASCADE;
CREATE TABLE species.dt_country_endemics AS
SELECT id_no,code country,CARDINALITY(code) n_country,CASE CARDINALITY(code) WHEN 1 THEN 1::bool ELSE 0::bool END endemic
FROM (
	SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) code
	FROM species.lt_species_countries
	GROUP by id_no ORDER BY id_no
	) a
ORDER BY id_no,country;

--- CHECK RESULTS
WITH 
a AS (
SELECT *
FROM species.mt_attributes a
LEFT JOIN species.dt_country_endemics b USING(id_no)
),
b AS (SELECT internaltaxonid::bigint id_no,* FROM species_202001.countries)
SELECT * FROM b WHERE id_no IN (SELECT DISTINCT id_no FROM a WHERE country IS NULL)

