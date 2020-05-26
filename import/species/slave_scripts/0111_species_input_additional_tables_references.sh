#!/bin/bash

# PARAMETERS
source species_parameters_dopaprc.conf

###################
### REFERENCES ###
###################

### IMPORT REFERENCES PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.additional_tables_references CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_all_except_passeriformes/references.csv" \
-nln ${SCH}."additional_tables_references"
wait
### IMPORT REFERENCES PART2
ogr2ogr \
-update \
-append \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/redlist_species_data_only_passeriformes/references.csv" \
-nln ${SCH}."additional_tables_references"
