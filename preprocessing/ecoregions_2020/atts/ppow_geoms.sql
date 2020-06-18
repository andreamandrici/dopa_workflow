DROP TABLE IF EXISTS ecoregion_ppow_input;
CREATE TEMPORARY TABLE ecoregion_ppow_input AS 
SELECT first_level_code::integer,first_level,second_level_code::integer,second_level,third_level_code::integer,third_level,source,wkb_geometry geom FROM eco2020_input.meow_ppow_ogr a
NATURAL JOIN eco2020_input.ppow_atts b WHERE a.type='PPOW' ORDER BY first_level_code::integer;

DROP TABLE IF EXISTS ecoregion_ppow_dump;
CREATE TEMPORARY TABLE ecoregion_ppow_dump AS 
SELECT ROW_NUMBER () OVER () id,first_level_code,(ST_DUMP(geom)).* FROM ecoregion_ppow_input ORDER BY first_level_code;

DROP TABLE IF EXISTS ecoregion_ppow_valid;
CREATE TEMPORARY TABLE ecoregion_ppow_valid AS
SELECT id,(ST_ISVALIDDETAIL(geom)).* FROM ecoregion_ppow_dump WHERE ST_ISVALID(geom) = FALSE;

DROP TABLE IF EXISTS ecoregion_ppow_st_geometrytype;
CREATE TEMPORARY TABLE ecoregion_ppow_st_geometrytype AS
SELECT id,ST_GEOMETRYTYPE(geom) FROM ecoregion_ppow_dump WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon';

DROP TABLE IF EXISTS ecoregion_ppow_dump_input;
CREATE TABLE ecoregion_ppow_dump_input AS
SELECT a.*,b.valid,b.reason,b.location,c.st_geometrytype
FROM ecoregion_ppow_dump a
LEFT JOIN ecoregion_ppow_valid b USING(id)
LEFT JOIN ecoregion_ppow_st_geometrytype c USING(id)
ORDER BY a.id,a.first_level_code;

DROP TABLE IF EXISTS fixed;
CREATE TEMPORARY TABLE fixed AS
SELECT *,ST_GEOMETRYTYPE(geom),ST_AREA(geom::geography) FROM 
(SELECT id,first_level_code,(ST_DUMP((ST_MULTI(ST_MAKEVALID(geom))))).* FROM ecoregion_ppow_dump_input WHERE st_geometrytype IS NOT NULL OR valid IS NOT NULL) a;
SELECT * FROM fixed;

-- DELETE FROM ecoregion_ppow_dump_input WHERE id IN (SELECT DISTINCT id FROM fixed) AND "valid" = FALSE;
-- INSERT INTO ecoregion_ppow_dump_input(id,first_level_code,path,geom)
-- SELECT id,first_level_code,path,geom FROM fixed ORDER BY id ASC, st_area DESC;

DROP TABLE IF EXISTS eco2020_input.ecoregion_ppow_input;
CREATE TABLE eco2020_input.ecoregion_ppow_input AS
SELECT * FROM 
(SELECT first_level_code,ST_MULTI(ST_COLLECT(geom)) geom FROM ecoregion_ppow_dump_input GROUP BY first_level_code) a
JOIN (SELECT DISTINCT first_level_code,first_level,second_level_code,second_level,third_level_code,third_level,source FROM ecoregion_ppow_input) b USING(first_level_code)
ORDER BY first_level_code;
