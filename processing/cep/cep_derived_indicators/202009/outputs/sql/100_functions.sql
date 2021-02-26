--------------------------------------------------------------------------------------
-- OUTPUT TABLES TEMPLATES
--------------------------------------------------------------------------------------
-- country table
DROP TABLE IF EXISTS dopa_41.dopa_country_all_inds_template CASCADE;CREATE TABLE dopa_41.dopa_country_all_inds_template AS
SELECT * FROM dopa_41.dopa_country_all_inds LIMIT 0;
-- ecoregion_in_country table
DROP TABLE IF EXISTS dopa_41.dopa_country_ecoregions_stats_template CASCADE;
DROP TABLE IF EXISTS dopa_41.dopa_country_ecoregion_all_inds_template CASCADE;CREATE TABLE dopa_41.dopa_country_ecoregion_all_inds_template AS
SELECT * FROM dopa_41.dopa_country_ecoregion_all_inds LIMIT 0;
-- ecoregion table
DROP TABLE IF EXISTS dopa_41.dopa_ecoregion_all_inds_template CASCADE;CREATE TABLE dopa_41.dopa_ecoregion_all_inds_template AS
SELECT * FROM dopa_41.dopa_ecoregion_all_inds LIMIT 0;
-- wdpa table
DROP TABLE IF EXISTS dopa_41.dopa_wdpa_all_inds_template CASCADE;CREATE TABLE dopa_41.dopa_wdpa_all_inds_template AS
SELECT * FROM dopa_41.dopa_wdpa_all_inds LIMIT 0;

---------------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------------
-- COUNTRY FUNCTIONS
---------------------------------------------------------------------------------------
-- get_country_all_inds
DROP FUNCTION IF EXISTS dopa_41.get_dopa_country_all_inds(text,text,text);
CREATE OR REPLACE FUNCTION dopa_41.get_dopa_country_all_inds(a_iso3 text DEFAULT NULL::text,b_iso2 text DEFAULT NULL::text,c_un_m49 text DEFAULT NULL::text)
RETURNS SETOF dopa_41.dopa_country_all_inds_template 
LANGUAGE 'plpgsql' AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql :='
SELECT * FROM dopa_41.dopa_country_all_inds';
IF a_iso3 IS NOT NULL THEN
			sql := sql || ' WHERE country_iso3 = $1';
ELSE	sql := sql || ' WHERE country_iso3 IS NOT NULL';
END IF;

IF b_iso2 IS NOT NULL THEN
			sql := sql || ' AND country_iso2 = $2';
ELSE	sql := sql || ' AND country_iso2 IS NOT NULL';
END IF;

IF c_un_m49 IS NOT NULL THEN
			sql := sql || ' AND country_un_m49 = $3';
ELSE	sql := sql || ' AND country_un_m49 IS NOT NULL';
END IF;
RETURN QUERY EXECUTE sql USING a_iso3,b_iso2,c_un_m49;
END;
$BODY$;
GRANT EXECUTE ON FUNCTION dopa_41.get_dopa_country_all_inds(text,text,text) TO h05ibexro;
-- get_country_ecoregions_stats
DROP FUNCTION IF EXISTS dopa_41.get_dopa_country_ecoregion_all_inds(text,text,text);
CREATE FUNCTION dopa_41.get_dopa_country_ecoregion_all_inds(a_iso3 text DEFAULT NULL::text,b_iso2 text DEFAULT NULL::text,c_un_m49 text DEFAULT NULL::text)
RETURNS SETOF dopa_41.dopa_country_ecoregion_all_inds_template
LANGUAGE 'plpgsql' AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql :='
SELECT * FROM dopa_41.dopa_country_ecoregion_all_inds';
IF a_iso3 IS NOT NULL THEN
			sql := sql || ' WHERE iso3 = $1';
ELSE	sql := sql || ' WHERE iso3 IS NOT NULL';
END IF;

IF b_iso2 IS NOT NULL THEN
			sql := sql || ' AND iso2 = $2';
ELSE	sql := sql || ' AND iso2 IS NOT NULL';
END IF;

IF c_un_m49 IS NOT NULL THEN
			sql := sql || ' AND un_m49 = $3';
ELSE	sql := sql || ' AND un_m49 IS NOT NULL';
END IF;
RETURN QUERY EXECUTE sql USING a_iso3,b_iso2,c_un_m49;
END;
$BODY$;
GRANT EXECUTE ON FUNCTION dopa_41.get_dopa_country_ecoregion_all_inds(text,text,text) TO h05ibexro;
---------------------------------------------------------------------------------------
-- REGION FUNCTIONS
---------------------------------------------------------------------------------------
-- get_region_all_inds
DROP FUNCTION IF EXISTS dopa_41.get_dopa_region_all_inds(text,text,boolean);
CREATE FUNCTION dopa_41.get_dopa_region_all_inds(region_name text DEFAULT 'world'::text,subregion_name text DEFAULT NULL::text,status_multi boolean DEFAULT false)
RETURNS SETOF dopa_41.dopa_country_all_inds_template
LANGUAGE 'plpgsql' AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql := 'SELECT a.* FROM dopa_41.dopa_country_all_inds a
JOIN (SELECT DISTINCT UNNEST(lookup_country_id) country_id FROM dopa_41.dopa_regions WHERE region_name='''||region_name||''') b USING (country_id)';
IF subregion_name IS NOT NULL THEN sql := sql || ' JOIN (SELECT DISTINCT UNNEST(lookup_country_id) country_id FROM dopa_41.dopa_regions WHERE region_name='''||subregion_name||''') c USING (country_id)';
END IF;
IF status_multi IS FALSE THEN sql := sql || ' WHERE status IS NULL';
END IF;
sql := sql || ' ORDER BY country_id';
RETURN QUERY EXECUTE sql USING region_name,subregion_name,status_multi;
END;
$BODY$;
GRANT EXECUTE ON FUNCTION dopa_41.get_dopa_region_all_inds(text,text,boolean) TO h05ibexro;
---------------------------------------------------------------------------------------
-- ECOREGION FUNCTIONS
---------------------------------------------------------------------------------------
-- get_ecoregion_all_inds
DROP FUNCTION IF EXISTS dopa_41.get_dopa_ecoregion_all_inds(integer);
CREATE OR REPLACE FUNCTION dopa_41.get_dopa_ecoregion_all_inds(eco_id integer DEFAULT NULL::integer)
RETURNS SETOF dopa_41.dopa_ecoregion_all_inds_template
LANGUAGE 'plpgsql' AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql :='
SELECT * FROM dopa_41.dopa_ecoregion_all_inds';
IF eco_id IS NOT NULL THEN
			sql := sql || ' WHERE eco_id = $1;';
ELSE	sql := sql || ';';
END IF;
RETURN QUERY EXECUTE sql USING eco_id;
END;
$BODY$;
GRANT EXECUTE ON FUNCTION dopa_41.get_dopa_ecoregion_all_inds(integer) TO h05ibexro;
---------------------------------------------------------------------------------------
-- WDPA FUNCTIONS
---------------------------------------------------------------------------------------
-- get_wdpa_all_inds
DROP FUNCTION IF EXISTS dopa_41.get_dopa_wdpa_all_inds(integer);
CREATE FUNCTION dopa_41.get_dopa_wdpa_all_inds(wdpaid integer DEFAULT NULL::integer)
RETURNS SETOF dopa_41.dopa_wdpa_all_inds_template
LANGUAGE 'plpgsql' AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql :='
SELECT * FROM dopa_41.dopa_wdpa_all_inds';
IF wdpaid IS NOT NULL THEN
			sql := sql || ' WHERE wdpaid = $1;';
ELSE	sql := sql || ';';
END IF;
RETURN QUERY EXECUTE sql USING wdpaid;
END;
$BODY$;
GRANT EXECUTE ON FUNCTION dopa_41.get_dopa_wdpa_all_inds(integer) TO h05ibexro;

----------------------------------------------------------------------------------
-- FUNCTIONS PARAMETERS
-----------------------------------------------------------------------------------
DROP VIEW IF EXISTS dopa_41.v_functions_parameters;
CREATE VIEW dopa_41.v_functions_parameters AS
WITH
a AS (
SELECT
a.specific_schema::text schema_name,
a.routine_name::text function_name,
b.parameter_name::text,
NULL::text parameter_description,
b.parameter_mode::text parameter_mode_io,
b.data_type::text parameter_type_io,
b.parameter_default::text parameter_def_value,
NULL::bool parameter_compulsory,
b.ordinal_position
FROM information_schema.routines a
LEFT JOIN information_schema.parameters b ON a.specific_name=b.specific_name
WHERE a.specific_schema='dopa_41'
ORDER BY a.routine_name,b.ordinal_position),
b AS (
SELECT
table_schema::text schema_name,
REPLACE(table_name,'dopa','get_dopa') function_name,
column_name parameter_name,
NULL::text parameter_description,
'OUT'::text parameter_mode_io,
data_type::text parameter_type_io,
NULL::text parameter_def_value,
NULL::bool parameter_compulsory,
ordinal_position
FROM information_schema.columns
WHERE table_schema='dopa_41' AND table_name NOT ILIKE('%_template')
ORDER BY table_name,ordinal_position)
SELECT * FROM a UNION SELECT * FROM b ORDER BY function_name,parameter_mode_io,ordinal_position;