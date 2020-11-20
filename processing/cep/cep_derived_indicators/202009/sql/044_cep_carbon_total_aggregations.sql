-- country
DROP TABLE IF EXISTS results_202009.country_total_carbon;
CREATE TABLE results_202009.country_total_carbon AS
WITH
a AS (SELECT country_id,agb_tot_c_pg_total c_pg_total,agb_tot_c_pg_prot c_pg_prot,agb_tot_c_pg_unprot c_pg_unprot  FROM results_202009.country_above_ground_carbon),
b AS (SELECT country_id,bgb_tot_c_pg_total c_pg_total,bgb_tot_c_pg_prot c_pg_prot,bgb_tot_c_pg_unprot c_pg_unprot FROM results_202009.country_belowground_biomass_carbon),
c AS (SELECT country_id,gsoc_tot_c_pg_total c_pg_total,gsoc_tot_c_pg_prot c_pg_prot,gsoc_tot_c_pg_unprot c_pg_unprot FROM results_202009.country_soil_organic_carbon),
d AS (SELECT * FROM a UNION SELECT * FROM b UNION SELECT * FROM c)
SELECT country_id,SUM(c_pg_total) carbon_tot_c_pg_total,SUM(c_pg_prot) carbon_tot_c_pg_prot,SUM(c_pg_unprot) carbon_tot_c_pg_unprot FROM d GROUP BY country_id ORDER BY country_id;
-- ecoregion
DROP TABLE IF EXISTS results_202009.ecoregion_total_carbon;
CREATE TABLE results_202009.ecoregion_total_carbon AS
WITH
a AS (SELECT eco_id,agb_tot_c_pg_total c_pg_total,agb_tot_c_pg_prot c_pg_prot,agb_tot_c_pg_unprot c_pg_unprot  FROM results_202009.ecoregion_above_ground_carbon),
b AS (SELECT eco_id,bgb_tot_c_pg_total c_pg_total,bgb_tot_c_pg_prot c_pg_prot,bgb_tot_c_pg_unprot c_pg_unprot FROM results_202009.ecoregion_belowground_biomass_carbon),
c AS (SELECT eco_id,gsoc_tot_c_pg_total c_pg_total,gsoc_tot_c_pg_prot c_pg_prot,gsoc_tot_c_pg_unprot c_pg_unprot FROM results_202009.ecoregion_soil_organic_carbon),
d AS (SELECT * FROM a UNION SELECT * FROM b UNION SELECT * FROM c)
SELECT eco_id,SUM(c_pg_total) carbon_tot_c_pg_total,SUM(c_pg_prot) carbon_tot_c_pg_prot,SUM(c_pg_unprot) carbon_tot_c_pg_unprot FROM d GROUP BY eco_id ORDER BY eco_id;
-- wdpa
DROP TABLE IF EXISTS results_202009.wdpa_total_carbon;
CREATE TABLE results_202009.wdpa_total_carbon AS
WITH
a AS (SELECT wdpaid,agb_tot_c_mg c_pg_total FROM results_202009.wdpa_above_ground_carbon),
b AS (SELECT wdpaid,bgb_tot_c_mg c_pg_total FROM results_202009.wdpa_belowground_biomass_carbon),
c AS (SELECT wdpaid,gsoc_tot_c_mg c_pg_total FROM results_202009.wdpa_soil_organic_carbon),
d AS (SELECT * FROM a UNION SELECT * FROM b UNION SELECT * FROM c)
SELECT wdpaid,SUM(c_pg_total) carbon_tot_c_mg FROM d GROUP BY wdpaid ORDER BY wdpaid;

