#!/bin/bash

## EXECUTE IT AS ./z_do_it_all.sh > logs/z_do_it_all.log 2>&1 &

# TIMER START
START_T1=$(date +%s)

# set number of dedicated cores for all the subscripts
ncores=7

# PRE RUN
#------------------------------------------------------------------------

## OPTIONAL - MAKE A BACKUP
## drops the previous backup, and MOVES the working schema as backup
#./x_backup_script.sh > logs/x_backup_script.log 2>&1 wait 

# CREATE ALL INFRASTRUCTURE
## drops (if exists) and creates processing schema,tables and functions, evaluating dynamically parameters defined in workflow parameters
#./00_create_infrastructure.sh > logs/00_create_infrastructure.log 2>&1 wait

# OPTIONAL - SETUP A FILTER ON TILE NUMBERS
## filters the grid by qid (setting FALSE qfilter field in the grid) - set parameters in THIS script!
#./01_create_filter.sh > logs/01_create_filter.log 2>&1 wait

# OPTIONAL - RESTORE A BACKUP
## MOVES tables from backup to working schema - set parameters in THIS script!
#./y_restore_script.sh > logs/y_restore_script.log 2>&1 wait 
 
# FOR EACH INPUT TOPIC
#------------------------------------------------------------------------

# A-INPUT TABLES
## populates input tables
#./a_input_teow.sh ${ncores} > logs/a_input_teow.log 2>&1 wait
#./a_input_meow.sh ${ncores} > logs/a_input_meow.log 2>&1 wait
#./a_input_ppow.sh ${ncores} > logs/a_input_ppow.log 2>&1 wait
#./a_input_eeow.sh ${ncores} > logs/a_input_eeow.log 2>&1 wait

# B-CLIP TABLES
## populates clip tables
#./b_clip_teow.sh ${ncores} > logs/b_clip_teow.log 2>&1 wait
#./b_clip_meow.sh ${ncores} > logs/b_clip_meow.log 2>&1 wait
#./b_clip_ppow.sh ${ncores} > logs/b_clip_ppow.log 2>&1 wait

# C-RASTER TABLES
## populates raster tables
#./c_rast_teow.sh ${ncores} > logs/c_raster_teow.log 2>&1 wait
#./c_rast_meow.sh ${ncores} > logs/c_raster_meow.log 2>&1 wait
#./c_rast_ppow.sh ${ncores} > logs/c_raster_ppow.log 2>&1 wait

# D-TILED TABLES
## DA-populates tiled tables (in parallel)
./da_tiled_teow.sh ${ncores} > logs/da_tiled_teow.log 2>&1 wait
./da_tiled_meow.sh ${ncores} > logs/da_tiled_meow.log 2>&1 wait
./da_tiled_ppow.sh ${ncores} > logs/da_tiled_ppow.log 2>&1 wait
./da_tiled_eeow.sh ${ncores} > logs/da_tiled_ppow.log 2>&1 wait

## FOR AGGREGATED INPUTS
##------------------------------------------------------------------------

### DB-populates tiled tables (single core)
./db_tiled_all.sh ${ncores} > logs/db_tiled_all.log 2>&1 wait

## E-FLAT TABLE
### populates flat_all table
./e_flat_all.sh ${ncores} > logs/e_flat_all.log 2>&1 wait

## F-ATTRIBUTE TABLE
#### populates atts_tile, THEN atts_all tables
./f_attributes_all.sh ${ncores} > logs/f_attributes_all.log 2>&1 wait

# FLAT_TEMP
## populates flat_temp
./g_final_all.sh ${ncores} > logs/g_final_all.log 2>&1 wait

# FLAT_FINAL
## populates flat
./h_output.sh > logs/h_output.log 2>&1 wait

# USEFUL COMMANDS
#------------------------------------------------------------------------

# READ LOGS
### lists completed
# less e_flat_all.log | grep " in "

### counts completed
# less e_flat_all.log | grep " in " | wc -l

### shows the end of the process
# tail -n 30 e_flat_all.log

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
echo "analysis end"
exit
