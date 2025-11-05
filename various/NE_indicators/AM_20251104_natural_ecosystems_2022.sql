-----------------------------------------------------------------------
--land index
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_index;CREATE TEMPORARY TABLE land_index AS 
SELECT qid,cid,iso3,name_eng,sqkm FROM cep_out.cep a
NATURAL JOIN (SELECT DISTINCT qid,cid,iso3,name_eng FROM cep_out.index_cep WHERE source = 'land') b
ORDER BY qid,cid;
SELECT * FROM land_index LIMIT 10;
-----------------------------------------------------------------------
--land index prot
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_index_prot;CREATE TEMPORARY TABLE land_index_prot AS 
SELECT qid,cid,iso3,name_eng,sqkm FROM cep_out.cep a
NATURAL JOIN (SELECT DISTINCT qid,cid,iso3,name_eng FROM cep_out.index_cep WHERE source = 'land' and is_protected IS TRUE) b
ORDER BY qid,cid;
-----------------------------------------------------------------------
--crosswalk landcover classes to natural ecosystems - does not include water
-----------------------------------------------------------------------
DROP TABLE IF EXISTS lc_ne;CREATE TEMPORARY TABLE lc_ne AS 
SELECT
lc_code cat,lc_class,
CASE WHEN lc_code IN (40,50,60,61,62,70,71,72,80,81,82,90,100,110,120,121,122,130,140,150,151,152,153,160,170,180,220) THEN TRUE ELSE FALSE END is_natural
FROM dopa_oecm_43_old.class_lc_esa;
SELECT * FROM lc_ne;

-----------------------------------------------------------------------
--land ecosystems 2022
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_esa_2022;CREATE TEMPORARY TABLE land_esa_2022 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2022_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index) land USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_esa_2022 LIMIT 10;

-----------------------------------------------------------------------
--land_prot ecosystems 2022
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_prot_esa_2022;CREATE TEMPORARY TABLE land_prot_esa_2022 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2022_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index_prot) land_prot USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_prot_esa_2022 LIMIT 10;
-----------------------------------------------------------------------
--country_2022
-----------------------------------------------------------------------
DROP TABLE IF EXISTS country_2022;CREATE TEMPORARY TABLE country_2022 AS 
WITH
a AS (SELECT iso3,SUM(sqkm) land_sqkm_2022 FROM land_esa_2022 GROUP BY iso3),
b AS (SELECT iso3,SUM(sqkm) land_prot_sqkm_2022 FROM land_prot_esa_2022 GROUP BY iso3 ORDER BY iso3),
c AS (SELECT iso3,SUM(sqkm) land_ne_sqkm_2022 FROM land_esa_2022 WHERE is_natural IS TRUE GROUP BY iso3),
d AS (SELECT iso3,SUM(sqkm) land_ne_prot_sqkm_2022 FROM land_prot_esa_2022 WHERE is_natural IS TRUE GROUP BY iso3),
e AS (
SELECT * FROM a
LEFT JOIN b USING (iso3)
LEFT JOIN c USING (iso3)
LEFT JOIN d USING (iso3)
)
SELECT *,
land_prot_sqkm_2022/land_sqkm_2022*100 land_prot_perc_land_2022,
land_ne_sqkm_2022/land_sqkm_2022*100 land_ne_perc_land_2022,
land_ne_prot_sqkm_2022/land_ne_sqkm_2022*100 land_ne_prot_perc_land_ne_2022
FROM e
ORDER BY iso3;
SELECT * FROM country_2022;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--global_2022
-----------------------------------------------------------------------
DROP TABLE IF EXISTS global_2022_land_ne_prt;CREATE TEMPORARY TABLE global_2022_land_ne_prt AS
WITH
a AS (
SELECT
SUM(land_sqkm_2022) land_sqkm_2022,
SUM(land_prot_sqkm_2022) land_prot_sqkm_2022,
SUM(land_ne_sqkm_2022) AS land_ne_sqkm_2022,
SUM(land_ne_prot_sqkm_2022) AS land_ne_prot_sqkm_2022
FROM country_2022),
b AS (
SELECT *,
ROUND((land_prot_sqkm_2022/land_sqkm_2022*100)::numeric,2) land_prot_perc_land_tot_2022,
ROUND((land_ne_sqkm_2022/land_sqkm_2022*100)::numeric,2) land_ne_perc_land_tot_2022,
ROUND((land_ne_prot_sqkm_2022/land_sqkm_2022*100)::numeric,2) land_ne_prot_perc_land_tot_2022,
ROUND((land_ne_prot_sqkm_2022/land_ne_sqkm_2022*100)::numeric,2) land_ne_prot_perc_land_ne_2022,
ROUND((land_ne_prot_sqkm_2022/land_prot_sqkm_2022*100)::numeric,2) land_ne_prot_perc_land_prot_2022
FROM a)
SELECT * FROM b;
SELECT * FROM global_2022_land_ne_prt;