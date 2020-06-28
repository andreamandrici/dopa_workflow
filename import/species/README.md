# Data Import

## Species

### IUCN spatial

Using ogr_fdw:

Check supported Formats: 
`/usr/lib/postgresql/12/bin/ogr_fdw_info -f`

Check layers in path: 
`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_202001/`

Check fields for specific layer (this also shows the code to create server and import one single table):
`/usr/lib/postgresql/12/bin/ogr_fdw_info -s /home/felixwolf/wip/data/species_202001/ -l MAMMALS`

Create server and import ALL the tables:
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
