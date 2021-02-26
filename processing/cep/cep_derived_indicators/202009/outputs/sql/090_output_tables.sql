-----------------------------------
-- SETUP THE RIGHT INPUT SCHEMA ---
-----------------------------------
DROP SCHEMA IF EXISTS dopa_41 CASCADE;
CREATE SCHEMA dopa_41;
GRANT USAGE ON SCHEMA dopa_41 TO h05ibexro;

-- COUNTRY ------------------------
DROP TABLE IF EXISTS dopa_41.dopa_country_all_inds;
CREATE TABLE dopa_41.dopa_country_all_inds AS
SELECT *
FROM results_202009_cep_out.country_conservation_coverage
LEFT JOIN results_202009_non_cep.country_conservation_connectivity USING(country_id)
LEFT JOIN results_202009_non_cep.country_conservation_kba USING(country_id)
LEFT JOIN results_202009_non_cep.country_conservation_mta USING(country_id)
LEFT JOIN results_202009_cep_out.country_carbon_above_ground USING(country_id)
LEFT JOIN results_202009_cep_out.country_carbon_below_ground USING(country_id)
LEFT JOIN results_202009_cep_out.country_carbon_soil_organic USING(country_id)
LEFT JOIN results_202009_cep_out.country_carbon_total USING(country_id)
LEFT JOIN results_202009_cep_out.country_elevation_profile USING(country_id)
LEFT JOIN results_202009_cep_out.country_global_forest_cover_gain USING(country_id)
LEFT JOIN results_202009_cep_out.country_global_forest_cover_loss USING(country_id)
LEFT JOIN results_202009_cep_out.country_global_forest_cover_treecover USING(country_id)
LEFT JOIN results_202009_cep_out.country_water_surface_inland USING(country_id)
-- LEFT JOIN results_202009_cep_out.country_land_degradation USING(country_id)							-- DA FARE PER 202101 (results_202009.r_stats_cep_lpd)
-- LEFT JOIN results_202009_cep_out.country_land_fragmentation USING(country_id)						-- DA FARE PER 202101 (results_202009.r_stats_cep_mspa_lc_****) 
;

-- REGION ------------------------
DROP TABLE IF EXISTS dopa_41.dopa_regions CASCADE;
CREATE TABLE  dopa_41.dopa_regions AS
SELECT * FROM administrative_units.regions;
GRANT SELECT ON dopa_41.dopa_regions TO h05ibexro;

-- ECOREGION IN COUNTRY ------------------------
DROP TABLE IF EXISTS dopa_41.dopa_country_ecoregion_stats;
DROP TABLE IF EXISTS dopa_41.dopa_country_ecoregion_all_inds;
CREATE TABLE dopa_41.dopa_country_ecoregion_all_inds AS
SELECT * FROM results_202009_cep_out.country_conservation_coverage_ecoregions_stats;

-- ECOREGION ------------------------
DROP TABLE IF EXISTS dopa_41.dopa_ecoregion_all_inds;
CREATE TABLE dopa_41.dopa_ecoregion_all_inds AS
SELECT * FROM results_202009_cep_out.ecoregion_conservation_coverage
LEFT JOIN results_202009_non_cep.ecoregion_conservation_connectivity USING(eco_id)
LEFT JOIN results_202009_non_cep.ecoregion_conservation_kba USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_carbon_above_ground USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_carbon_below_ground USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_carbon_soil_organic USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_carbon_total USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_elevation_profile USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_global_forest_cover_gain USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_global_forest_cover_loss USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_global_forest_cover_treecover USING(eco_id)
LEFT JOIN results_202009_cep_out.ecoregion_water_surface_inland USING(eco_id)
-- LEFT JOIN results_202009_cep_out.ecoregion_land_degradation USING(eco_id)						-- DA FARE PER 202101 (results_202009.r_stats_cep_lpd)
-- LEFT JOIN results_202009_cep_out.ecoregion_land_fragmentation USING(eco_id)						-- DA FARE PER 202101 (results_202009.r_stats_cep_mspa_lc_****) 
-- LEFT JOIN results_202009_cep_out.ecoregion_pressure_livestock USING(eco_id)						-- DA FARE PER 202101 (results_202009_on_hold.r_univar_cep_glw3_*_with_qid)
;

-- PA ------------------------
DROP TABLE IF EXISTS dopa_41.dopa_wdpa_all_inds;
CREATE TABLE dopa_41.dopa_wdpa_all_inds AS
SELECT * FROM results_202009_cep_out.wdpa_conservation_coverage
LEFT JOIN results_202009_cep_out.wdpa_carbon_above_ground USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_carbon_below_ground USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_carbon_soil_organic USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_carbon_total USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_climate USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_elevation_profile USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_global_forest_cover_gain USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_global_forest_cover_loss USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_global_forest_cover_treecover USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_habitat_diversity_profile_thdi USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_habitat_diversity_profile_mhdi USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_water_surface_inland USING(wdpaid)
-- LEFT JOIN results_202009_cep_out.wdpa_land_degradation USING(wdpaid)							-- DA FARE PER 202101 (results_202009.r_stats_cep_lpd)
-- LEFT JOIN results_202009_cep_out.wdpa_land_fragmentation USING(wdpaid)						-- DA FARE PER 202101 (results_202009.r_stats_cep_mspa_lc_****) 
-- LEFT JOIN results_202009_cep_out.wdpa_pressure_agriculture_pa USING(wdpaid) 					-- DA FARE PER 202101 (class 40 from results_202009.r_stats_cep_copernicus_lc_2019)
LEFT JOIN results_202009_non_cep.wdpa_pressure_agriculture_bu USING(wdpaid)
--LEFT JOIN results_202009_cep_out.wdpa_pressure_builtup_pa USING(wdpaid) 						-- DA FARE (results_202009.r_stats_cep_builtup)
LEFT JOIN results_202009_non_cep.wdpa_pressure_builtup_bu USING(wdpaid)
LEFT JOIN results_202009_cep_out.wdpa_pressure_population_pa USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_pressure_population_bu USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_pressure_roads_pa USING(wdpaid)
LEFT JOIN results_202009_non_cep.wdpa_pressure_roads_bu USING(wdpaid)
-- LEFT JOIN results_202009_cep_out.wdpa_pressure_livestock_pa USING(wdpaid)					-- DA FARE PER 202101	
-- LEFT JOIN results_202009_non_cep.wdpa_pressure_livestock_bu USING(wdpaid)					-- DA FARE PER 202101	
;

GRANT SELECT ON TABLE dopa_41.dopa_country_all_inds TO h05ibexro;
GRANT SELECT ON TABLE dopa_41.dopa_country_ecoregion_all_inds TO h05ibexro;
GRANT SELECT ON TABLE dopa_41.dopa_ecoregion_all_inds TO h05ibexro;
GRANT SELECT ON TABLE dopa_41.dopa_wdpa_all_inds TO h05ibexro;
