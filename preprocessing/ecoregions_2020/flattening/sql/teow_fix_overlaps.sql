---BACKUPS!!!
CREATE TABLE eco2020_input_teow.back_e_flat_all AS SELECT * FROM eco2020_input_teow.e_flat_all;
CREATE TABLE eco2020_input_teow.back_fa_atts_tile AS SELECT * FROM eco2020_input_teow.fa_atts_tile;
CREATE TABLE eco2020_input_teow.back_fb_atts_all AS SELECT * FROM eco2020_input_teow.fb_atts_all;
CREATE TABLE eco2020_input_teow.back_g_flat_temp AS SELECT * FROM eco2020_input_teow.g_flat_temp;
CREATE TABLE eco2020_input_teow.back_h_flat AS SELECT * FROM eco2020_input_teow.h_flat;
-- CLIPPED ORIGINAL GEOMETRIES OVERLAPPING (check by qid)
DROP TABLE IF EXISTS eco2020_input_teow.b_clip_teow_overlaps; CREATE TABLE eco2020_input_teow.b_clip_teow_overlaps AS
WITH
-- multiple fid CIDs BY qid
a AS (SELECT DISTINCT qid,cid,teow FROM eco2020_input_teow.h_flat WHERE CARDINALITY(teow) > 1 ORDER BY qid,cid),-- OFFSET 0 LIMIT 1),
-- clipped geoms for selected qid,fid
b0 AS (SELECT * FROM eco2020_input_teow.b_clip_teow NATURAL JOIN (SELECT DISTINCT qid FROM a ORDER BY qid) b1),
b AS (SELECT qid,tid,fid,path,geom FROM b0 NATURAL JOIN (SELECT DISTINCT qid,UNNEST(teow) fid FROM a ORDER BY fid) b2),
-- intersecting tid pairs by qid
c AS (SELECT DISTINCT b1.qid,b1.tid t1,b2.tid t2 FROM b b1 JOIN b b2 ON b1.qid=b2.qid AND ST_INTERSECTS(b1.geom,b2.geom) WHERE b1.fid!=b2.fid),
-- non redundant list of qid,tids intersecting
d AS (SELECT qid,t1 tid FROM c UNION SELECT qid,t2 tid FROM c ORDER BY qid,tid),
-- list of intersecting objects
e AS (SELECT *,'overlap' note FROM b NATURAL JOIN d ORDER BY qid,tid,fid,path),
-- complete set of intersecting and non-intersecting objects
f AS (SELECT b0.*,e.note FROM b0 LEFT JOIN e USING(qid,tid,fid,path))
SELECT tid,qid,fid,path,geom,valid,reason,location,st_geometrytype FROM f ORDER BY tid,qid,fid,path;

