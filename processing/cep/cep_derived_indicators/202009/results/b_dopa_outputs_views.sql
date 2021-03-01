--- OUTPUT STATUS
DROP VIEW IF EXISTS results.dopa_outputs_status CASCADE;CREATE VIEW results.dopa_outputs_status AS
WITH
a AS (SELECT * FROM results.dopa_indicators),
b AS (SELECT type_udt_schema::text schema_name,REPLACE(type_udt_name::text,'_template','') table_name,routine_name::text function_name,column_name::text parameter_name
      FROM information_schema.routines a
      LEFT JOIN information_schema.columns b ON (a.type_udt_schema=b.table_schema AND a.type_udt_name=b.table_name)
      WHERE a.routine_schema IN ('administrative_units','habitats_and_biotopes','protected_sites','species')),
c AS (SELECT ROW_NUMBER () OVER () tempid,* FROM a FULL OUTER JOIN b USING(schema_name,function_name,parameter_name)),
d AS (
SELECT tempid,'calculated, not in rest' status FROM c WHERE (rest IS NULL OR rest is false)
UNION
SELECT tempid,'not calculated' status FROM c WHERE table_name IS NULL
UNION
SELECT tempid,'calculated' status FROM c WHERE table_name IS NOT NULL AND rest IS true
)
SELECT
tid,theme,theme_description,stid,subtheme,subtheme_description,
schema_name,function_name,parameter_name,parameter_description,
reporting_level,reporting_level_description,
table_name,source,rest,
status,
xls_template,xls_column_name_lv_1,xls_column_name_lv_2--,
--progress_code,progress_code_description
FROM c
LEFT JOIN d USING(tempid)
LEFT JOIN results.themes g USING(stid)
LEFT JOIN results.reporting_level_codes e USING(reporting_level)
LEFT JOIN results.progress_codes f USING(progress_code)
ORDER BY schema_name,function_name,stid,tid,theme,parameter_name,table_name;

-- INDICATORS PROGRESS
DROP VIEW IF EXISTS results.dopa_indicators_progress;
CREATE VIEW results.dopa_indicators_progress AS
WITH
a AS (SELECT ROW_NUMBER () OVER ()id ,stid,schema_name,function_name,parameter_name FROM results.dopa_indicators WHERE progress_code IS NOT NULL),
b AS (SELECT stid,schema_name,function_name,parameter_name FROM  results.dopa_outputs_status WHERE status = 'calculated'),
c AS (SELECT * FROM a NATURAL JOIN b),
d AS (SELECT * FROM a WHERE id NOT IN (SELECT DISTINCT id FROM c))
SELECT
tid,theme,theme_description,stid,subtheme,subtheme_description,
schema_name,function_name,parameter_name,
reporting_level,
source,rest,xls_template,xls_column_name_lv_1,xls_column_name_lv_2,progress_code,progress_code_description
FROM results.dopa_indicators
NATURAL JOIN d
LEFT JOIN results.progress_codes USING(progress_code)
LEFT JOIN results.themes USING(stid)
ORDER BY theme, function_name,parameter_name;
