#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

outpath=`pwd`"/raster_output"
echo ${outpath}

####################################################################################################################################################

psql ${dbpar2} -t -c "\COPY (SELECT * FROM ${SCH}.fb_atts_all ORDER BY cid) TO '${outpath}/raster_output_attributes_b.csv' DELIMITER '|' CSV HEADER;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
