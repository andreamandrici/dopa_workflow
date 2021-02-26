-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS SELECT * FROM :v1.:v2;
------------------------------------------------------------
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS SELECT * FROM cep.index_country_cep_last;
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS SELECT * FROM cep.index_ecoregion_cep_last;
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last;
------------------------------------------------------------------
\set vmin '_':v3'_min'
\set vmax '_':v3'_max'
\set vmean '_':v3'_mean'
\set vsum '_':v3'_sum'
\set vtot '_tot'
\set vprot '_prot'
\set vunprot '_unprot'
\set vland '_land'
\set vmar '_marine'
-- COUNTRY
\set vtab 'country'
-- COUNTRY TOT
DROP TABLE IF EXISTS :vtab:vtot;CREATE TEMPORARY TABLE :vtab:vtot AS
SELECT country country_id,MIN(min) :vtab:vtot:vmin,MAX(max) :vtab:vtot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vmean,SUM(sum) :vtab:vtot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
-- COUNTRY TOT PROT
DROP TABLE IF EXISTS :vtab:vtot:vprot;CREATE TEMPORARY TABLE :vtab:vtot:vprot AS
SELECT country country_id,MIN(min) :vtab:vtot:vprot:vmin,MAX(max) :vtab:vtot:vprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vprot:vmean,SUM(sum) :vtab:vtot:vprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_protected IS TRUE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
-- COUNTRY TOT UNPROT
DROP TABLE IF EXISTS :vtab:vtot:vunprot;CREATE TEMPORARY TABLE :vtab:vtot:vunprot AS
SELECT country country_id,MIN(min) :vtab:vtot:vunprot:vmin,MAX(max) :vtab:vtot:vunprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vunprot:vmean,SUM(sum) :vtab:vtot:vunprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_protected IS FALSE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY LAND
DROP TABLE IF EXISTS :vtab:vland;CREATE TEMPORARY TABLE :vtab:vland AS
SELECT country country_id,MIN(min) :vtab:vland:vmin,MAX(max) :vtab:vland:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vland:vmean,SUM(sum) :vtab:vland:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY LAND PROT
DROP TABLE IF EXISTS :vtab:vland:vprot;CREATE TEMPORARY TABLE :vtab:vland:vprot AS
SELECT country country_id,MIN(min) :vtab:vland:vprot:vmin,MAX(max) :vtab:vland:vprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vland:vprot:vmean,SUM(sum) :vtab:vland:vprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE AND is_protected IS TRUE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY LAND UNPROT
DROP TABLE IF EXISTS :vtab:vland:vunprot;CREATE TEMPORARY TABLE :vtab:vland:vunprot AS
SELECT country country_id,MIN(min) :vtab:vland:vunprot:vmin,MAX(max) :vtab:vland:vunprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vland:vunprot:vmean,SUM(sum) :vtab:vland:vunprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE AND is_protected IS FALSE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY MARINE
DROP TABLE IF EXISTS :vtab:vmar;CREATE TEMPORARY TABLE :vtab:vmar AS
SELECT country country_id,MIN(min) :vtab:vmar:vmin,MAX(max) :vtab:vmar:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vmar:vmean,SUM(sum) :vtab:vmar:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY MARINE PROT
DROP TABLE IF EXISTS :vtab:vmar:vprot;CREATE TEMPORARY TABLE :vtab:vmar:vprot AS
SELECT country country_id,MIN(min) :vtab:vmar:vprot:vmin,MAX(max) :vtab:vmar:vprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vmar:vprot:vmean,SUM(sum) :vtab:vmar:vprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE AND is_protected IS TRUE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
--COUNTRY MARINE UNPROT
DROP TABLE IF EXISTS :vtab:vmar:vunprot;CREATE TEMPORARY TABLE :vtab:vmar:vunprot AS
SELECT country country_id,MIN(min) :vtab:vmar:vunprot:vmin,MAX(max) :vtab:vmar:vunprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vmar:vunprot:vmean,SUM(sum) :vtab:vmar:vunprot:vsum
FROM (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE AND is_protected IS FALSE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY country ORDER BY country;
----------------------------------------
-- ECOREGION
\set vtab 'ecoregion'
-- ECOREGION TOT
DROP TABLE IF EXISTS :vtab:vtot;CREATE TEMPORARY TABLE :vtab:vtot AS
SELECT ecoregion eco_id,MIN(min) :vtab:vtot:vmin,MAX(max) :vtab:vtot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vmean,SUM(sum) :vtab:vtot:vsum
FROM (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY ecoregion ORDER BY ecoregion;
-- ECOREGION PROT
DROP TABLE IF EXISTS :vtab:vtot:vprot;CREATE TEMPORARY TABLE :vtab:vtot:vprot AS
SELECT ecoregion eco_id,MIN(min) :vtab:vtot:vprot:vmin,MAX(max) :vtab:vtot:vprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vprot:vmean,SUM(sum) :vtab:vtot:vprot:vsum
FROM (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_protected IS TRUE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY ecoregion ORDER BY ecoregion;
-- ECOREGION UNPROT
DROP TABLE IF EXISTS :vtab:vtot:vunprot;CREATE TEMPORARY TABLE :vtab:vtot:vunprot AS
SELECT ecoregion eco_id,MIN(min) :vtab:vtot:vunprot:vmin,MAX(max) :vtab:vtot:vunprot:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vtot:vunprot:vmean,SUM(sum) :vtab:vtot:vunprot:vsum
FROM (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_protected IS FALSE)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY ecoregion ORDER BY ecoregion;
----------------------------------------
-- PROTECTION
\set vtab 'pa'
DROP TABLE IF EXISTS :vtab;CREATE TEMPORARY TABLE :vtab AS
SELECT pa wdpaid,MIN(min) :vtab:vmin,MAX(max) :vtab:vmax,SUM(mean*area_m2)/SUM(area_m2) :vtab:vmean,SUM(sum) :vtab:vsum
FROM (SELECT DISTINCT pa,qid,cid,(sqkm*1000000) area_m2  FROM pa_index)a
JOIN (SELECT qid,cid,min,max,mean,sum FROM theme)b USING(qid,cid)
GROUP BY pa ORDER BY pa;

-------------------------------------------------------------
-- OUTPUTS
-------------------------------------------------------------
-- country
DROP TABLE IF EXISTS results_aggregated.country_:v3;
CREATE TABLE results_aggregated.country_:v3 AS
SELECT * FROM country_tot a 
LEFT JOIN country_tot_prot b USING(country_id)
LEFT JOIN country_tot_unprot c USING(country_id)
LEFT JOIN country_land d USING(country_id)
LEFT JOIN country_land_prot e USING(country_id)
LEFT JOIN country_land_unprot f USING(country_id)
LEFT JOIN country_marine g USING(country_id)
LEFT JOIN country_marine_prot h USING(country_id)
LEFT JOIN country_marine_unprot i USING(country_id);
-- ecoregion
DROP TABLE IF EXISTS results_aggregated.ecoregion_:v3;
CREATE TABLE results_aggregated.ecoregion_:v3 AS
SELECT * FROM ecoregion_tot a
LEFT JOIN ecoregion_tot_prot b USING(eco_id)
LEFT JOIN ecoregion_tot_unprot c USING(eco_id);
-- pa
DROP TABLE IF EXISTS results_aggregated.wdpa_:v3;
CREATE TABLE results_aggregated.wdpa_:v3 AS
SELECT * FROM pa;
