# DOPA workflow

Calculating a [DOPA](https://dopa.jrc.ec.europa.eu/en) indicator means, in general, to do a spatial intersection within **at least** two layers. EG:

+  country dataset intersecting protected areas dataset gives protection coverage for countries
+  ecoregion dataset intersecting protected country dataset gives coverage of ecoregion in country, or country in ecoregion
+  country, ecoregion and protected areas datasets intersecting each other give various coverages: percentage of ecoregion in country which is protected, etc...
+  country, ecoregion, protected areas and IUCN species ranges datasets intersecting each other give very complex coverages: endangered species living out of the protected portion of a specific country included in a specific ecoregion...  

Things are complicated by:

+  some dataset (eg: protected areas, species) has overlapping features
+  boundaries and or coastline do not match within datasets
+  big numbers of features. Eg: 250K protected areas, 25K species
+  big size: DOPA indicators are global, and uses global datasets
+  big numbers of indicators (and consequently of input datasets). Eg: DOPA currently reports 155 metrics for countries, intersecting them with many thematic layers (eg: landcover, species, etc...).

Due to the reasons above, updating the indicators requires a long processing time, which is a constraint for frequence of update.

A few (but not cheap) steps have been identified as necessary to improve the process in quality and speed:

+  a structured and standardised workflow: avoid desktop analysis conducted by different operators with different tools/methods/speeds/results
+  reduce the number of runs needed, identifying:
    +  a base layer (aggregation of country/ecoregions/wdpa), which provides the principal coverage indicators, and intersects
    +  thematic datasets (aggregated too, when possible), providing the rest of the metrics
+  simplify complexity:
    +  reducing overlaps
    +  harmonizing boundaries
+  optimize the process
    +  parallelizing calculations
    +  reducing redundant processes.

Above targets are reached **scripting all the sequence of actions needed to build a pseudo-topology** (eg: merging information from countries, ecoregions and protected areas to build the base layer).

## Flat layers

**Pseudo-topology** is meant as a [simple feature](https://www.ogc.org/standards/sfa) layer, flattened, which keeps the information from the original sources at the level of each single atomic geometry in which it can be destructured.

Building a real topology would be too expensive due to the size of the input datasets.

Key parts of the process are:

+  **tiling**: each input object is split in tiles (defaults to one degree).
+  **parallelizing**: calculations are distributed to cores, by tile. Different cores calculates in parallel values for different tiles. The number of tiles calculated in series is dependant by the number of the available cores.
+  **pseudo-rasterizing**: in every tile, every object is
   +  temporary rasterized (defaults to 1 arcsec resolution: about 30 meters at equator), then
   +  re-vectorized.

   This step, despite increasing the number of vector nodes participating to each tile, simplifies the overlapping geometries, in a more efficient way respect to other (tested) approaches: snap to grid; snap to other geometries; simplify; the already mentioned, unsustainable, real topology building.

+  **flattening**: simplified geometries from previous step are intersected, by tile.
+  **re-joining**: the attributes of the original objects are spatially joined to the new geometric objects. Multiple attributes related (coming from overlapping objects) become ordered arrays collected in a single row.
+  **aggregating**:  objects (geometry and attributes) are aggregated by unique combinations of attributes.

The result is a spatial table, in which each box has a unique ID (qid) and contains MultiPolygons, named (cid) according to the unique combination of the original components (topic1, topic2, topic_N_ ...)

Basically, the process consists of:

+  one bash script which creates from scratch (according to few parameters passed through an env file) a series of:
   +  bash scripts (a\_\*.sh, b\_\*.sh, etc... optimized for the input files) 
   +  postgresql/postgis functions and tables.
 
 Running in sequence the above scripts, will in turn run the postgis functions, which in turn fill fill the postgres tables.

It takes 27 hours to process the whole CEP (global country, ecoregion, protection) on 40 cores hardware.

Some sample output deriving from [this 10 Mb sample inputs](./cep_sample/dopa_cep_input_sample.gpkg.tar.7z):

+  [CEP sample output 30 arcsec - 41 seconds processing time](./cep_sample/dopa_cep_output_sample_30arcsec_41sec.geojson)
+  [CEP output 10 arcsec - 41 seconds processing time](./cep_sample/dopa_cep_output_sample_10arcsec_41sec.geojson)
+  [CEP sample output 3 arcsec - 53 seconds processing time](./cep_sample/dopa_cep_output_sample_3arcsec_53sec.geojson)
+  [CEP output 1 arcsec - 151 seconds processing time](./cep_sample/dopa_cep_output_sample_1arcsec_151sec.geojson).

A lot of effort has been put in making the above task universal, and not exclusively targeted to the above objects (country/ecoregion/pa).
It can be applied as-it-is to pre-process other datasets (eg IUCN species).

### Detailed instructions

#### 0.  Prerequisites

It works for me on Xubuntu 18.04 amd64, with installed:

+  postgresql-10-postgis-3/bionic,now 3.0.1+dfsg-2~bionic0
+  postgis/bionic,now 3.0.1+dfsg-2~bionic0
+  gdal-bin/bionic,now 3.0.4+dfsg-1~bionic0

#### 1.  Define the environment

In **workflow_parameters.conf**

`TOPICS=NN` -- _defines the number of processed "topics" (eg: for CEP (country+ecoregion+pa) it would be 3)_

`TOPIC_N="topic name"` -- _defines a name to be used for topic N_

`VERSION_TOPIC_N="schema name.table name"` -- _specifies which table contains data for topic N_

`FID_TOPIC_N="topic ID"` -- _specifies which is the numeric field (not required to be unique at this stage) for topic N_

_... repeat the above for the NN number of the defined topics)..._

`SCH="working schema name"` -- _this one defines the working schema, WHICH WILL BE DROPPED AND RECREATED!_

`GS=x` --_defines grid tile size in degrees, integer submultiple of 180; default is 1 degree_

`CS=y` --_defines raster cell size in arcasec, integer submultiple of 3600; default is 1 arcsec_

#### 2.  Create the infrastructure

run **`./00_create_infrastructure.sh`** which will create from scratch the following scripts:

#### 3.  Run scripts

1.  For each topic defined in **workflow_parameters.conf**
  +  `a_input_topic_n.sh` populates input tables: copies, checks and cleans data inside the working schema
  +  `b_clip_topic_n.sh` clips input data according to tiles defined in the grid
  +  `c_rast_topic_n.sh` pseudo-rasterizes (rasterize 30 meters, then vectorize back) above clipped data
  +  `da_tiled_topic_n.sh` populates tiled tables
2.  For aggregated results from above steps
  +  `db_tiled_all.sh` populates tiled tables
  +  `e_flat_all.sh` populates flat_all table
  +  `f_attributes_all.sh` populates atts_tile, THEN atts_all tables
  +  `g_final_all.sh` populates flat_temp
  +  `h_output.sh` populates the flat final layer. **This is the only single core process, the rest is parallelized on multicores.**

All the scripts from `a_*` to `g_*` must run in parallel, launching them in background.

EG: `./a_input_country.sh Ncores > logs/a_input_country_log.txt 2>&1`

where **Ncores** is the number of cores to assign to the process, and the following part of the command will write a detailed log.

All the **scripts** (not the **resulting tables**, which are striclty interconnected) are independent from each other: this allows to debug (through the aforementioned logs) every step, and every input.

Still, all the commands could be collected and launched in a unique script.

EG:`z_do_it_all.sh` (read inline comments for instructions).

Further ancillary scripts for specific tasks should be self-explanatory:

EG: `01_create_filter.sh` gives the option to filter only few tiles (EG: specific BIOPAMA needs).
