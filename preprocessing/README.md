# COUNTRIES (V2020)

A flat topological corrected admin layer has been obtained in PostGIS, using the following:
  +  [admin 2020 preprocessing](./admin_2020/preprocessing.sql)
  +  [admin 2020 flattening](./admin_2020/flattening)
  +  [admin 2020 preprocessing results: country attributes (land-marine)](./admin_2020/gisco_admin_2020_atts.csv)
  +  [admin 2020 preprocessing results: country attributes (land-marine dissolved)](./admin_2020/gisco_admin_2020_lmd_atts.csv)
  +  [admin 2020 postprocessing](./admin_2020/postprocessing.sql)

# COUNTRIES (V2024)

A flat topological corrected admin layer has been obtained in PostGIS, using the SQL scripts:
  +  [admin 2024 preprocessing](./admin_2024/preprocessing.sql)
  +  [admin 2024 flattening](./admin_2024/flattening)
  +  [admin 2024 postprocessing](./admin_2024/postprocessing.sql)

## problems

DOPA needs a global admin geographic object reporting by iso2,iso3,un_m49 codes.

The used version is CNTR_REG 2024 (documented by GISCO as DRAFT) 1:1M, and related CNTR_AT, AND EEZ 2020 1:1M.

The target is to NOT manually correct any inconsistency, to avoid ending up again with "correct", but not shared data.

Listed below are a number of problems encountered in using these datasets. We have already checked that the following problems happen also on

  +  1:100K version
  +  2020 version
    
therefore, using one of the above older/higher resolutions cannot be a solution.
 
  +  The coastaline within LAND (CNTR) and MARINE (EEZ) are not harmonized:
     +  each other
     +  with the additional COAS_REG 2020 object (global land polygon) 
  +  There are numerous holes in the derived ABNJ object, made as difference between global surface (-180,180,-90,90) and union of land and marine.
  +  The field POLI_ORG_CODE (Political Organisation Code)
     +  According to documentation should contain 4 codes (1,2,3,99); the real table contains 5 codes (1,2,3, 4,99) (code 4 is missing in the documentation)
     +  According to documentation should be linked to lookup table POLI_ORG_DOM; Table POLI_ORG_DOM does not exist
  +  Country coding using:
     +  UA (User assigned code elements)
        +  do not match any UN object
        +  almost all of them use 2 characters for ISO3 code (this will break our REST services)
  +  ER (Exceptionally reserved code element):
        +  Clipperton Island: does not exists in UN standard coding.

### GISCO-LAND non-matching officially-registered UN Codes 

The following GISCO LAND objects do not match standard UN codes:
 +  [GISCO-LAND non-matching officially-registered UN Codes](./admin_2024/gl_no_match_officially_registered_un_codes.csv)

### Missing officially-registered UN Codes in GISCO-LAND

The following standard UN codes do not match GISCO LAND objects:
 +  [Missing officially-registered UN Codes in GISCO-LAND](./admin_2024/officially_registered_un_codes_missing_in_gl.csv)

### GISCO-MARINE redundant objects

The following GISCO MARINE objects
+  present a unique verbose description,but are redundant by ISO2 (EEZ_ID)
+  some of these objects exist with different code
   +  in GISCO LAND (EG: Bassas da India exists as object in GISCO LAND with code XO, in GISCO MARINE with code FR) and/or
   +  in UN Codes (EG: Reunion has official iso codes RE/REU, and sovereign iso code FR):

+  [GISCO-MARINE redundant objects](./admin_2024/gm_redundant_objects.csv)

### Comparison within GISCO-LAND and GISCO-MARINE
 
The following is the comparison of the two sources (GISCO LAND and MARINE), joined by common fields cntr_id/eez_id (iso2).
Source of land/marine names is gisco land; rendundant codes in marine values are aggregated  by code (this could be managed differently: EG CP-Clipperton Island code exists in land, but do not exists in marine; anyway the geographical marine object exists, and it is characterized by the description; This condition may not be homogeneous with other geographic objects and codes). 

+  [GISCO-LAND-MARINE comparison](./admin_2024/gl_gm_comparison.csv)

### Comparison within DOPA-GISCO and DOPA-GAUL_EEZ

The main differences within GISCO CNTR/EEZ and GAUL/EEZ are given by: 
+  the many officially registered UN codes present in CEP (eg: Guadeloupe, Mayotte, Martinique, Guyana, Reunion, etc…), and reassigned to the sovereign country in GISCO (eg: France). 
+  the non-officially registred UN codes present in GISCO
+  Inconsistencies within GISCO itself, land and marine:
   +  CODES: a deeply checked example is UMI code, which is thousands of times smaller in GISCO respect to CEP: this because it is assigned to US in GISCO-EEZ, and to UMI in GISCO-LAND (in GAUL/EEZ both land and marine are assigned to UMI)… The same happens (can be seen graphically, on the map) with Heard and McDonald Islands/Australia, French Southern and Antarctic Lands/France, New Caledonia/France, etc..
   +  COASTLINE: non matching coastline produce holes, which
      +  will slow a lot every intersection
      +  produce an ABNJ which should not exists south and over Antarctica.

Results won’t be comparable with previous releases, there won’t be correspondence with WDPA (WCMC for protected areas correctly reports both country and sovereign country code, using only UN officially registered codes).

ALL the REST functions must be adapted to the different and missing fields (EG: UN_M49), and records (the already listed missing officially registered codes).

Specific inconsistencies are:

+  DOM-COM: is a geometry error in GISCO-EEZ (missing DOM marine)
+  TWN-CHN: inconsistence within GISCO-LAND/MARINE (Taiwan: CHI in Land, TWN in Marine)
+  PRI-USA: inconsistence within GISCO-LAND/MARINE (Puerto Rico: PRI in Land, USA in Marine).

The following is a comparison within the DOPA-GISCO and DOPA-GAUL admin datasets: 

+  [DOPA_GISCO_DOPA_GAUL_comparison](./admin_2024/dopa_gisco_gaul_comparison.csv)

# COUNTRIES (V2019)

A flat topological corrected layer for EEZ has been obtained in PostGIS, using the SQL script [eez_2019](./eez_2019.sql).
Update of Countries is pending since November 2019, waiting for decision on Land dataset.

# ECOREGIONS (V2024)

Dataset is given by intersection of (more details in [Sources/Base Layers](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html)):

+ OneEarth Terrestrial Ecoregions (TE)
+ Freshwater Ecoregions of the World (FE)
+ Marine Ecoregions of the World (ME)
+ Pelagic Provinces Of the World (PE).

The version of MEOW/PPOW without coastline is used.
TEOW is overlayed on top of MEOW/PPOW, and MEOW is clipped by TEOW's coastline.
"Holes" (big lakes) are filled by FEOW.

After the intersections, the overlapping classes are assigned as:

+  TEOW⋂MEOW/PPOW/FEOW=TEOW
+  MEOW⋂PPOW/FEOW=MEOW
+  PPOW⋂FEOW=PPOW;

**NB: Original sources do not reach -90 South. An additional band is addedd as eco_id 1144-hole, source=DOPA as difference within global surface and final ecoregions.**

## preprocessing scripts

### inputs

+   [ecoregions_2017](./ecoregions_2024/ecoregions_2017.sql)
+   [freshwater_ecoregions](./ecoregions_2024/freshwater_ecoregions.sql)
+   [marine+pelagic_ecoregions](./ecoregions_2024/meow_ppow.sql)

### flattening 

+   [flattening sequence and mods](./ecoregions_2024/flattening_sequence_and_mods.sql)
+   [workflow parameters](./ecoregions_2024/workflow_parameters.conf)
+   [f_revector postigs function](./ecoregions_2024/f_revector.sql)
+   [f_revector bash launcher](./ecoregions_2024/q_revector.sh)

### postprocessing
+   [final_postprocessing](./ecoregions_2024/postprocessing.sql)

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
+  EEOW⋂=EEOW; these have been considered "unassigned land ecoregion", and (**differently from Ecoregions V2019**) have not been partially assigned to adjoining TEOW classes.

Detailed step-by-step description is in [ecoregions_2020](./ecoregions_2020).

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



