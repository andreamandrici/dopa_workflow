--ATTRIBUTES
DROP TABLE IF EXISTS fao_fish_dopa_attributes;CREATE TEMPORARY TABLE fao_fish_dopa_attributes AS
SELECT f_code::text o_code,* FROM gisco.fao_fish_at;
UPDATE fao_fish_dopa_attributes SET f_code='21.5.Z.e.c' WHERE f_code='21.5.Z.c';
UPDATE fao_fish_dopa_attributes SET f_code='21.5.Z.e.u' WHERE f_code='21.5.Z.u';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c' WHERE f_code='27.3.b, c';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c.23' WHERE f_code='27.3.b.23';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c.22' WHERE f_code='27.3.c.22';
UPDATE fao_fish_dopa_attributes
SET f_code=SPLIT_PART(f_code,'.',1)||'.'||SPLIT_PART(f_code,'.',2)||'.'||(SPLIT_PART(f_code,'.',3)::double precision/10)::text
WHERE f_code IN ('34.1.11','34.1.12','34.1.13','34.1.31','34.1.32','34.3.11','34.3.12','34.3.13','87.1.11','87.1.12','87.1.13','87.1.14','87.1.15','87.1.21','87.1.22','87.1.23','87.1.24','87.1.25','87.2.11','87.2.12','87.2.13','87.2.14','87.2.15','87.2.16','87.2.17','87.2.21','87.2.22','87.2.23','87.2.24','87.2.25','87.2.26','87.2.27','87.3.11','87.3.12','87.3.13','87.3.21','87.3.22','87.3.23');

DROP TABLE IF EXISTS gisco.fao_fish_dopa_attributes;CREATE TABLE gisco.fao_fish_dopa_attributes AS
SELECT DISTINCT
CASE f_level WHEN 'MAJOR' THEN 1 WHEN 'SUBAREA' THEN 2 WHEN 'DIVISION' THEN 3 WHEN 'SUBDIVISION' THEN 4 WHEN 'SUBUNIT' THEN 5 ELSE 0 END f_level_order,
LOWER(f_level)::text f_level,f_code::text,o_code,ocean::text,subocean::integer,name_en::text,name_fr::text,name_es::text,
SPLIT_PART(f_code,'.',1)fl1,SPLIT_PART(f_code,'.',2)fl2,SPLIT_PART(f_code,'.',3)fl3,SPLIT_PART(f_code,'.',4)fl4,SPLIT_PART(f_code,'.',5)fl5
FROM fao_fish_dopa_attributes
ORDER BY f_level_order,f_code;

--GEOMS
DROP TABLE IF EXISTS fao_fish_rg_dopa_preprocess;CREATE TEMPORARY TABLE fao_fish_rg_dopa_preprocess AS
SELECT f_code::text o_code,*  FROM gisco.fao_fish_rg;
UPDATE fao_fish_rg_dopa_preprocess SET f_code='21.5.Z.e.c' WHERE f_code='21.5.Z.c';
UPDATE fao_fish_rg_dopa_preprocess SET f_code='21.5.Z.e.u' WHERE f_code='21.5.Z.u';
UPDATE fao_fish_rg_dopa_preprocess SET f_code='27.3.b,c' WHERE f_code='27.3.b, c';
UPDATE fao_fish_rg_dopa_preprocess SET f_code='27.3.b,c.23' WHERE f_code='27.3.b.23';
UPDATE fao_fish_rg_dopa_preprocess SET f_code='27.3.b,c.22' WHERE f_code='27.3.c.22';
UPDATE fao_fish_rg_dopa_preprocess
SET f_code=SPLIT_PART(f_code,'.',1)||'.'||SPLIT_PART(f_code,'.',2)||'.'||(SPLIT_PART(f_code,'.',3)::double precision/10)::text
WHERE f_code IN ('34.1.11','34.1.12','34.1.13','34.1.31','34.1.32','34.3.11','34.3.12','34.3.13','87.1.11','87.1.12','87.1.13','87.1.14','87.1.15','87.1.21','87.1.22','87.1.23','87.1.24','87.1.25','87.2.11','87.2.12','87.2.13','87.2.14','87.2.15','87.2.16','87.2.17','87.2.21','87.2.22','87.2.23','87.2.24','87.2.25','87.2.26','87.2.27','87.3.11','87.3.12','87.3.13','87.3.21','87.3.22','87.3.23');

DROP TABLE IF EXISTS gisco.fao_fish_rg_dopa_preprocess;CREATE TABLE gisco.fao_fish_rg_dopa_preprocess AS
SELECT ROW_NUMBER () OVER () nid,* FROM (
SELECT
CASE level_ WHEN 'MAJOR' THEN 1 WHEN 'SUBAREA' THEN 2 WHEN 'DIVISION' THEN 3 WHEN 'SUBDIVISION' THEN 4 WHEN 'SUBUNIT' THEN 5 ELSE 0 END f_level_order,
LOWER(level_)::text f_level,f_code::text,o_code,
NULL::bool gvalid,geom FROM fao_fish_rg_dopa_preprocess ORDER BY f_code,id) a;
ALTER TABLE gisco.fao_fish_rg_dopa_preprocess ADD PRIMARY KEY (nid);
UPDATE gisco.fao_fish_rg_dopa_preprocess SET geom=ST_MAKEVALID(geom),gvalid=FALSE WHERE ST_ISVALID(geom) IS FALSE;

DROP TABLE IF EXISTS fl1;CREATE TEMPORARY TABLE fl1 AS
SELECT
f_level_order,f_level,f_code,
b.ocean,b.subocean,b.name_en,b.name_fr,b.name_es,
b.fl1,b.fl2,b.fl3,b.fl4,b.fl5,
a.nid,a.o_code,a.geom
FROM gisco.fao_fish_rg_dopa_preprocess a JOIN gisco.fao_fish_dopa_attributes b USING(f_level_order,f_level,f_code)
WHERE a.f_level_order = 1;
--------------------------------------------------------
DROP TABLE IF EXISTS fl2;CREATE TEMPORARY TABLE fl2 AS
SELECT
f_level_order,f_level,f_code,
b.ocean,b.subocean,b.name_en,b.name_fr,b.name_es,
b.fl1,b.fl2,b.fl3,b.fl4,b.fl5,
a.nid,a.o_code,a.geom
FROM gisco.fao_fish_rg_dopa_preprocess a JOIN gisco.fao_fish_dopa_attributes b USING(f_level_order,f_level,f_code)
WHERE a.f_level_order = 2;
--------------------------------------------------------
DROP TABLE IF EXISTS fl3;CREATE TEMPORARY TABLE fl3 AS
SELECT
f_level_order,f_level,f_code,
b.ocean,b.subocean,b.name_en,b.name_fr,b.name_es,
b.fl1,b.fl2,b.fl3,b.fl4,b.fl5,
a.nid,a.o_code,a.geom
FROM gisco.fao_fish_rg_dopa_preprocess a JOIN gisco.fao_fish_dopa_attributes b USING(f_level_order,f_level,f_code)
WHERE a.f_level_order = 3 AND nid !=3128 ;
--------------------------------------------------------
DROP TABLE IF EXISTS fl4;CREATE TEMPORARY TABLE fl4 AS
SELECT
f_level_order,f_level,f_code,
b.ocean,b.subocean,b.name_en,b.name_fr,b.name_es,
b.fl1,b.fl2,b.fl3,b.fl4,b.fl5,
a.nid,a.o_code,a.geom
FROM gisco.fao_fish_rg_dopa_preprocess a JOIN gisco.fao_fish_dopa_attributes b USING(f_level_order,f_level,f_code)
WHERE a.f_level_order = 4;
--------------------------------------------------------
DROP TABLE IF EXISTS fl5;CREATE TEMPORARY TABLE fl5 AS
SELECT
f_level_order,f_level,f_code,
b.ocean,b.subocean,b.name_en,b.name_fr,b.name_es,
b.fl1,b.fl2,b.fl3,b.fl4,b.fl5,
a.nid,a.o_code,a.geom
FROM gisco.fao_fish_rg_dopa_preprocess a JOIN gisco.fao_fish_dopa_attributes b USING(f_level_order,f_level,f_code)
WHERE a.f_level_order = 5;

SELECT 1 l,COUNT(*) FROM fl1
UNION
SELECT 2 l,COUNT(*) FROM fl2
UNION
SELECT 3 l,COUNT(*) FROM fl3
UNION
SELECT 4 l,COUNT(*) FROM fl4
UNION
SELECT 5 l,COUNT(*) FROM fl5
ORDER BY l;

DROP TABLE IF EXISTS afl1;CREATE TEMPORARY TABLE afl1 AS
SELECT f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,
ARRAY_AGG(nid ORDER BY nid) nid,o_code,ST_SETSRID(ST_MULTI(ST_COLLECT(geom)),4326) geom
FROM fl1
GROUP BY f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,o_code
ORDER BY f_level_order,f_level,f_code;

DROP TABLE IF EXISTS afl2;CREATE TEMPORARY TABLE afl2 AS
SELECT f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,
ARRAY_AGG(nid ORDER BY nid) nid,o_code,ST_SETSRID(ST_MULTI(ST_COLLECT(geom)),4326) geom
FROM fl2
GROUP BY f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,o_code
ORDER BY f_level_order,f_level,f_code;

DROP TABLE IF EXISTS afl3;CREATE TEMPORARY TABLE afl3 AS
SELECT f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,
ARRAY_AGG(nid ORDER BY nid) nid,o_code,ST_SETSRID(ST_MULTI(ST_COLLECT(geom)),4326) geom
FROM fl3
GROUP BY f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,o_code
ORDER BY f_level_order,f_level,f_code;

DROP TABLE IF EXISTS afl4;CREATE TEMPORARY TABLE afl4 AS
SELECT f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,
ARRAY_AGG(nid ORDER BY nid) nid,o_code,ST_SETSRID(ST_MULTI(ST_COLLECT(geom)),4326) geom
FROM fl4
GROUP BY f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,o_code
ORDER BY f_level_order,f_level,f_code;

DROP TABLE IF EXISTS afl5;CREATE TEMPORARY TABLE afl5 AS
SELECT f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,
ARRAY_AGG(nid ORDER BY nid) nid,o_code,ST_SETSRID(ST_MULTI(ST_COLLECT(geom)),4326) geom
FROM fl5
GROUP BY f_level_order,f_level,f_code,ocean,subocean,name_en,name_fr,name_es,fl1,fl2,fl3,fl4,fl5,o_code
ORDER BY f_level_order,f_level,f_code;

DROP TABLE IF EXISTS nested_codes;CREATE TEMPORARY TABLE nested_codes AS
WITH
a1 AS (SELECT f_code,fl1 FROM gisco.fao_fish_dopa_attributes WHERE f_level_order = 1),
a2 AS (SELECT f_code,fl1,fl2 FROM gisco.fao_fish_dopa_attributes WHERE f_level_order = 2),
a3 AS (SELECT f_code,fl1,fl2,fl3 FROM gisco.fao_fish_dopa_attributes WHERE f_level_order = 3),
a4 AS (SELECT f_code,fl1,fl2,fl3,fl4 FROM gisco.fao_fish_dopa_attributes WHERE f_level_order = 4),
a5 AS (SELECT f_code,fl1,fl2,fl3,fl4,fl5 FROM gisco.fao_fish_dopa_attributes WHERE f_level_order = 5),
ab1 AS (SELECT a1.f_code l1_code,a2.f_code l2_code,fl1,fl2 FROM a1 LEFT JOIN a2 USING(fl1)),
ab2 AS (SELECT l1_code,l2_code,f_code l3_code,fl1,fl2,fl3 FROM ab1 LEFT JOIN a3 USING(fl1,fl2)),
ab3 AS (SELECT l1_code,l2_code,l3_code,f_code l4_code,fl1,fl2,fl3,fl4 FROM ab2 LEFT JOIN a4 USING(fl1,fl2,fl3)),
ab4 AS (SELECT l1_code,l2_code,l3_code,l4_code,f_code l5_code,fl1,fl2,fl3,fl4,fl5 FROM ab3 LEFT JOIN a5 USING(fl1,fl2,fl3,fl4))
SELECT ROW_NUMBER() OVER () fid,* FROM ab4
ORDER BY l1_code,l2_code,l3_code,l4_code,l5_code;

DROP TABLE IF EXISTS nested_geoms;CREATE TEMPORARY TABLE nested_geoms AS
WITH
a AS (SELECT a.fid,a.fl1 l1,a.l1_code l1_major_code,b.ocean l1_ocean,b.subocean l1_subocean,b.name_en l1_name_en,b.name_fr l1_name_fr,b.name_es l1_name_es,b.o_code l1_ocode,b.nid l1_nid,b.geom l1geom FROM nested_codes a JOIN afl1 b ON a.l1_code=b.f_code),
b AS (SELECT a.fid,a.fl2 l2,a.l2_code l2_subarea_code,b.ocean l2_ocean,b.subocean l2_subocean,b.name_en l2_name_en,b.name_fr l2_name_fr,b.name_es l2_name_es,b.o_code l2_ocode,b.nid l2_nid,b.geom l2geom FROM nested_codes a JOIN afl2 b ON a.l2_code=b.f_code),
c AS (SELECT a.fid,a.fl3 l3,a.l3_code l3_division_code,b.ocean l3_ocean,b.subocean l3_subocean,b.name_en l3_name_en,b.name_fr l3_name_fr,b.name_es l3_name_es,b.o_code l3_ocode,b.nid l3_nid,b.geom l3geom FROM nested_codes a JOIN afl3 b ON a.l3_code=b.f_code),
d AS (SELECT a.fid,a.fl4 l4,a.l4_code l4_subdivision_code,b.ocean l4_ocean,b.subocean l4_subocean,b.name_en l4_name_en,b.name_fr l4_name_fr,b.name_es l4_name_es,b.o_code l4_ocode,b.nid l4_nid,b.geom l4geom FROM nested_codes a JOIN afl4 b ON a.l4_code=b.f_code),
e AS (SELECT a.fid,a.fl5 l5,a.l5_code l5_subunit_code,b.ocean l5_ocean,b.subocean l5_subocean,b.name_en l5_name_en,b.name_fr l5_name_fr,b.name_es l5_name_es,b.o_code l5_ocode,b.nid l5_nid,b.geom l5geom FROM nested_codes a JOIN afl5 b ON a.l5_code=b.f_code),
f AS (SELECT * FROM a LEFT JOIN b USING(fid) LEFT JOIN c USING(fid) LEFT JOIN d USING(fid) LEFT JOIN e USING(fid) ORDER BY fid)
SELECT *,l1_nid nid,l1geom geom 
FROM f ORDER BY fid;

UPDATE nested_geoms SET geom=l2geom WHERE l2geom IS NOT NULL;
UPDATE nested_geoms SET geom=l3geom WHERE l3geom IS NOT NULL;
UPDATE nested_geoms SET geom=l4geom WHERE l4geom IS NOT NULL;
UPDATE nested_geoms SET geom=l5geom WHERE l5geom IS NOT NULL;
UPDATE nested_geoms SET nid=l2_nid WHERE l2_nid IS NOT NULL;
UPDATE nested_geoms SET nid=l3_nid WHERE l3_nid IS NOT NULL;
UPDATE nested_geoms SET nid=l4_nid WHERE l4_nid IS NOT NULL;
UPDATE nested_geoms SET nid=l5_nid WHERE l5_nid IS NOT NULL;
ALTER TABLE nested_geoms
DROP column l1geom,DROP column l2geom,DROP column l3geom,DROP column l4geom,DROP column l5geom,
DROP column l1_nid,DROP column l2_nid,DROP column l3_nid,DROP column l4_nid,DROP column l5_nid;

DROP TABLE IF EXISTS gisco.dopa_fao_fish;CREATE TABLE gisco.dopa_fao_fish AS
SELECT * FROM nested_geoms ORDER BY fid;
ALTER TABLE gisco.dopa_fao_fish ADD PRIMARY KEY(fid);
CREATE INDEX ON gisco.dopa_fao_fish USING GIST(geom);

SELECT
fid,
l1,
l1_major_code,
l1_ocean,
l1_subocean,
l1_name_en,
l1_name_fr,
l1_name_es,
l1_ocode,
l2,
l2_subarea_code,
l2_ocean,
l2_subocean,
l2_name_en,
l2_name_fr,
l2_name_es,
l2_ocode,
l3,
l3_division_code,
l3_ocean,
l3_subocean,
l3_name_en,
l3_name_fr,
l3_name_es,
l3_ocode,
l4,
l4_subdivision_code,
l4_ocean,
l4_subocean,
l4_name_en,
l4_name_fr,
l4_name_es,
l4_ocode,
l5,
l5_subunit_code,
l5_ocean,
l5_subocean,
l5_name_en,
l5_name_fr,
l5_name_es,
l5_ocode,
nid
FROM gisco.dopa_fao_fish;
