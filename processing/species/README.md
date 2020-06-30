# DOPA workflow

## SPECIES

### harmonization

Since dataset is made by different sources (IUCN and Birdlife) and data models (spatial and non-spatial tables), harmonization of the objects is needed.

+  Some selected information is extracted from IUCN geometric data
+  Birdlife geometric data are processed in the way to get the same structure of IUCN data
+  In Birdlife Version 2019-1 information on Ecosystems for few species is missing. This information is extracted from IUCN non-spatial dataset
+  not all the geometric information is used (geometries are imported only WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3); which include: Extant and Probably Extant; Native and Reintroduced; Resident, Breeding Season and Non-breeding Season. Therefore, only correspondant species are included from non-spatial dataset.

### spatial

### non-spatial
