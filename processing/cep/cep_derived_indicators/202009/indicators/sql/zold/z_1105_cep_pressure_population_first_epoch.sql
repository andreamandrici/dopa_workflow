-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS SELECT * FROM :v1.:v2;
------------------------------------------------------------
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS SELECT * FROM cep.index_country_cep_last;
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS SELECT * FROM cep.index_ecoregion_cep_last;
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last;
------------------------------------------------------------------
-- COUNTRY
-- COUNTRY TOT
DROP TABLE IF EXISTS country_tot; CREATE TEMPORARY TABLE country_tot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min) country_tot_min_:v3,MAX(max) country_tot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_tot_mean_:v3,SUM(sum) country_tot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_tot_prot; CREATE TEMPORARY TABLE country_tot_prot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min) country_tot_prot_min_:v3,MAX(max) country_tot_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_tot_prot_mean_:v3,SUM(sum) country_tot_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_tot_unprot; CREATE TEMPORARY TABLE country_tot_unprot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_tot_unprot_min_:v3,MAX(max) country_tot_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_tot_unprot_mean_:v3,SUM(sum) country_tot_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;
--COUNTRY LAND
DROP TABLE IF EXISTS country_land; CREATE TEMPORARY TABLE country_land AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min) country_land_min_:v3,MAX(max)country_land_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_land_mean_:v3,SUM(sum) country_land_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_land_prot; CREATE TEMPORARY TABLE country_land_prot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE AND is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_land_prot_min_:v3,MAX(max)country_land_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_land_prot_mean_:v3,SUM(sum) country_land_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_land_unprot; CREATE TEMPORARY TABLE country_land_unprot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS FALSE AND is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_land_unprot_min_:v3,MAX(max)country_land_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_land_unprot_mean_:v3,SUM(sum) country_land_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;
--COUNTRY MARINE
DROP TABLE IF EXISTS country_marine; CREATE TEMPORARY TABLE country_marine AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_marine_min_:v3,MAX(max)country_marine_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_marine_mean_:v3,SUM(sum) country_marine_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_marine_prot; CREATE TEMPORARY TABLE country_marine_prot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE AND is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_marine_prot_min_:v3,MAX(max)country_marine_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_marine_prot_mean_:v3,SUM(sum) country_marine_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

DROP TABLE IF EXISTS country_marine_unprot; CREATE TEMPORARY TABLE country_marine_unprot AS
WITH
a AS (SELECT DISTINCT country,qid,cid,(sqkm*1000000) area_m2 FROM country_index WHERE is_marine IS TRUE AND is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT country country_id ,MIN(min)country_marine_unprot_min_:v3,MAX(max)country_marine_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) country_marine_unprot_mean_:v3,SUM(sum) country_marine_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY country ORDER BY country;

----------------------------------------
-- ECOREGION
-- ECOREGION TOT
DROP TABLE IF EXISTS eco_tot; CREATE TEMPORARY TABLE eco_tot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_tot_min_:v3,MAX(max)ecoregion_tot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_tot_mean_:v3,SUM(sum) ecoregion_tot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_tot_prot; CREATE TEMPORARY TABLE eco_tot_prot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_tot_prot_min_:v3,MAX(max)ecoregion_tot_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_tot_prot_mean_:v3,SUM(sum) ecoregion_tot_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_tot_unprot; CREATE TEMPORARY TABLE eco_tot_unprot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_tot_unprot_min_:v3,MAX(max)ecoregion_tot_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_tot_unprot_mean_:v3,SUM(sum) ecoregion_tot_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

-- ECOREGION LAND
DROP TABLE IF EXISTS eco_land; CREATE TEMPORARY TABLE eco_land AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_land_min_:v3,MAX(max)ecoregion_land_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_land_mean_:v3,SUM(sum) ecoregion_land_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_land_prot; CREATE TEMPORARY TABLE eco_land_prot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS FALSE AND is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_land_prot_min_:v3,MAX(max)ecoregion_land_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_land_prot_mean_:v3,SUM(sum) ecoregion_land_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_land_unprot; CREATE TEMPORARY TABLE eco_land_unprot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS FALSE AND is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_land_unprot_min_:v3,MAX(max)ecoregion_land_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_land_unprot_mean_:v3,SUM(sum) ecoregion_land_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

-- ECOREGION MARINE
DROP TABLE IF EXISTS eco_marine; CREATE TEMPORARY TABLE eco_marine AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_marine_min_:v3,MAX(max)ecoregion_marine_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_marine_mean_:v3,SUM(sum) ecoregion_marine_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_marine_prot; CREATE TEMPORARY TABLE eco_marine_prot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS TRUE AND is_protected IS TRUE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_marine_prot_min_:v3,MAX(max)ecoregion_marine_prot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_marine_prot_mean_:v3,SUM(sum) ecoregion_marine_prot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

DROP TABLE IF EXISTS eco_marine_unprot; CREATE TEMPORARY TABLE eco_marine_unprot AS
WITH
a AS (SELECT DISTINCT ecoregion,qid,cid,(sqkm*1000000) area_m2 FROM ecoregion_index WHERE is_marine IS TRUE AND is_protected IS FALSE),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT ecoregion eco_id,MIN(min)ecoregion_marine_unprot_min_:v3,MAX(max)ecoregion_marine_unprot_max_:v3,SUM(mean*area_m2)/SUM(area_m2) ecoregion_marine_unprot_mean_:v3,SUM(sum) ecoregion_marine_unprot_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY ecoregion ORDER BY ecoregion;

----------------------------------------
-- PROTECTION
DROP TABLE IF EXISTS pa; CREATE TEMPORARY TABLE pa AS
WITH
a AS (SELECT DISTINCT pa,qid,cid,(sqkm*1000000) area_m2  FROM pa_index),
b AS (SELECT qid,cid,min,max,mean,sum FROM theme)
SELECT pa wdpaid,MIN(min)pa_min_:v3,MAX(max)pa_max_:v3,SUM(mean*area_m2)/SUM(area_m2) pa_mean_:v3,SUM(sum) pa_sum_:v3 FROM a JOIN b USING(qid,cid) GROUP BY pa ORDER BY pa;

-- -------------------------------------------------------------
-- -- OUTPUTS
-- -------------------------------------------------------------
-- country
DROP TABLE IF EXISTS results_aggregated.country_:v3;
CREATE TABLE results_aggregated.country_:v3 AS
SELECT *
FROM country_tot a 
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
SELECT *
FROM eco_tot a
LEFT JOIN eco_tot_prot b USING(eco_id)
LEFT JOIN eco_tot_unprot c USING(eco_id)
LEFT JOIN eco_land d USING(eco_id)
LEFT JOIN eco_land_prot e USING(eco_id)
LEFT JOIN eco_land_unprot f USING(eco_id)
LEFT JOIN eco_marine g USING(eco_id)
LEFT JOIN eco_marine_prot h USING(eco_id)
LEFT JOIN eco_marine_unprot i USING(eco_id);
-- pa
DROP TABLE IF EXISTS results_aggregated.wdpa_:v3;
CREATE TABLE results_aggregated.wdpa_:v3 AS
SELECT * FROM pa;
