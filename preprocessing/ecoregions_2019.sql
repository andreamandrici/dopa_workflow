------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- MAIN VERSION (dissolved AND single parts)
------------------------------------------------------------------------------------

--CREATE A TABLE FROM IMPORTED ONE
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved AS
SELECT
objectid,
geom,
eco_source,
eco_id
FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_import
ORDER BY objectid;
ALTER TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved ADD PRIMARY KEY(objectid);
CREATE INDEX teow_meow_ppow_eeow_dissolved_geom_idx ON habitats_and_biotopes.teow_meow_ppow_eeow_dissolved USING GIST(geom);

--FIX MULTIPOLYGONS AS POLYGONS (IS JUST BEAUTIFYING: THEY ARE ACTUALY ALREADY SINGLEPART POLYGONS, BUT HAVE BEEN IMPORTED AS MULTI; CHANGES THE DATATYPE, BUT NOT THE NUMBER OF OBJECTS...)
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart AS
SELECT
objectid,
(ST_DUMP(geom)).*,
eco_source,
eco_id
FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved
ORDER BY objectid;
--(... IN FACT I CAN USE ORIGINAL OBJECTID AS PRIMARY KEY)
ALTER TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart ADD PRIMARY KEY(objectid);
CREATE INDEX teow_meow_ppow_eeow_dissolved_singlepart_geom_idx ON habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart USING GIST(geom);

--GEOMETRY CHECK (VALIDITY AND SINGULARITY) - WRITES EXTERNAL TABLE "_CHECK"
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_check AS
SELECT objectid,(ST_IsValidDetail(geom)).*,ST_GeometryType(geom)
FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart WHERE ST_IsValid(geom) = FALSE OR ST_GeometryType(geom) != 'ST_Polygon';
--SELECT 42
--Query returned successfully in 1 min.

--FIX GEOMETRIES -- WRITES EXTERNAL TABLE "_FIX", POSITIVE FILTERING ON "_CHECK"
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix AS
SELECT
objectid,
ST_MakeValid(geom) geom,
eco_source,
eco_id
FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart
WHERE objectid IN (SELECT DISTINCT objectid FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_check);
--SELECT 42
--Query returned successfully in 17 secs 205 msec.

--GEOMETRY CHECK (VALIDITY AND SINGULARITY) ON EXTERNAL TABLE "_FIX"
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix_check AS
SELECT objectid,(ST_IsValidDetail(geom)).*,ST_GeometryType(geom)
FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix;
--SELECT 42
--Query returned successfully in 2 secs 573 msec.

--GEOMETRY UNION FROM "_FIX"+ORIGINALS (NEGATIVE FILTERED FROM "_FIX") 
CREATE TABLE habitats_and_biotopes.teow_meow_ppow_eeow AS
SELECT objectid,geom,eco_source,eco_id FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix
UNION
SELECT objectid,geom,eco_source,eco_id FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart
WHERE objectid NOT IN (SELECT DISTINCT objectid FROM habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix)
ORDER BY objectid;
--SELECT 405496
--Query returned successfully in 12 secs 762 msec.
ALTER TABLE habitats_and_biotopes.teow_meow_ppow_eeow ADD PRIMARY KEY(objectid);
CREATE INDEX teow_meow_ppow_eeow_geom_idx ON habitats_and_biotopes.teow_meow_ppow_eeow_dissolved USING GIST(geom);
--ADD SQKM
ALTER TABLE habitats_and_biotopes.teow_meow_ppow_eeow ADD COLUMN sqkm double precision;
UPDATE habitats_and_biotopes.teow_meow_ppow_eeow
SET sqkm = ST_AREA(geom::geography)/1000000
--UPDATE 405496
--Query returned successfully in 32 secs 575 msec.

------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- MAIN VERSION (dissolved AND single parts) -- FINAL TABLES
------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- SINGLE PART VERSION (... wrong naming...)
------------------------------------------------------------------------------------
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_multi;
CREATE TABLE habitats_and_biotopes.ecoregions_2019_multi
(
    objectid integer PRIMARY KEY,
	first_level_code integer,
    geom geometry(Polygon,4326),
    first_level text,
    second_level_code integer,
    second_level text,
    third_level_code integer,
    third_level text,
    source text,
    sqkm double precision
);
CREATE INDEX ecoregions_2019_multi_geom_idx ON habitats_and_biotopes.ecoregions_2019_multi USING gist(geom);
--POPULATE IT
--GET ATTRIBUTES FROM PREVIOUS VERSION
WITH
a AS (
	SELECT first_level_code::integer,first_level::text,second_level_code::integer,second_level::text,third_level_code::integer,third_level::text,source::text FROM habitats_and_biotopes.ecoregions
	UNION
	SELECT 100001::integer first_level_code,'unassigned_land'::text first_level,NULL::integer,NULL::text,NULL::integer,NULL::text,'eeow'::text source
),
b AS (SELECT objectid::integer,eco_id::integer first_level_code,geom,sqkm FROM habitats_and_biotopes.teow_meow_ppow_eeow)
INSERT INTO habitats_and_biotopes.ecoregions_2019_multi
SELECT objectid,first_level_code,geom,first_level,second_level_code,second_level,third_level_code,third_level,source,sqkm FROM a JOIN b USING(first_level_code) ORDER BY objectid;
------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- MULTIPART VERSION
------------------------------------------------------------------------------------

DROP TABLE habitats_and_biotopes.ecoregions_2019;
CREATE TABLE habitats_and_biotopes.ecoregions_2019
(
    first_level_code integer NOT NULL,
    geom geometry(MultiPolygon,4326),
    first_level text,
    second_level_code integer,
    second_level text,
    third_level_code integer,
    third_level text,
    source text,
    sqkm double precision,
    CONSTRAINT ecoregions_2019_pkey PRIMARY KEY (first_level_code)
);
CREATE INDEX ecoregions_2019_geom_idx ON habitats_and_biotopes.ecoregions_2019 USING gist(geom);
INSERT INTO habitats_and_biotopes.ecoregions_2019
SELECT
first_level_code,ST_Collect(ARRAY_AGG(geom)) geom,first_level,second_level_code,second_level,third_level_code,third_level,source,SUM(sqkm) sqkm
FROM habitats_and_biotopes.ecoregions_2019_multi
GROUP BY first_level_code,first_level,second_level_code,second_level,third_level_code,third_level,source
ORDER BY source,first_level_code;

DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow;
DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow_dissolved;
DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart;
DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_check;
DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix;
DROP TABLE IF EXISTS habitats_and_biotopes.teow_meow_ppow_eeow_dissolved_singlepart_geometry_fix_check;

------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- SINGLE PART VERSION (patch for the wrong naming)
------------------------------------------------------------------------------------
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_single_part;
CREATE TABLE habitats_and_biotopes.ecoregions_2019_single_part
(
    objectid integer PRIMARY KEY,
	first_level_code integer,
    geom geometry(Polygon,4326),
    first_level text,
    second_level_code integer,
    second_level text,
    third_level_code integer,
    third_level text,
    source text,
    sqkm double precision
);
CREATE INDEX ecoregions_2019_single_part_geom_idx ON habitats_and_biotopes.ecoregions_2019_single_part USING gist(geom);
INSERT INTO habitats_and_biotopes.ecoregions_2019_single_part
SELECT * FROM habitats_and_biotopes.ecoregions_2019_multi ORDER BY objectid;

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_multi;

------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- RAW VERSION (non dissolved, with source)
------------------------------------------------------------------------------------

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw AS
SELECT objectid,geom,eco_source,eco_id,notes::text notes FROM habitats_and_biotopes."ecoregions teow_meow_ppow_eeow_final01"
ORDER BY objectid;
ALTER TABLE habitats_and_biotopes.ecoregions_2019_raw ADD PRIMARY KEY(objectid);
CREATE INDEX ecoregions_2019_raw_geom_idx ON habitats_and_biotopes.ecoregions_2019_raw USING GIST(geom);

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw_single_part AS
SELECT
objectid,
(ST_DUMP(geom)).*,
eco_source,
eco_id,
notes
FROM habitats_and_biotopes.ecoregions_2019_raw
ORDER BY objectid;

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw_single_parts AS
SELECT
ROW_NUMBER () OVER (ORDER BY objectid,path) fid,
geom,
eco_source,
eco_id,
notes
FROM habitats_and_biotopes.ecoregions_2019_raw_single_part
ORDER BY objectid,path;
ALTER TABLE habitats_and_biotopes.ecoregions_2019_raw_single_parts ADD PRIMARY KEY(fid);
CREATE INDEX ecoregions_2019_raw_single_parts_geom_idx ON habitats_and_biotopes.ecoregions_2019_raw_single_parts USING GIST(geom);

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_check AS
SELECT fid,(ST_IsValidDetail(geom)).*,ST_GeometryType(geom)
FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts WHERE ST_IsValid(geom) = FALSE OR ST_GeometryType(geom) != 'ST_Polygon';

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix AS
SELECT
fid,
ST_MakeValid(geom) geom,
eco_source,
eco_id,
notes
FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts
WHERE fid IN (SELECT DISTINCT fid FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_check);

CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix_check AS
SELECT fid,(ST_IsValidDetail(geom)).*,ST_GeometryType(geom)
FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix;

------------------------------------------------------------------------------------
-- ECOREGIONS 2019 -- RAW VERSION - FINAL TABLE
------------------------------------------------------------------------------------

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw;
CREATE TABLE habitats_and_biotopes.ecoregions_2019_raw AS
SELECT fid objectid,geom,eco_source,eco_id,notes FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix
UNION
SELECT fid objectid,geom,eco_source,eco_id,notes FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts
WHERE fid NOT IN (SELECT DISTINCT fid FROM habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix)
ORDER BY objectid;
--SELECT 610141
--Query returned successfully in 13 secs 562 msec.
ALTER TABLE habitats_and_biotopes.ecoregions_2019_raw ADD PRIMARY KEY(objectid);
CREATE INDEX ecoregions_2019_raw_geom_idx ON habitats_and_biotopes.ecoregions_2019_raw USING GIST(geom);
--ADD SQKM
ALTER TABLE habitats_and_biotopes.ecoregions_2019_raw ADD COLUMN sqkm double precision;
UPDATE habitats_and_biotopes.ecoregions_2019_raw
SET sqkm = ST_AREA(geom::geography)/1000000;

DROP TABLE IF EXISTS habitats_and_biotopes."ecoregions teow_meow_ppow_eeow_final01";
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw_single_part;
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw_single_parts;
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_check;
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix;
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2019_raw_single_parts_geometry_fix_check;

------------------------------------------------------------------------------------
-- STATISTICS
------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ecoregions_2019_raw_stats_eco_id;
CREATE TEMPORARY TABLE ecoregions_2019_raw_stats_eco_id AS
SELECT eco_source,eco_id,notes,SUM(sqkm) sqkm FROM habitats_and_biotopes.ecoregions_2019_raw GROUP BY eco_source,eco_id,notes ORDER BY eco_source,notes,eco_id;

DROP TABLE IF EXISTS ecoregions_2019_raw_stats_eco_source;
CREATE TEMPORARY TABLE ecoregions_2019_raw_stats_eco_source AS
SELECT eco_source,notes,SUM(sqkm) sqkm FROM habitats_and_biotopes.ecoregions_2019_raw GROUP BY eco_source,notes ORDER BY eco_source,notes;

--source sqkm diff from 2017 version
DROP TABLE IF EXISTS source_diff_2017_2019;
CREATE TEMPORARY TABLE source_diff_2017_2019 AS
WITH
old_eco AS (SELECT source,SUM(sqkm) eco_2017_sqkm FROM habitats_and_biotopes.ecoregions GROUP BY source),
new_eco AS (SELECT source,SUM(sqkm) eco_2019_sqkm FROM habitats_and_biotopes.ecoregions_2019 GROUP BY source),
change AS (SELECT * FROM old_eco RIGHT JOIN new_eco USING(source))
SELECT *,eco_2019_sqkm/eco_2017_sqkm*100 perc_change FROM change

--source change for 2019 version
DROP TABLE IF EXISTS source_change_2019;
CREATE TEMPORARY TABLE source_change_2019 AS
SELECT eco_source,SUM(sqkm) sqkm,'land not assigned to ecoregions; previously marine or pelagic' notes
FROM ecoregions_2019_raw_stats_eco_source WHERE eco_source='eeow' GROUP BY eco_source
UNION
SELECT eco_source,SUM(sqkm) sqkm,'marine/pelagic ecoregions overlapping terrestrial ecoregions; previously terrestrial ecoregions' notes
FROM ecoregions_2019_raw_stats_eco_source WHERE eco_source IN ('meow','ppow') AND notes ILIKE 'assigned%' GROUP BY eco_source
UNION
SELECT eco_source,SUM(sqkm) sqkm,'new land assigned to adjoint terrestrial ecoregions; previously holes in the topology' notes
FROM ecoregions_2019_raw_stats_eco_source WHERE eco_source IN ('teow') AND notes ILIKE '%assigned%' GROUP BY eco_source
UNION
SELECT eco_source,SUM(sqkm) sqkm,'unchanged' notes
FROM ecoregions_2019_raw_stats_eco_source WHERE eco_source IN ('meow','ppow','teow') AND notes ILIKE 'originally%' GROUP BY eco_source
ORDER BY eco_source,notes

--source,eco_id sqkm diff from 2017 version
DROP TABLE IF EXISTS eco_diff_2017_2019;
CREATE TEMPORARY TABLE eco_diff_2017_2019 AS
WITH
old_eco AS (SELECT source,first_level_code eco_id,SUM(sqkm) eco_2017_sqkm FROM habitats_and_biotopes.ecoregions GROUP BY source,eco_id),
new_eco AS (SELECT source,first_level_code eco_id,SUM(sqkm) eco_2019_sqkm FROM habitats_and_biotopes.ecoregions_2019 GROUP BY source,eco_id),
change AS (SELECT * FROM old_eco RIGHT JOIN new_eco USING(source,eco_id))
SELECT *,eco_2019_sqkm/eco_2017_sqkm*100 perc_change FROM change

--source change for 2019 version
DROP TABLE IF EXISTS eco_change_2019;
CREATE TEMPORARY TABLE eco_change_2019 AS
SELECT eco_source,eco_id,SUM(sqkm) sqkm,'land not assigned to ecoregions; previously marine or pelagic' notes
FROM ecoregions_2019_raw_stats_eco_id WHERE eco_source='eeow' GROUP BY eco_source,eco_id
UNION
SELECT eco_source,eco_id,SUM(sqkm) sqkm,'marine/pelagic ecoregions overlapping terrestrial ecoregions; previously terrestrial ecoregions' notes
FROM ecoregions_2019_raw_stats_eco_id WHERE eco_source IN ('meow','ppow') AND notes ILIKE 'assigned%' GROUP BY eco_source,eco_id
UNION
SELECT eco_source,eco_id,SUM(sqkm) sqkm,'new land assigned to adjoint terrestrial ecoregions; previously holes in the topology' notes
FROM ecoregions_2019_raw_stats_eco_id WHERE eco_source IN ('teow') AND notes ILIKE '%assigned%' GROUP BY eco_source,eco_id
UNION
SELECT eco_source,eco_id,SUM(sqkm) sqkm,'unchanged' notes
FROM ecoregions_2019_raw_stats_eco_id WHERE eco_source IN ('meow','ppow','teow') AND notes ILIKE 'originally%' GROUP BY eco_source,eco_id
ORDER BY eco_source,notes

SELECT * FROM source_diff_2017_2019
SELECT * FROM source_change_2019
SELECT * FROM eco_diff_2017_2019
SELECT * FROM eco_change_2019



