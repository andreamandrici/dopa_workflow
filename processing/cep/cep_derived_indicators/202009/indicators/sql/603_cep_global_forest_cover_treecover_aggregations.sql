-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS SELECT * FROM :v1.r_univar_cep_gfc_treecover_over30;
-- SELECT THE GRID;
DROP TABLE IF EXISTS grid_index; CREATE TEMPORARY TABLE grid_index AS SELECT qid,eid FROM :v3.z_grid ORDER BY qid,eid;
-- SELECT THE AREA;
DROP TABLE IF EXISTS area_index; CREATE TEMPORARY TABLE area_index AS SELECT eid,cid,(area_m2/1000000) sqkm FROM :v1.cid_area_by_tile ORDER BY eid,cid;
------------------------------------------------------------
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS
SELECT *
FROM cep.index_country_cep_last
JOIN grid_index USING (qid);
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS SELECT * FROM cep.index_ecoregion_cep_last JOIN grid_index USING (qid);
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last JOIN grid_index USING (qid);

------------------------------------------------------------------
-- COUNTRY
DROP TABLE IF EXISTS country_land_theme; CREATE TEMPORARY TABLE country_land_theme AS
WITH
country_eid_cid_land AS (SELECT country,eid,cid,SUM(sqkm) sqkm FROM country_index WHERE is_marine = FALSE GROUP BY country,eid,cid),
country_eid_cid_prot_land AS (SELECT DISTINCT country,eid,cid,SUM(sqkm) sqkm FROM country_index WHERE is_marine = FALSE AND is_protected = TRUE GROUP BY country,eid,cid),
country_land AS (SELECT country,SUM(sqkm) tot_sqkm FROM country_eid_cid_land GROUP BY country),
b AS (SELECT eid,cid,mean FROM theme),
c AS (SELECT eid,cid,sqkm tsqkm FROM area_index),
d AS (SELECT country,SUM(tsqkm*mean/100) sqkm FROM country_eid_cid_land a JOIN b USING(eid,cid) JOIN c USING(eid,cid) GROUP BY country ORDER BY country),
e AS (SELECT country,SUM(tsqkm*mean/100) prot_sqkm FROM country_eid_cid_prot_land a JOIN b USING(eid,cid) JOIN c USING(eid,cid) GROUP BY country ORDER BY country)
SELECT
country,
sqkm,
prot_sqkm,
(sqkm/tot_sqkm*100) perc,
(prot_sqkm/tot_sqkm*100) prot_perc
FROM country_land a LEFT JOIN d USING(country) LEFT JOIN e USING(country);

----------------------------------------
-- ECOREGION
DROP TABLE IF EXISTS ecoregion_land_theme; CREATE TEMPORARY TABLE ecoregion_land_theme AS
WITH
ecoregion_eid_cid_land AS (SELECT ecoregion,eid,cid,SUM(sqkm) sqkm FROM ecoregion_index WHERE is_marine = FALSE GROUP BY ecoregion,eid,cid),
ecoregion_eid_cid_prot_land AS (SELECT DISTINCT ecoregion,eid,cid,SUM(sqkm) sqkm FROM ecoregion_index WHERE is_marine = FALSE AND is_protected = TRUE GROUP BY ecoregion,eid,cid),
ecoregion_land AS (SELECT ecoregion,SUM(sqkm) tot_sqkm FROM ecoregion_eid_cid_land GROUP BY ecoregion),
b AS (SELECT eid,cid,mean FROM theme),
c AS (SELECT eid,cid,sqkm tsqkm FROM area_index),
d AS (SELECT ecoregion,SUM(tsqkm*mean/100) sqkm FROM ecoregion_eid_cid_land a JOIN b USING(eid,cid) JOIN c USING(eid,cid) GROUP BY ecoregion ORDER BY ecoregion),
e AS (SELECT ecoregion,SUM(tsqkm*mean/100) prot_sqkm FROM ecoregion_eid_cid_prot_land a JOIN b USING(eid,cid) JOIN c USING(eid,cid) GROUP BY ecoregion ORDER BY ecoregion)
SELECT
ecoregion,
sqkm,
prot_sqkm,
(sqkm/tot_sqkm*100) perc,
(prot_sqkm/tot_sqkm*100) prot_perc
FROM ecoregion_land a LEFT JOIN d USING(ecoregion) LEFT JOIN e USING(ecoregion);
----------------------------------------
-- PROTECTION
DROP TABLE IF EXISTS pa_land_theme; CREATE TEMPORARY TABLE pa_land_theme AS
WITH
pa_eid_cid_land AS (SELECT pa,eid,cid,SUM(sqkm) sqkm FROM pa_index WHERE marine IN (0,1) GROUP BY pa,eid,cid),
pa_land AS (SELECT pa,SUM(sqkm) tot_sqkm FROM pa_eid_cid_land GROUP BY pa),
b AS (SELECT eid,cid,mean FROM theme),
c AS (SELECT eid,cid,sqkm tsqkm FROM area_index),
d AS (SELECT pa,SUM(tsqkm*mean/100) sqkm FROM pa_eid_cid_land a JOIN b USING(eid,cid) JOIN c USING(eid,cid) GROUP BY pa ORDER BY pa)
SELECT
pa,
sqkm,
(sqkm/tot_sqkm*100) perc
FROM pa_land a LEFT JOIN d USING(pa);

-------------------------------------------------------------
-- OUTPUTS
-------------------------------------------------------------
-- country
DROP TABLE IF EXISTS results_aggregated.country_global_forest_cover_treecover;
CREATE TABLE results_aggregated.country_global_forest_cover_treecover AS
SELECT
country country_id,
sqkm gfc_treecover_km2,
prot_sqkm gfc_treecover_prot_km2,
perc gfc_treecover_perc,
prot_perc gfc_treecover_prot_perc
FROM country_land_theme;
-- ecoregion
DROP TABLE IF EXISTS results_aggregated.ecoregion_global_forest_cover_treecover;
CREATE TABLE results_aggregated.ecoregion_global_forest_cover_treecover AS
SELECT
ecoregion eco_id,
sqkm gfc_treecover_km2,
prot_sqkm gfc_treecover_prot_km2,
perc gfc_treecover_perc,
prot_perc gfc_treecover_prot_perc
FROM ecoregion_land_theme;
-- pa
DROP TABLE IF EXISTS results_aggregated.wdpa_global_forest_cover_treecover;
CREATE TABLE results_aggregated.wdpa_global_forest_cover_treecover AS
SELECT
pa wdpaid,
sqkm gfc_treecover_km2,
perc gfc_treecover_perc
FROM pa_land_theme;

