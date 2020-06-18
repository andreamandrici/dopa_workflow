#!/bin/bash
# PARAMETERS
source eco_parameters.conf
MEOWPPOW="/ECOREGIONS/DataPack-14_001_WCMC036_MEOW_PPOW_2007_2012_v1/01_Data/WCMC-036-MEOW-PPOW-2007-2012.shp"
TEOW="/ECOREGIONS/TEOW/wwf_terr_ecos.shp"

## SCHEMA MANAGEMENT
psql ${dbpar2} -c "DROP SCHEMA IF EXISTS $SCH CASCADE;"
psql ${dbpar2} -c "CREATE SCHEMA IF NOT EXISTS $SCH;"

# IMPORT VECTORS

###			ogr2ogr parameters used
### -overwrite				delete the output layer if exists and recreate it empty 					
### -dialect sqlite			use sqlite SQL dialect				
### -sql					SQL statement to execute			
### -f						format_name				
### -lco					Layer creation option (format specific)
	###	FID						name of the PK column to create
### -nlt					define the geometry type for the created layer
### -nln					Assign a name to the new layer	


### ogr2ogr ############################################################
### MEOW_PPOW ##########################################################

echo "IMPORT ${pgen}${MEOWPPOW} with ogr2ogr"
# TIMER START
START_T1=$(date +%s)

psql ${dbpar2} -c "DROP TABLE IF EXISTS ${SCH}.meow_ppow_ogr CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" "${pgen}${MEOWPPOW}" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."meow_ppow_ogr"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE! IMPORT ${pgen}${MEOWPPOW} with ogr2ogr: $TOTAL_DIFF
"

### TEOW ###############################################################
echo "IMPORT ${pgen}${TEOW} with ogr2ogr"
# TIMER START
START_T1=$(date +%s)

psql ${dbpar2} -c "DROP TABLE IF EXISTS ${SCH}.teow_ogr CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" "${pgen}${TEOW}" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."teow_ogr"

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE! ${pgen}${TEOW} with ogr2ogr: $TOTAL_DIFF
"

#### shp2pgsql NON DUMP #################################################

#### MEOW_PPOW NON DUMP #################################################

#echo "IMPORT ${pgen}${MEOWPPOW} with shp2pgsql non-dump"
## TIMER START
#START_T1=$(date +%s)

#psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.meow_ppow_shp CASCADE;"
#shp2pgsql -s 4326 ${pgen}${MEOWPPOW} ${SCH}.meow_ppow_shp | psql ${dbpar2}

## stop timer
#END_T1=$(date +%s)
#TOTAL_DIFF=$(($END_T1 - $START_T1))
#echo "
#DONE! IMPORT ${pgen}${MEOWPPOW} with shp2pgsql non-dump: $TOTAL_DIFF
#"

#### TEOW NON DUMP #################################################

#echo "IMPORT ${pgen}${TEOW} with shp2pgsql non-dump"
## TIMER START
#START_T1=$(date +%s)

#psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.teow_shp CASCADE;"
#shp2pgsql -s 4326 ${pgen}${TEOW} ${SCH}.teow_shp | psql ${dbpar2}

## stop timer
#END_T1=$(date +%s)
#TOTAL_DIFF=$(($END_T1 - $START_T1))
#echo "
#DONE! IMPORT ${pgen}${TEOW} with shp2pgsql non-dump: $TOTAL_DIFF
#"


#### shp2pgsql DUMP #####################################################

#### MEOW_PPOW DUMP #####################################################

#echo "IMPORT ${pgen}${MEOWPPOW} with shp2pgsql dump"
## TIMER START
#START_T1=$(date +%s)

#psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.meow_ppow_shp_d CASCADE;"
#shp2pgsql -s 4326 -D ${pgen}${MEOWPPOW} ${SCH}.meow_ppow_shp_d | psql ${dbpar2}

## stop timer
#END_T1=$(date +%s)
#TOTAL_DIFF=$(($END_T1 - $START_T1))
#echo "
#DONE! MPORT ${pgen}${MEOWPPOW} with shp2pgsql dump: $TOTAL_DIFF
#"

#### TEOW DUMP #####################################################

#echo "IMPORT ${pgen}${TEOW} with shp2pgsql dump"
## TIMER START
#START_T1=$(date +%s)

#psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.teow_shp_d CASCADE;"
#shp2pgsql -s 4326 -D ${pgen}${TEOW} ${SCH}.teow_shp_d | psql ${dbpar2}

## stop timer
#END_T1=$(date +%s)
#TOTAL_DIFF=$(($END_T1 - $START_T1))
#echo "
#DONE! MPORT ${pgen}${TEOW} with shp2pgsql dump: $TOTAL_DIFF
#"


