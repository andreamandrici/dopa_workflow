#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

# EXECUTE AS ./execute.sh > logs/execute.log 2>&1

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

psql ${dbpar2} -f ./${SQL}/090_output_tables.sql
wait
psql ${dbpar2} -f ./${SQL}/100_functions.sql
wait

echo "analysis done"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"







