------------------------------------------------------------------------------------
-- CHECK aggregations to do
------------------------------------------------------------------------------------
DROP VIEW IF EXISTS results.v_to_agg;CREATE VIEW results.v_to_agg AS
SELECT
pg_table,theme,UNNEST(STRING_TO_ARRAY(stats_required,';')) parameter_name,reporting_level,
CASE
WHEN reporting_level IN ('terrestrial countries','region') THEN 'country_all_inds_template'
WHEN reporting_level IN ('terrestrial ecoregions') THEN 'ecoregion_all_inds_template'
WHEN reporting_level IN ('terrestrial pa','pa') THEN 'wdpa_all_inds_template'
END table_name,
needed_for_cbd,aggregation_notes
FROM results.to_agg
ORDER BY pg_table,theme,stats_required,needed_for_cbd;

---------------------------------------
WITH
-----------------------------------
-- current output from local tables
-----------------------------------
a AS (
SELECT type_udt_schema::text schema_name,type_udt_name::text table_name,routine_name::text function_name,column_name::text parameter_name
FROM information_schema.routines a
JOIN information_schema.columns b ON (a.type_udt_schema=b.table_schema AND a.type_udt_name=b.table_name)
WHERE
a.routine_schema IN ('administrative_units','habitats_and_biotopes','protected_sites','species')),
-----------------------------------
-- expected output from functions
-----------------------------------
b AS (SELECT schema_name::text,function_name::text,parameter_name::text FROM results.dopa_indicators_rest),
-----------------------------------
-- to aggregate
-----------------------------------
d AS (SELECT * FROM results.v_to_agg),
-----------------------------------
-- excel output
-----------------------------------
e AS (SELECT * FROM results.dopa_indicators_excel),
-----------------------------------
-- current vs expected outputs
-----------------------------------
f AS (SELECT * FROM a FULL OUTER JOIN b USING(schema_name,function_name,parameter_name)),
-----------------------------------
-- outputs vs_aggregations
-----------------------------------
g AS (SELECT * FROM f FULL OUTER JOIN d USING (parameter_name,table_name))
SELECT DISTINCT schema_name,table_name,function_name,theme,parameter_name,pg_table,reporting_level,aggregation_notes
FROM g
-- FILTERS - CHANGE HERE!!!!
WHERE --schema_name = 'administrative_units' AND function_name='get_country_all_inds' AND needed_for_cbd = 'yes' AND 
theme='surface_inland_water'
ORDER BY theme,schema_name,table_name,reporting_level,function_name,parameter_name;
