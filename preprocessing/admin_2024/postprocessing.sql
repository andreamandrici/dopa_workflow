-- DROP TABLE IF EXISTS gisco.h_flat;CREATE TABLE gisco.h_flat AS
-- SELECT qid,NULL::integer cid,NULL::integer tid,land,marine,abnj,geom
-- FROM gisco_2024.h_flat
-- ORDER BY qid,land,marine,abnj;
	
-- DROP TABLE IF EXISTS lma1a;CREATE TEMPORARY TABLE lma1a AS
-- SELECT qid,NULL::integer cid,NULL::integer tid,land,marine,abnj,geom
-- FROM gisco.h_flat
-- ORDER BY qid,land,marine,abnj;
-- UPDATE lma1a SET abnj='{1}' WHERE abnj!='{0}';
-- UPDATE lma1a SET abnj='{0}' WHERE abnj = '{1}' AND (land != '{0}' OR marine != '{0}'); 
-- UPDATE lma1a SET marine='{181}' WHERE marine = '{181,241}'; 
-- UPDATE lma1a SET marine='{0}' WHERE abnj ='{0}' AND land != '{0}' AND marine != '{0}';

-- DROP TABLE IF EXISTS lma1b;CREATE TEMPORARY TABLE lma1b AS
-- SELECT qid,cid,tid,UNNEST(land) land,UNNEST(marine) marine,UNNEST(abnj) abnj,geom FROM lma1a ORDER BY qid,land,marine,abnj;

-- DROP TABLE IF EXISTS lma2a;CREATE TEMPORARY TABLE lma2a AS 
-- SELECT ROW_NUMBER() OVER () tid,* FROM 
-- (SELECT DISTINCT land,marine,abnj FROM lma1b ORDER BY land,marine,abnj) a;

-- UPDATE lma1b SET tid=b.tid FROM lma2a b WHERE lma1b.land=b.land AND lma1b.marine=b.marine AND lma1b.abnj=b.abnj;

-- DROP TABLE IF EXISTS lma2b;CREATE TEMPORARY TABLE lma2b AS
-- WITH
-- a AS (
-- SELECT tid,marine,land,abnj,liso3,miso3,liso2,miso2,lname,mname,lsvrg_un,msvrg_un,svrg_flag FROM lma2a
-- LEFT JOIN (SELECT DISTINCT fidl land,iso3_code liso3,cntr_id liso2,svrg_un lsvrg_un,name_engl lname FROM gisco.input_land) a USING(land)
-- LEFT JOIN (SELECT DISTINCT fidm marine,iso3_code miso3,cntr_id miso2,svrg_flag,svrg_un msvrg_un,name_engl mname FROM gisco.input_marine) b USING(marine)
-- ORDER BY tid)
-- SELECT *,
-- CASE
-- 	WHEN abnj = 1 THEN 'ABNJ'
-- 	WHEN miso3 IS NULL AND abnj = 0 THEN liso3
-- 	WHEN liso3 IS NULL AND abnj = 0 THEN miso3
-- END iso3,
-- CASE
-- 	WHEN abnj = 1 THEN 'ABNJ'
-- 	WHEN miso2 IS NULL AND abnj = 0 THEN liso2
-- 	WHEN liso2 IS NULL AND abnj = 0 THEN miso2
-- END iso2,
-- CASE
-- 	WHEN abnj = 1 THEN 'Area Beyond National Jurisdiction/inconsistent coastline'
-- 	WHEN mname IS NULL AND abnj = 0 THEN lname
-- 	WHEN lname IS NULL AND abnj = 0 THEN mname
-- END name_eng,
-- CASE
-- 	WHEN abnj = 1 THEN NULL
-- 	WHEN msvrg_un IS NULL AND abnj = 0 THEN lsvrg_un
-- 	WHEN lsvrg_un IS NULL AND abnj = 0 THEN msvrg_un
-- END svrg_un,
-- CASE
-- 	WHEN land > 0 THEN 'land'::text
-- 	WHEN marine > 0 THEN 'marine'::text
-- 	WHEN marine = 0 AND land = 0 THEN 'hole'::text
-- 	END lma
-- FROM a ORDER BY tid;

-- DROP TABLE IF EXISTS lma2c;CREATE TEMPORARY TABLE lma2c AS 
-- SELECT ROW_NUMBER() OVER () cid,*,CARDINALITY(tids) n_tids FROM 
-- (SELECT iso3,iso2,svrg_un,name_eng,svrg_flag,ARRAY_AGG(tid ORDER BY tid) tids FROM lma2b GROUP BY iso3,iso2,name_eng,svrg_un,svrg_flag ORDER BY iso3,iso2,name_eng,svrg_un,svrg_flag) a;

-- DROP TABLE IF EXISTS lma2d;CREATE TEMPORARY TABLE lma2d AS
-- WITH a AS (SELECT UNNEST(tids) tid,cid FROM lma2c ORDER BY cid,tid)
-- SELECT * FROM a JOIN lma2b USING(tid) ORDER BY cid,tid;

-- UPDATE lma1b SET cid=b.cid FROM lma2d b
-- WHERE lma1b.tid=b.tid AND lma1b.land=b.land AND lma1b.marine=b.marine AND lma1b.abnj=b.abnj;

-- DROP TABLE IF EXISTS lma3a;CREATE TEMPORARY TABLE lma3a AS 
-- SELECT qid,cid,tid,land,marine,abnj,(ST_DUMP(geom)).*
-- FROM lma1b ORDER BY qid,cid,tid,path;

-- DROP TABLE IF EXISTS lma4;CREATE TEMPORARY TABLE lma4 AS 
-- SELECT qid,cid,tid,land,marine,abnj,iso2,iso3,name_eng,svrg_un,svrg_flag,lma,geom
-- FROM lma3a a JOIN lma2d b USING(cid,tid,land,marine,abnj)
-- ORDER BY qid,cid,tid;
------------------------------
-- DROP TABLE IF EXISTS gisco.lma5a;CREATE TABLE gisco.lma5a AS 
-- SELECT qid,cid,tid,land,marine,abnj,iso2,iso3,name_eng,svrg_un,svrg_flag,ST_UNION(geom) geom
-- FROM lma4
-- GROUP BY qid,cid,tid,land,marine,abnj,iso2,iso3,name_eng,svrg_un,svrg_flag
-- ORDER BY qid,cid,tid;
------------------------------
-- DROP TABLE IF EXISTS gisco.lma5b;CREATE TABLE gisco.lma5b AS 
-- SELECT qid,cid,tid,land,marine,abnj,iso2,iso3,name_eng,svrg_un,svrg_flag,(ST_DUMP(geom)).*,NULL::double precision sqkm
-- FROM gisco.lma5a
-- ORDER BY qid,cid,tid;

-- UPDATE gisco.lma5b SET sqkm=(ST_AREA(geom::geography))/1000000;

SELECT * FROM gisco.lma5b LIMIT 1
------------------------------

-- DROP TABLE IF EXISTS gisco.lma5b_atts;CREATE TABLE gisco.lma5b_atts AS
-- WITH
-- a AS (
-- SELECT DISTINCT cid,tid,land,marine,abnj,REPLACE(iso2,'_','|')iso2,REPLACE(iso3,'_','|')iso3,REPLACE(name_eng,'_','|') name_eng,REPLACE(svrg_un,'_','|') svrg_un,
-- CASE svrg_flag
-- 	WHEN  'D' THEN 'disputed'
-- 	WHEN  'J' THEN 'joint-managed'
-- END svrg_flag
-- FROM gisco.lma5b),
-- b AS (SELECT cid,tid,iso2,iso3,name_eng,
-- CASE
-- 	WHEN svrg_un IS NULL AND svrg_flag IS NULL THEN NULL
-- 	WHEN svrg_un IS NOT NULL AND svrg_flag IS NULL THEN svrg_un
-- 	WHEN svrg_un IS NOT NULL AND svrg_flag IS NOT NULL THEN svrg_un||' ; '||svrg_flag
-- 	WHEN svrg_un IS NULL AND svrg_flag IS NOT NULL THEN svrg_flag
-- END status,
-- CASE
-- 	WHEN land > 0 THEN 'land'::text
-- 	WHEN marine > 0 THEN 'marine'::text
-- 	WHEN marine = 0 AND land = 0 THEN 'abnj_hole'::text
-- END source,
-- CASE
-- 	WHEN abnj != 0 THEN 3000+abnj
-- 	WHEN marine = 0 AND abnj = 0 THEN 1000+land
-- 	WHEN land = 0 AND abnj = 0 THEN 2000+marine
-- END source_id
-- FROM a)
-- SELECT * FROM b ORDER BY source_id;

SELECT * FROM gisco.lma5b_atts;

-- DROP TABLE IF EXISTS gisco.crosswalk_country_id_object_id_cid_tid_source_id;
-- CREATE TABLE gisco.crosswalk_country_id_object_id_cid_tid_source_id AS
-- WITH
-- a AS (SELECT ROW_NUMBER() OVER() country_id,* FROM (SELECT DISTINCT iso2,iso3,name_eng,COALESCE(status,NULL,'') status FROM gisco.lma5b_atts ORDER BY iso2)a),
-- b AS (SELECT ROW_NUMBER() OVER() object_id,* FROM (SELECT DISTINCT iso2,iso3,name_eng,COALESCE(status,NULL,'') status,source FROM gisco.lma5b_atts ORDER BY iso2,source)a),
-- c AS (SELECT DISTINCT iso2,iso3,name_eng,COALESCE(status,NULL,'') status,source,cid,tid,source_id FROM gisco.lma5b_atts),
-- d AS (SELECT * FROM b LEFT JOIN a USING(iso2,iso3,name_eng,status)),
-- e AS (SELECT country_id,object_id,name_eng,iso2,iso3,status,source,source_id,cid,tid FROM d NATURAL JOIN c ORDER BY country_id,object_id)
-- SELECT * FROM e;

-- DROP TABLE IF EXISTS gisco.crosswalk_country_id_object_id_source_ids;
-- CREATE TABLE gisco.crosswalk_country_id_object_id_source_ids AS
-- SELECT country_id,object_id,name_eng,iso2,iso3,status,source,ARRAY_AGG(source_id) source_ids
-- FROM gisco.crosswalk_country_id_object_id_cid_tid_source_id
-- GROUP BY country_id,object_id,name_eng,iso2,iso3,status,source
-- ORDER BY country_id,object_id;
	
-- DROP TABLE IF EXISTS gisco.crosswalk_country_id_object_ids;
-- CREATE TABLE gisco.crosswalk_country_id_object_ids AS
-- SELECT country_id,ARRAY_AGG(object_id)object_ids,name_eng,iso2,iso3,status
-- FROM gisco.crosswalk_country_id_object_id_cid_tid_source_id
-- GROUP BY country_id,name_eng,iso2,iso3,status
-- ORDER BY country_id;

-- DROP TABLE IF EXISTS gisco.crosswalk_dopa_gisco_gaul;CREATE TABLE gisco.crosswalk_dopa_gisco_gaul AS
-- SELECT
-- a.*,
-- c.country_id old_dopa_country_id,
-- c.object_id old_dopa_object_id,
-- c.country_name old_dopa_country_name,
-- c.sovereign_iso3 old_dopa_sovereign_iso3,
-- c.sovereign_iso2 old_dopa_sovereign_iso2,
-- c.iso3 old_dopa_iso3,
-- c.iso2 old_dopa_iso2,
-- c.un_m49 old_dopa_un_m49,
-- c.source old_dopa_source,
-- c.status old_dopa_status,
-- c.changed_iso old_dopa_changed_iso,
-- c.orig_iso3 old_dopa_orig_iso3,
-- c.orig_iso2 old_dopa_orig_iso2,
-- c.changed_iso3 old_dopa_changed_iso3,
-- c.changed_iso2 old_dopa_changed_iso2
-- FROM gisco.crosswalk_country_id_object_id_cid_tid_source_id a
-- JOIN gisco.lma5b_ids b USING(cid,tid)
-- FULL OUTER JOIN administrative_units.gaul_eez_era_atts c ON (b.country_id=c.country_id AND b.object_id=c.object_id)
-- ORDER BY a.country_id,a.object_id;

DROP TABLE IF EXISTS gisco.admin1;CREATE TABLE gisco.admin1 AS
SELECT a.qid,b.country_id,b.object_id,b.name_eng,b.iso2,b.iso3,b.status,b.source,b.source_id,a.geom,a.sqkm
FROM gisco.lma5b a
JOIN gisco.crosswalk_country_id_object_id_cid_tid_source_id b USING(cid,tid)
ORDER BY qid,cid,tid;
---
DROP TABLE IF EXISTS gisco.admin2;CREATE TABLE gisco.admin2 AS
SELECT qid,country_id,object_id,name_eng,iso2,iso3,status,source,ARRAY_AGG(DISTINCT source_id ORDER BY source_id) source_id,ST_UNION(geom) geom,SUM(sqkm) sqkm
FROM gisco.admin1
GROUP BY qid,country_id,object_id,name_eng,iso2,iso3,status,source
ORDER BY qid,country_id,object_id;
---attribute table
DROP TABLE IF EXISTS gisco.admin3;CREATE TABLE gisco.admin3 AS
SELECT country_id,object_id,name_eng,iso2,iso3,status,source,ARRAY_AGG(DISTINCT source_id ORDER BY source_id) source_id,SUM(sqkm) sqkm
FROM gisco.admin1
GROUP BY country_id,object_id,name_eng,iso2,iso3,status,source
ORDER BY country_id,object_id;
--main table
DROP TABLE IF EXISTS gisco.admin4;CREATE TABLE gisco.admin4 AS
SELECT qid,country_id,object_id,name_eng,iso2,iso3,status,source,source_id,geom,sqkm FROM gisco.admin2 WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon'
UNION
SELECT qid,country_id,object_id,name_eng,iso2,iso3,status,source,source_id,ST_MULTI(geom) geom,sqkm FROM gisco.admin2 WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon'
ORDER BY qid,country_id,object_id;
ALTER TABLE gisco.admin4 ADD PRIMARY KEY(qid,object_id);
CREATE INDEX ON gisco.admin4 USING GIST(geom);
---
DROP TABLE IF EXISTS gisco.admin5;CREATE TABLE gisco.admin5 AS
SELECT qid,country_id,ARRAY_AGG(DISTINCT object_id ORDER BY object_id) object_id,name_eng,iso2,iso3,status,ARRAY_AGG(DISTINCT source_id ORDER BY source_id) source_id,ST_UNION(geom) geom,SUM(sqkm) sqkm
FROM gisco.admin1
GROUP BY qid,country_id,name_eng,iso2,iso3,status
ORDER BY qid,country_id;
---main dissolved table
DROP TABLE IF EXISTS gisco.admin6;CREATE TABLE gisco.admin6 AS
SELECT qid,country_id,object_id,name_eng,iso2,iso3,status,source_id,geom,sqkm FROM gisco.admin5 WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon'
UNION
SELECT qid,country_id,object_id,name_eng,iso2,iso3,status,source_id,ST_MULTI(geom) geom,sqkm FROM gisco.admin5 WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon'
ORDER BY qid,country_id,object_id;
ALTER TABLE gisco.admin6 ADD PRIMARY KEY(qid,country_id);
CREATE INDEX ON gisco.admin6 USING GIST(geom);

DROP TABLE IF EXISTS administrative_units.gisco_admin_country;CREATE TABLE administrative_units.gisco_admin_country AS
SELECT * FROM remote_wolfe.admin6;
ALTER TABLE administrative_units.gisco_admin_country ADD PRIMARY KEY (qid,country_id);
CREATE INDEX ON administrative_units.gisco_admin_country USING GIST(geom);

DROP TABLE IF EXISTS administrative_units.gisco_admin_country_objects;CREATE TABLE administrative_units.gisco_admin_country_objects AS
SELECT * FROM remote_wolfe.admin4;
ALTER TABLE administrative_units.gisco_admin_country_objects ADD PRIMARY KEY (qid,object_id);
CREATE INDEX ON administrative_units.gisco_admin_country_objects USING GIST(geom);

DROP TABLE IF EXISTS administrative_units.gisco_admin_attributes;CREATE TABLE administrative_units.gisco_admin_attributes AS
SELECT * FROM remote_wolfe.admin3;
