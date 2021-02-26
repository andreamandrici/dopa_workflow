-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS
SELECT * FROM :v1.:v2;

--------------------------------------------------------------
-- PREPARE INDEXES FOR CURRENT VERSION;
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS
SELECT country,is_marine,is_protected,cid,SUM(sqkm) sqkm FROM cep.index_country_cep_last GROUP BY country,is_marine,is_protected,cid;
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS
SELECT ecoregion,is_marine,is_protected,cid,SUM(sqkm) sqkm FROM cep.index_ecoregion_cep_last GROUP BY ecoregion,is_marine,is_protected,cid;
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS
SELECT pa,cid,marine,SUM(sqkm) sqkm FROM cep.index_pa_cep_last GROUP BY pa,cid,marine;
--AGGREGATE CIDS IN THEMATIC LAYER
DROP TABLE IF EXISTS cep_theme;CREATE TEMPORARY TABLE cep_theme AS
SELECT cid,cat,SUM(area_m2)/1000000 cat_sqkm
FROM theme GROUP BY cid,cat ORDER BY cid,cat;
--------------------------------------------
-- COUNTRY
--------------------------------------------
-- country_theme_aggregations
DROP TABLE IF EXISTS country_theme;CREATE TEMPORARY TABLE country_theme AS
WITH
country_cid_land AS (SELECT country,cid,sqkm FROM country_index WHERE is_marine IS FALSE),
country_cid_land_prot AS (SELECT country,cid,sqkm FROM country_index WHERE is_marine IS FALSE AND is_protected IS TRUE),
country_land AS (SELECT country,SUM(sqkm) tot_sqkm FROM country_cid_land GROUP BY country),
country_land_prot AS (SELECT country,SUM(sqkm) tot_prot_sqkm FROM country_cid_land_prot GROUP BY country),
country_land_tot_theme AS (SELECT country,cat,SUM(cat_sqkm) cat_sqkm FROM country_cid_land JOIN cep_theme USING(cid) GROUP BY country,cat),
country_land_prot_theme AS (SELECT country,cat,SUM(cat_sqkm) cat_prot_sqkm FROM country_cid_land_prot JOIN cep_theme USING(cid) GROUP BY country,cat),
country_land_tot_prot_theme AS (SELECT * FROM country_land_tot_theme LEFT JOIN country_land_prot_theme USING(country,cat))
SELECT *
FROM country_land 
LEFT JOIN country_land_prot USING(country)
LEFT JOIN country_land_tot_prot_theme USING(country)
ORDER BY country,cat;
--------------------------------------------------------------------------------------
-- country_change_in_forest_cover_gain
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS country_change_in_forest_cover_gain; CREATE TEMPORARY TABLE country_change_in_forest_cover_gain AS
WITH
a AS (SELECT country,tot_sqkm,tot_prot_sqkm,SUM(cat_sqkm) cat_sqkm,SUM(cat_prot_sqkm) cat_prot_sqkm FROM country_theme WHERE cat = 1 GROUP BY country,tot_sqkm,tot_prot_sqkm)
SELECT
country country_id,
cat_sqkm gfc_gain_km2,
cat_prot_sqkm gfc_gain_prot_km2,
cat_sqkm/tot_sqkm*100 gfc_gain_perc,
cat_prot_sqkm/tot_sqkm*100 gfc_gain_prot_perc
FROM a;
--------------------------------------------
-- ECOREGION
--------------------------------------------
-- ecoregion_theme_aggregations
DROP TABLE IF EXISTS ecoregion_theme;CREATE TEMPORARY TABLE ecoregion_theme AS
WITH
ecoregion_cid_land AS (SELECT ecoregion,cid,sqkm FROM ecoregion_index WHERE is_marine IS FALSE),
ecoregion_cid_land_prot AS (SELECT ecoregion,cid,sqkm FROM ecoregion_index WHERE is_marine IS FALSE AND is_protected IS TRUE),
ecoregion_land AS (SELECT ecoregion,SUM(sqkm) tot_sqkm FROM ecoregion_cid_land GROUP BY ecoregion),
ecoregion_land_prot AS (SELECT ecoregion,SUM(sqkm) tot_prot_sqkm FROM ecoregion_cid_land_prot GROUP BY ecoregion),
ecoregion_land_tot_theme AS (SELECT ecoregion,cat,SUM(cat_sqkm) cat_sqkm FROM ecoregion_cid_land JOIN cep_theme USING(cid) GROUP BY ecoregion,cat),
ecoregion_land_prot_theme AS (SELECT ecoregion,cat,SUM(cat_sqkm) cat_prot_sqkm FROM ecoregion_cid_land_prot JOIN cep_theme USING(cid) GROUP BY ecoregion,cat),
ecoregion_land_tot_prot_theme AS (SELECT * FROM ecoregion_land_tot_theme LEFT JOIN ecoregion_land_prot_theme USING(ecoregion,cat))
SELECT *
FROM ecoregion_land 
LEFT JOIN ecoregion_land_prot USING(ecoregion)
LEFT JOIN ecoregion_land_tot_prot_theme USING(ecoregion)
ORDER BY ecoregion,cat;
--------------------------------------------------------------------------------------
-- ecoregion_change_in_forest_cover_gain
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ecoregion_change_in_forest_cover_gain; CREATE TEMPORARY TABLE ecoregion_change_in_forest_cover_gain AS
WITH
a AS (SELECT ecoregion,tot_sqkm,tot_prot_sqkm,SUM(cat_sqkm) cat_sqkm,SUM(cat_prot_sqkm) cat_prot_sqkm FROM ecoregion_theme WHERE cat = 1 GROUP BY ecoregion,tot_sqkm,tot_prot_sqkm)
SELECT
ecoregion eco_id,
cat_sqkm gfc_gain_km2,
cat_prot_sqkm gfc_gain_prot_km2,
cat_sqkm/tot_sqkm*100 gfc_gain_perc,
cat_prot_sqkm/tot_sqkm*100 gfc_gain_prot_perc
FROM a;
--------------------------------------------
-- PROTECTION
--------------------------------------------
-- protection_theme_aggregations
DROP TABLE IF EXISTS protection_theme;CREATE TEMPORARY TABLE protection_theme AS
WITH
protection_cid_land AS (SELECT pa,cid,sqkm FROM pa_index WHERE marine IN (0,1)),
protection_land AS (SELECT pa,SUM(sqkm) tot_sqkm FROM protection_cid_land GROUP BY pa),
protection_land_theme AS (SELECT pa,cat,SUM(cat_sqkm) cat_sqkm FROM protection_cid_land JOIN cep_theme USING(cid) GROUP BY pa,cat)
SELECT *
FROM protection_land 
LEFT JOIN protection_land_theme USING(pa)
ORDER BY pa,cat;
--------------------------------------------------------------------------------------
-- protection_change_in_forest_cover_gain
--------------------------------------------------------------------------------------
DROP TABLE IF EXISTS protection_change_in_forest_cover_gain; CREATE TEMPORARY TABLE protection_change_in_forest_cover_gain AS
WITH
a AS (SELECT pa,tot_sqkm,SUM(cat_sqkm) cat_sqkm FROM protection_theme WHERE cat = 1 GROUP BY pa,tot_sqkm)
SELECT
pa wdpaid,
cat_sqkm gfc_gain_km2,
cat_sqkm/tot_sqkm*100 gfc_gain_perc
FROM a;
--------------------------------------------
-- OUTPUT
--------------------------------------------
-- country
DROP TABLE IF EXISTS results_aggregated.country_global_forest_cover_gain; CREATE TABLE results_aggregated.country_global_forest_cover_gain AS
SELECT * FROM country_change_in_forest_cover_gain;
-- ecoregion
DROP TABLE IF EXISTS results_aggregated.ecoregion_global_forest_cover_gain; CREATE TABLE results_aggregated.ecoregion_global_forest_cover_gain AS
SELECT * FROM ecoregion_change_in_forest_cover_gain;
-- protection
DROP TABLE IF EXISTS results_aggregated.wdpa_global_forest_cover_gain; CREATE TABLE results_aggregated.wdpa_global_forest_cover_gain AS
SELECT * FROM protection_change_in_forest_cover_gain;

