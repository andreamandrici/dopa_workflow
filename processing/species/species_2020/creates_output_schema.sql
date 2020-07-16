-- CREATE SCHEMA -------------------------------------------------------
DROP SCHEMA IF EXISTS species CASCADE; CREATE SCHEMA species;

------ MT_ATTRIBUTES ---------------------------------------------------
DROP TABLE IF EXISTS species.mt_attributes CASCADE;
CREATE TABLE species.mt_attributes AS
SELECT * FROM species_202001.attributes ORDER BY id_no;

----------CATEGORIES----------------------------------------------------
------ MT_CATEGORIES ---------------------------------------------------
DROP TABLE IF EXISTS species.mt_categories CASCADE;
CREATE TABLE species.mt_categories AS
SELECT
CASE a.redlistcategory
WHEN 'Extinct'::text THEN 'EX'::text
WHEN 'Extinct in the Wild'::text THEN 'EW'::text
WHEN 'Critically Endangered'::text THEN 'CR'::text
WHEN 'Endangered'::text THEN 'EN'::text
WHEN 'Vulnerable'::text THEN 'VU'::text
WHEN 'Extinct in the Wild'::text THEN 'EW'::text
WHEN 'Near Threatened'::text THEN 'NT'::text
WHEN 'Least Concern'::text THEN 'LC'::text
WHEN 'Data Deficient'::text THEN 'DD'::text
WHEN 'Lower Risk/conservation dependent'::text THEN 'LR/cd'::text
WHEN 'Lower Risk/near threatened'::text THEN 'LR/nt'::text
WHEN 'Lower Risk/near threatened'::text THEN 'LR/nt'::text
WHEN 'Regionally Extinct'::text THEN 'rEX'::text
WHEN 'Not Applicable'::text THEN 'NA'::text
ELSE NULL::text
END AS code,
a.redlistcategory AS name
FROM (SELECT DISTINCT redlistcategory::text FROM species_202001.assessments) a
ORDER BY code;
---- DT_THREATENED
DROP TABLE IF EXISTS species.dt_species_threatened CASCADE;
CREATE TABLE species.dt_species_threatened AS
SELECT id_no,true::bool threatened
FROM species.mt_attributes
WHERE category IN ('CR','EN','VU')
ORDER BY id_no;

--------- COUNTRIES ----------------------------------------------------
------ MT_COUNTRIES ----------------------------------------------------
DROP TABLE IF EXISTS species.mt_countries CASCADE;
CREATE TABLE species.mt_countries AS
WITH
countries AS (
SELECT DISTINCT
code::text,
name::text
FROM species_202001.countries
ORDER BY code::text
)
SELECT
code,name
FROM countries ORDER BY code;

------ LT_SPECIES_COUNTRIES --------------------------------------------
DROP TABLE IF EXISTS species.lt_species_countries CASCADE; 
CREATE TABLE species.lt_species_countries AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
code::text
FROM species_202001.countries
-- WHERE presence::text IN ('Extant','Possibly Extant')--,'Possibly Extinct')--,'Presence Uncertain') -- CHECK THE ALTERNATIVES!
WHERE presence::text IN ('Extant','Possibly Extant','Possibly Extinct','Presence Uncertain')
AND origin::text IN ('Native','Reintroduced')
AND (seasonality::text IS NULL OR seasonality::text ILIKE '%Resident%' OR seasonality::text ILIKE '%Breeding Season%' OR seasonality::text ILIKE '%Non-Breeding Season%')
ORDER BY (internaltaxonid)::bigint,code::text)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

---- DT_COUNTRY_ENDEMICS
DROP TABLE IF EXISTS species.dt_species_country_endemics CASCADE;
CREATE TABLE species.dt_species_country_endemics AS
SELECT id_no,code country,CARDINALITY(code) n_country,CASE CARDINALITY(code) WHEN 1 THEN 1::bool ELSE 0::bool END endemic
FROM (
	SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) code
	FROM species.lt_species_countries
	GROUP by id_no ORDER BY id_no
	) a
ORDER BY id_no,country;

------ CONSERVATION_NEEDED ---------------------------------------------
------ MT_CONSERVATION_NEEDED -------------------------------------------
DROP TABLE IF EXISTS species.mt_conservation_needed CASCADE; 
CREATE TABLE species.mt_conservation_needed AS
WITH
a AS (
SELECT DISTINCT
code, name
FROM species_202001.conservation_needed
ORDER BY code
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS conservation_needed_cl1,
(split_part((a.code)::text, '.'::text, 2))::integer AS conservation_needed_cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS conservation_needed_cl3,
a.code,
a.name
FROM a
),
conservation_needed AS (
SELECT
b.conservation_needed_cl1,
b.conservation_needed_cl2,
b.conservation_needed_cl3,
b.code::text,
b.name::text
FROM b
ORDER BY b.conservation_needed_cl1, b.conservation_needed_cl2, b.conservation_needed_cl3
)
SELECT
conservation_needed_cl1,
conservation_needed_cl2,
conservation_needed_cl3,
code,
name
FROM conservation_needed
ORDER BY code;

------ LT_SPECIES_CONSERVATION_NEEDED ----------------------------------
DROP TABLE IF EXISTS species.lt_species_conservation_needed CASCADE; 
CREATE TABLE species.lt_species_conservation_needed AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.conservation_needed
ORDER BY (conservation_needed.internaltaxonid)::bigint, (conservation_needed.code)::text
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

------ ---HABITATS ---------------------------------------........------
------ MT_HABITATS ---------------------------------------........------
DROP TABLE IF EXISTS species.mt_habitats CASCADE; 
CREATE TABLE species.mt_habitats AS
WITH
a AS (
SELECT DISTINCT
code::text,
name::text
FROM species_202001.habitats
ORDER BY code::text
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS habitats_cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS habitats_cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS habitats_cl3,
a.code,
a.name
FROM a
),
habitats AS (
SELECT
b.habitats_cl1,
b.habitats_cl2,
b.habitats_cl3,
b.code,
b.name
FROM b
ORDER BY b.habitats_cl1, b.habitats_cl2, b.habitats_cl3
)
SELECT
habitats_cl1,
habitats_cl2,
habitats_cl3,
code,
name
FROM habitats
ORDER BY code;

------ LT_SPECIES_HABITATS ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_habitats CASCADE; 
CREATE TABLE species.lt_species_habitats AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.habitats
ORDER BY (internaltaxonid)::bigint, (code)::text
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

--------- RESEARCH_NEEDED ----------------------------------------------
------ MT_RESEARCH_NEEDED ----------------------------------------------
DROP TABLE IF EXISTS species.mt_research_needed CASCADE; 
CREATE TABLE species.mt_research_needed AS
WITH
a AS (
SELECT DISTINCT
code::text,
name::text
FROM species_202001.research_needed
ORDER BY code::text
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS research_needed_cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS research_needed_cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS research_needed_cl3,
a.code,
a.name
FROM a
),
research_needed AS (
SELECT
b.research_needed_cl1,
b.research_needed_cl2,
b.research_needed_cl3,
b.code,
b.name
FROM b
ORDER BY b.research_needed_cl1, b.research_needed_cl2, b.research_needed_cl3
)
SELECT
research_needed_cl1,
research_needed_cl2,
research_needed_cl3,
code,
name
FROM research_needed
ORDER BY code;

------ LT_SPECIES_RESEARCH_NEEDED ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_research_needed CASCADE; 
CREATE TABLE species.lt_species_research_needed AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.research_needed
ORDER BY (internaltaxonid)::bigint, (code)::text
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;




--------- STRESSES -----------------------------------------------------
------ MT_STRESSES -----------------------------------------------------
DROP TABLE IF EXISTS species.mt_stresses CASCADE; 
CREATE TABLE species.mt_stresses AS
WITH
a AS (
SELECT DISTINCT
stresscode,
stressname
FROM species_202001.threats
),
b AS (
SELECT
string_to_array((a.stresscode)::text, '|'::text) AS stresscode,
string_to_array((a.stressname)::text, '|'::text) AS stressname
FROM a
),
c AS (
SELECT DISTINCT
u.code,
u.name
FROM b,
LATERAL UNNEST(b.stresscode, b.stressname) WITH ORDINALITY u(code, name, ordinality)
ORDER BY u.code
),
d AS (
SELECT
(split_part(c.code, '.'::text, 1))::integer AS stress_cl1,
CASE
WHEN (c.code ~~ '%.%'::text) THEN (split_part(c.code, '.'::text, 2))::integer
ELSE 0
END AS stress_cl2,
CASE
WHEN (c.code ~~ '%.%.%'::text) THEN (split_part(c.code, '.'::text, 3))::integer
ELSE 0
END AS stress_cl3,
c.code,
c.name
FROM c
),
stress AS (
SELECT
d.stress_cl1,
d.stress_cl2,
d.stress_cl3,
d.code,
d.name
FROM d
ORDER BY d.stress_cl1, d.stress_cl2, d.stress_cl3
)
SELECT
stress_cl1,
stress_cl2,
stress_cl3,
code,
name
FROM stress
ORDER BY code;

------ LT_SPECIES_STRESSES ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_stresses CASCADE; 
CREATE TABLE species.lt_species_stresses AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
unnest(string_to_array((stresscode)::text, '|'::text)) AS code
FROM species_202001.threats
ORDER BY (internaltaxonid)::bigint, (unnest(string_to_array((stresscode)::text, '|'::text)))
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

--------- THREATS ------------------------------------------------------
------ MT_THREATS ------------------------------------------------------
DROP TABLE IF EXISTS species.mt_threats CASCADE; 
CREATE TABLE species.mt_threats AS
WITH
a AS (
SELECT DISTINCT
code::text,
name::text
FROM species_202001.threats
ORDER BY code::text
),
b AS (
SELECT
(split_part((a.code)::text, '.'::text, 1))::integer AS threats_cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS threats_cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS threats_cl3,
a.code,
a.name
FROM a
),
threats AS (
SELECT
b.threats_cl1,
b.threats_cl2,
b.threats_cl3,
b.code,
b.name
FROM b
ORDER BY b.threats_cl1, b.threats_cl2, b.threats_cl3
)
SELECT
threats_cl1,
threats_cl2,
threats_cl3,
code,
name
FROM threats
ORDER BY code;

------ LT_SPECIES_THREATS ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_threats CASCADE; 
CREATE TABLE species.lt_species_threats AS 
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.threats
ORDER BY (internaltaxonid)::bigint, (code)::text
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;

--------- USETRADE -----------------------------------------------------
------ MT_USETRADE -----------------------------------------------------
DROP TABLE IF EXISTS species.mt_usetrade CASCADE; 
CREATE TABLE species.mt_usetrade AS
SELECT DISTINCT
(code)::integer AS code,
(name)::text AS name
FROM species_202001.usetrade
ORDER BY (code)::integer;

------ LT_SPECIES_USETRADE ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_usetrade CASCADE; 
CREATE TABLE species.lt_species_usetrade AS
WITH
a AS (
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.usetrade
ORDER BY (internaltaxonid)::bigint, (code)::text
)
SELECT * FROM a
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;
