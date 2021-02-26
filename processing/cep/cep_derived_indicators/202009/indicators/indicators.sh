#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

# EXECUTE AS ./execute.sh > logs/execute.log 2>&1

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

####################################################################################################################################################
#psql ${dbpar2} -f ./${SQL}/010_cep_atts_indexes.sql -v v1="gaul_eez_dissolved_201912" -v v2="ecoregions_2020_atts" -v v3="wdpa_202009" -v v4="cep202009" 
## INPUTS: v1=country v2=ecoregion v3=wdpa v4=current cep flattening schema
## OUTPUTS: general outputs in cep schema - IN FUTURE COULD BE INCLUDED IN CEP GENERATION
#wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/100_200_cep_information_conservation_aggregations.sql
# # INPUTS: current CEP
# # OUTPUTS:
# ## results_aggregated.country_conservation_coverage
# ## results_aggregated.country_conservation_coverage_ecoregions_stats
# ## results_aggregated.ecoregion_conservation_coverages
# ## results_aggregated.wdpa_conservation_coverages
# wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/301_cep_carbon_above_ground_aggregations.sql -v v1="results_202009" -v v2="r_univar_cep_agc2017_100m" -v v3="cep202009" 
# # INPUTS: v1=input dataset schema v2=input dataset v3=area grid
# # OUTPUTS:
# ## results_aggregated.country_carbon_above_ground
# ## results_aggregated.ecoregion_carbon_above_ground
# ## results_aggregated.wdpa_carbon_above_ground
# wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/302_cep_carbon_below_ground_aggregations.sql -v v1="results_202009" -v v2="r_univar_cep_bgc2017_100m" -v v3="cep202009" 
# # INPUTS: v1=input dataset schema v2=input dataset v3=area grid
# # OUTPUTS:
# ## results_aggregated.country_carbon_below_ground
# ## results_aggregated.ecoregion_carbon_below_ground
# ## results_aggregated.wdpa_carbon_below_ground
# wait

# ####################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/303_cep_carbon_soil_organic_aggregations.sql -v v1="results_202009" -v v2="r_univar_cep_gsoc_tot" -v v3="cep202009" 
# # INPUTS: v1=input dataset schema v2=input dataset v3=area grid
# # OUTPUTS:
# ## results_aggregated.country_carbon_soil_organic
# ## results_aggregated.ecoregion_carbon_soil_organic
# ## results_aggregated.wdpa_carbon_soil_organic
# wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/304_cep_carbon_total_aggregations.sql -v v1="results_202009" -v v2="r_univar_cep_carbon_total_202009" -v v3="cep202009" 
# # INPUTS: v1=input dataset schema v2=input dataset v3=area grid
# # OUTPUTS:
# ## results_aggregated.country_carbon_soil_organic
# ## results_aggregated.ecoregion_carbon_soil_organic
# ## results_aggregated.wdpa_carbon_soil_organic
# wait

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/cep_r_univar.sql -v v1="results_202009" -v v2="r_univar_cep_gebco2020" -v v3="elevation_profile"
wait

# INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
# OUTPUTS:
## results_aggregated.country_elevation_profile
## results_aggregated.ecoregion_elevation_profile
## results_aggregated.wdpa_elevation_profile

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/601_cep_global_forest_cover_gain_aggregations.sql -v v1="results_202009" -v v2="r_stats_cep_gfc_gain_over30"
# # INPUTS: v1=input dataset schema v2=input dataset
# # OUTPUTS:
# ## results_aggregated.country_global_forest_cover_gain
# ## results_aggregated.ecoregion_global_forest_cover_gain
# ## results_aggregated.wdpa_global_forest_cover_gain
# wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/602_cep_global_forest_cover_loss_aggregations.sql -v v1="results_202009" -v v2="r_stats_cep_gfc_lossyear_over30"
# # INPUTS: v1=input dataset schema v2=input dataset
# # OUTPUTS:
# ## results_aggregated.country_global_forest_cover_loss
# ## results_aggregated.ecoregion_global_forest_cover_loss
# ## results_aggregated.wdpa_global_forest_cover_loss
# wait

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/603_cep_global_forest_cover_treecover_aggregations.sql -v v1="results_202009" -v v2="r_univar_cep_gfc_treecover_over30" -v v3="cep202009" 
# # INPUTS: v1=input dataset schema v2=input dataset v3=area grid
# # OUTPUTS:
# ## results_aggregated.country_global_forest_cover_treecover
# ## results_aggregated.ecoregion_global_forest_cover_teecover
# ## results_aggregated.wdpa_global_forest_cover_treecover
# wait

###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/cep_r_univar.sql -v v1="results_202009" -v v2="r_univar_cep_ghs_pop_9as_1975" -v v3="pressure_population_first_epoch" 
wait
# INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
# OUTPUTS:
## results_aggregated.country_pressure_population_first_epoch
## results_aggregated.ecoregion_pressure_population_first_epoch
## results_aggregated.wdpa_pressure_population_first_epoch


###################################################################################################################################################
psql ${dbpar2} -f ./${SQL}/cep_r_univar.sql -v v1="results_202009" -v v2="r_univar_cep_ghs_pop_9as_2015" -v v3="pressure_population_last_epoch" 
wait
# INPUTS: v1=input dataset schema v2=input dataset v3=subtheme
# OUTPUTS:
## results_aggregated.country_pressure_population_last_epoch
## results_aggregated.ecoregion_pressure_population_last_epoch
## results_aggregated.wdpa_pressure_population_last_epoch

# ###################################################################################################################################################
# psql ${dbpar2} -f ./${SQL}/1300_cep_water_surface_inland_aggregations.sql -v v1="results_202009" -v v2="r_stats_cep_gsw_transitions"
# # INPUTS: v1=input dataset schema v2=input
# # OUTPUTS:
# ## results_aggregated.country_water_surface_inland
# ## results_aggregated.ecoregion_water_surface_inland
# ## results_aggregated.wdpa_water_surface_inland

echo "analysis done"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"







