--DROP SCHEMA iucn_get_last CASCADE;CREATE SCHEMA iucn_get_last;
-- DROP TABLE IF EXISTS iucn_get_last.class_codes;CREATE TABLE iucn_get_last.class_codes AS
-- WITH
-- a AS (SELECT DISTINCT realm::text c0_class,SPLIT_PART(biome::text,' ',1) c01,biome::text,"ecosystem functional group (efg)"::text efg,SPLIT_PART("ecosystem functional group (efg)"::text,' ',1) c2 FROM iucn_get_last.original_codes ORDER BY c0_class),
-- b AS (SELECT
-- 	  c01,
-- 	  REGEXP_REPLACE(SPLIT_PART(c01,'_',1),'[[:digit:]]','','g') c0,
-- 	  REGEXP_REPLACE(SPLIT_PART(c01,'_',1),'[[:alpha:]]','','g')::integer c1,
-- 	  c0_class,
-- 	  REPLACE(biome,c01||' ','') c1_class,
-- 	  biome,
-- 	  c2,
-- 	  efg FROM a ORDER BY c01,c2),
-- 	  c AS (
-- SELECT DISTINCT c01,c0 c0t,CASE c0 WHEN 'T' THEN 1 WHEN 'S' THEN 2 WHEN 'SF' THEN 3 WHEN 'SM' THEN 4 WHEN 'TF' THEN 5 WHEN 'F' THEN 6 WHEN 'FM' THEN 7 WHEN 'M' THEN 8 WHEN 'MT' THEN 9 WHEN 'MFT' THEN 10 END c0n,c0_class,c1,c1_class,
-- c2 c012,
-- SPLIT_PART(c2,'.',2)::integer c2,
-- REPLACE(efg,c2||' ','') c2_class,
-- efg
-- FROM b ORDER BY c0n,c1,c2),
-- d AS (SELECT c0n c0,c0t,c0_class c0_class_realm,c1,c1_class c1_class_biome,c2,c0t||c1||'.'||c2 ct,c2_class c2_class_ecosystem_functional_group FROM c ORDER BY c0,c1,c2),
-- e AS (SELECT GENERATE_SERIES(1, 2, 1) c3)
-- SELECT c0*10000+c1*1000+c2*10+c3 cn,*,CASE c3 WHEN 1 THEN 'major' WHEN 2 THEN 'minor' END c3_class_occurrence FROM d,e ORDER BY cn;
-- ALTER TABLE iucn_get_last.class_codes ADD PRIMARY KEY(cn);
-- DROP TABLE IF EXISTS iucn_get_last.original_codes;

WITH
a AS (SELECT table_schema::text,table_name::text,column_name::text,
	  CASE column_name::text
	  WHEN 'name' THEN 1 WHEN 'occurrence' THEN 2 WHEN 'value' THEN 3 WHEN 'wkb_geometry' THEN 4 ELSE 0 END ocn
	  FROM information_schema.columns
	  WHERE table_schema = 'iucn_get_last' AND column_name != 'ogc_fid'
	 ORDER BY table_name,ocn),
b AS (SELECT 'SELECT '''||table_name||''' tname,occurrence::text,wkb_geometry geom FROM '||table_schema||'.'||table_name||' UNION' FROM a)
SELECT DISTINCT * FROM b;

DROP TABLE IF EXISTS iucn_get_last.merge_all;CREATE TABLE iucn_get_last.merge_all AS
SELECT 'f1_1_web_mix_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_1_web_mix_v2_0 UNION
SELECT 'f1_2_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_2_web_map_v1_0 UNION
SELECT 'f1_3_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_3_web_map_v1_0 UNION
SELECT 'f1_4_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_4_web_map_v1_0 UNION
SELECT 'f1_5_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_5_web_map_v1_0 UNION
SELECT 'f1_6_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_6_web_mix_v1_0 UNION
SELECT 'f1_7_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f1_7_web_orig_v2_0 UNION
SELECT 'f2_10_web_mix_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_10_web_mix_v2_0 UNION
SELECT 'f2_1_web_alt_v4_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_1_web_alt_v4_0 UNION
SELECT 'f2_2_web_mix_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_2_web_mix_v2_0 UNION
SELECT 'f2_3_web_mix_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_3_web_mix_v2_0 UNION
SELECT 'f2_4_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_4_web_mix_v1_0 UNION
SELECT 'f2_5_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_5_web_mix_v1_0 UNION
SELECT 'f2_6_web_mix_v4_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_6_web_mix_v4_0 UNION
SELECT 'f2_7_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_7_web_mix_v1_0 UNION
SELECT 'f2_8_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_8_web_mix_v1_0 UNION
SELECT 'f2_9_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f2_9_web_mix_v1_0 UNION
SELECT 'f3_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f3_1_web_orig_v1_0 UNION
SELECT 'f3_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f3_2_web_orig_v1_0 UNION
SELECT 'f3_3_web_alt_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f3_3_web_alt_v2_0 UNION
SELECT 'f3_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f3_4_web_orig_v1_0 UNION
SELECT 'f3_5_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.f3_5_web_orig_v1_0 UNION
SELECT 'fm1_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.fm1_1_web_map_v1_0 UNION
SELECT 'fm1_2_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.fm1_2_web_map_v1_0 UNION
SELECT 'fm1_3_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.fm1_3_web_orig_v2_0 UNION
SELECT 'm1_10_wm_nwx_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_10_wm_nwx_v1_0 UNION
SELECT 'm1_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_1_web_orig_v1_0 UNION
SELECT 'm1_2_web_orig_v2_2' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_2_web_orig_v2_2 UNION
SELECT 'm1_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_3_web_orig_v1_0 UNION
SELECT 'm1_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_4_web_orig_v1_0 UNION
SELECT 'm1_5_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_5_web_orig_v1_0 UNION
SELECT 'm1_6_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_6_web_orig_v1_0 UNION
SELECT 'm1_7_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_7_web_orig_v1_0 UNION
SELECT 'm1_8_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_8_web_orig_v1_0 UNION
SELECT 'm1_9_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m1_9_web_orig_v1_0 UNION
SELECT 'm2_1_web_orig_v2_1' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m2_1_web_orig_v2_1 UNION
SELECT 'm2_2_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m2_2_web_orig_v2_0 UNION
SELECT 'm2_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m2_3_web_orig_v1_0 UNION
SELECT 'm2_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m2_4_web_orig_v1_0 UNION
SELECT 'm2_5_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m2_5_web_orig_v1_0 UNION
SELECT 'm3_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_1_web_orig_v1_0 UNION
SELECT 'm3_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_2_web_orig_v1_0 UNION
SELECT 'm3_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_3_web_orig_v1_0 UNION
SELECT 'm3_4_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_4_web_orig_v2_0 UNION
SELECT 'm3_5_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_5_web_orig_v1_0 UNION
SELECT 'm3_6_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_6_web_orig_v1_0 UNION
SELECT 'm3_7_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m3_7_web_orig_v1_0 UNION
SELECT 'm4_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m4_1_web_orig_v1_0 UNION
SELECT 'm4_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.m4_2_web_orig_v1_0 UNION
SELECT 'mft1_1_map_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mft1_1_map_orig_v1_0 UNION
SELECT 'mft1_2_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mft1_2_web_orig_v2_0 UNION
SELECT 'mft1_3_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mft1_3_web_orig_v2_0 UNION
SELECT 'mt1_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt1_1_web_map_v1_0 UNION
SELECT 'mt1_2_im_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt1_2_im_orig_v1_0 UNION
SELECT 'mt1_3_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt1_3_web_map_v1_0 UNION
SELECT 'mt1_4_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt1_4_web_map_v1_0 UNION
SELECT 'mt2_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt2_1_web_map_v1_0 UNION
SELECT 'mt2_2_im_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt2_2_im_orig_v1_0 UNION
SELECT 'mt3_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.mt3_1_web_map_v1_0 UNION
SELECT 's1_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.s1_1_web_orig_v1_0 UNION
SELECT 's1_2_endolithic_systems' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.s1_2_endolithic_systems UNION
SELECT 's2_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.s2_1_web_orig_v1_0 UNION
SELECT 'sf1_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sf1_1_web_orig_v1_0 UNION
SELECT 'sf1_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sf1_2_web_orig_v1_0 UNION
SELECT 'sf2_1_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sf2_1_web_orig_v1_0 UNION
SELECT 'sf2_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sf2_2_web_orig_v1_0 UNION
SELECT 'sm1_1_web_grid_v3_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sm1_1_web_grid_v3_0 UNION
SELECT 'sm1_2_web_grid_v3_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sm1_2_web_grid_v3_0 UNION
SELECT 'sm1_3_web_grid_v3_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.sm1_3_web_grid_v3_0 UNION
SELECT 't1_1_web_mix_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t1_1_web_mix_v2_0 UNION
SELECT 't1_2_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t1_2_web_mix_v1_0 UNION
SELECT 't1_3_wm_nwx_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t1_3_wm_nwx_v1_0 UNION
SELECT 't1_4_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t1_4_web_orig_v2_0 UNION
SELECT 't2_1_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_1_web_mix_v1_0 UNION
SELECT 't2_2_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_2_web_mix_v1_0 UNION
SELECT 't2_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_3_web_orig_v1_0 UNION
SELECT 't2_4_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_4_web_orig_v2_0 UNION
SELECT 't2_5_web_alt_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_5_web_alt_v2_0 UNION
SELECT 't2_6_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t2_6_web_mix_v1_0 UNION
SELECT 't3_1_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t3_1_web_orig_v2_0 UNION
SELECT 't3_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t3_2_web_orig_v1_0 UNION
SELECT 't3_3_web_alt_v4_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t3_3_web_alt_v4_0 UNION
SELECT 't3_4_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t3_4_web_mix_v1_0 UNION
SELECT 't4_1_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t4_1_web_mix_v1_0 UNION
SELECT 't4_2_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t4_2_web_orig_v1_0 UNION
SELECT 't4_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t4_3_web_orig_v1_0 UNION
SELECT 't4_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t4_4_web_orig_v1_0 UNION
SELECT 't4_5_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t4_5_web_orig_v1_0 UNION
SELECT 't5_1_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t5_1_web_mix_v1_0 UNION
SELECT 't5_2_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t5_2_web_mix_v1_0 UNION
SELECT 't5_3_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t5_3_web_mix_v1_0 UNION
SELECT 't5_4_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t5_4_web_mix_v1_0 UNION
SELECT 't5_5_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t5_5_web_mix_v1_0 UNION
SELECT 't6_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t6_1_web_map_v1_0 UNION
SELECT 't6_2_web_alt_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t6_2_web_alt_v2_0 UNION
SELECT 't6_3_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t6_3_web_map_v1_0 UNION
SELECT 't6_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t6_4_web_orig_v1_0 UNION
SELECT 't6_5_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t6_5_web_mix_v1_0 UNION
SELECT 't7_1_web_alt_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t7_1_web_alt_v2_0 UNION
SELECT 't7_2_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t7_2_web_map_v1_0 UNION
SELECT 't7_3_web_alt_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t7_3_web_alt_v2_0 UNION
SELECT 't7_4_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t7_4_web_orig_v1_0 UNION
SELECT 't7_5_web_mix_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.t7_5_web_mix_v1_0 UNION
SELECT 'tf1_1_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_1_web_map_v1_0 UNION
SELECT 'tf1_2_web_orig_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_2_web_orig_v2_0 UNION
SELECT 'tf1_3_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_3_web_orig_v1_0 UNION
SELECT 'tf1_4_web_map_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_4_web_map_v1_0 UNION
SELECT 'tf1_5_web_map_v2_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_5_web_map_v2_0 UNION
SELECT 'tf1_6_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_6_web_orig_v1_0 UNION
SELECT 'tf1_7_web_orig_v1_0' tname,occurrence::text,wkb_geometry geom FROM iucn_get_last.tf1_7_web_orig_v1_0 ;

UPDATE iucn_get_last.merge_all SET geom = ST_TRANSFORM(ST_SETSRID(geom,4087),4326) WHERE tname = 't1_3_wm_nwx_v1_0';

DROP TABLE IF EXISTS geoms;CREATE TEMPORARY TABLE geoms AS
SELECT tname,occurrence::integer c3,geom FROM iucn_get_last.merge_all WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon'
UNION
SELECT tname,(CASE occurrence WHEN 'major' THEN '1' WHEN 'minor' THEN '2' ELSE occurrence END)::integer c3,(ST_DUMP(geom)).geom FROM iucn_get_last.merge_all WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon'
;
DROP TABLE IF EXISTS iucn_get_last.merge_all_2;CREATE TABLE iucn_get_last.merge_all_2 AS
SELECT ROW_NUMBER() OVER () id,cn,geom
FROM geoms JOIN iucn_get_last.class_code_objects USING(tname,c3) ORDER BY cn;
ALTER TABLE iucn_get_last.merge_all_2 ADD PRIMARY KEY (id);

DROP TABLE IF EXISTS iucn_get_last.merge_all_2_check;CREATE TABLE iucn_get_last.merge_all_2_check AS
SELECT id,(ST_ISVALIDDETAIL(geom)).* FROM iucn_get_last.merge_all_2 WHERE ST_ISVALID(geom) IS FALSE ORDER BY id;

UPDATE iucn_get_last.merge_all_2 SET geom = ST_MAKEVALID(geom) WHERE id IN (SELECT id FROM iucn_get_last.merge_all_2_check);

SELECT DISTINCT ST_ISVALID(geom) FROM iucn_get_last.merge_all_2 WHERE id IN (SELECT id FROM iucn_get_last.merge_all_2_check); 
SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM iucn_get_last.merge_all_2 WHERE id IN (SELECT id FROM iucn_get_last.merge_all_2_check); 

CREATE INDEX ON iucn_get_last.merge_all_2 USING GIST(geom);

DROP TABLE IF EXISTS iucn_get_last.selector;CREATE TABLE iucn_get_last.selector AS
SELECT 1 sid,(ST_GeogFromText('LINESTRING(180 -90, 180 90)')::geometry) geom
UNION
SELECT 2 sid,(ST_GeogFromText('LINESTRING(-180 -90, -180 90)')::geometry) geom;
ALTER TABLE iucn_get_last.selector ADD PRIMARY KEY (sid);
CREATE INDEX ON iucn_get_last.selector USING GIST(geom);
SELECT * FROM iucn_get_last.selector;

-- find geoms that go over -180 and 180
DROP TABLE IF EXISTS merge_all_2_cross;CREATE TEMPORARY TABLE merge_all_2_cross AS
SELECT a.id,b.sid,NULL::integer c FROM iucn_get_last.merge_all_2 a,iucn_get_last.selector b
WHERE ST_INTERSECTS(a.geom,b.geom)
ORDER BY id,sid;
UPDATE merge_all_2_cross SET c = b.c
FROM (SELECT id,COUNT(*) c FROM merge_all_2_cross GROUP BY id ORDER BY c DESC) b
WHERE merge_all_2_cross.id=b.id;
DROP TABLE IF EXISTS iucn_get_last.merge_all_2_cross;CREATE TABLE iucn_get_last.merge_all_2_cross AS
WITH
a AS (SELECT id,c,sid east FROM merge_all_2_cross WHERE sid =1),
b AS (SELECT id,c,sid west FROM merge_all_2_cross WHERE sid =2)
SELECT * FROM a FULL OUTER JOIN b USING(id,c) ORDER BY c DESC,id,east,west;
SELECT * FROM iucn_get_last.merge_all_2_cross;

DROP TABLE IF EXISTS iucn_get_last.merge_all_2_cross_temp;CREATE TABLE iucn_get_last.merge_all_2_cross_temp AS
SELECT * FROM iucn_get_last.merge_all_2 JOIN iucn_get_last.merge_all_2_cross USING(id)
ORDER BY c DESC,east,west,cn,id;
ALTER TABLE iucn_get_last.merge_all_2_cross_temp ADD PRIMARY KEY(id);
CREATE INDEX ON iucn_get_last.merge_all_2_cross_temp USING GIST(geom);
WITH a AS (SELECT id,c,east,west,ST_XMIN(geom),ST_XMAX(geom) FROM iucn_get_last.merge_all_2_cross_temp GROUP BY id,c,east,west)
DELETE FROM iucn_get_last.merge_all_2_cross_temp WHERE id IN (SELECT id FROM a WHERE NOT (st_xmin < -180 OR st_xmax > 180));

DROP TABLE IF EXISTS iucn_get_last.iucn_get;CREATE TABLE iucn_get_last.iucn_get AS
SELECT cn,c0,c0t,c0_class_realm,c1,c1_class_biome,c2,ct,c2_class_ecosystem_functional_group,c3,c3_class_occurrence,ST_MULTI(ST_COLLECT(geom)) geom
FROM iucn_get_last.merge_all_2 JOIN iucn_get_last.class_code_objects USING (cn)
GROUP BY cn,c0,c0t,c0_class_realm,c1,c1_class_biome,c2,ct,c2_class_ecosystem_functional_group,c3,c3_class_occurrence
ORDER BY cn;
ALTER TABLE iucn_get_last.iucn_get ADD PRIMARY KEY(cn);
CREATE INDEX ON iucn_get_last.iucn_get USING GIST(geom);

DROP TABLE IF EXISTS iucn_get_last.iucn_get_major;CREATE TABLE iucn_get_last.iucn_get_major AS
SELECT * FROM iucn_get_last.iucn_get WHERE c3 = 1 ORDER BY cn;
ALTER TABLE iucn_get_last.iucn_get_major ADD PRIMARY KEY(cn);
CREATE INDEX ON iucn_get_last.iucn_get_major USING GIST(geom);

DROP TABLE IF EXISTS iucn_get_last.iucn_get_minor;CREATE TABLE iucn_get_last.iucn_get_minor AS
SELECT * FROM iucn_get_last.iucn_get WHERE c3 = 2 ORDER BY cn;
ALTER TABLE iucn_get_last.iucn_get_minor ADD PRIMARY KEY(cn);
CREATE INDEX ON iucn_get_last.iucn_get_minor USING GIST(geom);
