-- Since 2026 Ecoregions stop being base dataset (CEP) and become thematic layer, consequent;y they are processed in grass.
-- the following is the aggregation script for ECOREGION TERRESTRIAL 2017, preprocessed to include the overlaps.

DROP TABLE IF EXISTS r_stats_cep_ecoreg_202601;CREATE TEMPORARY TABLE r_stats_cep_ecoreg_202601 AS 
SELECT * FROM results_202601_cep_in.r_stats_cep_ecoreg_202601;
-- there is a mistake in the attributes: cat 9999 is written as 999.
UPDATE r_stats_cep_ecoreg_202601 SET cat = 9999 WHERE cat = 999; 

-- there are overlapping objects. The following classes are added (also in the geometries)
--"eco_id"	"eco_name"
-- 1011	true	"Eastern Arc forests/Northern Acacia-Commiphora bushlands and thickets - (Overlapping eco_id: 9,51)"
-- 1121	true	"Dronning Maud Land tundra/Rock and Ice - (Overlapping eco_id: 119,9999)"
-- 1126	true	"Marie Byrd Land tundra/Rock and Ice - (Overlapping eco_id: 124,9999)"
-- 1137	true	"Transantarctic Mountains tundra/Rock and Ice - (Overlapping eco_id: 134,9999)"
-- 9999	true	"Rock and Ice"
DROP TABLE IF EXISTS ecoregions_2017_export.ecoregions2017_original_atts;CREATE TABLE ecoregions_2017_export.ecoregions2017_original_atts AS
WITH
a AS (SELECT DISTINCT cat eco_id, TRUE p FROM r_stats_cep_ecoreg_202601 ORDER BY eco_id),
b1 AS (SELECT "ECO_ID"::integer eco_id,"ECO_NAME"::text eco_name FROM ecoregions_2017_export.ecoregions2017_original ORDER BY eco_id),
b2 AS (SELECT eco_id,eco_name||' - (Overlapping eco_id: '||ARRAY_TO_STRING(original_eco_id,',')||')' eco_name FROM ecoregions_2017_export.ecoregions_atts wHERE cardinality(original_eco_id)>1),
b AS (SELECT * FROM b1 UNION SELECT * FROM b2 ORDER BY eco_id)
SELECT * FROM a FULL OUTER JOIN b USING(eco_id);
UPDATE ecoregions_2017_export.ecoregions2017_original_atts SET eco_name = 'Rock and Ice' WHERE eco_id = 9999;
UPDATE ecoregions_2017_export.ecoregions2017_original_atts SET eco_name = NULL WHERE eco_id = 0;
SELECT * FROM ecoregions_2017_export.ecoregions2017_original_atts ORDER BY eco_id;
SELECT * FROM ecoregions_2017_export.ecoregions2017_original_atts WHERE eco_id > 899;
SELECT * FROM ecoregions_2017_export.ecoregions2017_original_atts WHERE eco_id=0;

----------------------------------------------------------------------------------
SELECT * FROM cep_data_202601.cep_index LIMIT 10;
SELECT * FROM results_202601_cep_in.r_stats_cep_ecoreg_202601 WHERE cat IN (0,999);
SELECT DISTINCT cat FROM results_202601_cep_in.r_stats_cep_ecoreg_202601 WHERE cat IN (0,999);


----------------------------------------------------------------------------------
DROP TABLE if exists country_land_cid;CREATE TEMPORARY TABLE country_land_cid AS
WITH
a AS (SELECT DISTINCT cid,country_id FROM cep_data_202601.cep_index WHERE is_marine IS FALSE ORDER BY country_id,cid)
SELECT DisTINCT country_id,cid,SUM(sqkm) sqkm FROM cep_data_202601.cep JOIN a USING(cid) GROUP BY country_id,cid ORDER BY country_id,cid;
SELECT * FROM country_land_cid;

DROP TABLE if exists country_land_cat;CREATE TEMPORARY TABLE country_land_cat AS
SELECT country_id,cat,sum(area_m2)/1000000 sqkm
FROM country_land_cid a 
JOIN r_stats_cep_ecoreg_202601 b USING (cid)
GROUP by country_id,cat ORDER BY country_id,cat;

-----------------------------------------------------------------------------------------------
DROP TABLE if exists country_land_prot_cid;CREATE TEMPORARY TABLE country_land_prot_cid AS
WITH
a AS (SELECT DISTINCT cid,country_id FROM cep_data_202601.cep_index WHERE is_marine IS FALSE AND is_protected IS TRUE ORDER BY country_id,cid)
SELECT DisTINCT country_id,cid,SUM(sqkm) sqkm FROM cep_data_202601.cep JOIN a USING(cid) GROUP BY country_id,cid ORDER BY country_id,cid;
SELECT * FROM country_land_prot_cid;

DROP TABLE if exists country_prot_cat;CREATE TEMPORARY TABLE country_prot_cat AS
SELECT country_id,cat,sum(area_m2)/1000000 sqkm
FROM country_land_prot_cid a 
JOIN r_stats_cep_ecoreg_202601 b USING (cid)
GROUP by country_id,cat ORDER BY country_id,cat;

---------------------------------------------------------------------------------------------

DROP TABLE if exists country_land_prot;CREATE TEMPORARY TABLE country_land_prot AS
WITH a AS (SELECT DISTINCT country_id FROM country_land_cid UNION SELECT DISTINCT country_id FROM country_land_prot_cid)
SELECT * FROM a
LEFT JOIN (SELECT country_id,SUM(sqkm) v_land_sqkm FROM country_land_cid GROUP BY country_id) b USING(country_id)
LEFT JOIN (SELECT country_id,SUM(sqkm) r_land_sqkm FROM country_land_cat GROUP BY country_id) c USING(country_id)
LEFT JOIN (SELECT country_id,SUM(sqkm) v_land_prot_sqkm FROM country_land_prot_cid GROUP BY country_id) d USING(country_id)
LEFT JOIN (SELECT country_id,SUM(sqkm) r_land_prot_sqkm FROM country_prot_cat GROUP BY country_id) e USING(country_id)
ORDER BY country_id;
SELECT * FROM country_land_prot;

DROP TABLE if exists eco_tot_prot;CREATE TEMPORARY TABLE eco_tot_prot AS
WITH
a AS (SELECT cat,SUM(sqkm) r_eco_tot_sqkm FROM country_land_cat GROUP BY cat),
b AS (SELECT cat,SUM(sqkm) r_eco_prot_sqkm FROM country_prot_cat GROUP BY cat)
SELECT * FROM a LEFT JOIN b USING(cat)
ORDER BY cat;
SELECT * FROM eco_tot_prot;

---------------------------------------------------------------------------------------
--ALL TOGETHER NOW!
DROP TABLE IF EXISTS ecoregions_2017_export.results_country_ecoregion_v_r_tot_prot;
CREATE TABLE ecoregions_2017_export.results_country_ecoregion_v_r_tot_prot AS
SELECT
a.country_id,svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso3,iso2,status,
a.country_land_sqkm,b.v_land_sqkm,b.r_land_sqkm,
a.country_land_prot_sqkm,b.v_land_prot_sqkm,b.r_land_prot_sqkm
FROM cep_data_202601.country_all_inds a
JOIN country_land_prot b USING(country_id);

DROP TABLE IF EXISTS ecoregions_2017_export.results_country_ecoregion;
CREATE TABLE ecoregions_2017_export.results_country_ecoregion AS
SELECT country_id,cat eco_id,d.eco_name,c.r_eco_tot_sqkm ecoregion_tot_sqkm,a.sqkm country_eco_sqkm,c.r_eco_prot_sqkm ecoregion_prot_sqkm,b.sqkm country_eco_prot_sqkm
FROM country_land_cat a
LEFT JOIN country_prot_cat b USING(country_id,cat)
JOIN eco_tot_prot c USING(cat)
LEFT JOIN ecoregions_2017_export.ecoregions2017_original_atts d ON cat=eco_id
ORDER BY country_id,eco_id;

SELECT * FROM ecoregions_2017_export.results_country_ecoregion;
