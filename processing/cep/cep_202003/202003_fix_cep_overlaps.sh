#!/bin/bash

## EXECUTE IT AS ./fix_cep_overlaps.sh > logs/fix_cep_overlaps_log.txt 2>&1 &

# TIMER START
START_T1=$(date +%s)

# set number of dedicated cores for all the subscripts
ncores=72


# FLAT_TEMP
## populates flat_temp
./g_final_all.sh ${ncores} > logs/g_final_all_log.txt 2>&1 wait

# FLAT_FINAL
## populates flat
./h_output.sh > logs/h_output_log.txt 2>&1 wait

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
echo "analysis end"
exit
