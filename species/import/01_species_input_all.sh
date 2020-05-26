#!/bin/bash

###instructions
###launch it as: ./01_species_input_all.sh > logs/01_species_input_all.log 2>&1
###

# TIMER START
START_T1=$(date +%s)

# PARAMETERS
source species_parameters_dopaprc.conf

## SCHEMA MANAGEMENT
#psql ${dbpar2} -c "DROP SCHEMA IF EXISTS $SCH CASCADE;"
#psql ${dbpar2} -c "CREATE SCHEMA IF NOT EXISTS $SCH;"

time ./slave_scripts/01a_species_input_corals.sh && echo "corals" &
time ./slave_scripts/01b_species_input_chondrichthyes.sh && echo "chondrichthyes" &
time ./slave_scripts/01c_species_input_amphibians.sh && echo "amphibians" &
time ./slave_scripts/01d_species_input_mammals.sh && echo "mammals" &

wait

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE!
TOTAL SCRIPT TIME: $TOTAL_DIFF"
