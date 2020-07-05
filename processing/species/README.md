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
   +  ecosystem_mtf (text): this field aggregates the three fields marine, terrestrial and freshwater ecosystems (true/false) in one text field ecosystem_mtf (marine, terrestrial, freshwater; 0/1-0/1-/01). **IUCN field name "terrestial" is wrong at origin**: it misses R in the name (terrestial != terrest**R**ial).

    Code is: [creates_attributes_sp_iucn.sql](./species_2020/creates_attributes_sp_iucn.sql).
    Output table is: **species_202001.attributes_sp_iucn**.

3.  Birdlife **geometric** data are processed, and **selected attributes** are extracted, in the way to get the **same structure** of processed IUCN data. 

    Code is: [creates_attributes_sp_birdlife.sql](./species_2020/creates_attributes_sp_birdlife.sql).
    Output table is: **species_202001.attributes_sp_birdlife**.

4.  IUCN and Birdlife **selected attributes from geometric** data are appended each other.

    Code is: [creates_attributes_sp.sql](./species_2020/creates_attributes_sp.sql).
    Output table is: **species_202001.attributes_sp**.
 
5.  not all the geometric information is used (geometries are imported only WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3); which include: Extant and Probably Extant; Native and Reintroduced; Resident, Breeding Season and Non-breeding Season. Therefore, **only correspondant species are included from non-spatial dataset**.

+  The flattening workflow get rid of:
   +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
   +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).



### spatial

"Sytematic" groups (corals, sharks, rays and chimaeras, amphibians, birds, mammals) are processed independently using the flattening workflow (fully described in another section).
Here are reported the scripts and environment files:

### non-spatial
