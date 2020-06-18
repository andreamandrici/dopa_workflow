DROP TABLE IF EXISTS fa_atts_tile_single; CREATE TEMPORARY TABLE fa_atts_tile_single AS
SELECT DISTINCT * FROM eco2020_input_teow.fa_atts_tile WHERE CARDINALITY(teow)=1 ORDER BY qid,tid,teow;
DROP TABLE IF EXISTS fa_atts_tile_multi; CREATE TEMPORARY TABLE fa_atts_tile_multi AS
WITH
a AS (SELECT DISTINCT qid,tid,teow FROM eco2020_input_teow.fa_atts_tile WHERE CARDINALITY(teow)>1 ORDER BY qid,tid,teow
),
b AS (SELECT DISTINCT qid,tid,cid,teow,geom FROM eco2020_input_teow.e_flat_all NATURAL JOIN a ORDER BY qid,cid,tid,teow),
c AS (SELECT DISTINCT qid,cid,UNNEST(teow) fid FROM b ORDER BY qid,cid,fid),
d AS (
SELECT qid,c.cid,fid,ST_COLLECT(geom) geom,SUM(sqkm) sqkm FROM
(SELECT DISTINCT qid,cid,UNNEST(teow) fid,geom,sqkm FROM eco2020_input_teow.h_flat WHERE CARDINALITY(teow)=1) d1 JOIN c USING(qid,fid) WHERE d1.cid!=c.cid
GROUP BY qid,c.cid,fid 
ORDER BY qid,c.cid,sqkm DESC,fid),
e AS (SELECT DENSE_RANK() OVER (PARTITION BY qid,cid ORDER BY qid,cid,sqkm DESC,fid),* FROM d),
f AS (SELECT qid,cid,fid FROM e WHERE dense_rank=1),
g AS (SELECT f.*,b.tid FROM f JOIN b USING(qid,cid))
SELECT qid,tid,ARRAY_AGG(fid) teow FROM g GROUP BY qid,tid ORDER BY qid,tid;
TRUNCATE TABLE eco2020_input_teow.fa_atts_tile;
INSERT INTO eco2020_input_teow.fa_atts_tile
SELECT * FROM fa_atts_tile_single
UNION
SELECT * FROM fa_atts_tile_multi
ORDER BY qid,tid;
TRUNCATE TABLE eco2020_input_teow.fb_atts_all RESTART IDENTITY;
INSERT INTO eco2020_input_teow.fb_atts_all
SELECT ROW_NUMBER () OVER () cid,* FROM (SELECT DISTINCT teow FROM eco2020_input_teow.fa_atts_tile ORDER BY teow) a;


