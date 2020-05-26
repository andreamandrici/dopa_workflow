#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### SIMPLE_SUMMARY ###
###################

### IMPORT SIMPLE_SUMMARY PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_simple_summary CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/simple_summary.csv" \
-nln ${SCH}."additional_tables_simple_summary"
wait
### IMPORT SIMPLE_SUMMARY PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/simple_summary.csv" \
-nln ${SCH}."additional_tables_simple_summary"
