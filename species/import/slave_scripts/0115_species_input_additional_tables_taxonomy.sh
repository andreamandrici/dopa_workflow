#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### TAXONOMY ###
###################

### IMPORT TAXONOMY PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_taxonomy CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/taxonomy.csv" \
-nln ${SCH}."additional_tables_taxonomy"
wait
### IMPORT TAXONOMY PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/taxonomy.csv" \
-nln ${SCH}."additional_tables_taxonomy"
