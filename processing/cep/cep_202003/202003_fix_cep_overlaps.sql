--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--one polygon in cep202003.fb_atts_all has empty country.
--manually check the country id intersected by that cid. 
WITH
a AS (
	SELECT qid,tid,cid,point,geom,country,ecoregion FROM cep202003.e_flat_all a1
	JOIN (SELECT DISTINCT cid,country,ecoregion FROM cep202003.fb_atts_all WHERE country @> '{0}') a2 USING(cid)
),
c AS (SELECT a.qid,a.tid,cid,fid FROM a JOIN cep202003.b_clip_country c1 ON ST_INTERSECTS(a.point,c1.geom) WHERE a.qid=c1.qid)
SELECT * FROM c;
--manually update the empty country with country_id found in the previous step. NB: the correction is applied to fa_atts_tile
UPDATE cep202003.fa_atts_tile
SET country = '{171}'
WHERE qid=52043 AND tid=1202;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--100 cids (all single pixel, 30x30) have multiple(2) country (1) or ecoregion (99). This is due to overlapping original geometries (they shouldn't). The total surface involved is non-significant, but to make the process "smooth", they are randomly assigned to one or the other original fid (it also works with rasterization at low resolution...).

DROP TABLE IF EXISTS fa_atts_tile;
CREATE TEMPORARY TABLE fa_atts_tile AS
WITH
--select cid with multiple ecoregion in the array
a AS (SELECT qid,tid,country,ARRAY_AGG((ecoregion)[FLOOR(random()*(CARDINALITY(ecoregion)-1+1))+1]) ecoregion,wdpa
FROM cep202003.fa_atts_tile WHERE CARDINALITY(ecoregion) > 1 GROUP BY qid,tid,country,wdpa),
--select cid with multiple country in the array
b AS (SELECT qid,tid,ARRAY_AGG((country)[FLOOR(random()*(CARDINALITY(country)-1+1))+1]) country,ecoregion,wdpa
FROM cep202003.fa_atts_tile WHERE CARDINALITY(country) > 1 GROUP BY qid,tid,ecoregion,wdpa),
--select cid with single country/ecoregion in the array
c AS (SELECT * FROM cep202003.fa_atts_tile WHERE CARDINALITY(country) <= 1 AND CARDINALITY(ecoregion) <= 1)
--merge the above; NB: the correction is applied to a temporary fa_atts_tile
SELECT * FROM a UNION SELECT * FROM b UNION SELECT * FROM c ORDER BY qid,tid;

-- the following steps will recreate all (not only the corrected) the steps from fa_atts_tile (f_attributes_all.sh) in the flattening workflow, as temporary tables

--create a new CID sequence
DROP TABLE IF EXISTS fb_atts_all;
CREATE TEMPORARY TABLE fb_atts_all AS
SELECT ROW_NUMBER () OVER () cid,*
FROM (SELECT DISTINCT country,ecoregion,wdpa FROM fa_atts_tile ORDER BY country,ecoregion,wdpa) a;

--attach the new cid sequence to original arrays,qid,tid
DROP TABLE IF EXISTS new_cid;
CREATE TEMPORARY TABLE new_cid AS
SELECT DISTINCT qid,tid,cid ncid,country,ecoregion,wdpa FROM fa_atts_tile JOIN fb_atts_all USING(country,ecoregion,wdpa) ORDER BY qid,tid,ncid;

--extract all cids
DROP TABLE IF EXISTS old_cid;
CREATE TEMPORARY TABLE old_cid AS
SELECT DISTINCT qid,tid,cid ocid FROM cep202003.e_flat_all JOIN (SELECT DISTINCT qid,tid FROM fa_atts_tile) a USING(qid,tid) ORDER BY qid,tid;

--create a map with new and old cid, attached to final arrays,qid,tid
DROP TABLE IF EXISTS cid_map;
CREATE TEMPORARY TABLE cid_map AS
SELECT * FROM old_cid JOIN new_cid USING (qid,tid);

--create a new temporary table containing geoms,points, qid,tid and old/new cid
DROP TABLE IF EXISTS e_flat_all;
CREATE TABLE e_flat_all AS
SELECT qid,tid,ncid cid,geom,point,valid,reason,location,st_geometrytype
FROM cep202003.e_flat_all a
JOIN new_cid b USING(qid,tid)
ORDER BY qid,cid,tid;

--backup results and substitute them with new temporary calculated tables.
DROP TABLE IF EXISTS cep202003.e_flat_all_bak;
CREATE TABLE cep202003.e_flat_all_bak AS SELECT * FROM cep202003.e_flat_all;
TRUNCATE cep202003.e_flat_all RESTART IDENTITY;
INSERT INTO cep202003.e_flat_all SELECT * FROM e_flat_all;

DROP TABLE IF EXISTS cep202003.fa_atts_tile_bak;
CREATE TABLE cep202003.fa_atts_tile_bak AS SELECT * FROM cep202003.fa_atts_tile;
TRUNCATE cep202003.fa_atts_tile RESTART IDENTITY;
INSERT INTO cep202003.fa_atts_tile SELECT * FROM fa_atts_tile;

DROP TABLE IF EXISTS cep202003.fb_atts_all_bak;
CREATE TABLE cep202003.fb_atts_all_bak AS SELECT * FROM cep202003.fb_atts_all;
TRUNCATE cep202003.fb_atts_all RESTART IDENTITY;
INSERT INTO cep202003.fb_atts_all SELECT * FROM fb_atts_all;

DROP TABLE IF EXISTS cep202003.g_flat_temp_bak;
CREATE TABLE cep202003.g_flat_temp_bak AS SELECT * FROM cep202003.g_flat_temp;

DROP TABLE IF EXISTS cep202003.h_flat_bak;
CREATE TABLE cep202003.h_flat_bak AS SELECT * FROM cep202003.h_flat;

DROP TABLE IF EXISTS cep202003.cid_map;
CREATE TABLE cep202003.cid_map AS
SELECT * FROM old_cid JOIN new_cid USING (qid,tid);

-- THE OUTPUT IS READY TO BE REPROCESSED with a rerun of the last steps (g_final_all.sh and h_output.sh) of the z_do_it_all.sh script in the flattening sequence; these steps are saved in the attached file 202003_fix_cep_overlaps.sh 
