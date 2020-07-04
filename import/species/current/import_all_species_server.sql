CREATE SERVER species_iucn_spatial_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/globes/ORIGINAL_DATASETS/SPECIES/current/species_iucn_spatial_202001/',
	format 'ESRI Shapefile' );
CREATE SCHEMA species_iucn_spatial_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_spatial_202001
  INTO species_iucn_spatial_202001;
  
CREATE SERVER species_iucn_non_spatial_non_passeriformes_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/globes/ORIGINAL_DATASETS/SPECIES/current/species_iucn_non_spatial_non_passeriformes_202001/',
	format 'CSV' );
CREATE SCHEMA species_iucn_non_spatial_non_passeriformes_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_non_spatial_non_passeriformes_202001
  INTO species_iucn_non_spatial_non_passeriformes_202001;
  
CREATE SERVER species_iucn_non_spatial_only_passeriformes_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/globes/ORIGINAL_DATASETS/SPECIES/current/species_iucn_non_spatial_only_passeriformes_202001/',
	format 'CSV' );
CREATE SCHEMA species_iucn_non_spatial_only_passeriformes_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_non_spatial_only_passeriformes_202001
  INTO species_iucn_non_spatial_only_passeriformes_202001;
  
CREATE SERVER species_birdlife_201903
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/globes/ORIGINAL_DATASETS/SPECIES/current/species_birdlife_201903/RL_2019.gdb/',
	format 'OpenFileGDB' );
CREATE SCHEMA species_birdlife_201903;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_birdlife_201903
  INTO species_birdlife_201903;