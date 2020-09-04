-- FIND PROBLEMATIC CIDs from fb_atts_all
DROP TABLE IF EXISTS prob_cid;CREATE TEMPORARY TABLE prob_cid AS SELECT DISTINCT * FROM cep202009.fb_atts_all WHERE 0 = ANY(country) OR CARDINALITY(country) > 1;
-- FIND PROBLEMATIC TIDS from fa_atts_tile
DROP TABLE IF EXISTS prob_tid;CREATE TEMPORARY TABLE prob_tid AS  SELECT b.* FROM cep202009.fa_atts_tile b JOIN prob_cid a USING(country,ecoregion,wdpa);
-- FIND PROBLEMATIC GEOMS from e_flat_all
DROP TABLE IF EXISTS prob_geom;CREATE TEMPORARY TABLE prob_geom AS  
SELECT * FROM cep202009.e_flat_all NATURAL JOIN prob_tid;
-- FIND CORRECT ATTRIBUTES intersecting correct_country with original countries
DROP TABLE IF EXISTS correct_country;CREATE TEMPORARY TABLE correct_country AS  
WITH
a AS (SELECT qid,tid,point FROM prob_geom),
b AS (SELECT country_id,country_name,iso3,geom FROM administrative_units.gaul_eez_dissolved_201912)
SELECT qid,tid,country_id,country_name,iso3 FROM a,b WHERE ST_INTERSECTS(a.point,b.geom);
-- CREATE CORRECT tids 
DROP TABLE IF EXISTS correct_tid;CREATE TEMPORARY TABLE correct_tid AS  
SELECT qid,tid,ARRAY[country_id]::int[] country,ecoregion,wdpa FROM prob_tid NATURAL JOIN correct_country;
--CHECK IF CORRECT ATTRIBUTES EXISTS IN cid (OPTIONAL)
SELECT * FROM cep202009.fb_atts_all NATURAL JOIN correct_tid;
--UPDATE CORRECTED ATTRIBUTES FOR PROBLEMATIC TIDs IN fa_atts_tile
UPDATE cep202009.fa_atts_tile
SET country=b.country
FROM correct_tid b
WHERE fa_atts_tile.qid=b.qid AND fa_atts_tile.tid=b.tid;
-- CREATE CORRECT cids 
DROP TABLE IF EXISTS correct_cid;CREATE TEMPORARY TABLE correct_cid AS  
SELECT
ROW_NUMBER() OVER () cid,*
FROM (SELECT DISTINCT country,ecoregion,wdpa FROM cep202009.fa_atts_tile) a
ORDER BY country,ecoregion,wdpa;
-- UPDATE CORRECTED CIDs IN fb_atts_all
TRUNCATE TABLE cep202009.fb_atts_all;
INSERT INTO cep202009.fb_atts_all
SELECT * FROM correct_cid ORDER BY cid;
-- CHECK IF PROBLEMATIC CIDs STILL EXISTS IN fb_atts_all
SELECT DISTINCT * FROM cep202009.fb_atts_all WHERE 0 = ANY(country) OR CARDINALITY(country) > 1;

