#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

# EXECUTE AS ./execute.sh > logs/execute.log 2>&1

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

psql ${dbpar2} -f ./${SQL}/010_cep_atts_indexes.sql
wait
psql ${dbpar2} -f ./${SQL}/020_cep_coverages_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/030_protconn.sql
wait
psql ${dbpar2} -f ./${SQL}/041_cep_agb_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/042_cep_bgb_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/043_cep_soc_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/044_cep_carbon_total_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/051_cep_change_in_forest_cover_gain_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/052_cep_change_in_forest_cover_loss_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/053_cep_change_in_forest_cover_treecover.sql
wait
psql ${dbpar2} -f ./${SQL}/060_cep_inland_water_aggregations.sql
wait
psql ${dbpar2} -f ./${SQL}/090_output_tables.sql
wait
psql ${dbpar2} -f ./${SQL}/0100_functions.sql

echo "analysis done"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"







