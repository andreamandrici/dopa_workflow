# Sources

## Thematic Layers

### Landcover

+  [Copernicus Land cover classification gridded maps](https://cds.climate.copernicus.eu/cdsapp#!/dataset/satellite-land-cover).  VERSION 2.1. Publication date: 2019-10-24. Downloaded (only 2018) on 20191209.
Global maps derived from satellite observations, from 1992 to present, describing the land surface into 22 classes defined using FAO Land Cover Classification System (LCCS).
Product consistent with the series of global annual LC maps from the 1990s to 2015 produced by the European Space Agency (ESA) Climate Change Initiative (CCI):

+  [ESA CCI-LC](http://www.esa-landcover-cci.org). Global land cover maps 1992-2015 at 300m spatial resolution. Last updated (version 1.6.1) on 201601.
First download on 201511 from [ftp://geo10.elie.ucl.ac.be/CCI/](ftp://geo10.elie.ucl.ac.be/CCI/).

Extracted as tiff with:

gdalwarp -of Gtiff -co COMPRESS=LZW -co TILED=YES -ot Byte -te -180.0000000 -90.0000000 180.0000000 90.0000000 -tr 0.002777777777778 0.002777777777778 -t_srs EPSG:4326 NETCDF:C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc:lccs_class C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.tif

### Species

+  [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search). IUCN, Version 2020-1. Downloaded on 20200408. Non-spatial attributes (**only species selected**) for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)    
   +  Amphibians
   +  Birds
   +  Mammals.

+  [IUCN Red List of Threatened Species Spatial Data](https://www.iucnredlist.org/resources/spatial-data-download). IUCN, Version 2020-1. Downloaded on 20200408. Spatial data for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)
   +  Amphibians
   +  Mammals.

+  [BirdLife's species distribution data](http://datazone.birdlife.org/species/requestdis). BirdLife International, Version 2019-1. Received on 20200131. Spatial and non-spatial tables for birds.
