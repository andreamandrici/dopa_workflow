#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### SYNONYMS ###
###################

### IMPORT SYNONYMS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_synonyms CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/synonyms.csv" \
-nln ${SCH}."additional_tables_synonyms"
wait
### IMPORT SYNONYMS PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/synonyms.csv" \
-nln ${SCH}."additional_tables_synonyms"
