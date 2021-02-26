-- reports by land only
\set vinput 'results_':v1'_cep_in'
-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS SELECT * FROM :vinput.:v2;
-- SELECT THE GRID;
DROP TABLE IF EXISTS grid_index; CREATE TEMPORARY TABLE grid_index AS SELECT qid,eid FROM cep.grid_vector ORDER BY qid,eid;
------------------------------------------------------------
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS SELECT * FROM cep.index_country_cep_last JOIN grid_index USING (qid);
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS SELECT * FROM cep.index_ecoregion_cep_last JOIN grid_index USING (qid);
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last JOIN grid_index USING (qid);
------------------------------------------------------------------
-- COUNTRY
DROP TABLE IF EXISTS country_land; CREATE TEMPORARY TABLE country_land AS
WITH
a AS (SELECT country,qid,cid,SUM(sqkm) country_land_sqkm FROM country_index WHERE is_marine = FALSE GROUP BY country,qid,cid),
b AS (SELECT country,a.qid,a.cid,a.country_land_sqkm,b.mean FROM a JOIN theme b USING(qid,cid))
SELECT country,SUM(country_land_sqkm)country_land_sqkm,SUM(country_land_sqkm*mean/100) theme_land_sqkm FROM b GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_land_prot; CREATE TEMPORARY TABLE country_land_prot AS
WITH
a AS (SELECT country,qid,cid,SUM(sqkm) country_land_prot_sqkm FROM country_index WHERE is_marine = FALSE AND is_protected = TRUE GROUP BY country,qid,cid),
b AS (SELECT country,a.qid,a.cid,a.country_land_prot_sqkm,b.mean FROM a JOIN theme b USING(qid,cid))
SELECT country,SUM(country_land_prot_sqkm)country_land_prot_sqkm,SUM(country_land_prot_sqkm*mean/100) theme_land_prot_sqkm FROM b GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_indicator; CREATE TEMPORARY TABLE country_indicator AS
SELECT
country,
theme_land_sqkm,
(theme_land_sqkm/country_land_sqkm*100) theme_land_perc_country_land,
theme_land_prot_sqkm,
(theme_land_prot_sqkm/country_land_sqkm*100) theme_land_prot_perc_country_land,
(theme_land_prot_sqkm/country_land_prot_sqkm*100) theme_land_prot_perc_country_land_prot,
(theme_land_prot_sqkm/NULLIF(theme_land_sqkm,0)*100) theme_land_prot_perc_theme_land
FROM country_land LEFT JOIN country_land_prot USING(country) ORDER BY country;

----------------------------------------
-- ECOREGION
DROP TABLE IF EXISTS eco_land; CREATE TEMPORARY TABLE eco_land AS
WITH
a AS (SELECT ecoregion,qid,cid,SUM(sqkm) ecoregion_land_sqkm FROM ecoregion_index WHERE is_marine IS FALSE GROUP BY ecoregion,qid,cid),
b AS (SELECT ecoregion,a.qid,a.cid,a.ecoregion_land_sqkm,b.mean FROM a JOIN theme b USING(qid,cid))
SELECT ecoregion,SUM(ecoregion_land_sqkm)ecoregion_land_sqkm,SUM(ecoregion_land_sqkm*mean/100) theme_land_sqkm FROM b GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_land_prot; CREATE TEMPORARY TABLE eco_land_prot AS
WITH
a AS (SELECT ecoregion,qid,cid,SUM(sqkm) ecoregion_land_sqkm FROM ecoregion_index WHERE is_marine IS FALSE AND is_protected = TRUE GROUP BY ecoregion,qid,cid),
b AS (SELECT ecoregion,a.qid,a.cid,a.ecoregion_land_sqkm,b.mean FROM a JOIN theme b USING(qid,cid))
SELECT ecoregion,SUM(ecoregion_land_sqkm)ecoregion_land_prot_sqkm,SUM(ecoregion_land_sqkm*mean/100) theme_land_prot_sqkm FROM b GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS ecoregion_indicator; CREATE TEMPORARY TABLE ecoregion_indicator AS
SELECT
ecoregion,
theme_land_sqkm,
(theme_land_sqkm/ecoregion_land_sqkm*100) theme_land_perc_ecoregion_land,
theme_land_prot_sqkm,
(theme_land_prot_sqkm/ecoregion_land_sqkm*100) theme_land_prot_perc_ecoregion_land,
(theme_land_prot_sqkm/ecoregion_land_prot_sqkm*100) theme_land_prot_perc_ecoregion_land_prot,
(theme_land_prot_sqkm/NULLIF(theme_land_sqkm,0)*100) theme_land_prot_perc_theme_land
FROM eco_land LEFT JOIN eco_land_prot USING(ecoregion) ORDER BY ecoregion;

----------------------------------------
-- PROTECTION
DROP TABLE IF EXISTS pa_land; CREATE TEMPORARY TABLE pa_land AS
WITH
a AS (SELECT pa,qid,cid,SUM(sqkm) pa_land_sqkm FROM pa_index WHERE marine IN (0,1) GROUP BY pa,qid,cid),
b AS (SELECT pa,a.qid,a.cid,a.pa_land_sqkm,b.mean FROM a JOIN theme b USING(qid,cid)),
c AS (SELECT pa,SUM(pa_land_sqkm)pa_land_sqkm,SUM(pa_land_sqkm*mean/100) theme_land_sqkm FROM b GROUP BY pa ORDER BY pa)
SELECT pa,theme_land_sqkm,(theme_land_sqkm/pa_land_sqkm*100) theme_land_perc_pa_land FROM c;

-------------------------------------------------------------
-- OUTPUTS
-------------------------------------------------------------
-- country
DROP TABLE IF EXISTS results_202009_cep_out.country_global_forest_cover_treecover;
CREATE TABLE results_202009_cep_out.country_global_forest_cover_treecover AS
SELECT
country country_id,
theme_land_sqkm gfc_treecover_land_sqkm,
theme_land_perc_country_land gfc_treecover_land_perc_country_land,
theme_land_prot_sqkm gfc_treecover_land_prot_sqkm,
theme_land_prot_perc_country_land gfc_treecover_land_prot_perc_country_land,
theme_land_prot_perc_country_land_prot gfc_treecover_land_prot_perc_country_land_prot,
theme_land_prot_perc_theme_land gfc_treecover_land_prot_perc_gfc_treecover_land
FROM country_indicator a;
-- ecoregion
DROP TABLE IF EXISTS results_202009_cep_out.ecoregion_global_forest_cover_treecover;
CREATE TABLE results_202009_cep_out.ecoregion_global_forest_cover_treecover AS
SELECT
ecoregion eco_id,
theme_land_sqkm gfc_treecover_land_sqkm,
theme_land_perc_ecoregion_land gfc_treecover_land_perc_ecoregion_land,
theme_land_prot_sqkm gfc_treecover_land_prot_sqkm,
theme_land_prot_perc_ecoregion_land gfc_treecover_land_prot_perc_ecoregion_land,
theme_land_prot_perc_ecoregion_land_prot gfc_treecover_land_prot_perc_ecoregion_land_prot,
theme_land_prot_perc_theme_land gfc_treecover_land_prot_perc_gfc_treecover_land
FROM ecoregion_indicator a;
-- pa
DROP TABLE IF EXISTS results_202009_cep_out.wdpa_global_forest_cover_treecover;
CREATE TABLE results_202009_cep_out.wdpa_global_forest_cover_treecover AS
SELECT
pa wdpaid,
theme_land_sqkm gfc_treecover_land_sqkm,
theme_land_perc_pa_land gfc_treecover_land_perc_pa_land
FROM pa_land;



