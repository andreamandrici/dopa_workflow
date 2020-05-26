#!/bin/bash
# PARAMETERS
source species_parameters_dopaprc.conf


## SCHEMA MANAGEMENT
#psql ${dbpar2} -c "DROP SCHEMA IF EXISTS $SCH CASCADE;"
#psql ${dbpar2} -c "CREATE SCHEMA IF NOT EXISTS $SCH;"

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

# ## IMPORT SPECIES

#############
### BIRDS ###
#############

echo ${pgen}
echo ${pbl}
echo ${pgen}${pbl}

## IMPORT BIRDS GEOMS
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.birds_geom CASCADE;"
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM All_Species WHERE PRESENCE IN (1,2) AND ORIGIN IN (1,2) AND SEASONAL IN (1,2,3)" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${pbl}"/RL_2019.gdb" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."birds_geom"

# ### IMPORT BIRDS ATTS
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.birds_taxonomic CASCADE;"
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM BirdLife_HBW_Taxonomic_Checklist_V4" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${pbl}"/RL_2019.gdb" \
-nln ${SCH}."birds_taxonomic"

### IMPORT BIRDS ADDITIONAL ATTS
psql ${dbpar2} -c "DROP TABLE IF EXISTS ${SCH}.birds_additional_atts CASCADE;"
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM SppListAdditional" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${pbl}"/RL_2019.gdb" \
-nln ${SCH}."birds_additional_atts"

### IMPORT BIRDS Species without biomes
psql ${dbpar2} -c "DROP TABLE IF EXISTS ${SCH}.birds_species_wo_biomes CASCADE;"
ogr2ogr \
-overwrite \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${pbl}"/SpeciesWithoutBiomes.csv" \
-nln ${SCH}."birds_species_wo_biomes"
