DROP TABLE IF EXISTS habitats_and_biotopes.meow_ppow_1;CREATE TABLE habitats_and_biotopes.meow_ppow_1 AS
SELECT DISTINCT realm::text,biome::text,ecoregion::text,provinc::text,LOWER(type::text) source,geom
FROM habitats_and_biotopes.meow_ppow_input_nocoastline
ORDER BY source,realm,biome,ecoregion,provinc;
--SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.meow_ppow_1;
--SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.meow_ppow_1;
UPDATE habitats_and_biotopes.meow_ppow_1
SET provinc='Juan Fernández and Desventuradas',ecoregion='Juan Fernández and Desventuradas' WHERE ecoregion= 'Juan Fern ndez and Desventuradas';

DROP TABLE IF EXISTS meow1;CREATE TEMPORARY TABLE meow1 AS
WITH
a AS (
SELECT *,ecoregion first_level,provinc second_level,realm third_level
FROM habitats_and_biotopes.meow_ppow_1
WHERE source = 'meow'
),
b AS (
SELECT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level
FROM habitats_and_biotopes.ecoregions_2020_atts WHERE source NOT IN ('eeow','teow'))
SELECT source,third_level_code,realm,second_level_code,provinc,first_level_code,ecoregion
FROM a NATURAL JOIN b
ORDER BY source,third_level_code,second_level_code,first_level_code;

DROP TABLE IF EXISTS ppow1;CREATE TEMPORARY TABLE ppow1 AS
WITH
a AS (
SELECT *,provinc first_level,biome second_level,realm third_level
FROM habitats_and_biotopes.meow_ppow_1 WHERE source = 'ppow'
),
b AS (
SELECT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level
FROM habitats_and_biotopes.ecoregions_2020_atts WHERE source NOT IN ('eeow','teow'))
SELECT source,third_level_code,realm,second_level_code,biome,first_level_code,provinc
FROM a NATURAL JOIN b
ORDER BY source,third_level_code,second_level_code,first_level_code;

-------------------------------
DROP TABLE IF EXISTS ppow_correction;CREATE TEMPORARY TABLE ppow_correction AS
SELECT source,third_level_code,third_level,second_level_code,second_level,first_level_code,first_level FROM habitats_and_biotopes.ecoregions_2020_atts
WHERE source IN ('ppow') AND first_level_code NOT IN (SELECT DISTINCT first_level_code FROM ppow1)
ORDER BY third_level_code,second_level_code,first_level_code;
SELECT * FROM ppow_correction;

DROP TABLE IF EXISTS ppow_correction1;CREATE TEMPORARY TABLE ppow_correction1 AS
SELECT a.*,ST_POINTONSURFACE(geom) point FROM ppow_correction a NATURAL JOIN habitats_and_biotopes.ecoregions_2019 b;

DROP TABLE IF EXISTS ppow_correction2;CREATE TEMPORARY TABLE ppow_correction2 AS
SELECT b.source,a.third_level_code,a.third_level,
a.second_level_code,b.biome second_level,
a.first_level_code,b.provinc first_level
FROM ppow_correction1 a, habitats_and_biotopes.meow_ppow_1 b
WHERE ST_INTERSECTS(a.point,b.geom) AND b.source='ppow';
SELECT * FROM ppow_correction2;

DROP TABLE IF EXISTS ppow2;CREATE TEMPORARY TABLE ppow2 AS
WITH
a AS (
SELECT *,provinc first_level,biome second_level,realm third_level
FROM habitats_and_biotopes.meow_ppow_1 WHERE source = 'ppow' AND provinc NOT IN (SELECT DISTINCT provinc FROM ppow1)
),
b AS (
SELECT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level
FROM ppow_correction2)
SELECT source,third_level_code,realm,second_level_code,biome,first_level_code,provinc
FROM a NATURAL JOIN b
ORDER BY source,third_level_code,second_level_code,first_level_code;
INSERT INTO ppow1 SELECT * FROM ppow2;

DROP TABLE IF EXISTS ppow_correction3;CREATE TEMPORARY TABLE ppow_correction3 AS
WITH
a AS (
SELECT * FROM habitats_and_biotopes.meow_ppow_1
WHERE source = 'ppow'
AND realm = 'Indo-Pacific Warm Water'
AND biome = 'Boundary - western'
AND provinc = 'Agulhas Current'
AND provinc NOT IN (SELECT DISTINCT provinc FROM ppow1)
),
b AS (
SELECT * FROM ppow_correction
WHERE third_level = 'Indo-Pacific Warm Water'
AND second_level = 'Western Boundary'
AND first_level = 'Agulhas Current')
SELECT
a.source,third_level_code,realm third_level,
second_level_code,biome second_level,
first_level_code,provinc first_level
FROM a,b;

DROP TABLE IF EXISTS ppow3;CREATE TEMPORARY TABLE ppow3 AS
WITH
a AS (
SELECT *,provinc first_level,biome second_level,realm third_level
FROM habitats_and_biotopes.meow_ppow_1 WHERE source = 'ppow' AND provinc NOT IN (SELECT DISTINCT provinc FROM ppow1)
),
b AS (
SELECT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level
FROM ppow_correction3)
SELECT source,third_level_code,realm,second_level_code,biome,first_level_code,provinc
FROM a NATURAL JOIN b
ORDER BY source,third_level_code,second_level_code,first_level_code;
INSERT INTO ppow1 SELECT * FROM ppow3;

--------------------------------------------------
DROP TABLE IF EXISTS habitats_and_biotopes.meow;CREATE TABLE habitats_and_biotopes.meow AS
SELECT * FROM meow1 a 
NATURAL JOIN habitats_and_biotopes.meow_ppow_1 b
ORDER BY source,third_level_code,second_level_code,first_level_code;

DROP TABLE IF EXISTS habitats_and_biotopes.ppow;CREATE TABLE habitats_and_biotopes.ppow AS
SELECT * FROM ppow1 a 
NATURAL JOIN habitats_and_biotopes.meow_ppow_1 b
ORDER BY source,third_level_code,second_level_code,first_level_code;

DROP TABLE IF EXISTS habitats_and_biotopes.meow_ppow_1;
