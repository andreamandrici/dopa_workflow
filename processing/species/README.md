# DOPA workflow

## SPECIES

### harmonization

Since dataset is made by different sources (IUCN and Birdlife) and data models (spatial and non-spatial tables), harmonization of the objects is needed.

+  In Birdlife Version 2019-1 information on Ecosystems for few species is missing. This information is recovered from IUCN non-spatial dataset. [fix_missing_ecosystems.sql](./species_2020/fix_missing_ecosystems.sql)
+  Some selected information is extracted from IUCN geometric data
+  Birdlife geometric data are processed in the way to get the same structure of IUCN data
+  not all the geometric information is used (geometries are imported only WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3); which include: Extant and Probably Extant; Native and Reintroduced; Resident, Breeding Season and Non-breeding Season. Therefore, only correspondant species are included from non-spatial dataset.

+  The flattening workflow get rid of:
   +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
   +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).



### spatial

"Sytematic" groups (corals, sharks, rays and chimaeras, amphibians, birds, mammals) are processed independently using the flattening workflow (fully described in another section).
Here are reported the scripts and environment files:

### non-spatial
