# COUNTRIES (V2019)

A flat topological corrected layer for EEZ has been obtained in PostGIS, using the SQL script [eez_2019](./eez_2019.sql).
Update of Countries is pending since November 2019, waiting for decision on Land dataset.

# ECOREGIONS (V2020)
Calculation of [Country/Ecoregion/Protection (CEP) layer for March 2020](https://andreamandrici.github.io/dopa_workflow/processing/cep/#version-202003) highlighted several (incorrect) geometric overlaps in the original [Terrestrial Ecoregions Dataset](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html#ecoregions-v2019), not identified by the relaxed ArcGIS PRO topological model, which led to the inclusion of a post-processing  [patch](../processing/cep/202003_fix_cep_overlaps.sql) to correct the data.
To avoid endlessly replicating the application of the above patch, ecoregions dataset has been regenerated from scratch, resolving the topological problems, abandoning ArcGIS and using the [flattening](../flattening/) scripts chain.

General approach is the same of [Ecoregions 2019](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html#ecoregions-v2019) (for further details please refer to it):
+  dataset is given by intersection of TEOW/MEOW/PPOW
+  the version of MEOW/PPOW with complete coastline version is used
+  MEOW/PPOW is overlayed on topo of TEOW, and MEOW coastline substitutes TEOW's one
+  "holes" are filled by an empty layer covering the whole globe, named EEOW (Empty Ecoregions of the World!), flagged as "unassigned land ecoregion".

To simplify the outputs and the following processing steps, few classes have been recoded:

+  PPOW code 0 reclassed to 37
+  TEOW code -9998 reclassed to 9998
+  TEOW code -9999 to 9999.

After the intersections, the classes are assigned as:

+  MEOW⋂EEOW=MEOW
+  MEOW⋂TEOW=MEOW; exception: 2 MEOW objects in classes 20073,20077 have been respectively assigned to the intersecting TEOW classes 61318,60172
+  PPOW⋂EEOW=PPOW; exception: 1 PPOW object in class 9 has been assigned to the intersecting TEOW class 61318
+  PPOW⋂TEOW=PPOW
+  TEOW⋂EEOW=TEOW
+  EEOW⋂=EEOW; these have been considered "unassigned land ecoregion", and (*differently from Ecoregions V2019*) have not been partially assigned to adjoining TEOW classes.


# ECOREGIONS (V2019)

MEOW/PPOW version with complete coastline has been used (previously the NoCoast one was used), because of the better coastline (eg: in previous versions a stripe of about 1000x1 Km was missing from the Adriatic coast), and because "Saint Pierre et Michelon" and "Tokealu" islands were obliterated by the NoCoast version.

A flat topological corrected layer, integrating the 3 sources [teow+(meow+ppow)] has been obtained:
1. assigning unique numeric id to each class in the original layers:
   +  for TEOW the original ECO_ID field has been used. The REALM info "AT" (Afrotropics) and "NT" (Neotropics) for ECO_IDs -9999 (Rock and Ice) and -9998 (Lake) is not included because, since for polar regions is NULL, it produces redundancy on the ECO_ID field (primary key in the final dataset).
   +  for MEOW and PPOW, for historical reasons, the same IDs previously assigned by JRC (reviewed with Bastian Bertzky in 2015) has been used, with a JOIN based on multiple fields (ECOREGION,PROVINC,BIOME or REALM, depending from the source), adapting original names when needed.
   +  correspondence table within original fields and final attributes is saved in the final output as "lookup_attribute_table", where the boolean fields "eco/pro/bio_is_mod" identify rows where ECOREGION/PROVINC/BIOME content has been modified (respect to "ORIGINAL_*" fields, included) to match the names in the final attributes (first_level, second_level, third_level), allowing this way the join.
      +  first_level corresponds to TEOW Ecoregion, MEOW Ecoregion, PPOW Province
      +  second_level corresponds to TEOW Biome, MEOW Province, PPOW Biome
      +  third_level corresponds to REALM for TEOW, MEOW and PPOW.
2. overlapping (ArcGIS PRO UNION) MEOW_PPOW with a Bounding Box Polygon (±180/90) as EEOW source (Empty Ecoregions of the World!), with the code 100001-"unassigned land ecoregion"
3. assigning MEOW/PPOW polygons intersecting EEOW to MEOW/PPOW. EEOW only polygons are left untouched
4. overlapping (ArcGIS PRO UNION) the TEOW+MEOW_PPOW_EEOW from the previous step
5. assigning:
   +  TEOW, MEOW or PPOW only polygons to TEOW, MEOW or PPOW
   +  TEOW polygons intersecting EEOW to TEOW
   +  TEOW polygons intersecting MEOW or PPOW to MEOW or PPOW. __This is different from previous version, where TEOW overlapped MEOW/PPOW. This is due to the better MEOW/PPOW coastline.__
      *  __exception to the above: 5 polygons intersecting both meow/ppow (codes ppow-9 and meow-20073,20077) and teow have been assigned to teow, because they were the only polygons assigned to teow 61318-"St. Peter and St. Paul rocks" and 60172-"Trindade-Martin Vaz Islands tropical forests".__
   +  To identify features not reaching ±180/90, EEOW only have been exploded to singlepart, then intersected with a multiline created at -0.5 arcsec (about 15 meters at equator) from extremes. This way:
   +  an unassigned stripe of 360dx15 Km has been flagged as real antarctic land (teow),
   +  few polygons (11 originally) have been manually split (20 polygons), then:
      *  the 14 parts adjoining TEOW and extremes have been assigned to the correspondent TEOW classes
      *  the other 6 parts have been left unchanged (EEOW).

The result of the above is included in the final geopackage as ecoregions_2019_raw spatial layer as undissolved, single part polygons, where for each of them is reported:
+  source (teow, meow, ppow, eeow)
+  eco_id (first_level_code)
+  notes:
   +  "originally teow/meow/ppow/eeow" = attribute unchanged
   +  "assigned to meow/ppow" = originally teow, assigned to meow/ppow
   +  "assigned to teow" = originally meow/ppow, assigned to teow (codes ppow-9 and meow-20073,20077; assigned to teow 61318-"St. Peter and St. Paul rocks" and 60172-"Trindade-Martin Vaz Islands tropical forests")
   +  "reassigned to teow" = originally eeow, assigned to adjacent teow classes (eg: antarctic land adjoining south pole), some with with manual split (14 parts crossing ±180)
   +  "reassigned to eeow" = originally eeow, split in the previous step.

Above object has been dissolved in ArcGIS PRO (returing the expected 1097 classes) then exploded as single part polygons. __NB: any correction to ecoregions should be applied to teow_meow_ppow_eeow_raw, then dissolve it again to get the final version.__

This version has been imported in PostGIS, then checked for geometry validity, fixed, finalized (single and multiparts) with the SQL script [ecoregions_2019](./ecoregions_2019.sql).
The same script contains also method to calculate statistics (source and ecoregions change), as discussed with Luca Battistella, available in xlsx [ecoregions_2019_statistics](./ecoregions_2019_statistics.xlsx).

The final version is exported as geopackage, wich includes:
+  ecoregions_2019 multipart
+  ecoregions_2019_raw (undissolved, single part polygons)
+  lookup_attribute_table (correspondence table within original fields and final attributes).
