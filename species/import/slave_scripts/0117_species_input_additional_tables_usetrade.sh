#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### USETRADE ###
###################

### IMPORT USETRADE PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_usetrade CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/usetrade.csv" \
-nln ${SCH}."additional_tables_usetrade"
wait
### IMPORT USETRADE PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/usetrade.csv" \
-nln ${SCH}."additional_tables_usetrade"
