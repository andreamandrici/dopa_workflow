# DOPA workflow

## SPECIES

### harmonization

Since dataset is made by different sources (IUCN and Birdlife) and data models (spatial and non-spatial tables), harmonization of the objects is needed.

1.  In Birdlife Version 2019-1 information on Ecosystems for few species is missing. This information is recovered from IUCN non-spatial dataset. [fix_missing_ecosystems.sql](./species_2020/fix_missing_ecosystems.sql)
2.  Some **selected attributes** are extracted and transformed from IUCN **geometric** data:
    +  id_no (bigint),
    +  binomial (text),
    +  kingdom (text),
    +  phylum (text),
    +  class (text),
    +  order_ (text),
    +  family (text),
    +  genus (text),
    +  category (text),
    +  ecosystem_mtf (text): this field aggregates the three fields marine, terrestrial and freshwater ecosystems (true/false) in one text field ecosystem_mtf (marine, terrestrial, freshwater; 0/1-0/1-0/1). **IUCN field name "terrestial" is wrong at origin**: it misses R in the name (terrestial != terrest**R**ial).

    Code is: [creates_attributes_sp_iucn.sql](./species_2020/creates_attributes_sp_iucn.sql).
    Output table is: **species_202001.attributes_sp_iucn**.


3.  Birdlife **geometric** data are processed, and **selected attributes** are extracted, in the way to get the **same structure** of processed IUCN data. 

    Code is: [creates_attributes_sp_birdlife.sql](./species_2020/creates_attributes_sp_birdlife.sql).
    Output table is: **species_202001.attributes_sp_birdlife**.

4.  IUCN and Birdlife **selected attributes from geometric** data are appended each other.

    Code is: [creates_attributes_sp.sql](./species_2020/creates_attributes_sp.sql).
    Output table is: **species_202001.attributes_sp**.
 
5.  There are different _taxa_ contained in spatial and non-spatial tables:
	+  **spatial tables**:
	   +  include species, subspecies, subpopulations (with redundant geometries):
	   +  are filtered at import on fields:
	      +  **presence**: 1-Extant, 2-Probably Extant are imported; 3-Possibly Extant, 4-Possibly Extinct, 5-Extinct, 6-Presence Uncertain are not imported
	      +  **origin**: 1-Native, 2-Reintroduced are imported; 3-Introduced, 4-Vagrant, 5-Origin Uncertain, 6-Assisted Colonisation are not imported
	      +  **seasonal** 1-Resident, 2-Breeding Season and 3-Non-breeding Season are imported; 4-Passage, 5-Seasonal Occurrence Uncertain are not imported
	+  **non-spatial tables**:
	   +  are filtered at download in the way to include species only
	   +  include _possibly extinct_ and _possibly extinct in the wild_ species.
	
	**Only species present in both datasets are included in the final selection**.

+  The flattening workflow get rid of:
   +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
   +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).



### spatial

"Sytematic" groups (corals, sharks, rays and chimaeras, amphibians, birds, mammals) are processed independently using the flattening workflow (fully described in another section).
Here are reported the scripts and environment files:

### non-spatial
