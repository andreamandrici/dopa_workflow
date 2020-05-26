#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### FAO ###
###################

### IMPORT FAO PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_fao CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/fao.csv" \
-nln ${SCH}."additional_tables_fao"
