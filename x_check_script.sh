#!/bin/bash

source workflow_parameters.conf

readschema='cep202003'
readtable='c_raster_country'

clear

echo "working schema is: ${SCH}"
echo "selected schema is: ${readschema}"
echo "selected table is: ${readtable}"

## list the existing schemas
echo "schemas in DB are:
" &&
psql ${dbpar2} -t -c "SELECT DISTINCT table_schema FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema','pg_catalog','public')
ORDER BY table_schema;"

## list the existing tables in WORKING schema (defined in workflow_parameters.conf)
echo "tables in WORKING schema are:
" &&
psql ${dbpar2} -t -c "SELECT DISTINCT table_schema,table_name FROM information_schema.tables
WHERE table_schema = '${SCH}'
ORDER BY table_schema,table_name;"

## list the existing tables in SELECTED schema (define the readschema above)
echo "tables in SELECTED schema are:
" &&
psql ${dbpar2} -t -c "SELECT DISTINCT table_schema,table_name FROM information_schema.tables
WHERE table_schema = '${readschema}'
ORDER BY table_schema,table_name;"

## count objects in table (define readschema and readtable above)
echo "number of objects in ${readschema}.${readtable} is:" &&
psql ${dbpar2} -t -c "SELECT COUNT(DISTINCT fid) FROM ${readschema}.${readtable};"


#psql ${dbpar2} -t -c "SELECT COUNT(*) FROM cep_202003.c_rast_wdpa;"
#psql ${dbpar2} -t -c "SELECT COUNT(DISTINCT fid) FROM cep_202003.c_rast_wdpa;"
#psql ${dbpar2} -t -c "SELECT COUNT(DISTINCT qid) FROM cep_202003.c_rast_wdpa;"
