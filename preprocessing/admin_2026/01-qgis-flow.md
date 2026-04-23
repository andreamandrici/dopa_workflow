# Sources

## country land
* CNTR_RG_01M_2024_4326.gpkg: geoms (263 multipolygons, all valid; fid as numerical primary key; epsg 4258)
* CNTR_AT_2024.gpkg: attributes (340 rows; cntr_id as text primary key)

## country marine
* GISCO.EEZ_RG_01M_2024.shp: geoms (288 multipolygons, some invalid; mrgid as numerical primary key; epsg 4258)
* EEZ_AT_2024.csv: attributes (288 rows; mrgid as numerical primary key) 

# Processing

## CNTR_RG_01M_2024_4326
* imported in POSTGIS (263 multipolygons; reproject from 4258 to 4326; fid as numerical primary key)

## CNTR_AT_2024
* imported in POSTGIS (340 rows; cntr_id as text primary key)


# EEZ

## EEZ_RG_01M_2024

* multipart to singlepart (377 polygons; mrgid is redundant: unique numeric fid is automatically added)
* gdal buffer 0 (twice, the second run on the first step result)
* check validity (GEOS)
* difference from CNTR_RG_01M_2024_4326 (ERASE land)
* multipart to singlepart (797 polygons; mrgid is redundant)
* check validity (GEOS)
* manual update fid to row
* gdal buffer 0 (twice, the second run on the first step result)
* check validity (GEOS)
* imported in POSTGIS (797 polygons; reproject from 4258 to 4326; fid as numerical primary key)

## EEZ_AT_2024 imported in POSTGIS (288 rows; mrgid as numerical primary key)
