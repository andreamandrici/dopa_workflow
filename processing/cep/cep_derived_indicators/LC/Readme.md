# PROCESSING 
## [CEP](../README.md) (Country/Ecoregion/Protection) derived indicators

### ESA Landcover related

Specific processing to calculate for Natura 2000 sites forest coverage proteced by WDPAID in IUCN classes Ia,Ib and II, using:

+  Copernicus LC CCI (ex ESA) 2015
+  WDPA 201905
+  CEP_201905

Files are:
+  `forest_pre_processing.sql`: prepares in SCHEMA forest tables to be processed
+  `forest_processing.sql`: effective processing
+  **n2k_coverages.csv** results from the above.

Fields in result are:
 
+  wdpaid: unique id of Natura 2000 site.
+  name
+  iso3
+  v_sqkm: vector area. DOPA GIS calculated area for the input vector object.
+  overlapping_n2k: array of other overlapping Natura 2000 sites 
+  overlapping_iucn_i:  array of overlapping Protected Areas in IUCN category Ia and Ib 
+  overlapping_iucn_ii: array of overlapping Protected Areas in IUCN category II
+  r_sqkm: raster total area for object rasterised at ESA LC resolution (300m pixel)
+  f_sqkm: forest area (ESA classes 50,60,61,62,70,71,72,80,81,82,90)
+  p_sqkm: protected area (overlapped by Protected Areas in IUCN category Ia,Ib,II)
+  pi_sqkm: IUCN I protected area (overlapped by Protected Areas in IUCN category Ia,Ib)
+  pii_sqkm: IUCN II protected area (overlapped by Protected Areas in IUCN category II)
+  fp_sqkm: forest protected area (forest overlapped by protected area)
+  fpi_sqkm: forest IUCN I protected area (forest overlapped by IUCN I protected area)
+  fpii_sqkm: forest IUCN II protected area (forest overlapped by IUCN II protected area)

