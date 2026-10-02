Ecoregions 2017 are flattened with the following sequence:

## workflow_parameters.conf

```
#!/bin/bash
# SET SOME VARIABLES
TOPICS=1

TOPIC_1="feature"
VERSION_TOPIC_1="flat_single_feature.ecoregions_2017"
FID_TOPIC_1="feat_id"

# GRID SIZE IN DEGREES, INTEGER SUBMULTIPLE OF 180
GS=1 #DEFAULT is 1 DEGREE

# CELL SIZE IN ARCSEC, INTEGER SUBMULTIPLE OF 3600
CS=1 #DEFAULT is 1 ARCSEC

# FOLDER TO KEEP EXTRA SQL
SQL="sql"

## database parameters
HOST="xxxxxx"
USER="xxxxxx"
DB="xxxx"
SCH="flat_single_feature"
PO=xxxx

# DO NOT TOUCH THE FOLLOWING VALUES
dbpar1="host=${HOST} user=${USER} dbname=${DB} port=${PO}"
dbpar2="-h ${HOST} -U ${USER} -d ${DB} -p ${PO}"
RWS=$((180/GS)) # NUMBER OF ROWS IN THE GRID
CLS=$((360/GS)) # NUMBER OF COLUMNS IN THE GRID
RCC=$((3600/CS)) # NUMBER OF ROWS/COLUMNS FOR CELL
RCCT=$((RCC*GS)) # NUMBER OF ROWS/COLUMNS FOR TILE
```

## first run
```
./a_input_feature.sh ${ncores} > logs/a_input_feature_log.txt 2>&1 wait
./b_clip_feature.sh ${ncores} > logs/b_clip_feature_log.txt 2>&1 wait
./c_rast_feature.sh ${ncores} > logs/c_rast_feature_log.txt 2>&1 wait
./da_tiled_feature.sh ${ncores} > logs/da_tiled_feature_log.txt 2>&1 wait
./db_tiled_all.sh ${ncores} > logs/db_tiled_all_log.txt 2>&1 wait
./e_flat_all.sh ${ncores} > logs/e_flat_all_log.txt 2>&1 wait
./f_attributes_all.sh ${ncores} > logs/f_attributes_all_log.txt 2>&1 wait
```

## sql correction

### analysis

```
SELECT * FROM 
(SELECT cid,feature,SUM(sqkm) sqkm 
FROM 
(SELECT b.cid,a.feature,(ST_AREA(geom::geography))/1000000 sqkm
FROM flat_single_feature.fa_atts_tile a
JOIN flat_single_feature.fb_atts_all b USING(feature)
JOIN flat_single_feature.e_flat_all c USING(qid,tid)
WHERE CARDINALITY(feature) > 1) a GROUP BY cid,feature) b
ORDER BY sqkm DESC;
```
The output contains:

|cid|feature|sqkm|
|---|----------|-----------|
|121|{119,1000}|5500.30188252813|
|126|{124,1000}|1157.9310384276262|
|10|{9,51}|107.23847924450509|
|225|{220,313}|0.8953933445296743|
|223|{219,220}|0.448573639916929|
|137|{134,1000}|0.051530017384389254|
|44|{42,65}|0.0009100735634490848|

Consequentely, the following SQL fix is applied:
```
---------------------------------------------------------------------------------------------
UPDATE flat_single_feature.fb_atts_all SET cid=feature[1] WHERE CARDINALITY(feature) = 1;
UPDATE flat_single_feature.fb_atts_all SET cid=feature[1]+feature[2] WHERE feature IN ('{119,1000}','{124,1000}');
UPDATE flat_single_feature.fb_atts_all SET cid=(feature[1]::text || feature[2]::text)::int WHERE feature = '{9,51}';
UPDATE flat_single_feature.fb_atts_all SET cid=feature[1] WHERE feature && '{42,65,134,219,313}' AND CARDINALITY(feature) > 1;
UPDATE flat_single_feature.fb_atts_all SET feature = ARRAY[feature[1]] WHERE feature && '{42,65,134,219,313}' AND CARDINALITY(feature) > 1;
UPDATE flat_single_feature.fa_atts_tile SET feature = ARRAY[feature[1]] WHERE feature && '{42,65,134,219,313}' AND CARDINALITY(feature) > 1;
```
Getting:
|cid|feature|sqkm|
|---|---|---|
|1119|{119,1000}|5500.30188252813|
|1124|{124,1000}|1157.9310384276266|
|951|{9,51}|107.23847924450507|

The rest of the cid get original eco_id;

## second run
After sql correction, the rest of flattening sequence is executed:

```
./g_final_all.sh ${ncores} > logs/g_final_all_log.txt 2>&1 wait
./h_output.sh > logs/h_output_log.txt 2>&1 wait
./o_raster.sh ${ncores} > logs/o_raster_log.txt 2>&1 wait
./p_export_raster.sh $((ncores/3)) > logs/p_export_raster_log.txt 2>&1 wait
```
