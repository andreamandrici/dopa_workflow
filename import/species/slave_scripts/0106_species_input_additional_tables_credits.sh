#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### CREDITS ###
###################

### IMPORT CREDITS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_credits CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/credits.csv" \
-nln ${SCH}."additional_tables_credits"
wait
### IMPORT CREDITS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/credits.csv" \
-nln ${SCH}."additional_tables_credits"
