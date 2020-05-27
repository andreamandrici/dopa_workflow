# PROCESSING

## Country/Ecoregion/Protection (CEP)

This is a specific application of [flattening](../flattening/).

DOPA CEP is made by:

+  country: merge of GAUL (for land) and EEZ (for marine) dissolved by common ISO code, without maintaining coastline information.
+  ecoregions: merge of Terrestrial, Marine and Pelagic, maintaining coastline information.
+  protected areas: last wdpa version.

The resulting dataset is a pseudo-topology where each polygon keeps the information from the original sources, and is simultaneously used as:

+  indicator: pre-calculated areas can be summed according to different filters and aggregations (eg: protected ecoregion in country), to quickly get coverages.

+  base dataset: intersecting geometries with thematic data, to get further indicators.

The output is always contained in:

`cep.cep_last`: 
`cep.cep_last_index`

