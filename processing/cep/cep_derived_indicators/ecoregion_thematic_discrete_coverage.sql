-- DEFINE CEP
DROP TABLE IF EXISTS cep;CREATE TEMPORARY TABLE cep AS SELECT cid,country,eco,pa,SUM(sqkm) sqkm FROM
--cep.cep_202003 -- CHANGE HERE!
(SELECT cid,country,ecoregion eco,wdpa pa,sqkm FROM cep202003_delli_raster.h_flat) a -- CHANGE HERE!
GROUP BY cid,country,eco,pa ORDER BY cid;
-- DEFINE ECOREGIONS
DROP TABLE IF EXISTS ecoregions;CREATE TEMPORARY TABLE ecoregions AS SELECT * FROM
habitats_and_biotopes.ecoregions_2020_atts; -- CHANGE HERE!
-- DEFINE CEP/THEME
DROP TABLE IF EXISTS cep_lc;CREATE TEMPORARY TABLE cep_lc AS SELECT cid,cat,SUM(area_m2)/1000000 sqkm FROM
results_202003.r_stats_cep_esalc_2018_temp -- CHANGE HERE!
GROUP BY cid,cat ORDER BY cid,cat;
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep_eco;CREATE TEMPORARY TABLE cep_eco AS SELECT DISTINCT cid,eco FROM cep ORDER BY cid,eco;
DROP TABLE IF EXISTS cep_eco_prot;CREATE TEMPORARY TABLE cep_eco_prot AS SELECT DISTINCT cid,eco FROM cep WHERE 0 != ANY(pa) ORDER BY cid,eco;
DROP TABLE IF EXISTS cep_eco_lc;CREATE TEMPORARY TABLE cep_eco_lc AS
WITH
a as  (SELECT * FROM cep_eco a JOIN cep_lc b USING(cid)),
b AS (SELECT UNNEST(eco) eco,cat,sqkm FROM a ORDER BY eco,cat),
c AS (SELECT eco,cat,SUM(sqkm) sqkm FROM b GROUP BY eco,cat)
SELECT * FROM c  ORDER BY eco,cat;
DROP TABLE IF EXISTS cep_eco_lc_prot;CREATE TEMPORARY TABLE cep_eco_lc_prot AS
WITH
a as  (SELECT * FROM cep_eco_prot a JOIN cep_lc b USING(cid)),
b AS (SELECT UNNEST(eco) eco,cat,sqkm FROM a ORDER BY eco,cat),
c AS (SELECT eco,cat,SUM(sqkm) prot_sqkm FROM b GROUP BY eco,cat)
SELECT * FROM c  ORDER BY eco,cat;

WITH
a AS (SELECT * FROM cep_eco_lc a LEFT JOIN cep_eco_lc_prot b USING(eco,cat)),
b AS (SELECT *,ROUND(((prot_sqkm/sqkm)*100)::numeric,2) perc_prot FROM a  ORDER BY eco,cat),
c AS(SELECT first_level_code eco,first_level eco_name,sqkm tot_sqkm FROM ecoregions),
d AS (SELECT eco,SUM(sqkm) lc_sqkm,SUM(prot_sqkm) lc_prot_sqkm FROM b GROUP BY eco)
SELECT * FROM c NATURAL JOIN d;

