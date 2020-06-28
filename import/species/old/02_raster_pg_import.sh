#!/bin/bash

###instructions
###launch it as: ./02_raster_pg_import.sh > logs/02_raster_pg_import.log 2>&1
###

# TIMER START
START_T1=$(date +%s)

# PARAMETERS
source species_parameters_dopaprc.conf

###################################################################
# EXECUTE AS postgres
## ALTER DATABASE wolfe SET postgis.gdal_enabled_drivers = 'ENABLE_ALL';
## ALTER DATABASE wolfe SET postgis.enable_outdb_rasters TO True;
## SELECT pg_reload_conf();

# raster2pgsql parameters used
## -p prepare
## -a append
## -b  BAND  Index (1-based) of band to extract from raster. For more than one band index, separate with comma (,). If unspecified, all bands of raster will be extracted.
## -t  # -t 512x512  TILE_SIZE Cut raster into tiles to be inserted one per table row. TILE_SIZE is expressed as WIDTHxHEIGHT or set to the value "auto" to allow the loader to compute an appropriate tile size using the first raster and applied to all rasters.


## -s  <SRID> Assign output raster with specified SRID. If not provided or is zero, raster's metadata will be checked to determine an appropriate SRID.
## -t  <TILE_SIZE> Cut raster into tiles to be inserted one per table row. TILE_SIZE is expressed as WIDTHxHEIGHT or set to the value "auto" to allow the loader to compute an appropriate tile size using the first raster and applied to all rasters.
### -P  Pad right-most and bottom-most tiles to guarantee that all tiles have the same width and height.
### -R  Register the raster as an out-of-db (filesystem) raster. Provided raster should have absolute path to the file
## -I  Create a GiST index on the raster column.
## -C  Apply raster constraints -- srid, pixelsize etc. to ensure raster is properly registered in raster_columns view.
## -r  Set the constraints (spatially unique and coverage tile) for regular blocking. Only applied if -C flag is also used.
## -e  Execute each statement individually, do not use a transaction.
### -N <nodata> NODATA value to use on bands without a NODATA value.
### -k  Skip NODATA value checks for each raster band.
## -Y  Use copy statements instead of insert statements.


###################################################################
# ESA_CCI
psql ${dbpar2} -c "DROP TABLE IF EXISTS ${SCH}.esa_cci_ll_2018 CASCADE"
raster2pgsql -s 4326 -t 360x360 -I -C -r -e -k -N 0 -Y $pgen/COPERNICUS/LCCI/uncompressed/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.tif ${SCH}.esa_cci_ll_2018 | psql ${dbpar2}

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "
DONE!
TOTAL SCRIPT TIME: $TOTAL_DIFF"

