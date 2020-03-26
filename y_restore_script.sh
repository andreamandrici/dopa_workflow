#!/bin/bash

source workflow_parameters.conf

# comment with -- to switch off tables

## DROP TABLES
psql ${dbpar2} -t -c "
DROP TABLE IF EXISTS ${SCH}.a_input_country;
DROP TABLE IF EXISTS ${SCH}.a_input_ecoregion;
DROP TABLE IF EXISTS ${SCH}.a_input_wdpa;
DROP TABLE IF EXISTS ${SCH}.b_clip_country;
DROP TABLE IF EXISTS ${SCH}.b_clip_ecoregion;
DROP TABLE IF EXISTS ${SCH}.b_clip_wdpa;
DROP TABLE IF EXISTS ${SCH}.c_raster_country;
DROP TABLE IF EXISTS ${SCH}.c_raster_ecoregion;
DROP TABLE IF EXISTS ${SCH}.c_raster_wdpa;
DROP TABLE IF EXISTS ${SCH}.da_tiled_country;
DROP TABLE IF EXISTS ${SCH}.da_tiled_ecoregion;
DROP TABLE IF EXISTS ${SCH}.da_tiled_wdpa;
DROP TABLE IF EXISTS ${SCH}.db_tiled_temp;
DROP TABLE IF EXISTS ${SCH}.dc_tiled_all;
DROP TABLE IF EXISTS ${SCH}.e_flat_all;
DROP TABLE IF EXISTS ${SCH}.fa_atts_tile;
DROP TABLE IF EXISTS ${SCH}.fb_atts_all;
DROP TABLE IF EXISTS ${SCH}.g_flat_temp;
DROP TABLE IF EXISTS ${SCH}.h_flat;
" 

## RESTORE TABLES
psql ${dbpar2} -t -c "
ALTER TABLE ${SCH}_bak.a_input_country SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.a_input_ecoregion SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.a_input_wdpa SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.b_clip_country SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.b_clip_ecoregion SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.b_clip_wdpa SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.c_raster_country SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.c_raster_ecoregion SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.c_raster_wdpa SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.da_tiled_country SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.da_tiled_ecoregion SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.da_tiled_wdpa SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.db_tiled_temp SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.dc_tiled_all SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.e_flat_all SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.fa_atts_tile SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.fb_atts_all SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.g_flat_temp SET SCHEMA ${SCH};
ALTER TABLE ${SCH}_bak.h_flat SET SCHEMA ${SCH};
"

