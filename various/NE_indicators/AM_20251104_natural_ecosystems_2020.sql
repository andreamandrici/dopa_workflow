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
--land ecosystems 1995
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_esa_1995;CREATE TEMPORARY TABLE land_esa_1995 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_1995_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index) land USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_esa_1995 LIMIT 10;
-----------------------------------------------------------------------
--land ecosystems 2015
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_esa_2015;CREATE TEMPORARY TABLE land_esa_2015 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2015_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index) land USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_esa_2015 LIMIT 10;
-----------------------------------------------------------------------
--land ecosystems 2020
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_esa_2020;CREATE TEMPORARY TABLE land_esa_2020 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2020_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index) land USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_esa_2020 LIMIT 10;


-----------------------------------------------------------------------
--land_prot ecosystems 1995
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_prot_esa_1995;CREATE TEMPORARY TABLE land_prot_esa_1995 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_1995_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index_prot) land_prot USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_prot_esa_1995 LIMIT 10;
-----------------------------------------------------------------------
--land_prot ecosystems 2015
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_prot_esa_2015;CREATE TEMPORARY TABLE land_prot_esa_2015 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2015_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index_prot) land_prot USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_prot_esa_2015 LIMIT 10;
-----------------------------------------------------------------------
--land_prot ecosystems 2020
-----------------------------------------------------------------------
DROP TABLE IF EXISTS land_prot_esa_2020;CREATE TEMPORARY TABLE land_prot_esa_2020 AS 
SELECT iso3,cat,is_natural,SUM(area_m2)/1000000 sqkm
FROM results_202501_cep_in.r_stats_cep_esalc_2020_202501
JOIN (SELECT cat,is_natural FROM lc_ne) ne USING(cat)
JOIN (SELECT DISTINCT iso3,qid,cid FROM land_index_prot) land_prot USING (qid,cid)
GROUP BY iso3,cat,is_natural
ORDER BY iso3,cat;
SELECT * FROM land_prot_esa_2020 LIMIT 10;

-----------------------------------------------------------------------
--country_1995
-----------------------------------------------------------------------
DROP TABLE IF EXISTS country_1995;CREATE TEMPORARY TABLE country_1995 AS 
WITH
a AS (SELECT iso3,SUM(sqkm) land_sqkm_1995 FROM land_esa_1995 GROUP BY iso3),
--b AS (SELECT iso3,SUM(sqkm) land_prot_sqkm_1995 FROM land_prot_esa_1995 GROUP BY iso3 ORDER BY iso3),
c AS (SELECT iso3,SUM(sqkm) land_ne_sqkm_1995 FROM land_esa_1995 WHERE is_natural IS TRUE GROUP BY iso3),
--d AS (SELECT iso3,SUM(sqkm) land_ne_prot_sqkm_1995 FROM land_prot_esa_1995 WHERE is_natural IS TRUE GROUP BY iso3),
e AS (
SELECT * FROM a
--LEFT JOIN b USING (iso3)
LEFT JOIN c USING (iso3)
--LEFT JOIN d USING (iso3)
)
SELECT *,
--land_prot_sqkm_1995/land_sqkm_1995*100 land_prot_perc_land_1995,
land_ne_sqkm_1995/land_sqkm_1995*100 land_ne_perc_land_1995
--,land_ne_prot_sqkm_1995/land_ne_sqkm_1995*100 land_ne_prot_perc_land_ne_prot_1995
FROM e
ORDER BY iso3;
SELECT * FROM country_1995;
-----------------------------------------------------------------------
--country_2015
-----------------------------------------------------------------------
DROP TABLE IF EXISTS country_2015;CREATE TEMPORARY TABLE country_2015 AS 
WITH
a AS (SELECT iso3,SUM(sqkm) land_sqkm_2015 FROM land_esa_2015 GROUP BY iso3),
--b AS (SELECT iso3,SUM(sqkm) land_prot_sqkm_2015 FROM land_prot_esa_2015 GROUP BY iso3 ORDER BY iso3),
c AS (SELECT iso3,SUM(sqkm) land_ne_sqkm_2015 FROM land_esa_2015 WHERE is_natural IS TRUE GROUP BY iso3),
--d AS (SELECT iso3,SUM(sqkm) land_ne_prot_sqkm_2015 FROM land_prot_esa_2015 WHERE is_natural IS TRUE GROUP BY iso3),
e AS (
SELECT * FROM a
--LEFT JOIN b USING (iso3)
LEFT JOIN c USING (iso3)
--LEFT JOIN d USING (iso3)
)
SELECT *,
--land_prot_sqkm_2015/land_sqkm_2015*100 land_prot_perc_land_2015,
land_ne_sqkm_2015/land_sqkm_2015*100 land_ne_perc_land_2015
--,land_ne_prot_sqkm_2015/land_ne_sqkm_2015*100 land_ne_prot_perc_land_ne_prot_2015
FROM e
ORDER BY iso3;
SELECT * FROM country_2015;
-----------------------------------------------------------------------
--country_2020
-----------------------------------------------------------------------
DROP TABLE IF EXISTS country_2020;CREATE TEMPORARY TABLE country_2020 AS 
WITH
a AS (SELECT iso3,SUM(sqkm) land_sqkm_2020 FROM land_esa_2020 GROUP BY iso3),
b AS (SELECT iso3,SUM(sqkm) land_prot_sqkm_2020 FROM land_prot_esa_2020 GROUP BY iso3 ORDER BY iso3),
c AS (SELECT iso3,SUM(sqkm) land_ne_sqkm_2020 FROM land_esa_2020 WHERE is_natural IS TRUE GROUP BY iso3),
d AS (SELECT iso3,SUM(sqkm) land_ne_prot_sqkm_2020 FROM land_prot_esa_2020 WHERE is_natural IS TRUE GROUP BY iso3),
e AS (
SELECT * FROM a
LEFT JOIN b USING (iso3)
LEFT JOIN c USING (iso3)
LEFT JOIN d USING (iso3)
)
SELECT *,
land_prot_sqkm_2020/land_sqkm_2020*100 land_prot_perc_land_2020,
land_ne_sqkm_2020/land_sqkm_2020*100 land_ne_perc_land_2020,
land_ne_prot_sqkm_2020/land_ne_sqkm_2020*100 land_ne_prot_perc_land_ne_2020
FROM e
ORDER BY iso3;
SELECT * FROM country_2020;
-----------------------------------------------------------------------
--country_1995-2020
-----------------------------------------------------------------------
DROP TABLE IF EXISTS country_1995_2025_land_ne_prt;CREATE TEMPORARY TABLE country_1995_2025_land_ne_prt AS
SELECT
iso3,
land_sqkm_2020 land_sqkm,
land_ne_sqkm_1995,ROUND(land_ne_perc_land_1995::numeric,2) land_ne_perc_land_1995,
land_ne_sqkm_2015,ROUND(land_ne_perc_land_2015::numeric,2) land_ne_perc_land_2015,
land_ne_sqkm_2020,ROUND(land_ne_perc_land_2020::numeric,2) land_ne_perc_land_2020,
land_prot_sqkm_2020,
ROUND(land_prot_perc_land_2020::numeric,2) land_prot_perc_land_2020,
land_ne_prot_sqkm_2020,
ROUND(land_ne_prot_perc_land_ne_2020::numeric,2) land_ne_prot_perc_land_ne_2020
FROM country_2020
JOIN country_1995 USING(iso3)
JOIN country_2015 USING(iso3)
ORDER BY iso3;
SELECT * FROM country_1995_2025_land_ne_prt;
-----------------------------------------------------------------------
--global_1995-2020
-----------------------------------------------------------------------
DROP TABLE IF EXISTS global_1995_2025_land_ne_prt;CREATE TEMPORARY TABLE global_1995_2025_land_ne_prt AS
WITH
a AS (
SELECT
SUM(land_sqkm) land_sqkm,
SUM(land_prot_sqkm_2020) land_prot_sqkm,
SUM(land_ne_sqkm_1995) AS land_ne_sqkm_1995,
SUM(land_ne_sqkm_2015) AS land_ne_sqkm_2015,
SUM(land_ne_sqkm_2020) AS land_ne_sqkm_2020,
SUM(land_ne_prot_sqkm_2020) AS land_ne_prot_sqkm_2020
FROM country_1995_2025_land_ne_prt),
b AS (
SELECT *,
ROUND((land_prot_sqkm/land_sqkm*100)::numeric,2) land_prot_perc_land_tot,
ROUND((land_ne_sqkm_2020/land_sqkm*100)::numeric,2) land_ne_perc_land_tot,
ROUND((land_ne_prot_sqkm_2020/land_sqkm*100)::numeric,2) land_ne_prot_perc_land_tot,
ROUND((land_ne_prot_sqkm_2020/land_ne_sqkm_2020*100)::numeric,2) land_ne_prot_perc_land_ne,
ROUND((land_ne_prot_sqkm_2020/land_prot_sqkm*100)::numeric,2) land_ne_prot_perc_land_prot
FROM a)
SELECT * FROM b
;
SELECT * FROM global_1995_2025_land_ne_prt;