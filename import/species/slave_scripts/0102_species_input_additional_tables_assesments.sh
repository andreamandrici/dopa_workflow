#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### ASSESSMENTS ###
###################

### IMPORT ASSESSMENTS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_assessments CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/assessments.csv" \
-nln ${SCH}."additional_tables_assessments"
wait
### IMPORT ASSESSMENTS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/assessments.csv" \
-nln ${SCH}."additional_tables_assessments"
