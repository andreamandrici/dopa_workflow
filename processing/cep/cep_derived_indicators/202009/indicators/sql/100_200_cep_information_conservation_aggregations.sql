-- SET THE OUTPUT_SCHEME IN THE LAST LINES!!!
---------------------------------------------------------------------------------------
-- country_block
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS t_country_tot;CREATE TEMPORARY TABLE t_country_tot AS
SELECT country,SUM(sqkm) country_tot_sqkm FROM cep.index_country_cep_last GROUP BY country ORDER BY country;
DROP TABLE IF EXISTS t_country_land;CREATE TEMPORARY TABLE t_country_land AS
SELECT country,SUM(sqkm) country_land_sqkm FROM cep.index_country_cep_last WHERE is_marine IS FALSE GROUP BY country ORDER BY country;
DROP TABLE IF EXISTS t_country_marine;CREATE TEMPORARY TABLE t_country_marine AS
SELECT country,SUM(sqkm) country_marine_sqkm FROM cep.index_country_cep_last WHERE is_marine IS TRUE GROUP BY country ORDER BY country;
DROP TABLE IF EXISTS t_country_prot ;CREATE TEMPORARY TABLE t_country_prot AS
SELECT country,SUM(sqkm) country_prot_sqkm FROM cep.index_country_cep_last WHERE is_protected IS TRUE GROUP BY country ORDER BY country;
DROP TABLE IF EXISTS t_country_land_prot;CREATE TEMPORARY TABLE t_country_land_prot AS
SELECT country,SUM(sqkm) country_land_prot_sqkm FROM cep.index_country_cep_last WHERE is_marine IS FALSE AND is_protected IS TRUE GROUP BY country ORDER BY country;
DROP TABLE IF EXISTS t_country_marine_prot;CREATE TEMPORARY TABLE t_country_marine_prot AS
SELECT country,SUM(sqkm) country_marine_prot_sqkm FROM cep.index_country_cep_last WHERE is_marine IS TRUE AND is_protected IS TRUE GROUP BY country ORDER BY country;
---------------------------------------------------------------------------------------
-- ecoregion_block
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS t_ecoregion_tot;CREATE TEMPORARY TABLE t_ecoregion_tot AS
SELECT ecoregion,SUM(sqkm) ecoregion_tot_sqkm FROM cep.index_ecoregion_cep_last GROUP BY ecoregion ORDER BY ecoregion;
DROP TABLE IF EXISTS t_ecoregion_prot;CREATE TEMPORARY TABLE t_ecoregion_prot AS
SELECT ecoregion,SUM(sqkm) ecoregion_prot_sqkm FROM cep.index_ecoregion_cep_last WHERE is_protected IS TRUE GROUP BY ecoregion ORDER BY ecoregion;
---------------------------------------------------------------------------------------
-- country_ecoregion_block
---------------------------------------------------------------------------------------
-- country_ecoregion_land_marine_protection (celmp)
DROP TABLE IF EXISTS celmp;CREATE TEMPORARY TABLE celmp AS 
WITH a AS (SELECT * FROM cep.index_country_cep_last a NATURAL JOIN cep.index_ecoregion_cep_last b)
SELECT country,ecoregion,is_marine,is_protected,SUM(sqkm) sqkm FROM a GROUP BY country,ecoregion,is_marine,is_protected ORDER BY country,ecoregion;
---------------------------------------------------------------------------------------
-- country_ecoregion_block
DROP TABLE IF EXISTS t_country_eco;CREATE TEMPORARY TABLE t_country_eco AS
WITH
a AS (SELECT country,ecoregion,SUM(sqkm) country_eco_sqkm FROM celmp GROUP BY country,ecoregion ORDER BY country,ecoregion),
b AS (SELECT country,ecoregion,SUM(sqkm) country_eco_prot_sqkm FROM celmp WHERE is_protected IS TRUE GROUP BY country,ecoregion ORDER BY country,ecoregion)
SELECT * FROM a LEFT JOIN b USING(country,ecoregion);

DROP TABLE IF EXISTS t_country_eco_all; CREATE TEMPORARY TABLE t_country_eco_all AS
SELECT *
FROM t_country_eco a
LEFT JOIN t_country_tot b USING(country)
LEFT JOIN t_country_land c USING(country)
LEFT JOIN t_country_marine d USING(country)
LEFT JOIN t_country_prot e USING(country)
LEFT JOIN t_country_land_prot f USING(country)
LEFT JOIN t_country_marine_prot g USING(country)
LEFT JOIN t_ecoregion_tot h USING(ecoregion)
LEFT JOIN t_ecoregion_prot i USING(ecoregion);
--------------------------------------------------------------------------------------
-- country stats block
---------------------------------------------------------------------------------------
-- country
DROP TABLE IF EXISTS output_country; CREATE TEMPORARY TABLE output_country AS
SELECT
a.country country_id,a.country_name,a.iso3 country_iso3,a.iso2 country_iso2,a.un_m49 country_un_m49,a.status,
country_tot_sqkm area_tot_km2,country_prot_sqkm area_prot_km2,ROUND((country_prot_sqkm/country_tot_sqkm*100)::numeric,3) area_prot_perc,
country_land_sqkm area_terr_km2,ROUND((country_land_sqkm/country_tot_sqkm*100)::numeric,3) area_terr_perc,
country_land_prot_sqkm area_prot_terr_km2,ROUND((country_land_prot_sqkm/country_land_sqkm*100)::numeric,3) area_prot_terr_perc,
country_marine_sqkm area_mar_km2,ROUND((country_marine_sqkm/country_tot_sqkm*100)::numeric,3) area_mar_perc,
country_marine_prot_sqkm area_prot_mar_km2,ROUND((country_marine_prot_sqkm/country_marine_sqkm*100)::numeric,3) area_prot_mar_perc
FROM cep.atts_country_last a
JOIN t_country_eco_all b USING(country)
GROUP BY country,country_name,iso3,iso2,un_m49,status,country_tot_sqkm,country_prot_sqkm,country_land_sqkm,country_land_prot_sqkm,country_marine_sqkm,country_marine_prot_sqkm
ORDER BY country_id;
---------------------------------------------------------------------------------------
-- ecoregion in country
DROP TABLE IF EXISTS output_ecoregion_in_country CASCADE; CREATE TEMPORARY TABLE output_ecoregion_in_country AS
SELECT
--country portion-----------------------------------------------------------
--country identifiers and attributes
a.country country_id,a.country_name,a.iso3,a.iso2,a.un_m49,a.status,
--country metrics
b.country_tot_sqkm,b.country_prot_sqkm,
b.country_land_sqkm,b.country_land_prot_sqkm,
b.country_marine_sqkm,b.country_marine_prot_sqkm,
--ecoregion portion-----------------------------------------------------------
--ecoregion identifiers and attributes
c.ecoregion_name ecoregion,c.ecoregion eco_id,c.source,c.is_marine,
--ecoregion metrics
b.ecoregion_tot_sqkm,b.ecoregion_prot_sqkm,
--country-ecoregion portion-----------------------------------------------------------
--country-ecoregion identifiers
a.country||'_'||c.ecoregion country_eco_id,
--country-ecoregion metrics
b.country_eco_sqkm,--corresponds to REST get_country_ecoregions_stats.area_km2
b.country_eco_prot_sqkm,
--country-ecoregion statistics
--as percentage of country-ecoregion
ROUND((b.country_eco_prot_sqkm/b.country_eco_sqkm*100)::numeric,3) country_eco_prot_perc_country_eco,
--as percentage of ecoregion
ROUND((b.country_eco_sqkm/b.ecoregion_tot_sqkm*100)::numeric,3) country_eco_perc_ecoregion_tot,
ROUND((b.country_eco_prot_sqkm/b.ecoregion_tot_sqkm*100)::numeric,3) country_eco_prot_perc_ecoregion_tot,
ROUND((b.country_eco_prot_sqkm/b.ecoregion_prot_sqkm*100)::numeric,3) country_eco_prot_perc_ecoregion_prot,
--as percentage of country
--tot
ROUND((b.country_eco_sqkm/b.country_tot_sqkm*100)::numeric,3) country_eco_perc_country_tot,
ROUND((b.country_eco_prot_sqkm/b.country_tot_sqkm*100)::numeric,3) country_eco_prot_perc_country_tot,
ROUND((b.country_eco_prot_sqkm/b.country_prot_sqkm*100)::numeric,3) country_eco_prot_perc_country_prot,
--land
ROUND((b.country_eco_sqkm/b.country_land_sqkm*100)::numeric,3) country_eco_perc_country_land,
ROUND((b.country_eco_prot_sqkm/b.country_land_sqkm*100)::numeric,3) country_eco_prot_perc_country_land,
ROUND((b.country_eco_prot_sqkm/b.country_land_prot_sqkm*100)::numeric,3) country_eco_prot_perc_country_land_prot,
--marine
ROUND((b.country_eco_sqkm/b.country_marine_sqkm*100)::numeric,3) country_eco_perc_country_marine,
ROUND((b.country_eco_prot_sqkm/b.country_marine_sqkm*100)::numeric,3) country_eco_prot_perc_country_marine,
ROUND((b.country_eco_prot_sqkm/b.country_marine_prot_sqkm*100)::numeric,3) country_eco_prot_perc_country_marine_prot
FROM cep.atts_country_last a
LEFT JOIN t_country_eco_all b USING(country)
LEFT JOIN cep.atts_ecoregion_last c USING(ecoregion)
ORDER BY a.country,c.ecoregion;

--------------------------------------------------------------------------------------
-- ecoregion stats block
---------------------------------------------------------------------------------------
-- ecoregion
DROP TABLE IF EXISTS output_ecoregion; CREATE TEMPORARY TABLE output_ecoregion AS
SELECT
a.ecoregion eco_id,a.ecoregion_name eco_name,a.second_level_code biome_id,a.second_level biome_name,a.third_level_code realm_id,a.third_level realm_name,a.source,a.is_marine,
ecoregion_tot_sqkm area_tot_km2,ecoregion_prot_sqkm area_prot_km2,ROUND((ecoregion_prot_sqkm/ecoregion_tot_sqkm*100)::numeric,3) area_prot_perc
FROM cep.atts_ecoregion_last a
JOIN t_country_eco_all b USING(ecoregion)
GROUP BY ecoregion,ecoregion_name,second_level_code,second_level,third_level_code,third_level,source,is_marine,ecoregion_tot_sqkm,ecoregion_prot_sqkm
ORDER BY ecoregion;

--------------------------------------------------------------------------------------
-- OUTPUT BLOC --SET OUTPUT SCHEME
--------------------------------------------------------------------------------------
-- country table
DROP TABLE IF EXISTS results_202009_cep_out.country_conservation_coverage CASCADE;CREATE TABLE results_202009_cep_out.country_conservation_coverage AS
SELECT * FROM output_country ORDER BY country_id;

-- ecoregion_in_country table
DROP TABLE IF EXISTS results_202009_cep_out.country_conservation_coverage_ecoregions_stats CASCADE;CREATE TABLE results_202009_cep_out.country_conservation_coverage_ecoregions_stats AS
SELECT * FROM output_ecoregion_in_country ORDER BY country_id,eco_id;

-- ecoregion table
DROP TABLE IF EXISTS results_202009_cep_out.ecoregion_conservation_coverage CASCADE;CREATE TABLE results_202009_cep_out.ecoregion_conservation_coverage AS
SELECT * FROM output_ecoregion a ORDER BY eco_id;

-- pa table
DROP TABLE IF EXISTS results_202009_cep_out.wdpa_conservation_coverage CASCADE;CREATE TABLE results_202009_cep_out.wdpa_conservation_coverage AS
SELECT a.pa wdpaid,a.pa_name,a.desig_eng,a.iucn_cat,a.marine,a.is_n2k,a.iso3,a.type,a.area_geo FROM cep.atts_pa_last a ORDER BY wdpaid;


