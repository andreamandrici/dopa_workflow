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

To obtain the above, the user is requested only:

1.  to setup few parameters in an env file ([workflow_parameters.conf](./202003_workflow_parameters.conf) used for **version 202003**), and

2.  to run a sequence of bash script ([z_do_it_all.sh](./202003_z_do_it_all.sh) used for **version 202003**).

The output is always exported in:

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

The code to (quickly) update the two above tables, after the (expensive) flattening step is a single [bash script](./cep.sh), where again the user is required to setup few parameters before executing it.


### Version 202003

+  [workflow_parameters.conf](./202003_workflow_parameters.conf) env file.
+  [z_do_it_all.sh](./202003_z_do_it_all.sh) bash script. Runs in about 40 hours.
+  **patch**: 100 cids (all single pixel, 30x30) resulted with multiple (2) country (1) or ecoregion (99), due to overlapping original geometries (which shouldn't). The total surface involved is non-significant, but to make the next steps (aggregations and disaggregations) process easier, they have been randomly assigned to one or the other original fid (it could also be fixed with rasterization at lower resolution: more expensive). The sequence to get the above fixed is:
    +  [patch sql sequence](./202003_fix_cep_overlaps.sql): to be manually executed, point by point. Fully commented.
    +  [patch bash sequence](./202003_fix_cep_overlaps.sh): bash script. Can be executed in one step. Runs in about 4 hours.
+  [cep_last](./cep.sh): bash script, executed at the end of the flattening script to:
    +  create the tables:
      +  cep.cep_202003 (to be kept across DOPA releases)
      +  cep.cep_index_202003 (to be kept across DOPA releases)
    +  cep.cep_last
    +  cep.cep_last_index.

 update the tables cep_last and cep_last_index.

