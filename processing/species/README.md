# DOPA workflow

## SPECIES

### harmonization

Since dataset is made by different sources (IUCN and Birdlife) and data models (spatial and non-spatial tables), harmonization of the objects is needed.

+  In Birdlife Version 2019-1 information on Ecosystems for few species is missing. This information is recovered from IUCN non-spatial dataset. [fix_missing_ecosystems.sql](./species_2020/fix_missing_ecosystems.sql)
+  Some **selected attributes** are extracted and transformed from IUCN **geometric** data:
   +  id_no (bigint),
   +  binomial (text),
   +  legend (text),
   +  kingdom (text),
   +  phylum (text),
   +  class (text),
   +  order_ (text),
   +  family (text),
   +  genus (text),
   +  category (text),
   +  ecosystem_mtf (text)

	-- aggregates marine,terrestRial and freshwater ecosystems in ecosystem_mtf (marine,terrestrial,freshwater). IUCN field name "terrestial" is wrong at origin: it misses an R in the name.

 -- creates table IUCN_SPATIAL_ATTRIBUTES as selection of attributes from spatial data
	--DROP TABLE IF EXISTS species_202001.iucn_sp_attributes; 
	CREATE TABLE species_202001.iucn_sp_attributes;

+  Birdlife geometric data are processed in the way to get the same structure of IUCN data
+  not all the geometric information is used (geometries are imported only WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3); which include: Extant and Probably Extant; Native and Reintroduced; Resident, Breeding Season and Non-breeding Season. Therefore, only correspondant species are included from non-spatial dataset.

+  The flattening workflow get rid of:
   +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
   +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).



### spatial

"Sytematic" groups (corals, sharks, rays and chimaeras, amphibians, birds, mammals) are processed independently using the flattening workflow (fully described in another section).
Here are reported the scripts and environment files:

### non-spatial
