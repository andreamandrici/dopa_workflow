-----------------------------------
-- SETUP THE RIGHT INPUT SCHEMA ---
-----------------------------------
-- COUNTRY ------------------------
DROP TABLE IF EXISTS administrative_units.country_all_inds;
CREATE TABLE administrative_units.country_all_inds AS
SELECT *
FROM results_aggregated.country_conservation_coverage
LEFT JOIN results_aggregated.country_conservation_connectivity USING(country_id)
LEFT JOIN results_aggregated.country_conservation_kba USING(country_id)
LEFT JOIN results_aggregated.country_conservation_mta USING(country_id)
LEFT JOIN results_aggregated.country_carbon_above_ground USING(country_id)
LEFT JOIN results_aggregated.country_carbon_below_ground USING(country_id)
LEFT JOIN results_aggregated.country_carbon_soil_organic USING(country_id)
LEFT JOIN results_aggregated.country_carbon_total USING(country_id)
LEFT JOIN results_aggregated.country_elevation_profile USING(country_id)
LEFT JOIN results_aggregated.country_global_forest_cover_gain USING(country_id)
LEFT JOIN results_aggregated.country_global_forest_cover_loss USING(country_id)
LEFT JOIN results_aggregated.country_global_forest_cover_treecover USING(country_id)
LEFT JOIN results_aggregated.country_water_surface_inland USING(country_id)
;
-- ECOREGION IN COUNTRY ------------------------
DROP TABLE IF EXISTS administrative_units.country_ecoregions_stats;
CREATE TABLE administrative_units.country_ecoregions_stats AS
SELECT * FROM results_aggregated.country_conservation_coverage_ecoregions_stats;

-- ECOREGION ------------------------
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregion_all_inds;
CREATE TABLE habitats_and_biotopes.ecoregion_all_inds AS
SELECT * FROM results_aggregated.ecoregion_conservation_coverage
LEFT JOIN results_aggregated.ecoregion_conservation_connectivity USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_conservation_kba USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_carbon_above_ground USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_carbon_below_ground USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_carbon_soil_organic USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_carbon_total USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_elevation_profile USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_global_forest_cover_gain USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_global_forest_cover_loss USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_global_forest_cover_treecover USING(eco_id)
LEFT JOIN results_aggregated.ecoregion_water_surface_inland USING(eco_id)
;

-- PA ------------------------
DROP TABLE IF EXISTS protected_sites.wdpa_all_inds;
CREATE TABLE protected_sites.wdpa_all_inds AS
SELECT * FROM results_aggregated.wdpa_conservation_coverage
LEFT JOIN results_aggregated.wdpa_carbon_above_ground USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_carbon_below_ground USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_carbon_soil_organic USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_carbon_total USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_climate USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_elevation_profile USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_global_forest_cover_gain USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_global_forest_cover_loss USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_global_forest_cover_treecover USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_habitat_diversity_profile_thdi USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_habitat_diversity_profile_mhdi USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_pressure_agriculture_bu USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_pressure_builtup_bu USING(wdpaid)
--LEFT JOIN results_aggregated.wdpa_pressure_livestock_bu USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_pressure_population_bu USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_pressure_roads_pa USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_pressure_roads_bu USING(wdpaid)
LEFT JOIN results_aggregated.wdpa_water_surface_inland USING(wdpaid)

;
