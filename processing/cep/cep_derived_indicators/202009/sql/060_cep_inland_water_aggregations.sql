-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS
SELECT * FROM results_202009.r_stats_cep_gsw_transitions;
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
a as (SELECT * FROM country_index a JOIN cep_theme b USING(cid) WHERE is_marine IS FALSE),
b AS (SELECT country,SUM(sqkm) tot_sqkm FROM a GROUP BY country),
c AS (SELECT country,cat,SUM(cat_sqkm) sqkm FROM a GROUP BY country,cat),
d AS (SELECT country,cat,SUM(cat_sqkm) prot_sqkm FROM a WHERE is_protected=TRUE GROUP BY country,cat)
SELECT *
FROM b
LEFT JOIN c USING(country)
LEFT JOIN d USING(country,cat)
ORDER BY country,cat;
SELECT * FROM country_theme;
-- country_theme_output
DROP TABLE IF EXISTS cep_202009_country_gsw_output; CREATE TEMPORARY TABLE cep_202009_country_gsw_output AS
WITH
list AS (SELECT DISTINCT country FROM country_theme),
--Permanent water by country  (tot and prot)
perm2018 AS (SELECT country, SUM(sqkm) perm2018 FROM country_theme where cat=1 OR cat=2 OR cat=7 GROUP BY country),
perm1984 AS (SELECT country, SUM(sqkm) perm1984 FROM country_theme where cat=1 OR cat=3 OR cat=8 GROUP BY country),
perm2018_prot AS (SELECT country, SUM(prot_sqkm) perm2018_prot FROM country_theme where cat=1 OR cat=2 OR cat=7 GROUP BY country),
perm1984_prot AS (SELECT country, SUM(prot_sqkm) perm1984_prot FROM country_theme where cat=1 OR cat=3 OR cat=8 GROUP BY country),
--Seasonal water by country (tot and prot)
seas2018 AS (SELECT country, SUM(sqkm) seas2018 FROM country_theme where cat=4 OR cat=5 OR cat=8 GROUP BY country),
seas1984 AS (SELECT country, SUM(sqkm) seas1984 FROM country_theme where cat=4 OR cat=6 OR cat=7 GROUP BY country),
seas2018_prot AS (SELECT country, SUM(prot_sqkm) seas2018_prot FROM country_theme where cat=4 OR cat=5 OR cat=8 GROUP BY country),
seas1984_prot AS (SELECT country, SUM(prot_sqkm) seas1984_prot FROM country_theme where cat=4 OR cat=6 OR cat=7 GROUP BY country)
--Netchange by country
SELECT
z.country country_id,
a.perm2018 water_p_now_km2,
b.perm1984 water_p_1985_km2,
a.perm2018-b.perm1984 water_p_netchange_km2,
((a.perm2018-b.perm1984)/b.perm1984)*100 water_p_netchange_perc,
c.perm2018_prot water_p_prot_now_km2,
d.perm1984_prot water_p_prot_1985_km2,
c.perm2018_prot-d.perm1984_prot water_p_prot_netchange_km2,
((c.perm2018_prot-d.perm1984_prot)/d.perm1984_prot)*100 water_p_prot_netchange_perc,
e.seas2018 water_s_now_km2,
f.seas1984 water_s_1985_km2,
e.seas2018-f.seas1984 water_s_netchange_km2,
((e.seas2018-f.seas1984)/f.seas1984)*100 water_s_netchange_perc,
g.seas2018_prot water_s_prot_now_km2,
h.seas1984_prot water_s_prot_1985_km2,
g.seas2018_prot-h.seas1984_prot water_s_prot_netchange_km2,
((g.seas2018_prot-h.seas1984_prot)/h.seas1984_prot)*100  water_s_prot_netchange_perc
FROM
list z
LEFT JOIN perm2018 a USING(country) 
LEFT JOIN perm1984 b USING(country)
LEFT JOIN seas2018 e USING(country)
LEFT JOIN seas1984 f USING(country)
LEFT JOIN perm2018_prot c USING(country)
LEFT JOIN perm1984_prot d USING(country)
LEFT JOIN seas2018_prot g USING(country)
LEFT JOIN seas1984_prot h USING(country)
ORDER BY z.country;

--------------------------------------------
-- ECOREGION
--------------------------------------------
-- ecoregion_theme_aggregations
DROP TABLE IF EXISTS ecoregion_theme;CREATE TEMPORARY TABLE ecoregion_theme AS
WITH
a as (SELECT * FROM ecoregion_index a JOIN cep_theme b USING(cid)),
b AS (SELECT ecoregion,SUM(sqkm) tot_sqkm FROM a GROUP BY ecoregion),
c AS (SELECT ecoregion,cat,SUM(cat_sqkm) sqkm FROM a GROUP BY ecoregion,cat),
d AS (SELECT ecoregion,cat,SUM(cat_sqkm) prot_sqkm FROM a WHERE is_protected=TRUE GROUP BY ecoregion,cat)
SELECT * FROM b
LEFT JOIN c USING(ecoregion)
LEFT JOIN d USING(ecoregion,cat)
ORDER BY ecoregion,cat;

-- ecoregion_theme_output
DROP TABLE IF EXISTS cep_202009_eco_gsw_output; CREATE TEMPORARY TABLE cep_202009_eco_gsw_output AS
WITH
list AS (SELECT DISTINCT ecoregion FROM ecoregion_theme),
--Permanent water by ecoregion  (tot and prot)
perm2018 AS (SELECT ecoregion, SUM(sqkm) perm2018 FROM ecoregion_theme where cat=1 OR cat=2 OR cat=7 GROUP BY ecoregion),
perm1984 AS (SELECT ecoregion, SUM(sqkm) perm1984 FROM ecoregion_theme where cat=1 OR cat=3 OR cat=8 GROUP BY ecoregion),
perm2018_prot AS (SELECT ecoregion, SUM(prot_sqkm) perm2018_prot FROM ecoregion_theme where cat=1 OR cat=2 OR cat=7 GROUP BY ecoregion),
perm1984_prot AS (SELECT ecoregion, SUM(prot_sqkm) perm1984_prot FROM ecoregion_theme where cat=1 OR cat=3 OR cat=8 GROUP BY ecoregion),
--Seasonal water by ecoregion (tot and prot)
seas2018 AS (SELECT ecoregion, SUM(sqkm) seas2018 FROM ecoregion_theme where cat=4 OR cat=5 OR cat=8 GROUP BY ecoregion),
seas1984 AS (SELECT ecoregion, SUM(sqkm) seas1984 FROM ecoregion_theme where cat=4 OR cat=6 OR cat=7 GROUP BY ecoregion),
seas2018_prot AS (SELECT ecoregion, SUM(prot_sqkm) seas2018_prot FROM ecoregion_theme where cat=4 OR cat=5 OR cat=8 GROUP BY ecoregion),
seas1984_prot AS (SELECT ecoregion, SUM(prot_sqkm) seas1984_prot FROM ecoregion_theme where cat=4 OR cat=6 OR cat=7 GROUP BY ecoregion)
--Netchange by ecoregion
SELECT
z.ecoregion eco_id,
a.perm2018 water_p_now_km2,
b.perm1984 water_p_1985_km2,
a.perm2018-b.perm1984 water_p_netchange_km2,
((a.perm2018-b.perm1984)/b.perm1984)*100 water_p_netchange_perc,
c.perm2018_prot water_p_prot_now_km2,
d.perm1984_prot water_p_prot_1985_km2,
c.perm2018_prot-d.perm1984_prot water_p_prot_netchange_km2,
((c.perm2018_prot-d.perm1984_prot)/d.perm1984_prot)*100 water_p_prot_netchange_perc,
e.seas2018 water_s_now_km2,
f.seas1984 water_s_1985_km2,
e.seas2018-f.seas1984 water_s_netchange_km2,
((e.seas2018-f.seas1984)/f.seas1984)*100 water_s_netchange_perc,
g.seas2018_prot water_s_prot_now_km2,
h.seas1984_prot water_s_prot_1985_km2,
g.seas2018_prot-h.seas1984_prot water_s_prot_netchange_km2,
((g.seas2018_prot-h.seas1984_prot)/h.seas1984_prot)*100  water_s_prot_netchange_perc
FROM
list z
LEFT JOIN perm2018 a USING(ecoregion)
LEFT JOIN perm1984 b USING(ecoregion)
LEFT JOIN seas2018 e USING(ecoregion)
LEFT JOIN seas1984 f USING(ecoregion)
LEFT JOIN perm2018_prot c USING(ecoregion)
LEFT JOIN perm1984_prot d USING(ecoregion)
LEFT JOIN seas2018_prot g USING(ecoregion)
LEFT JOIN seas1984_prot h USING(ecoregion)
ORDER BY z.ecoregion;

----------------------------------------
-- PROTECTION
-- protection_theme_aggregations
DROP TABLE IF EXISTS protection_theme;CREATE TEMPORARY TABLE protection_theme AS
WITH
a as (SELECT * FROM pa_index a JOIN cep_theme b USING(cid) WHERE marine IN (0,1)),
b AS (SELECT pa,SUM(sqkm) tot_sqkm FROM a GROUP BY pa),
c AS (SELECT pa,cat,SUM(cat_sqkm) sqkm FROM a GROUP BY pa,cat),
d AS (SELECT pa,cat,SUM(cat_sqkm) prot_sqkm FROM a GROUP BY pa,cat)
SELECT * FROM b
LEFT JOIN c USING(pa)
LEFT JOIN d USING(pa,cat)
ORDER BY pa,cat;
SELECT * FROM protection_theme;
-- protection_theme_output
DROP TABLE IF EXISTS cep_202009_pa_gsw_output; CREATE TEMPORARY TABLE cep_202009_pa_gsw_output AS
WITH
--Permanent water by pa  (tot and prot)
list AS (SELECT DISTINCT pa FROM protection_theme),
perm2018 AS (SELECT pa, SUM(sqkm) perm2018 FROM protection_theme where cat=1 OR cat=2 OR cat=7 GROUP BY pa),
perm1984 AS (SELECT pa, SUM(sqkm) perm1984 FROM protection_theme where cat=1 OR cat=3 OR cat=8 GROUP BY pa),
perm2018_prot AS (SELECT pa, SUM(prot_sqkm) perm2018_prot FROM protection_theme where cat=1 OR cat=2 OR cat=7 GROUP BY pa),
perm1984_prot AS (SELECT pa, SUM(prot_sqkm) perm1984_prot FROM protection_theme where cat=1 OR cat=3 OR cat=8 GROUP BY pa),
--Seasonal water by pa (tot and prot)
seas2018 AS (SELECT pa, SUM(sqkm) seas2018 FROM protection_theme where cat=4 OR cat=5 OR cat=8 GROUP BY pa),
seas1984 AS (SELECT pa, SUM(sqkm) seas1984 FROM protection_theme where cat=4 OR cat=6 OR cat=7 GROUP BY pa),
seas2018_prot AS (SELECT pa, SUM(prot_sqkm) seas2018_prot FROM protection_theme where cat=4 OR cat=5 OR cat=8 GROUP BY pa),
seas1984_prot AS (SELECT pa, SUM(prot_sqkm) seas1984_prot FROM protection_theme where cat=4 OR cat=6 OR cat=7 GROUP BY pa)
--Netchange by pa
SELECT 
z.pa wdpaid,
a.perm2018 water_p_now_km2,
b.perm1984 water_p_1985_km2,
a.perm2018-b.perm1984 water_p_netchange_km2,
((a.perm2018-b.perm1984)/b.perm1984)*100 water_p_netchange_perc,
--c.perm2018_prot water_p_prot_now_km2,
--d.perm1984_prot water_p_prot_1985_km2,
c.perm2018_prot-d.perm1984_prot water_p_prot_netchange_km2,
((c.perm2018_prot-d.perm1984_prot)/d.perm1984_prot)*100 water_p_prot_netchange_perc,
e.seas2018 water_s_now_km2,
f.seas1984 water_s_1985_km2,
e.seas2018-f.seas1984 water_s_netchange_km2,
((e.seas2018-f.seas1984)/f.seas1984)*100 water_s_netchange_perc,
g.seas2018_prot water_s_prot_now_km2--,
--h.seas1984_prot water_s_prot_1985_km2,
--g.seas2018_prot-h.seas1984_prot water_s_prot_netchange_km2,
--((g.seas2018_prot-h.seas1984_prot)/h.seas1984_prot)*100  water_s_prot_netchange_perc
FROM 
list z
LEFT JOIN perm2018 a USING(pa) 
LEFT JOIN perm1984 b USING(pa)
LEFT JOIN seas2018 e USING(pa)
LEFT JOIN seas1984 f USING(pa)
LEFT JOIN perm2018_prot c USING(pa)
LEFT JOIN perm1984_prot d USING(pa)
LEFT JOIN seas2018_prot g USING(pa)
LEFT JOIN seas1984_prot h USING(pa)
ORDER BY z.pa;

--------------------------------------------
-- OUTPUT TABLES
--------------------------------------------

DROP TABLE IF EXISTS results_202009.country_surface_inland_water;
CREATE TABLE results_202009.country_surface_inland_water AS
SELECT * FROM cep_202009_country_gsw_output;

DROP TABLE IF EXISTS results_202009.ecoregion_surface_inland_water;
CREATE TABLE results_202009.ecoregion_surface_inland_water AS
SELECT * FROM cep_202009_eco_gsw_output WHERE eco_id IN (SELECT ecoregion FROM ecoregion_index WHERE is_marine IS FALSE);

DROP TABLE IF EXISTS results_202009.wdpa_surface_inland_water;
CREATE TABLE results_202009.wdpa_surface_inland_water AS
SELECT * FROM cep_202009_pa_gsw_output;
