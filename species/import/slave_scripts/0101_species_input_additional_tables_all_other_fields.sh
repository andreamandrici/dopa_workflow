#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### ALL_OTHER_FIELDS ###
###################

### IMPORT ALL_OTHER_FIELDS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_all_other_fields CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/all_other_fields.csv" \
-nln ${SCH}."additional_tables_all_other_fields"
wait
### IMPORT ALL_OTHER_FIELDS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/all_other_fields.csv" \
-nln ${SCH}."additional_tables_all_other_fields"
