#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### RESEARCH_NEEDED ###
###################

### IMPORT RESEARCH_NEEDED PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_research_needed CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/research_needed.csv" \
-nln ${SCH}."additional_tables_research_needed"
wait
### IMPORT RESEARCH_NEEDED PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/research_needed.csv" \
-nln ${SCH}."additional_tables_research_needed"
