#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### HABITATS ###
###################

### IMPORT HABITATS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_habitats CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/habitats.csv" \
-nln ${SCH}."additional_tables_habitats"
wait
### IMPORT HABITATS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/habitats.csv" \
-nln ${SCH}."additional_tables_habitats"
