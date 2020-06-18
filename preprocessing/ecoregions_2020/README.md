## IMPORT
 
Geometries have been imported as:

`time ./eco_input.sh > eco_input.log 2>&1`

ogr2ogr and shp2pgsql scripts have been tested (`eco_input_time.txt` and `eco_input_compare.sql`): ogr2ogr import creating less invalid geometries in the output. 

## JOIN ATTRIBUTES

Original geometries have been joined to DOPA standardised attributes (meow_atts.csv, ppow_atts.csv, teow_atts.csv; imported in postgres) running `meow_geoms.sql`,`ppow_geoms.sql` and `teow_geoms.sql` scripts.

##  FLATTENING

Flattening sequence has been applied:

+  separately on teow,meow and ppow (workflow_parameters.conf are reported for each one)
+  on the outputs from the above step (tmp_workflow_parameters.conf is reported)
+  on the outputs from the above step, plus eeow (=grid tiles) (workflow_parameters.conf is reported).
Also, are available sql and sh scripts used at every step for various fixes (eg: qid 20721,20722,26125,26489,26849,28660,29020 have been recovered for teow, because the clipping step was returning an empty output).

SQL script to: 

+  move ppow class code 0 to 37
+  move teow -9998,-9999 to 9998,9999

is `01_populate_input_tables.sql`

SQL script to aggregate the different sources in the final DOPA ecoregions attributes is `aggregations.sql`.
