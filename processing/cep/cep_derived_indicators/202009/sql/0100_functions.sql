--------------------------------------------------------------------------------------
-- OUTPUT TABLES TEMPLATES
--------------------------------------------------------------------------------------
-- country table
DROP TABLE IF EXISTS administrative_units.country_all_inds_template CASCADE;CREATE TABLE administrative_units.country_all_inds_template AS
SELECT * FROM administrative_units.country_all_inds LIMIT 0;
-- ecoregion_in_country table
DROP TABLE IF EXISTS administrative_units.country_ecoregions_stats_template CASCADE;CREATE TABLE administrative_units.country_ecoregions_stats_template AS
SELECT * FROM administrative_units.country_ecoregions_stats LIMIT 0;
-- ecoregion table
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregion_all_inds_template CASCADE;CREATE TABLE habitats_and_biotopes.ecoregion_all_inds_template AS
SELECT * FROM habitats_and_biotopes.ecoregion_all_inds LIMIT 0;
-- country_in_ecoregion table
--DROP TABLE IF EXISTS habitats_and_biotopes.ecoregion_countries_stats_template CASCADE;CREATE TABLE habitats_and_biotopes.ecoregion_countries_stats_template AS
--SELECT * FROM habitats_and_biotopes.ecoregion_countries_stats LIMIT 0;
-- wdpa table
DROP TABLE IF EXISTS protected_sites.wdpa_all_inds_template CASCADE;CREATE TABLE protected_sites.wdpa_all_inds_template AS
SELECT * FROM protected_sites.wdpa_all_inds LIMIT 0;


---------------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------------
-- COUNTRY FUNCTIONS
---------------------------------------------------------------------------------------
-- get_country_all_inds
DROP FUNCTION IF EXISTS administrative_units.get_country_all_inds();
CREATE FUNCTION administrative_units.get_country_all_inds()
RETURNS SETOF administrative_units.country_all_inds_template
LANGUAGE SQL AS $BODY$ SELECT * FROM administrative_units.country_all_inds; $BODY$;
-- get_country_ecoregions_stats
DROP FUNCTION IF EXISTS administrative_units.get_country_ecoregions_stats();
CREATE FUNCTION administrative_units.get_country_ecoregions_stats()
RETURNS SETOF administrative_units.country_ecoregions_stats_template
LANGUAGE SQL AS $BODY$ SELECT * FROM administrative_units.country_ecoregions_stats; $BODY$;
---------------------------------------------------------------------------------------
-- REGION FUNCTIONS
---------------------------------------------------------------------------------------
-- get_region_all_inds
DROP FUNCTION IF EXISTS administrative_units.get_region_all_inds();
CREATE FUNCTION administrative_units.get_region_all_inds()
RETURNS SETOF administrative_units.country_all_inds_template
LANGUAGE SQL AS $BODY$ SELECT * FROM administrative_units.country_all_inds; $BODY$;
---------------------------------------------------------------------------------------
-- ECOREGION FUNCTIONS
---------------------------------------------------------------------------------------
-- get_ecoregion_all_inds
DROP FUNCTION IF EXISTS habitats_and_biotopes.get_ecoregion_all_inds();
CREATE FUNCTION habitats_and_biotopes.get_ecoregion_all_inds()
RETURNS SETOF habitats_and_biotopes.ecoregion_all_inds_template
LANGUAGE SQL AS $BODY$ SELECT * FROM habitats_and_biotopes.ecoregion_all_inds; $BODY$;
-- get_ecoregion_countries_stats
--DROP FUNCTION IF EXISTS habitats_and_biotopes.get_ecoregion_countries_stats();
--CREATE FUNCTION habitats_and_biotopes.get_ecoregion_countries_stats()
--RETURNS SETOF habitats_and_biotopes.ecoregion_countries_stats_template
--LANGUAGE SQL AS $BODY$ SELECT * FROM habitats_and_biotopes.ecoregion_countries_stats; $BODY$;
---------------------------------------------------------------------------------------
-- WDPA FUNCTIONS
---------------------------------------------------------------------------------------
-- get_wdpa_all_inds
DROP FUNCTION IF EXISTS protected_sites.get_wdpa_all_inds();
CREATE FUNCTION protected_sites.get_wdpa_all_inds()
RETURNS SETOF protected_sites.wdpa_all_inds_template
LANGUAGE SQL AS $BODY$ SELECT * FROM protected_sites.wdpa_all_inds; $BODY$;
