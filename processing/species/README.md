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

[Flattening](../../flattening/) at 30 arcsec (~900 meters at equator) is applied to each group. STEP 0 (create infrastructure) and A (import input tables) are executed independently. If needed, geometry fix is applied after step A. All the other steps are executed inside `z_do_it_all.sh` script.
[Environment](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/confs) and [log](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/logs) files are reported.
[SQL](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/sql) files are also reported, when geometry fix was needed (at step a of flattening).
Some of the species distribution ranges are too small to be (psuedo)rasterised at 1 Km (EG: 8 amphibians are left out, of which 3 are Data Deficient, 4 are Critically Endangered). They can be recovered assigning an artificial minimum range of 1 sqkm (the single pixel intersecting the centroid), then calculating the "boost" applied as ratio artificial/original. **This goes in the todo-list**

### non-spatial

Non-spatial data are normalized:
+  creating views where fields are extracted and normalized (eg: each table contains a unique id=`code` and a category=`name`)
+  splitting data in:
   +  main tables (mt_): tables which contains static lists of categories
   +  lookup tables (lt_): tables which put in relation species (through `id_no`) with category tables (through `code`).
   
	Code is: [creates_attributes.sql](./species_2020/creates_views_nsp.sql).
    Output is: 8 views for main tables (v_mt_) and 8 for related lookup tables (lt_):
	+  v_mt_categories; v_lt_species_categories
	+  v_mt_conservation_needed; v_lt_species_conservation_needed
	+  v_mt_countries; v_lt_species_countries;
	+  v_mt_habitats; v_lt_species_habitats
	+  v_mt_research_needed; v_lt_species_research_needed
	+  v_mt_stresses; v_lt_species_stresses
	+  v_mt_threats; v_lt_species_threats
	+  v_mt_usetrade; v_lt_species_usetrade

Options for country filters are (**bold**=used;_italic_=to be reviewed):
+  presence: Extant,Extinct Post-1500,Possibly Extant,Possibly Extinct,Presence Uncertain
+  origin: Assisted Colonisation,Introduced,Native,Origin Uncertain,Reintroduced,Vagrant
+  seasonality: NULL,Non-Breeding Season,Breeding Season,Resident,Passage,Seasonal Occurrence Uncertain

**v_lt_species_countries is filtered on fields:
+  `presence` ('Extant','Possibly Extant')(to review: 'Possibly Extinct','Presence Uncertain')
+  `origin` ('Native','Reintroduced')
+  `seasonality`(NULL,'%Resident%','%Breeding Season%','%Non-Breeding Season%')**;

Here's a simple footnote,[^1] and here's a longer one.[^2]

[^1]: This is the first footnote.

[^2]: This is the first footnote.


Testing <sub>subscript</sub> and <sup>superscript</sup>

Testing <sub>subscript <sub>subscript level 2</sub></sub>

Testing <sup>superscript <sup>superscript level 2</sup></sup>
