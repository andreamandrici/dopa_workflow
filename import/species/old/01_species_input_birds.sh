#!/bin/bash

###instructions
###launch it as: ./01_species_input_birds.sh > logs/01_species_input_birds.log 2>&1
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

time ./slave_scripts/01e_species_input_birds.sh && echo "birds" &

wait

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE!
TOTAL SCRIPT TIME: $TOTAL_DIFF"
