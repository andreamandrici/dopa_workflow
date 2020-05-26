----------------------------------------------------------------------------
-- EEZ 2019
----------------------------------------------------------------------------
-- ATTRIBUTES (AGGREGATE BY iso/sov)
-----------------------------------------------------------------------------

-- DROP FUNCTION test01.eez_processing();

CREATE OR REPLACE FUNCTION test01.eez_processing(
	)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    
AS $BODY$
BEGIN
DROP TABLE IF EXISTS test01.eez_attributes;
CREATE TABLE test01.eez_attributes AS 
SELECT mrgid::integer,geoname::text,mrgid_ter1::integer,pol_type::text,mrgid_sov1::integer,territory1::text,iso_ter1::text,sovereign1::text,mrgid_ter2::integer,mrgid_sov2::integer,territory2::text,iso_ter2::text,sovereign2::text,mrgid_ter3::integer,mrgid_sov3::integer,territory3::text,iso_ter3::text,sovereign3::text,x_1::double precision,y_1::double precision,mrgid_eez::integer,area_km2::double precision,iso_sov1::text,iso_sov2::text,iso_sov3::text,un_sov1::integer,un_sov2::integer,un_sov3::integer,un_ter1::integer,un_ter2::integer,un_ter3::integer FROM test01.eez_v11;
ALTER TABLE test01.eez_attributes ADD PRIMARY KEY(mrgid);
DROP TABLE IF EXISTS eez_attributes_processed;
CREATE TEMPORARY TABLE eez_attributes_processed AS 
WITH
a AS (SELECT DISTINCT mrgid,geoname,pol_type,x_1,y_1 FROM test01.eez_attributes),
b AS ( 
SELECT DISTINCT
mrgid,
ARRAY_REMOVE(ARRAY[NULLIF(mrgid_ter1,0),NULLIF(mrgid_ter2,0),NULLIF(mrgid_ter3,0)],NULL) mrgid_ter,
ARRAY_REMOVE(ARRAY[territory1,territory2,territory3],NULL) territory,
ARRAY_REMOVE(ARRAY[iso_ter1,iso_ter2,iso_ter3],NULL) iso_ter,
ARRAY_REMOVE(ARRAY[NULLIF(un_ter1,0),NULLIF(un_ter2,0),NULLIF(un_ter3,0)],NULL) un_ter,
ARRAY_REMOVE(ARRAY[NULLIF(mrgid_sov1,0),NULLIF(mrgid_sov2,0),NULLIF(mrgid_sov3,0)],NULL) mrgid_sov,
ARRAY_REMOVE(ARRAY[sovereign1,sovereign2,sovereign3],NULL) sovereign,
ARRAY_REMOVE(ARRAY[iso_sov1,iso_sov2,iso_sov3],NULL) iso_sov,
ARRAY_REMOVE(ARRAY[NULLIF(un_sov1,0),NULLIF(un_sov2,0),NULLIF(un_sov3,0)],NULL) un_sov
FROM test01.eez_attributes),
c AS (SELECT b.mrgid,t.* FROM b,UNNEST(mrgid_ter,territory,iso_ter,un_ter,mrgid_sov,sovereign,iso_sov,un_sov) t(mrgid_ter,territory,iso_ter,un_ter,mrgid_sov,sovereign,iso_sov,un_sov)),
d AS (SELECT
mrgid,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT mrgid_ter ORDER BY mrgid_ter),NULL) mrgid_ter,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT territory ORDER BY territory),NULL) territory,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT iso_ter ORDER BY iso_ter),NULL) iso_ter,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT un_ter ORDER BY un_ter),NULL) un_ter,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT mrgid_sov ORDER BY mrgid_sov),NULL) mrgid_sov,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT sovereign ORDER BY sovereign),NULL) sovereign,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT iso_sov ORDER BY iso_sov),NULL) iso_sov,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT un_sov ORDER BY un_sov),NULL) un_sov
FROM c
GROUP by mrgid ORDER BY mrgid),
e AS (SELECT
a.*,
REPLACE(ARRAY_TO_STRING(mrgid_ter,','),',','/') mrgid_ter,
CARDINALITY(mrgid_ter) cmrgid_ter,
REPLACE(ARRAY_TO_STRING(territory,','),',','/') territory,
CARDINALITY(territory) cterritory,
REPLACE(ARRAY_TO_STRING(iso_ter,','),',','/') iso_ter,
CARDINALITY(iso_ter) ciso_ter,
REPLACE(ARRAY_TO_STRING(un_ter,','),',','/') un_ter,
CARDINALITY(un_ter) cun_ter,
REPLACE(ARRAY_TO_STRING(mrgid_sov,','),',','/') mrgid_sov,
CARDINALITY(mrgid_sov) cmrgid_sov,
REPLACE(ARRAY_TO_STRING(sovereign,','),',','/') sovereign,
CARDINALITY(sovereign) csovereign,
REPLACE(ARRAY_TO_STRING(iso_sov,','),',','/') iso_sov,
CARDINALITY(iso_sov) ciso_sov,
REPLACE(ARRAY_TO_STRING(un_sov,','),',','/') un_sov,
CARDINALITY(un_sov) cun_sov
FROM a NATURAL JOIN d ORDER BY mrgid)
SELECT * FROM e ORDER BY mrgid;
DROP TABLE IF EXISTS tocheck;
CREATE TEMPORARY TABLE tocheck AS (SELECT * FROM eez_attributes_processed WHERE cmrgid_ter < 1 OR ciso_ter < 1 OR cun_ter < 1 OR cmrgid_sov < 1 OR csovereign < 1 OR ciso_sov < 1 OR cun_sov < 1);
DROP TABLE IF EXISTS notes;
CREATE TEMPORARY TABLE notes AS
SELECT mrgid,ARRAY_TO_STRING((ARRAY_REMOVE(notes,NULL)),'/') notes FROM
(SELECT mrgid,ARRAY_AGG(note ORDER BY note) notes FROM (
SELECT mrgid,CASE WHEN mrgid_ter = '' THEN 'mrgid_sov filled from mrgid_ter' END note FROM tocheck
UNION
SELECT mrgid,CASE WHEN iso_ter = '' THEN 'iso_ter filled from iso_sov' END note FROM tocheck
UNION
SELECT mrgid,CASE WHEN un_ter = '' THEN 'un_ter filled from un_sov' END note FROM tocheck) a
GROUP BY mrgid) b;
DROP TABLE IF EXISTS checked;
CREATE TEMPORARY TABLE checked AS
SELECT * FROM (
SELECT mrgid,geoname,pol_type,x_1,y_1,
CASE WHEN mrgid_ter = '' THEN mrgid_sov ELSE mrgid_ter END mrgid_ter,
territory,
CASE WHEN iso_ter = '' THEN iso_sov ELSE iso_ter END iso_ter,
CASE WHEN un_ter = '' THEN un_sov ELSE un_ter END un_ter,
mrgid_sov,sovereign,iso_sov,un_sov FROM tocheck) a
LEFT JOIN notes USING(mrgid);
DROP TABLE IF EXISTS test01.eez_attributes_processed;
CREATE TABLE test01.eez_attributes_processed AS
SELECT * FROM checked
UNION
SELECT mrgid,geoname,pol_type,x_1,y_1,mrgid_ter,territory,iso_ter,un_ter,mrgid_sov,sovereign,iso_sov,un_sov,NULL::text FROM eez_attributes_processed WHERE mrgid NOT IN (SELECT mrgid FROM checked)
ORDER BY mrgid;
DROP TABLE IF EXISTS test01.eez_names;
CREATE TABLE test01.eez_names AS
WITH
codes AS (SELECT id,"english short name"::text cname,"alpha-3 code"::text iso3,"alpha-2 code"::text iso2,"numeric" un_m49 FROM test01.iso_codes),
a AS (SELECT mrgid,
STRING_TO_ARRAY(iso_ter,'/') iso_ter,
STRING_TO_ARRAY(iso_sov,'/') iso_sov
FROM test01.eez_attributes_processed),
b AS (SELECT mrgid,t.* FROM a,UNNEST(iso_ter,iso_sov) t(iso_ter,iso_sov)),
c AS (SELECT DISTINCT mrgid,iso_ter,iso_sov FROM b),
ter AS (SELECT DISTINCT mrgid,cname,iso3,iso2,un_m49 FROM c JOIN codes ON iso_ter=iso3),
sov AS (SELECT DISTINCT mrgid,cname,iso3,iso2,un_m49 FROM c JOIN codes ON iso_sov=iso3),
territory AS (
SELECT mrgid,
STRING_AGG(cname,'/') territory,
STRING_AGG(iso3,'/') iso3,
STRING_AGG(iso3,'/') iso2,
STRING_AGG(un_m49::text,'/') un_m49
FROM (SELECT * FROM ter ORDER BY mrgid,iso3) a
GROUP BY mrgid ORDER BY mrgid),
sovereign AS (
SELECT mrgid,
STRING_AGG(cname,'/') sovereign,
STRING_AGG(iso3,'/') sov_iso3,
STRING_AGG(iso3,'/') sov_iso2,
STRING_AGG(un_m49::text,'/') sov_un_m49
FROM (SELECT * FROM sov ORDER BY mrgid,iso3) a
GROUP BY mrgid ORDER BY mrgid)
SELECT * FROM territory NATURAL JOIN sovereign ORDER BY mrgid;
END;
$BODY$;
-----------------------------------------------
--- EXECUTE THE FUNCTION TO GET test01.eez_names
-----------------------------------------------

SELECT * FROM test01.eez_processing();

----------------------------------------------------------------------------
-- EEZ 2019
----------------------------------------------------------------------------
-- GEOMS (cleanup and dissolve) -- execute manual, step by step, and check the results
-----------------------------------------------------------------------------

DROP TABLE IF EXISTS eez_geoms;
CREATE TEMPORARY TABLE eez_geoms AS
SELECT ROW_NUMBER () OVER () fid,mrgid,geom FROM (SELECT mrgid,(ST_DUMP(geom)).* FROM test01.eez_v11 ORDER BY mrgid) a ORDER BY mrgid,path;
DROP TABLE IF EXISTS eez_geoms_check;
CREATE TEMPORARY TABLE eez_geoms_check AS SELECT fid,(ST_IsValidDetail(geom)).*,ST_IsSimple(geom),ST_GeometryType(geom) FROM eez_geoms LIMIT 1;
TRUNCATE TABLE eez_geoms_check RESTART IDENTITY;
INSERT INTO eez_geoms_check(fid) SELECT fid FROM eez_geoms ORDER BY fid;
UPDATE eez_geoms_check SET valid=b.valid,reason=b.reason,location=b.location
FROM (SELECT fid,(ST_IsValidDetail(geom)).* FROM eez_geoms WHERE ST_IsValid(geom) = FALSE) b
WHERE eez_geoms_check.fid=b.fid;

UPDATE eez_geoms_check
SET	st_issimple=b.st_issimple
FROM (SELECT fid,ST_IsSimple(geom) FROM eez_geoms WHERE ST_IsSimple(geom) = FALSE) b
WHERE eez_geoms_check.fid=b.fid;

UPDATE eez_geoms_check
SET st_geometrytype=b.st_geometrytype
FROM (SELECT fid,ST_GeometryType(geom) FROM eez_geoms WHERE ST_GeometryType(geom) != 'ST_Polygon') b
WHERE eez_geoms_check.fid=b.fid;

SELECT * FROM eez_geoms_check WHERE valid IS NOT NULL OR st_issimple IS NOT NULL OR st_geometrytype IS NOT NULL;

CREATE TABLE test01.eez_geoms AS SELECT * FROM eez_geoms ORDER BY fid;
ALTER TABLE test01.eez_geoms ADD PRIMARY KEY(fid);
CREATE INDEX eez_geoms_geom_idx ON test01.eez_geoms USING GIST(geom);

CREATE TABLE test01.eez_single_part AS
SELECT * FROM test01.eez_geoms JOIN test01.eez_names USING(mrgid)
ORDER BY fid;
ALTER TABLE test01.eez_single_part ADD PRIMARY KEY(fid);
CREATE INDEX eez_single_part_geom_idx ON test01.eez_single_part USING GIST(geom);

CREATE TEMPORARY TABLE eez_multipart AS
SELECT DISTINCT territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49,ST_COLLECT(ARRAY_AGG(geom)) geom
FROM test01.eez_single_part
GROUP BY territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49
ORDER BY iso3,sov_iso3;

DROP TABLE IF EXISTS test01.eez_dissolved;
CREATE TABLE test01.eez_dissolved AS
SELECT ROW_NUMBER() OVER () cid,territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49,ST_Union(geom) geom
FROM eez_multipart
GROUP BY territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49
ORDER BY iso3,sov_iso3;
ALTER TABLE test01.eez_dissolved ADD PRIMARY KEY (cid);
CREATE INDEX eez_dissolved_geom_idx ON test01.eez_dissolved USING GIST(geom);

DROP TABLE IF EXISTS test01.eez_dissolved_check;
CREATE TABLE test01.eez_dissolved_check AS
SELECT cid,(ST_IsValidDetail(geom)).* FROM test01.eez_dissolved WHERE ST_IsValid(geom) = FALSE;

DROP TABLE IF EXISTS test01.eez_dissolved_fix;
CREATE TABLE test01.eez_dissolved_fix AS 
SELECT cid,ST_MakeValid(geom) geom FROM test01.eez_dissolved WHERE cid IN (SELECT DISTINCT cid FROM test01.eez_dissolved_check);

DROP TABLE IF EXISTS test01.eez_dissolved_fix_check;
CREATE TABLE test01.eez_dissolved_fix_check AS
SELECT cid,ST_GEOMETRYTYPE(geom) FROM test01.eez_dissolved_fix WHERE st_geometrytype(geom) !='ST_MultiPolygon';

DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump;
CREATE TABLE test01.eez_dissolved_fix_check_dump AS
SELECT cid,(ST_DUMP(geom)).geom FROM test01.eez_dissolved_fix;

DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check;
CREATE TABLE test01.eez_dissolved_fix_check_dump_check AS
SELECT cid,ST_GEOMETRYTYPE(geom) FROM test01.eez_dissolved_fix_check_dump;

DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check_line;
CREATE TABLE test01.eez_dissolved_fix_check_dump_check_line AS
SELECT * FROM test01.eez_dissolved_fix_check_dump WHERE ST_GEOMETRYTYPE(geom)='ST_LineString';

DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check_polygon;
CREATE TABLE test01.eez_dissolved_fix_check_dump_check_polygon AS
SELECT * FROM test01.eez_dissolved_fix_check_dump WHERE ST_GEOMETRYTYPE(geom)='ST_Polygon';

DROP TABLE IF EXISTS fixed_poly;
CREATE TEMPORARY TABLE fixed_poly AS
SELECT cid,ST_MULTI(geom) geom FROM
(SELECT cid,ST_UNION(geom) geom FROM test01.eez_dissolved_fix_check_dump_check_polygon GROUP BY cid ORDER BY cid) a
ORDER BY cid;

CREATE TABLE test01.eez_dissolved_fixed AS
SELECT cid,territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49,geom FROM fixed_poly JOIN 
(SELECT cid,territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49 FROM test01.eez_dissolved WHERE cid IN (SELECT cid FROM test01.eez_dissolved_check)) b USING(cid)
UNION
SELECT cid,territory,iso3,iso2,un_m49,sovereign,sov_iso3,sov_iso2,sov_un_m49,geom FROM test01.eez_dissolved WHERE cid NOT IN (SELECT cid FROM test01.eez_dissolved_check);

TRUNCATE TABLE test01.eez_dissolved RESTART IDENTITY;
INSERT INTO test01.eez_dissolved
SELECT *
FROM test01.eez_dissolved_fixed
ORDER BY iso3,sov_iso3;

-----------------------------------------------------------------------------
-- FINAL TABLE
-----------------------------------------------------------------------------

CREATE TABLE test01.eez_2019
(
    cid bigint NOT NULL,
    territory text,
    iso3 text,
    iso2 text,
    un_m49 text,
    sovereign text,
    sov_iso3 text,
    sov_iso2 text,
    sov_un_m49 text,
    geom geometry(MultiPolygon,4326),
    CONSTRAINT eez_2019_pkey PRIMARY KEY (cid)
);

CREATE INDEX eez_2019_geom_idx ON test01.eez_2019 USING gist(geom);

INSERT INTO test01.eez_2019 SELECT * FROM test01.eez_dissolved ORDER BY iso3,sov_iso3;

--------------------------------------------------------------------------------------
--- KEEP TRACK OF THE NOTES
--------------------------------------------------------------------------------------

DROP TABLE IF EXISTS update_notes;
CREATE TEMPORARY TABLE update_notes AS
WITH
atts AS (SELECT mrgid,iso3,sov_iso3,notes FROM test01.eez_names LEFT JOIN (SELECT mrgid,notes FROM test01.eez_attributes_processed WHERE notes is not null) a USING(mrgid)),
reatts AS (SELECT mrgid,iso3,sov_iso3,REPLACE(notes,'iso_ter filled from iso_sov/un_ter filled from un_sov','territory iso3 and un_m49 info filled from sovereign for mrgid: ') notes
FROM atts  WHERE notes ILIKE '%iso_sov/un_ter%'
UNION
SELECT mrgid,iso3,sov_iso3,REPLACE(notes,'mrgid_sov filled from mrgid_ter','sovereign info filled from territory info for mrgid: ') notes FROM atts WHERE notes ILIKE '%mrgid_sov%'
),
renotes AS (
SELECT iso3,sov_iso3,notes||ARRAY_TO_STRING(ARRAY_AGG(DISTINCT mrgid ORDER BY mrgid),', ') note FROM reatts
GROUP BY iso3,sov_iso3,notes
ORDER BY iso3,sov_iso3,notes)
SELECT cid,note notes FROM test01.eez_2019 NATURAL JOIN renotes;

--------------------------------------------------------------------------------------
-- ADD NOTES TO FINAL TABLE
--------------------------------------------------------------------------------------

ALTER TABLE test01.eez_2019 ADD COLUMN notes text;
UPDATE test01.eez_2019
SET notes=b.notes
FROM (select cid,notes FROM update_notes) b
WHERE eez_2019.cid=b.cid;


DROP TABLE IF EXISTS test01.eez_attributes_processed;
DROP TABLE IF EXISTS test01.eez_dissolved;
DROP TABLE IF EXISTS test01.eez_dissolved_check;
DROP TABLE IF EXISTS test01.eez_dissolved_fix;
DROP TABLE IF EXISTS test01.eez_dissolved_fix_check;
DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump;
DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check;
DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check_line;
DROP TABLE IF EXISTS test01.eez_dissolved_fix_check_dump_check_polygon;
DROP TABLE IF EXISTS test01.eez_dissolved_fixed;
DROP TABLE IF EXISTS test01.eez_single_part;
DROP TABLE IF EXISTS test01.eez_geoms;





