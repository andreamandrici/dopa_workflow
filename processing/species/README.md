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
    +  ecosystem_mtf (text): this field aggregates the three fields marine, terrestrial and freshwater ecosystems (true/false) in one text field ecosystem_mtf (marine, terrestrial, freshwater; 0/1-0/1-0/1). **IUCN field name "terrestial" is wrong at origin**: it misses R in the name (terrestial != terrest**R**ial); ecosystems for corals are Capitalized, for the other groups they are not! 
    
    Code is: [creates_attributes_sp_iucn.sql](./species_2020/creates_attributes_sp_iucn.sql).
    Output table is: **species_202001.attributes_sp_iucn**.


3.  Birdlife **geometric** data are processed, and **selected attributes** are extracted, in the way to get the **same structure** of processed IUCN data. Species flagged as **sensitive** are removed to avoid to disseminate their distribution (directly, or as intersection with protected areas). For Birdlife 2019-1 they are: *Thalasseus bernsteini* and *Garrulax courtoisi* (id_no: 22694585,22732350).

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
	
	Code is: [creates_attributes.sql](./species_2020/creates_attributes.sql).
    Output table is: **species_202001.attributes**.

6.  Spatial tables present other differences which need harmonization, which will be solved with a specific flattening workflow: 
    +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
    +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).

### spatial

"Sytematic" groups (_corals, sharks_rays_chimaeras, amphibians, birds, mammals_) are processed independently using the flattening workflow (fully described in another section).

#### input dataset

Geometries of all groups are filtered to include only species (selected in the previous "harmonization - step 5").

Code is: [creates_geoms.sql](./species_2020/creates_geoms.sql).
Output tables are:

+  **species_202001.geom_corals**
+  **species_202001.geom_sharks_rays_chimaeras**
+  **species_202001.geom_amphibians**
+  **species_202001.geom_mammals**
+  **species_202001.geom_birds**

#### groups flattening

[Flattening](../../flattening/) at 30 arcsec (~900 meters at equator) is applied to each group. Steps `00_create infrastructure`) and `a_import input` tables) are executed independently.

If needed, geometry fix is applied after step `a_`.

All the other steps are executed inside `z_do_it_all.sh` script.

Outputs are exported as raster vrt, with attribute table (to be used for reclass) containing:
"cid"|"species"|"richness"|"endemic_threatened"|"richness_endemic_threatened"
+  cid = pixel_value
+  species = array of species existing in the pixel
+  richness (number of species) by pixel
+  endemic_threatened = array of species which are endemic and threatened. **This information is derived from non-spatial processing**.    
+  richness_endemic_threatened = richness of endemic and threatened species by pixel.

[Environment](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/confs) and [log](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/logs) files are reported.
[SQL](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/sql) files are also reported, when geometry fix was needed (after step `a_` of flattening).

**Some of the species distribution ranges are too small to be (psuedo)rasterised at 1 Km (EG: 8 amphibians are left out, of which 3 are Data Deficient, 4 are Critically Endangered). They can be recovered assigning an artificial minimum range of 1 sqkm (the single pixel intersecting the centroid), then calculating the "boost" applied as ratio artificial/original. This goes in the todo-list**

### non-spatial

Non-spatial data are normalized **directly in the final, output schema (species)**:
+  creating tables where fields are filtered and normalized (eg: for each table extract the unique id=`code` and the category=`name`)
+  splitting data in:
   +  main tables (mt_): tables which contains static lists of categories **existing in the current dataset** (they are derived from input tables).
   +  lookup tables (lt_): intermediate tables which put in relation species (through `id_no`) with category tables (through `code`). **Only `id_no` present in both datasets (spatial and non spatial) are included in the final selection**. These tables are propaedeutic for the next category (derived tables; dt_), and exist only to facilitate the filtering of the input tables. In the next future, they could be deleted, moving the related code in the derived tables sections.
   +  derived tables (dt_): final tables which put in relation species (through `id_no`) with category tables (through arrays of `code`). **Only `id_no` present in both datasets (spatial and non spatial) are included in the final selection**. These tables are derived from the previous intermediate category (lookup tables; lt_), which exist only to facilitate the filtering of the input tables. In the next future, lookup tables could be deleted, moving the related code in this section.
	 
   Code is: [creates_output_schema.sql](./species_2020/creates_output_schema.sql).

Output schema contains

+  main tables (mt_):
   +  mt_attributes
   +  mt_categories
   +  mt_conservation_needed
   +  mt_countries
   +  mt_habitats
   +  mt_research_needed
   +  mt_stresses
   +  mt_threats
   +  mt_usetrade

+  lookup tables (lt_):
   +  lt_species_conservation_needed
   +  lt_species_countries;
   +  lt_species_habitats
   +  lt_species_research_needed
   +  lt_species_stresses
   +  lt_species_threats
   +  lt_species_usetrade

	Options for **country** filters are (**bold**=used; _italic_=to be reviewed):
	+  `presence`: **Extant**, Extinct Post-1500, **Possibly Extant**, _**Possibly Extinct**_, _**Presence Uncertain**_
	+  `origin`: Assisted Colonisation, Introduced, **Native**, Origin Uncertain, **Reintroduced**, Vagrant
	+  `seasonality`: _**NULL**_, **Non-Breeding Season**, **Breeding Season**, **Resident**, Passage, Seasonal Occurrence Uncertain
	Above impacts the calculation of endemicity [check_countries.sql](./species_2020/check_countries.sql)!

+  derived tables (dt_):
   +  dt_species_conservation_needed
   +  dt_species_country_endemics
   +  dt_species_ecosystems
   +  dt_species_habitats
   +  dt_species_research_needed
   +  dt_species_stresses
   +  dt_species_threatened
   +  dt_species_threats
   +  dt_species_usetrade

### Outputs

The final step creates:
+  mt_species_output: this table rebuild relations within `mt_attributes` table and all  `dt_` tables.
+  get_list_species_output: this function interrogates the above table, and returns a list of species, allowing filtering on columns
+  get_single_species_output: this function interrogates the above table filtering on a single id_no, and returns related informations expanded, with names
+  The following functions interrogate the related main tables, and shows existing values that can be used as filters on the main function:
   +  get_list_categories
   +  get_list_conservation_needed
   +  get_list_countries
   +  get_list_habitats
   +  get_list_research_needed 
   +  get_list_stresses
   +  get_list_threats
   +  get_list_usetrade


   Code is: [creates_output_table_function.sql](./species_2020/creates_output_table_function.sql).
