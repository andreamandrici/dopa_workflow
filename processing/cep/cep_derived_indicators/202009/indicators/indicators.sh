#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

# EXECUTE AS ./execute.sh > logs/execute.log 2>&1

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/010_cep_atts_indexes.sql -v v1="gaul_eez_dissolved_201912" -v v2="ecoregions_2020_atts" -v v3="wdpa_202009" -v v4="cep202009" 
wait
## INPUTS: v1=country v2=ecoregion v3=wdpa v4=current cep flattening schema
## OUTPUTS: general outputs in cep schema - IN FUTURE COULD BE INCLUDED IN CEP GENERATION

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/100_200_cep_information_conservation_aggregations.sql
wait
## INPUTS: current CEP
## OUTPUTS: country_conservation_coverage # country_conservation_coverage_ecoregions_stats # ecoregion_conservation_coverages # wdpa_conservation_coverages

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/301_cep_carbon_above_ground_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_agc2017_100m"
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: country_carbon_above_ground # ecoregion_carbon_above_ground # wdpa_carbon_above_ground

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/302_cep_carbon_below_ground_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_bgc2017_100m" 
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: country_carbon_below_ground # ecoregion_carbon_below_ground # wdpa_carbon_below_ground

####################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/303_cep_carbon_soil_organic_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_gsoc_tot"
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: country_carbon_soil_organic # ecoregion_carbon_soil_organic # wdpa_carbon_soil_organic

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/304_cep_carbon_total_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_carbon_total_202009"
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: # country_carbon_soil_organic # ecoregion_carbon_soil_organic # wdpa_carbon_soil_organic

##################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/cep_r_univar_continuous_quantity.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_gebco2020" -v v3="elevation_profile"
wait
## INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
## OUTPUTS: country_elevation_profile # ecoregion_elevation_profile # wdpa_elevation_profile

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/601_cep_global_forest_cover_gain_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_stats_cep_gfc_gain_over30"
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: country_global_forest_cover_gain # ecoregion_global_forest_cover_gain # wdpa_global_forest_cover_gain

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/602_cep_global_forest_cover_loss_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_stats_cep_gfc_lossyear_over30"
wait
## INPUTS: v1=input dataset schema v2=input dataset
## OUTPUTS: country_global_forest_cover_loss # ecoregion_global_forest_cover_loss # wdpa_global_forest_cover_loss

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/603_cep_global_forest_cover_treecover_aggregations.sql -v v1="202009" -v v2="r_univar_cep_gfc_treecover_over30" -v v4="gfc_treecover"
wait
# INPUTS: v1=release (eg:202009) v2=input dataset v4=subtheme
# OUTPUTS: country_global_forest_cover_treecover # ecoregion_global_forest_cover_teecover # wdpa_global_forest_cover_treecover

##################################################################################################################################################
#psql ${dbpar2} -f ./${SQL}/cep_r_univar_continuous_quantity.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_ghs_pop_9as_2000" -v v3="pressure_population_first_epoch" 
#wait
# INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
# OUTPUTS: country_pressure_population_first_epoch # ecoregion_pressure_population_first_epoch # wdpa_pressure_population_first_epoch

##################################################################################################################################################
#psql ${dbpar2} -f ./${SQL}/cep_r_univar_continuous_quantity.sql -v v1="results_202009_cep_in" -v v2="r_univar_cep_ghs_pop_9as_2015" -v v3="pressure_population_last_epoch" 
#wait
# INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
# OUTPUTS: country_pressure_population_last_epoch # ecoregion_pressure_population_last_epoch # wdpa_pressure_population_last_epoch

##################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/1105_cep_pressure_population.sql 
wait
### TO BE EDITED AND PARAMETRIZED

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/1300_cep_water_surface_inland_aggregations.sql -v v1="results_202009_cep_in" -v v2="r_stats_cep_gsw_transitions"
wait
# INPUTS: v1=input dataset schema v2=input
# OUTPUTS: country_water_surface_inland # ecoregion_water_surface_inland # wdpa_water_surface_inland

echo "analysis done"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"







