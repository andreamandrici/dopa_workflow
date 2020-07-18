# PROCESSING 
## [CEP](../README.md) (Country/Ecoregion/Protection) derived indicators

### ESA Landcover related

Specific processing to calculate for Natura 2000 sites forest coverage proteced by WDPAID in IUCN classes Ia,Ib and II, using:

+  ESA LC CCI 2015
+  WDPA 201905
+  CEP_201905

Files are:
+  `n2k_forest_pa_by_country.sql`
+  **n2k_forest_pa_by_country.csv** results from the above.

Fields in result are:
 
+  country_name: derived by intersected DOPA layer
+  iso3: derived by intersected DOPA layer
+  n2k_forest_sqkm: non redundant surface of forest areas covered by Natura 2000 sites
+  n2k_forest_pa_sqkm: non redundant surface of forest areas covered by Natura 2000 sites and other PAs in IUCN categories Ia, Ib, II.
