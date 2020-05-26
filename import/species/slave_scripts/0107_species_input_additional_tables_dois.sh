#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### DOIS ###
###################

### IMPORT DOIS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_dois CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/dois.csv" \
-nln ${SCH}."additional_tables_dois"
wait
### IMPORT DOIS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/dois.csv" \
-nln ${SCH}."additional_tables_dois"
