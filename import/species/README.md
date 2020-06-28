# Data Import

## Species

Species are imported using ogr_fdw extension (shp2pgsql and ogr2ogr approaches have been also tested).

### IUCN

#### IUCN spatial

Check supported Formats:

`/usr/lib/postgresql/12/bin/ogr_fdw_info -f`

Check layers in path: 

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_spatial_202001/`

Check fields for specific layer (this also shows the code to create server and import one single table):

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_spatial_202001/ -l MAMMALS`

Create server and import ALL the tables at once:
```
CREATE SERVER species_iucn_spatial_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/home/felixwolf/wip/data/species_iucn_spatial_202001/',
	format 'ESRI Shapefile' );
CREATE SCHEMA species_iucn_spatial_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_spatial_202001
  INTO species_iucn_spatial_202001;
```

#### IUCN non-spatial

This dataset is split due to the 10000 download limit of IUCN Redlist site.

##### Non passeriformes

Check layers in path:

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_non_spatial_non_passeriformes_202001/`

Shows the code to create server (using a single table as example):

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_non_spatial_non_passeriformes_202001/ -l taxonomy`

Create server and import ALL the tables at once:

```
CREATE SERVER species_iucn_non_spatial_non_passeriformes_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/home/felixwolf/wip/data/species_iucn_non_spatial_non_passeriformes_202001/',
	format 'CSV' );
CREATE SCHEMA species_iucn_non_spatial_non_passeriformes_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_non_spatial_non_passeriformes_202001
  INTO species_iucn_non_spatial_non_passeriformes_202001;
```

##### Only passeriformes

Check layers in path:

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_non_spatial_only_passeriformes_202001/`

Shows the code to create server (using a single table as example):

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_iucn_non_spatial_only_passeriformes_202001/ -l taxonomy`

Create server and import ALL the tables at once:

```
CREATE SERVER species_iucn_non_spatial_only_passeriformes_202001
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/home/felixwolf/wip/data/species_iucn_non_spatial_only_passeriformes_202001/',
	format 'CSV' );
CREATE SCHEMA species_iucn_non_spatial_only_passeriformes_202001;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_iucn_non_spatial_only_passeriformes_202001
  INTO species_iucn_non_spatial_only_passeriformes_202001;
```

### Birdlife (spatial)

#### Birdlife spatial

Check layers in path:

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_birdlife_201903/RL_2019.gdb/`

Shows the code to create server (using a single table as example):

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_birdlife_201903/RL_2019.gdb/ -l All_Species`

Create server and import ALL the tables at once:

```
CREATE SERVER species_birdlife_201903
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/home/felixwolf/wip/data/species_birdlife_201903/RL_2019.gdb/',
	format 'OpenFileGDB' );
CREATE SCHEMA species_birdlife_201903;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_birdlife_201903
  INTO species_birdlife_201903;
```

#### Birdlife non spatial

Check layers in path:

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_birdlife_201903/SpeciesWithoutBiomes.xlsx`

Shows the code to create server (using a single table as example):

`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_birdlife_201903/SpeciesWithoutBiomes.xlsx -l Sheet1`

Create server and import ALL the tables at once:

```
CREATE SERVER species_birdlife_non_spatial_201903
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/home/felixwolf/wip/data/species_birdlife_201903/SpeciesWithoutBiomes.xlsx',
	format 'XLSX' );
CREATE SCHEMA species_birdlife_non_spatial_201903;
IMPORT FOREIGN SCHEMA ogr_all
  FROM SERVER species_birdlife_non_spatial_201903
  INTO species_birdlife_non_spatial_201903;
```







