#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### THREATS ###
###################

### IMPORT THREATS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_threats CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/threats.csv" \
-nln ${SCH}."additional_tables_threats"
wait
### IMPORT THREATS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/threats.csv" \
-nln ${SCH}."additional_tables_threats"
