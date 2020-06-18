DROP TABLE IF EXISTS ecoregion_teow_input;
CREATE TEMPORARY TABLE ecoregion_teow_input AS 
SELECT first_level_code::integer,first_level,second_level_code::integer,second_level,third_level_code::integer,third_level,source,wkb_geometry geom FROM eco2020_input.teow_ogr a
NATURAL JOIN eco2020_input.teow_atts b ORDER BY first_level_code::integer;

DROP TABLE IF EXISTS ecoregion_teow_dump;
CREATE TEMPORARY TABLE ecoregion_teow_dump AS 
SELECT ROW_NUMBER () OVER () id,first_level_code,(ST_DUMP(geom)).* FROM ecoregion_teow_input ORDER BY first_level_code;

DROP TABLE IF EXISTS ecoregion_teow_valid;
CREATE TEMPORARY TABLE ecoregion_teow_valid AS
SELECT id,(ST_ISVALIDDETAIL(geom)).* FROM ecoregion_teow_dump WHERE ST_ISVALID(geom) = FALSE;

DROP TABLE IF EXISTS ecoregion_teow_st_geometrytype;
CREATE TEMPORARY TABLE ecoregion_teow_st_geometrytype AS
SELECT id,ST_GEOMETRYTYPE(geom) FROM ecoregion_teow_dump WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon';

DROP TABLE IF EXISTS ecoregion_teow_dump_input;
CREATE TABLE ecoregion_teow_dump_input AS
SELECT a.*,b.valid,b.reason,b.location,c.st_geometrytype
FROM ecoregion_teow_dump a
LEFT JOIN ecoregion_teow_valid b USING(id)
LEFT JOIN ecoregion_teow_st_geometrytype c USING(id)
ORDER BY a.id,a.first_level_code;

DROP TABLE IF EXISTS fixed;
CREATE TEMPORARY TABLE fixed AS
SELECT *,ST_GEOMETRYTYPE(geom) FROM 
(SELECT id,first_level_code,(ST_DUMP((ST_MULTI(ST_MAKEVALID(geom))))).* FROM ecoregion_teow_dump_input WHERE st_geometrytype IS NOT NULL OR valid IS NOT NULL) a;

UPDATE ecoregion_teow_dump_input a
SET geom=b.geom
FROM fixed b WHERE a.id=b.id;

DROP TABLE IF EXISTS eco2020_input.ecoregion_teow_input;
CREATE TABLE eco2020_input.ecoregion_teow_input AS
SELECT * FROM 
(SELECT first_level_code,ST_MULTI(ST_COLLECT(geom)) geom FROM ecoregion_teow_dump_input GROUP BY first_level_code) a
JOIN (SELECT DISTINCT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level,source FROM ecoregion_teow_input) b USING(first_level_code)
ORDER BY first_level_code
