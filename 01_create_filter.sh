#!/bin/bash
####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

psql ${dbpar2} -t -c "
UPDATE ${SCH}.z_1deg_grid
SET qfilter=FALSE
WHERE qid NOT IN (47352,47353,47354,47355,47712,47713,47714,47715,48072,48073,48074,48075,48432,48433,48434,48435)
;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
