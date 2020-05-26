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
# IMPORT VECTORS

# ## IMPORT SPECIES

##############
### CORALS ###
##############

### IMPORT CORALS
### IMPORT CORALS PART1
psql ${dbpar2} -c "DROP TABLE IF EXISTS  ${SCH}.corals CASCADE;"
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM REEF_FORMING_CORALS_PART1 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/REEF_FORMING_CORALS/REEF_FORMING_CORALS_PART1.shp" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."corals"
wait
### IMPORT CORALS PART2
ogr2ogr \
-update \
-append \
-dialect sqlite \
-sql "SELECT * FROM REEF_FORMING_CORALS_PART2 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/REEF_FORMING_CORALS/REEF_FORMING_CORALS_PART2.shp" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."corals"
wait
### IMPORT CORALS PART3
ogr2ogr \
-update \
-append \
-dialect sqlite \
-sql "SELECT * FROM REEF_FORMING_CORALS_PART3 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)" \
-f "PostgreSQL"  PG:"$dbpar1" ${pgen}${prl}"/REEF_FORMING_CORALS/REEF_FORMING_CORALS_PART3.shp" \
-nlt "MULTIPOLYGON" \
-nln ${SCH}."corals"
