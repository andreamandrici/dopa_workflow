#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source ./workflow_spirr_parameters.conf
threads=$1
####################################################################################################################################################

# INSTRUCTIONS
Usage () {
    echo "
This script will parallelize postgis processing. Execute it as:
time ./command_name.sh 72 > logs/command_name_log.txt 2>&1
"
}

## Parameters which are being read
# SCH_SP="species_cep_data"
# SCH_CEP="cep202003"
# SCH="species_irreplaceability"
####################################################################################################################################################
## INPUT TOPIC
####################################################################################################################################################
TOPIC_T="species_irr"
FID_T="qid"

echo "TOPIC IS ${TOPIC_T}"
echo "FID_TOPIC IS ${FID_T}"

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.species_cep_intersection;"
psql ${dbpar2} -t -c "CREATE TABLE ${SCH}.species_cep_intersection 
(unique_id text, qid integer, mammals int[], wdpa int[], country integer, ecoregion integer, area_km2 float);"
# This could go into the intro and we just truncate here.

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.input_${TOPIC_T}_onprocess;
CREATE TABLE ${SCH}.input_${TOPIC_T}_onprocess AS
SELECT DISTINCT ${FID_T} fid FROM ${SCH_CEP}.h_flat
ORDER BY fid;
SELECT fid FROM ${SCH}.input_${TOPIC_T}_onprocess;
EOF
)

## LIST
list=`psql ${dbpar2} -t -c "$sql_select"`
arr=(${list})
elements="${#arr[@]}"
objects=$((elements/threads))
if (( ${objects} == 0))
then
objects=1
fi

echo "number of elements: "${elements}
echo "number of objects in each step: "${objects}
echo "number of dedicated threads: "${threads}

## EXECUTE
sql_execute=$(cat<<EOF
SELECT fid FROM ${SCH}.input_${TOPIC_T}_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "start processing object "${OBJ}
			START_TT1=$(date +%s)
			# psql ${dbpar2} -t -c "SELECT ${SCH}.f_intersect_species_pa('${SCH}.a_input_${TOPIC_T}','${FID_T}','${VERSION_T}',${OBJ});"
			psql ${dbpar2} -t -c "SELECT ${SCH}.f_intersect_species_pa(${OBJ});"
			# for now just supply qid - we can pass other info later
			wait
			END_TT1=$(date +%s)
			PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
			echo "end processing object "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.input_${TOPIC_T}_onprocess;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
