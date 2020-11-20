-- CREATE AN EMPTY dopa_rest_indicators list table
CREATE TABLE results.dopa_rest_indicators
(
    db_name text COLLATE pg_catalog."default",
    schema_name text COLLATE pg_catalog."default",
    function_name text COLLATE pg_catalog."default",
    parameter_name text COLLATE pg_catalog."default",
    parameter_description text COLLATE pg_catalog."default",
    reporting_level text COLLATE pg_catalog."default",
    source text COLLATE pg_catalog."default",
    rest boolean,
    xls_template character varying COLLATE pg_catalog."default",
    xls_column_name_lv_1 character varying COLLATE pg_catalog."default",
    xls_column_name_lv_2 character varying COLLATE pg_catalog."default",
    progress_code integer
);
--IMPORT NOW DATA IN THE ABOVE TABLE
-- CREATE VIEW
DROP VIEW IF EXISTS results.v_indicator_status;CREATE VIEW results.v_indicator_status AS
WITH
a AS (SELECT * FROM results.dopa_rest_indicators),
b AS (
SELECT type_udt_schema::text schema_name,type_udt_name::text table_name,routine_name::text function_name,column_name::text parameter_name
FROM information_schema.routines a
JOIN information_schema.columns b ON (a.type_udt_schema=b.table_schema AND a.type_udt_name=b.table_name)
WHERE a.routine_schema IN ('administrative_units','habitats_and_biotopes','protected_sites','species')
),
c AS (SELECT DISTINCT * FROM a FULL OUTER JOIN b USING(schema_name,function_name,parameter_name)),
d AS (
SELECT schema_name,table_name,function_name,parameter_name,parameter_description,reporting_level,rest,source,'calculated, not in rest' status,xls_template,xls_column_name_lv_1,xls_column_name_lv_2,progress_code FROM c WHERE rest IS NULL
UNION
SELECT schema_name,table_name,function_name,parameter_name,parameter_description,reporting_level,rest,source,'not calculated' status,xls_template,xls_column_name_lv_1,xls_column_name_lv_2,progress_code FROM c WHERE table_name IS NULL
UNION
SELECT schema_name,table_name,function_name,parameter_name,parameter_description,reporting_level,rest,source,'calculated' status,xls_template,xls_column_name_lv_1,xls_column_name_lv_2,progress_code FROM c WHERE table_name IS NOT NULL AND rest IS NOT NULL
)
SELECT * FROM d ORDER BY schema_name,function_name,parameter_name;

