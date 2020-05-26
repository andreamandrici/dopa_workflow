#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### COUNTRIES ###
###################

### IMPORT COUNTRIES PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_countries CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/countries.csv" \
-nln ${SCH}."additional_tables_countries"
wait
### IMPORT COUNTRIES PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/countries.csv" \
-nln ${SCH}."additional_tables_countries"
