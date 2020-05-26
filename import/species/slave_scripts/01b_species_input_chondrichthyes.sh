#!/bin/bash
# PARAMETERS
source species_parameters_dopaprc.conf

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

######################
### CHONDRICHTHYES ###
######################

### IMPORT CHONDRICHTHYES ALL
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.chondrichthyes CASCADE;"
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM SHARKS_RAYS_CHIMAERAS WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/SHARKS_RAYS_CHIMAERAS/SHARKS_RAYS_CHIMAERAS.shp" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."chondrichthyes"
