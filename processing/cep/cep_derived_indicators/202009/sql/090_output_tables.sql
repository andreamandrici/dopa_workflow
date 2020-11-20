-----------------------------------
-- SETUP THE RIGHT INPUT SCHEMA ---
-----------------------------------
-- COUNTRY ------------------------
DROP TABLE IF EXISTS administrative_units.country_all_inds;
CREATE TABLE administrative_units.country_all_inds AS
SELECT *
FROM results_202009.country_coverages coverages
LEFT JOIN results_202009.country_protconn protconn USING(country_id)
LEFT JOIN results_202009.kba_country_202009 kba USING(country_id)
LEFT JOIN results_202009.country_above_ground_carbon agb USING(country_id)
LEFT JOIN results_202009.country_belowground_biomass_carbon bgb USING(country_id)
LEFT JOIN results_202009.country_soil_organic_carbon soc USING(country_id)
LEFT JOIN results_202009.country_total_carbon tot_c USING(country_id)
LEFT JOIN results_202009.country_change_in_forest_cover_gain USING(country_id)
LEFT JOIN results_202009.country_change_in_forest_cover_loss USING(country_id)
LEFT JOIN results_202009.country_change_in_forest_cover_treecover USING(country_id)
LEFT JOIN results_202009.country_surface_inland_water water USING(country_id)
;
-- ECOREGION IN COUNTRY ------------------------
DROP TABLE IF EXISTS administrative_units.country_ecoregions_stats;
CREATE TABLE administrative_units.country_ecoregions_stats AS
SELECT * FROM results_202009.country_ecoregions_stats coverages;

-- ECOREGION ------------------------
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregion_all_inds;
CREATE TABLE habitats_and_biotopes.ecoregion_all_inds AS
SELECT * FROM results_202009.ecoregion_coverages coverages
LEFT JOIN results_202009.ecoregion_protconn protconn USING(eco_id)
LEFT JOIN results_202009.kba_ecoregions_202009 kba USING(eco_id)
LEFT JOIN results_202009.ecoregion_above_ground_carbon agb USING(eco_id)
LEFT JOIN results_202009.ecoregion_belowground_biomass_carbon bgb USING(eco_id)
LEFT JOIN results_202009.ecoregion_soil_organic_carbon soc USING(eco_id)
LEFT JOIN results_202009.ecoregion_total_carbon tot_c USING(eco_id)
LEFT JOIN results_202009.ecoregion_change_in_forest_cover_gain USING(eco_id)
LEFT JOIN results_202009.ecoregion_change_in_forest_cover_loss USING(eco_id)
LEFT JOIN results_202009.ecoregion_change_in_forest_cover_treecover USING(eco_id)
LEFT JOIN results_202009.ecoregion_surface_inland_water water USING(eco_id)
;
-- COUNTRY IN ECOREGION ------------------------
--DROP TABLE IF EXISTS habitats_and_biotopes.ecoregion_countries_stats;
--CREATE TABLE habitats_and_biotopes.ecoregion_countries_stats AS
--SELECT * FROM results_202009.ecoregion_countries_stats;

-- PA ------------------------
DROP TABLE IF EXISTS protected_sites.wdpa_all_inds;
CREATE TABLE protected_sites.wdpa_all_inds AS
SELECT * FROM results_202009.wdpa_coverages
LEFT JOIN results_202009.wdpa_above_ground_carbon agb USING(wdpaid)
LEFT JOIN results_202009.wdpa_belowground_biomass_carbon bgb USING(wdpaid)
LEFT JOIN results_202009.wdpa_soil_organic_carbon soc USING(wdpaid)
LEFT JOIN results_202009.wdpa_total_carbon tot_c USING(wdpaid)
LEFT JOIN results_202009.wdpa_change_in_forest_cover_gain USING(wdpaid)
LEFT JOIN results_202009.wdpa_change_in_forest_cover_loss USING(wdpaid)
LEFT JOIN results_202009.wdpa_change_in_forest_cover_treecover USING(wdpaid)
LEFT JOIN results_202009.wdpa_surface_inland_water water USING(wdpaid)
;