#!/bin/bash

###instructions
###launch it as: ./01_species_input_additional_tables.sh > logs/01_species_input_additional_tables.log 2>&1
###

# TIMER START
START_T1=$(date +%s)

# PARAMETERS
source species_parameters_dopaprc.conf
## SCHEMA MANAGEMENT
#psql ${dbpar2} -c "DROP SCHEMA IF EXISTS $SCH CASCADE;"
#psql ${dbpar2} -c "CREATE SCHEMA IF NOT EXISTS $SCH;"

# IMPORT VECTORS

###			ogr2ogr parameters used
### -overwrite				delete the output layer if exists and recreate it empty 					
### -dialect sqlite			use sqlite SQL dialect				
### -sql					SQL statement to execute			
### -f						format_name				
### -lco					Layer creation option (format specific)
	###	FID						name of the PK column to create
### -nlt					define the geometry type for the created layer
### -nln					Assign a name to the new layer	

time ./slave_scripts/0101_species_input_additional_tables_all_other_fields.sh && echo "all_other_fields"  &
time ./slave_scripts/0102_species_input_additional_tables_assesments.sh && echo "assesments"  &
time ./slave_scripts/0103_species_input_additional_tables_common_names.sh && echo "common_names"  &
time ./slave_scripts/0104_species_input_additional_tables_conservation_needed.sh && echo "conservation_needed"  &
time ./slave_scripts/0105_species_input_additional_tables_countries.sh && echo "countries"  &
time ./slave_scripts/0106_species_input_additional_tables_credits.sh && echo "credits"  &
time ./slave_scripts/0107_species_input_additional_tables_dois.sh && echo "dois"  &
time ./slave_scripts/0108_species_input_additional_tables_fao.sh && echo "fao"  &
time ./slave_scripts/0109_species_input_additional_tables_habitats.sh && echo "habitats"  &
time ./slave_scripts/0110_species_input_additional_tables_lme.sh && echo "lme"  &
time ./slave_scripts/0111_species_input_additional_tables_references.sh && echo "references"  &
time ./slave_scripts/0112_species_input_additional_tables_research_needed.sh && echo "research_needed"  &
time ./slave_scripts/0113_species_input_additional_tables_simple_summary.sh && echo "simple_summary"  &
time ./slave_scripts/0114_species_input_additional_tables_synonyms.sh && echo "synonyms"  &
time ./slave_scripts/0115_species_input_additional_tables_taxonomy.sh && echo "taxonomy"  &
time ./slave_scripts/0116_species_input_additional_tables_threats.sh && echo "threats"  &
time ./slave_scripts/0117_species_input_additional_tables_usetrade.sh && echo "usetrade"  &
wait

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE!
TOTAL SCRIPT TIME: $TOTAL_DIFF"

