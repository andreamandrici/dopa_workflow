#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### COMMON NAMES ###
###################

### IMPORT COMMON NAMES PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_common_names CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/common_names.csv" \
-nln ${SCH}."additional_tables_common_names"
wait
### IMPORT COMMON NAMES PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/common_names.csv" \
-nln ${SCH}."additional_tables_common_names"
