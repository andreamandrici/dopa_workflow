IUCN Global Ecosystem Typology

Downloaded from:
+  https://global-ecosystems.org/ (website)
+  https://www.nature.com/articles/s41586-022-05318-4 (paper)
+  https://doi.org/10.5281/zenodo.3546513 (all datasets)

Several downloads (20231005, 20231021, 20231023, 20240415, 20240412) and contacts with the author (David Keith <david.keith@unsw.edu.au>) were required. Within the various releases:
+  All the objects have been renamed
+  M1.10.WM.nwx_v1.0.json has been added
+  MT2.2.IM.orig_v1.0.json has been added
+  T1.3.WM.nwx_v1.0.json has been updated (old name was: T1_3_Trop_montane_rainforests.json)
+  T7.1.web.alt_v2.0.json has been updated (old name was: T7_1_Croplands.json), but the new version was truncated; consequently:
+  T7.1.web.alt_v2.0.json.bz2 has been obtained by the author
+  S1_2_Endolithic_systems.json exists only in one of the old release.

Vectors (geojson format...) have been imported in PostGIS with the script [import.sh](./import.sh).

PostGIS geometries have been pre-processed with the script [iucn_get.sql](./iucn_get.sql).

The original categories have been reorganized as by [class_code_objects.csv](./class_code_objects.csv).

Flat version has been obtained with the dopa flattening sequence, with configuration as by [workflow_parameters.conf](./workflow_parameters.conf).


=======================================

Citation:
=========
- David A. Keith, José R. Ferrer-Paris, Emily Nicholson and Richard T. Kingsford (eds.) (2020) The IUCN Global Ecosystem Typology 2.0: Descriptive profiles for biomes and ecosystem functional groups. Gland, Switzerland: IUCN. ISBN: 978-2-8317-2077-7. DOI:10.2305/IUCN.CH.2020.13.en
- Keith, David et al. (2022) 'A function-based typology for Earth's ecosystems'. Nature DOI:10.1038/s41586-022-05318-4

Data set citation:
=================
Keith, David A., Ferrer-Paris, Jose R., Nicholson, Emily, ..., Kingsford, Richard T. (2020). Indicative distribution maps for Ecological Functional Groups - Level 3 of IUCN Global Ecosystem Typology [Data set]. Zenodo. http://doi.org/10.5281/zenodo.3546513
