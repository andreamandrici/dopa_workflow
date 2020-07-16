DROP TABLE IF EXISTS lt_species_countries CASCADE; 
CREATE TEMPORARY TABLE lt_species_countries AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
code::text
FROM species_202001.countries
-- CHECK THE ALTERNATIVES!	
--WHERE presence::text IN ('Extant','Possibly Extant','Possibly Extinct','Presence Uncertain')
--WHERE presence::text IN ('Extant','Possibly Extant','Possibly Extinct')
WHERE presence::text IN ('Extant','Possibly Extant')
AND origin::text IN ('Native','Reintroduced')
-- CHECK THE ALTERNATIVES!	
-- AND (seasonality::text IS NULL OR seasonality::text ILIKE '%Resident%' OR seasonality::text ILIKE '%Breeding Season%' OR seasonality::text ILIKE '%Non-Breeding Season%')
AND (seasonality::text ILIKE '%Resident%' OR seasonality::text ILIKE '%Breeding Season%' OR seasonality::text ILIKE '%Non-Breeding Season%')
ORDER BY (internaltaxonid)::bigint,code::text)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

---- DT_SPECIES_COUNTRY_ENDEMICS
DROP TABLE IF EXISTS dt_species_country_endemics CASCADE;
CREATE TEMPORARY TABLE dt_species_country_endemics AS
SELECT id_no,code country,CARDINALITY(code) n_country,CASE CARDINALITY(code) WHEN 1 THEN 1::bool ELSE 0::bool END endemic
FROM (
	SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) code
	FROM lt_species_countries
	GROUP by id_no ORDER BY id_no
	) a
ORDER BY id_no,country;
--- CHECK RESULTS
WITH 
a AS (
SELECT *
FROM species.mt_attributes a
LEFT JOIN dt_species_country_endemics b USING(id_no)
),
b AS (
SELECT internaltaxonid::bigint id_no,scientificname::text binomial,code::text,name::text,presence::text,origin::text,seasonality::text
FROM species_202001.countries
)
-----CHECK THE FOLLOWING ALTERNATIVES!
-- SELECT * FROM a -----CHECK THE IMPACT ON ENDEMICS CALCULATIONS
SELECT * FROM b WHERE id_no IN (SELECT DISTINCT id_no FROM a WHERE country IS NULL) ORDER BY id_no;-----CHECK THE IMPACT ON THE EXCLUDED SPECIES
