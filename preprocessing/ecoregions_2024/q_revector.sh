#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf
threads=$1
####################################################################################################################################################

# INSTRUCTIONS
Usage () {
    echo "
This script will parallelize postgis processing. Execute it as:
time ./command_name.sh 72 > logs/command_name_log.txt 2>&1
"
}

####################################################################################################################################################
## 
####################################################################################################################################################


# CLEAN OUTPUT TABLES
psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.q_revector_temp;CREATE TABLE ${SCH}.q_revector_temp(qid integer,cid bigint,geom geometry(MultiPolygon,4326),sqkm double precision);"

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.revector_all_onprocess;
CREATE TABLE ${SCH}.revector_all_onprocess AS
SELECT DISTINCT qid FROM ${SCH}.o_raster ORDER BY qid;
SELECT qid FROM ${SCH}.revector_all_onprocess;
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
SELECT qid FROM ${SCH}.revector_all_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "start processing tile "${OBJ}
			START_TT1=$(date +%s)
 
psql ${dbpar2} -t -c "SELECT ${SCH}.f_revector(${OBJ},'${SCH}');"
wait
END_TT1=$(date +%s)
PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
echo "end processing tile "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait
psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.q_revector;CREATE TABLE ${SCH}.q_revector AS SELECT * FROM ${SCH}.q_revector_temp ORDER BY qid,cid;"
psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.revector_all_onprocess;"
psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.q_revector_temp;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
