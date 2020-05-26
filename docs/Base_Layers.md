# COUNTRIES (2019)

## Sources

ISO CODES. ISO 3166 officially assigned country codes from International Organization for Standardization, Geneva.
Available online at https://www.iso.org/obp/ui/#search.
Downloaded on 20191122.

EEZ V11. Flanders Marine Institute (2019). Maritime Boundaries Geodatabase, version 11.
Available online at http://www.marineregions.org/. https://doi.org/10.14284/382.
Downloaded on 20191122.

Preprocessing

A flat topological corrected layer for EEZ has been obtained in PostGIS, using the
script http://h05-redmine.jrc.it/attachments/download/315/eez_2019.sql, also
available in /GLOBES/processing_current/eez_2019.sql.

# ECOREGIONS (V2019)

## Sources

+  Olson, D. M., Dinerstein, E., Wikramanayake, E. D., Burgess, N. D., Powell, G. V. N., Underwood, E. C., D'Amico, J. A., Itoua, I., Strand, H. E., Morrison, J. C., Loucks, C. J., Allnutt, T. F., Ricketts, T. H., Kura, Y., Lamoreux, J. F., Wettengel, W. W., Hedao, P., Kassem, K.R. 2001. Terrestrial ecoregions of the world: a new map of life on Earth. Bioscience 51(11):933-938.
Available online at http://www.worldwildlife.org/publications/terrestrial-ecoregions-of-the-world.
Downloaded on 201603.

+  The Nature Conservancy (2012). Marine Ecoregions and Pelagic Provinces of the World. GIS layers developed by The Nature Conservancy with multiple partners, combined from Spalding et al. (2007) and Spalding et al. (2012). Cambridge (UK): The Nature Conservancy.
Downloaded on 20160720 from http://data.unep-wcmc.org/datasets/38.
Version with complete coastline has been used (in previous versions NoCoast was used), because of the better coastline of MEOW/PPOW (eg: a stripe of about 1000x1 Km was missing from land on Adriatic sea), and to the fact that "Saint Pierre et Michelon" and "Tokealu" islands were obliterated by the NoCoast version.

Original dataset are kept in /SPATIAL_DATA/ORIGINAL_DATASETS/ folder, within
TEOW and WCMC/MEOW_PPOW/ subfolders

Preprocessing
h05-redmine.jrc.it/projects/dopa/wiki/DOPA_complete_workflow
3/82/28/2020

DOPA complete workflow - DOPA - Redmine

A flat topological corrected layer, integrating the 3 sources [teow+
(meow+ppow)] has been obtained:
1. assigning unique numeric id to each class in the original layers:
1. for TEOW the original ECO_ID field has been used. The REALM info
"AT" (Afrotropics) and "NT" (Neotropics) for ECO_IDs -9999
(Rock and Ice) and -9998 (Lake) is not included because, since
for polar regions is NULL, it produces redundancy on the
ECO_ID field (primary key in the final dataset).
2. for MEOW and PPOW, for historical reasons, the same IDs previously
assigned by JRC (reviewed with Bastian Bertzky in 2015) has been
used, with a JOIN based on multiple fields
(ECOREGION,PROVINC,BIOME or REALM, depending from the source),
adapting original names when needed.
3. correspondence table within original fields and final attributes is saved
in the final geopackage as "lookup_attribute_table", where the boolean
fields "eco/pro/bio_is_mod" identify rows where
ECOREGION/PROVINC/BIOME content has been modified (respect to
"ORIGINAL_*" fields, included) to match the names in the final
attributes (first_level, second_level, third_level), allowing this way the
join.
first_level corresponds to TEOW Ecoregion, MEOW Ecoregion,
PPOW Province
second_level corresponds to TEOW Biome, MEOW Province, PPOW
Biome
third_level corresponds to REALM for TEOW, MEOW and PPOW.
2. overlapping (ArcGIS PRO UNION) MEOW_PPOW with a Bounding Box
Polygon (±180/90) as EEOW source (Empty Ecoregions of the World!), with
the code 100001-"unassigned land ecoregion"
3. assigning MEOW/PPOW polygons intersecting EEOW to MEOW/PPOW. EEOW
only polygons are left untouched
4. overlapping (ArcGIS PRO UNION) the TEOW+MEOW_PPOW_EEOW from the
previous step
5. assigning:
1. TEOW, MEOW or PPOW only polygons to TEOW, MEOW or PPOW
2. TEOW polygons intersecting EEOW to TEOW
3. TEOW polygons intersecting MEOW or PPOW to MEOW or PPOW. This
is different from previous version, where TEOW overlapped
MEOW/PPOW. This is due to the better MEOW/PPOW coastline.
exception to the above: 5 polygons intersecting both
meow/ppow (codes ppow-9 and meow-20073,20077) and
teow have been assigned to teow, because they were the
only polygons assigned to teow 61318-"St. Peter and St.
Paul rocks" and 60172-"Trindade-Martin Vaz Islands
tropical forests".
4. To identify features not reaching ±180/90, EEOW only have been
exploded to singlepart, then intersected with a multiline created at -0.5
arcsec (about 15 meters at equator) from extremes. This way:
5. an unassigned stripe of 360dx15 Km has been flagged as real antarctic
land (teow),
6. few polygons (11 originally) have been manually split (20 polygons),
then:
the 14 parts adjoining TEOW and extremes have been assigned to
the correspondent TEOW classes
the other 6 parts have been left unchanged (EEOW).
The result of the above is included in the final geopackage as
ecoregions_2019_raw spatial layer as undissolved, single part polygons,
where for each of them is reported:
source (teow, meow, ppow, eeow)
eco_id (first_level_code)
notes:
"originally teow/meow/ppow/eeow" = attribute unchanged
"assigned to meow/ppow" = originally teow, assigned to meow/ppow
"assigned to teow" = originally meow/ppow, assigned to teow (codes
ppow-9 and meow-20073,20077; assigned to teow 61318-"St. Peter
and St. Paul rocks" and 60172-"Trindade-Martin Vaz Islands tropical
forests")
h05-redmine.jrc.it/projects/dopa/wiki/DOPA_complete_workflow
4/82/28/2020
DOPA complete workflow - DOPA - Redmine
"reassigned to teow" = originally eeow, assigned to adjacent teow
classes (eg: antarctic land adjoining south pole), some with with
manual split (14 parts crossing ±180)
"reassigned to eeow" = originally eeow, split in the previous step.
Above object has been dissolved in ArcGIS PRO (returing the expect 1097
classes) then exploded as single part polygons. NB: any correction to
ecoregions should be applied to teow_meow_ppow_eeow_raw, then
dissolve it again to get the final version.
This version has been imported in PostGIS, then checked for geometry validity,
fixed, finalized (single and multiparts) with the script http://h05-
redmine.jrc.it/attachments/download/314/ecoregions_2019.sql, also available in
/GLOBES/processing_current/ecoregions_2019.sql. The same script contains also
method to calculate statistics (source and ecoregions change), as discussed with
Luca Battistella, also available as http://h05-
redmine.jrc.it/attachments/download/313/ecoregions_2019_statistics.xlsx, and
http://h05-redmine.jrc.it/attachments/download/312/ecoregions_2019.sql, also
available in /GLOBES/processing_current/ecoregions_2019_statistics.xlsx.
The final version is included as geopackage in
/spatial_data/Derived_Datasets/ecoregions_2019.gpkg, wich includes:
ecoregions_2019 multipart
ecoregions_2019_raw (undissolved, single part polygons)
lookup_attribute_table (correspondence table within original fields and final
attributes).
THEMATIC LAYERS
SPECIES
