DROP TABLE IF EXISTS gisco.un_codes;CREATE TABLE gisco.un_codes AS
SELECT "m49 code"::integer un_m49,"iso-alpha2 code"::text iso2,"iso-alpha3 code"::text iso3,"country or area"::text country_name
FROM gisco.unsd_methodology
ORDER BY un_m49;
-- DROP TABLE IF EXISTS gisco.attributes;CREATE TABLE gisco.attributes AS
-- SELECT DISTINCT
-- cntr_id::text,
-- iso3_code::text,
-- cntr_code_stat::text,
-- country_uri::text,
-- name_engl::text,
-- name_gaul::text,
-- poli_org_code::text,
-- svrg_un::text
-- FROM gisco.gisco_cntr_at_2024 ORDER BY cntr_id;

-----------------------------------------------------
-- DROP TABLE IF EXISTS gisco.cntr_geom;
-- CREATE TABLE gisco.cntr_geom AS
-- SELECT cntr_id::text,country_uri::text,ST_Force2D(geom) geom,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
-- FROM gisco.gisco_cntr_01m_2024
-- ORDER BY cntr_id;

-- UPDATE gisco.cntr_geom
-- SET geom=ST_MAKEVALID(geom) WHERE valid is false;

--------------------------------------------

-- DROP TABLE IF EXISTS gisco.eez_geom;
-- CREATE TABLE gisco.eez_geom AS
-- SELECT
-- eez_id::text,svrg_flag::text,description::text,geom,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
-- FROM gisco.eez_01m_2020 ORDER BY eez_id;

-- UPDATE gisco.eez_geom
-- SET geom=ST_MAKEVALID(geom) WHERE valid is false;

----------------------------------------------------------------------
DROP TABLE IF EXISTS land;CREATE TEMPORARY TABLE land AS
SELECT cntr_id,country_uri,geom
FROM gisco.cntr_geom ORDER BY cntr_id;

DROP TABLE IF EXISTS marine;CREATE TEMPORARY TABLE marine AS
SELECT eez_id,svrg_flag,description,ST_MULTI(ST_COLLECT(geom)) geom
FROM gisco.eez_geom
GROUP BY eez_id,svrg_flag,description
ORDER BY eez_id,svrg_flag;

DROP TABLE IF EXISTS gisco.land_attributes;CREATE TABLE gisco.land_attributes AS
SELECT *,'gisco'::text source FROM land
LEFT JOIN gisco.attributes USING(cntr_id,country_uri)
ORDER BY cntr_id;
UPDATE gisco.land_attributes SET name_gaul=NULL WHERE name_engl=name_gaul;
SELECT * FROM gisco.land_attributes;

DROP TABLE IF EXISTS marine_attributes;CREATE TEMPORARY TABLE marine_attributes AS
SELECT * FROM marine
LEFT JOIN gisco.attributes ON eez_id=cntr_id
ORDER BY eez_id,cntr_id;

DROP TABLE IF EXISTS marine_multiple_attributes;CREATE TEMPORARY TABLE marine_multiple_attributes AS
WITH
a AS (SELECT eez_id,COALESCE(svrg_flag,'N')svrg_flag,description,geom FROM marine_attributes WHERE cntr_id IS NULL),
b AS (SELECT eez_id,svrg_flag,description,o.cntr_id,o.n FROM a,UNNEST(STRING_TO_ARRAY(eez_id,'_')) WITH ORDINALITY o(cntr_id,n)),
c AS (SELECT * FROM b LEFT JOIN gisco.attributes USING(cntr_id)),
d AS (SELECT eez_id,svrg_flag,description,
ARRAY_TO_STRING(ARRAY_AGG(cntr_id ORDER BY n),'_') cntr_id,
ARRAY_TO_STRING(ARRAY_AGG(iso3_code ORDER BY n),'_') iso3_code,
ARRAY_TO_STRING(ARRAY_AGG(cntr_code_stat ORDER BY n),'_') cntr_code_stat,
ARRAY_TO_STRING(ARRAY_AGG(country_uri ORDER BY n),'_') country_uri,
ARRAY_TO_STRING(ARRAY_AGG(name_engl ORDER BY n),'_') name_engl,
ARRAY_TO_STRING(ARRAY_AGG(name_gaul ORDER BY n),'_') name_gaul,
ARRAY_TO_STRING(ARRAY_AGG(poli_org_code ORDER BY n),'_') poli_org_code,
ARRAY_TO_STRING(ARRAY_AGG(svrg_un ORDER BY n),'_') svrg_un
FROM c GROUP BY eez_id,svrg_flag,description)
SELECT * FROM a JOIN d USING (eez_id,svrg_flag,description)
ORDER BY eez_id,svrg_flag,description,cntr_id;
UPDATE marine_multiple_attributes SET svrg_flag = NULL WHERE svrg_flag = 'N';

DROP TABLE IF EXISTS gisco.marine_attributes;CREATE TABLE gisco.marine_attributes AS
SELECT *,'eez' source FROM
(SELECT * FROM marine_attributes WHERE cntr_id IS NOT NULL
UNION
SELECT * FROM marine_multiple_attributes) a
ORDER BY eez_id,cntr_id,svrg_flag,description;
UPDATE gisco.marine_attributes SET name_gaul=NULL WHERE name_engl=name_gaul;
SELECT * FROM gisco.marine_attributes WHERE name_engl!=name_gaul;

--DROP TABLE IF EXISTS gisco.land_marine_attributes;CREATE TABLE gisco.land_marine_attributes AS

DROP TABLE IF EXISTS gisco.input_land;CREATE TABLE gisco.input_land AS
SELECT ROW_NUMBER() OVER() fidl,* FROM
(SELECT * FROM gisco.land_attributes ORDER BY cntr_id) a;

DROP TABLE IF EXISTS gisco.input_marine;CREATE TABLE gisco.input_marine AS
SELECT ROW_NUMBER() OVER() fidm,* FROM
(
SELECT
cntr_id,
iso3_code,
cntr_code_stat,
country_uri,
name_engl,
name_gaul,
poli_org_code,
svrg_un,
svrg_flag,
description,
geom FROM gisco.marine_attributes
ORDER BY cntr_id) a;

UPDATE gisco.abnj_single_poly SET description='small abnj',fid=3 WHERE sqm > 0 AND sqm <= 900;
UPDATE gisco.abnj_single_poly SET description='med abnj',fid=2 WHERE sqm > 900;
UPDATE gisco.abnj_single_poly SET description='big abnj',fid=1 WHERE sqm < 0 OR sqm > 3431859087.0010667;

DROP TABLE IF EXISTS gisco.input_abnj;CREATE TABLE gisco.input_abnj AS
SELECT fid fida,geom,description,sqm FROM gisco.abnj_single_poly ORDER BY fida,sqm;
