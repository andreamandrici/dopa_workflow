DROP FUNCTION IF EXISTS results.get_output_parameters();
CREATE OR REPLACE FUNCTION results.get_output_parameters(
	table_schema text,table_name text
	)
    RETURNS TABLE (table_schema text,table_name text,ordinal_position integer,column_name text, description text)
    LANGUAGE 'sql'    
AS $BODY$
SELECT c.table_schema::text,c.table_name::text,c.ordinal_position,c.column_name::text,d.description
FROM information_schema.columns c
LEFT JOIN pg_description d ON ((c.table_schema||'.'||c.table_name)::regclass=d.objoid AND c.ordinal_position=d.objsubid)
WHERE c.table_schema = $1 AND table_name = $2
$BODY$;
SELECT * FROM results.get_output_parameters('administrative_units','country_ecoregions_stats');


