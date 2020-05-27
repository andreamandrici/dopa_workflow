# PROCESSING

## Country/Ecoregion/Protection (CEP)

This is a specific application of [flattening](../../flattening/).

DOPA CEP is made by:

+  country: merge of GAUL (for land) and EEZ (for marine) dissolved by common ISO code, without maintaining coastline information.
+  ecoregions: merge of Terrestrial, Marine and Pelagic, maintaining coastline information.
+  protected areas: last wdpa version.

The resulting dataset is a pseudo-topology where each polygon keeps the information from the original sources, and is simultaneously used as:

+  indicator: pre-calculated areas can be summed according to different filters and aggregations (eg: protected ecoregion in country), to quickly get coverages.

+  base dataset: intersecting geometries with thematic data, to get further indicators.

The output is always contained in:

### cep.cep_last
non-redundant geometry table where:
+  qid: tile id (doesn't change within versions: if wdpa was versioned, could be processed only tiles intersecting pas that are changed)
+  cid: unique combination of country/ecoregion/protection (does change within versions)
+  country: array of country ids covered by the polygon. Since countries should not overlap, ony one dimension is allowed 
+  eco: array of ecoregion ids covered by the polygon. Since ecoregions should not overlap, ony one dimension is allowed
+  pa: array of wdpa ids covered by the polygons. Overlaps are allowed
+  sqkm: Polygon extent
+  geom: Polygon geometry. 

### cep.cep_last_index
non-geometric version of the above, with expanded arrays
+  qid: as above
+  cid: as above (redundant)
+  country: as above (expanded array)
+  country_name: text attribute joined from the original source
+  iso3: text attribute joined from the original source
+  eco: as above (expanded array)
+  eco_name: text attribute joined from the original source
+  is_marine: boolean, calculate if polygon (cid) is covered by marine/pelagic OR terrestrial ecoregion 
+  pa: as above (redundant: expanded array)
+  pa_name: text attribute joined from the original source
+  is_protected: boolean, calculated if polygon (cid) is covered by a protected area.

