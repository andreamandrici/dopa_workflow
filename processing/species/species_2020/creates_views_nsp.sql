-- VIEWS (V) -------------[--------------------------------------
---- MAIN TABLES (MT_) ------------------------------------------
------ MT_CATEGORIES --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_categories CASCADE; -- this one remove this view and all related lt objects
CREATE VIEW species_202001.v_mt_categories AS
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
a.redlistcategory
FROM (SELECT DISTINCT redlistcategory::text FROM species_202001.assessments) a;
------ MT_CONSERVATION_NEEDED --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_conservation_needed CASCADE;
CREATE VIEW species_202001.v_mt_conservation_needed AS
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
FROM conservation_needed;
------ MT_COUNTRIES --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_countries CASCADE;
CREATE VIEW species_202001.v_mt_countries AS
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

------ MT_HABITATS --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_habitats CASCADE;
CREATE VIEW species_202001.v_mt_habitats AS
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
FROM habitats;

------ MT_RESEARCH NEEDED --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_research_needed CASCADE;
CREATE VIEW species_202001.v_mt_research_needed AS
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
FROM research_needed;

------ MT_STRESSES --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_stresses CASCADE;
CREATE VIEW species_202001.v_mt_stresses AS
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
FROM stress;

------ MT_THREATS --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_threats CASCADE;
CREATE VIEW species_202001.v_mt_threats AS
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
FROM threats;

------ MT_USETRADE --------------------------------------------
DROP VIEW IF EXISTS species_202001.v_mt_usetrade CASCADE;
CREATE VIEW species_202001.v_mt_usetrade AS
SELECT DISTINCT
(code)::integer AS code,
(name)::text AS name
FROM species_202001.usetrade
ORDER BY (code)::integer;

---- LOOKUP TABLES (LT_) ----------------------------------------
------ LT_CATEGORIES ---------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_categories CASCADE;
CREATE VIEW species_202001.v_lt_species_categories AS
WITH
a AS (
SELECT DISTINCT
internaltaxonid,
redlistcategory
FROM species_202001.assessments
)
SELECT (
a.internaltaxonid)::bigint AS id_no,
code
FROM (a JOIN species_202001.v_mt_categories USING (redlistcategory))
ORDER BY (a.internaltaxonid)::bigint, code;

------ LT_CONSERVATION NEEDED ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_conservation_needed CASCADE;
CREATE VIEW species_202001.v_lt_species_conservation_needed AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.conservation_needed
ORDER BY (conservation_needed.internaltaxonid)::bigint, (conservation_needed.code)::text;

------ LT_COUNTRIES ---------------------------------------------
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

------ LT_HABITATS ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_habitats CASCADE;
CREATE VIEW species_202001.v_lt_species_habitats AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.habitats
ORDER BY (internaltaxonid)::bigint, (code)::text;

------ LT_RESEARCH NEEDED ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_research_needed CASCADE;
CREATE VIEW species_202001.v_lt_species_research_needed AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.research_needed
ORDER BY (internaltaxonid)::bigint, (code)::text;

------ LT_STRESSES ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_stresses CASCADE;
CREATE VIEW species_202001.v_lt_species_stresses AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
unnest(string_to_array((stresscode)::text, '|'::text)) AS code
FROM species_202001.threats
ORDER BY (internaltaxonid)::bigint, (unnest(string_to_array((stresscode)::text, '|'::text)));

------ LT_THREATS ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_threats CASCADE;
CREATE VIEW species_202001.v_lt_species_threats AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.threats
ORDER BY (internaltaxonid)::bigint, (code)::text;

------ LT_USETRADE ---------------------------------------------
DROP VIEW IF EXISTS species_202001.v_lt_species_usetrade CASCADE;
CREATE VIEW species_202001.v_lt_species_usetrade AS
SELECT DISTINCT
(internaltaxonid)::bigint AS id_no,
(code)::text AS code
FROM species_202001.usetrade
ORDER BY (internaltaxonid)::bigint, (code)::text;

