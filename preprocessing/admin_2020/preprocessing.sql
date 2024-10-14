-----------------------------------------------------
--cntr_geom valid
DROP TABLE IF EXISTS gisco_2020.cntr_geom;CREATE TABLE gisco_2020.cntr_geom AS
SELECT cntr_id::text,geom
FROM gisco_2020.cntr_rg_100k_2020
ORDER BY cntr_id::text;

UPDATE gisco_2020.cntr_geom SET geom=ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;

-----------------------------------------------------
--eez_valid
DROP TABLE IF EXISTS gisco_2020.eez_geom;CREATE TABLE gisco_2020.eez_geom AS
SELECT eez_id::text,svrg_flag::text,description::text,geom,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM gisco_2020.eez_01m_2020 ORDER BY eez_id;
UPDATE gisco_2020.eez_geom SET geom=ST_MAKEVALID(geom) WHERE valid is false;

-----------------------------------------------------
--coastline_valid
DROP TABLE IF EXISTS gisco_2020.coas_geom;CREATE TABLE gisco_2020.coas_geom AS
SELECT coas_pl_id::integer,geom FROM gisco_2020.coas_rg_100k_2020 ORDER BY coas_pl_id::integer;
UPDATE gisco_2020.coas_geom SET geom=ST_MAKEVALID(geom) WHERE ST_MAKEVALID(geom) IS FALSE;

-----------------------------------------------------
--atts
DROP TABLE IF EXISTS gisco_2020.cntr_at;CREATE TABLE gisco_2020.cntr_at AS
SELECT cntr_id::text,name_engl::text,poli_org_code::text,cntr_code_stat::text,name_gaul::text,iso3_code::text,svrg_un::text,eu_stat::boolean
FROM gisco_2020.cntr_at_2020
ORDER BY cntr_id;
-------------------------------------------------------
--land
DROP TABLE IF EXISTS land;CREATE TEMPORARY TABLE land AS
SELECT cntr_id,geom
FROM gisco_2020.cntr_geom ORDER BY cntr_id;

DROP TABLE IF EXISTS land_attributes;CREATE TEMPORARY TABLE land_attributes AS
SELECT *,'gisco'::text source FROM land
LEFT JOIN gisco_2020.cntr_at USING(cntr_id)
ORDER BY cntr_id;
UPDATE land_attributes SET name_gaul=NULL WHERE name_engl=name_gaul;

DROP TABLE IF EXISTS gisco_2020.land;CREATE TABLE gisco_2020.land AS
SELECT ROW_NUMBER() OVER() fidl,* FROM (SELECT * FROM land_attributes ORDER BY cntr_id) a;

-------------------------------------------------------
DROP TABLE IF EXISTS marine;CREATE TEMPORARY TABLE marine AS
SELECT eez_id,svrg_flag,description,geom
FROM gisco_2020.eez_geom
ORDER BY eez_id,svrg_flag;

DROP TABLE IF EXISTS marine_attributes;CREATE TEMPORARY TABLE marine_attributes AS
SELECT * FROM marine
LEFT JOIN gisco_2020.cntr_at ON eez_id=cntr_id
ORDER BY eez_id,cntr_id;

DROP TABLE IF EXISTS marine_multiple_attributes;CREATE TEMPORARY TABLE marine_multiple_attributes AS
WITH
a AS (SELECT eez_id,COALESCE(svrg_flag,'N')svrg_flag,description,geom FROM marine_attributes WHERE cntr_id IS NULL),
b AS (SELECT eez_id,svrg_flag,description,o.cntr_id,o.n FROM a,UNNEST(STRING_TO_ARRAY(eez_id,'_')) WITH ORDINALITY o(cntr_id,n)),
c AS (SELECT * FROM b LEFT JOIN gisco_2020.cntr_at USING(cntr_id)),
d AS (SELECT eez_id,svrg_flag,description,
ARRAY_TO_STRING(ARRAY_AGG(cntr_id ORDER BY n),'_') cntr_id,
ARRAY_TO_STRING(ARRAY_AGG(iso3_code ORDER BY n),'_') iso3_code,
ARRAY_TO_STRING(ARRAY_AGG(cntr_code_stat ORDER BY n),'_') cntr_code_stat,
ARRAY_TO_STRING(ARRAY_AGG(name_engl ORDER BY n),'_') name_engl,
ARRAY_TO_STRING(ARRAY_AGG(name_gaul ORDER BY n),'_') name_gaul,
ARRAY_TO_STRING(ARRAY_AGG(poli_org_code ORDER BY n),'_') poli_org_code,
ARRAY_TO_STRING(ARRAY_AGG(svrg_un ORDER BY n),'_') svrg_un
FROM c GROUP BY eez_id,svrg_flag,description)
SELECT * FROM a JOIN d USING (eez_id,svrg_flag,description)
ORDER BY eez_id,svrg_flag,description,cntr_id;
UPDATE marine_multiple_attributes SET svrg_flag = NULL WHERE svrg_flag = 'N';

DROP TABLE IF EXISTS marine_all_attributes;CREATE TEMPORARY TABLE marine_all_attributes AS
SELECT *,'eez' source FROM
(SELECT eez_id,svrg_flag,description,geom,cntr_id,iso3_code,cntr_code_stat,name_engl,name_gaul,poli_org_code,svrg_un FROM marine_attributes WHERE cntr_id IS NOT NULL
UNION
SELECT * FROM marine_multiple_attributes) a
ORDER BY eez_id,cntr_id,svrg_flag,description;
UPDATE marine_all_attributes SET name_gaul=NULL WHERE name_engl=name_gaul;

DROP TABLE IF EXISTS gisco_2020.marine;CREATE TABLE gisco_2020.marine AS
SELECT ROW_NUMBER() OVER() fidm,*,'eez' source FROM
(SELECT cntr_id,iso3_code,cntr_code_stat,name_engl,name_gaul,poli_org_code,svrg_un,svrg_flag,description,geom
FROM marine_all_attributes ORDER BY cntr_id) a;

DROP TABLE IF EXISTS land_marine;CREATE TEMPORARY TABLE land_marine AS
SELECT ROW_NUMBER() OVER () tid,*,((ST_AREA(geom::geography))/1000000) sqkm FROM (
SELECT fidl fid,cntr_id,name_engl,iso3_code,cntr_code_stat,name_gaul,poli_org_code,svrg_un,NULL::TEXT svrg_flag,NULL::text description,source,geom FROM gisco_2020.land
UNION
SELECT fidm fid,cntr_id,name_engl,iso3_code,cntr_code_stat,name_gaul,poli_org_code,svrg_un,svrg_flag,description,source,geom FROM gisco_2020.marine
) a
ORDER BY cntr_id,source;

DROP TABLE IF EXISTS atts_tmp1;CREATE TEMPORARY TABLE atts_tmp1 AS
WITH
a AS (
SELECT DISTINCT
tid,fid,
REPLACE(cntr_id,'_','|') iso2,
REPLACE(iso3_code,'_','|') iso3,
REPLACE(name_engl,'_','|') name_eng,
REPLACE(svrg_un,'_','|') svrg_un,
CASE svrg_flag
	WHEN  'D' THEN 'disputed'
	WHEN  'J' THEN 'joint-managed'
END svrg_flag,
REPLACE(cntr_code_stat,'_','|') cntr_code_stat,
REPLACE(poli_org_code,'_','|') poli_org_code,
REPLACE(name_gaul,'_','|') name_gaul,
description,source
FROM land_marine),
b AS (
SELECT tid,fid,iso2,iso3,name_eng,
CASE
	WHEN svrg_un IS NULL AND svrg_flag IS NULL THEN NULL
	WHEN svrg_un IS NOT NULL AND svrg_flag IS NULL THEN svrg_un
	WHEN svrg_un IS NOT NULL AND svrg_flag IS NOT NULL THEN svrg_un||'; '||svrg_flag
	WHEN svrg_un IS NULL AND svrg_flag IS NOT NULL THEN svrg_flag
END status,
cntr_code_stat,name_gaul,poli_org_code,description,source
FROM a)
SELECT * FROM b ORDER BY iso2,source;

DROP TABLE IF EXISTS atts_tmp2;CREATE TEMPORARY TABLE atts_tmp2 AS
WITH
a AS (SELECT ROW_NUMBER() OVER () country_id,* FROM (SELECT DISTINCT iso2,iso3,name_eng,status FROM atts_tmp1 ORDER BY iso2)a1),
b AS (SELECT ROW_NUMBER() OVER () country_pid,* FROM (SELECT DISTINCT iso2,iso3,name_eng,status,source FROM atts_tmp1 ORDER BY iso2,source)b1),
c AS (SELECT * FROM b NATURAL JOIN a)
SELECT tid,country_id,country_pid,iso2,iso3,name_eng,status,source,cntr_code_stat,name_gaul,poli_org_code,description
FROM c NATURAL JOIN atts_tmp1
ORDER BY tid,country_id,country_pid;

DROP TABLE IF EXISTS gisco_2020.land_marine;CREATE TABLE  gisco_2020.land_marine AS
SELECT a.*,b.geom,b.sqkm FROM atts_tmp2 a JOIN land_marine b USING(tid) ORDER BY tid;
DROP TABLE IF EXISTS gisco_2020.land;
DROP TABLE IF EXISTS gisco_2020.marine;

-----------------------------------------------------------------------------------

DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020;CREATE TABLE  gisco_2020.gisco_admin_2020 AS
SELECT country_id,country_pid,iso2,iso3,name_eng,status,source,cntr_code_stat,name_gaul,poli_org_code,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT description ORDER BY description),NULL) descriptions,
ARRAY_AGG(tid ORDER BY tid) tids,
ST_MULTI(ST_COLLECT(geom)) geom,SUM(sqkm) sqkm
FROM gisco_2020.land_marine
GROUP BY country_id,country_pid,iso2,iso3,name_eng,status,source,cntr_code_stat,name_gaul,poli_org_code
ORDER BY country_id,country_pid;

DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020_atts;CREATE TABLE gisco_2020.gisco_admin_2020_atts AS
SELECT country_id,country_pid,iso2,iso3,name_eng,status,source,CASE source WHEN 'gisco' THEN FALSE WHEN 'eez' THEN TRUE END is_marine,cntr_code_stat,name_gaul,poli_org_code,ARRAY_TO_STRING(descriptions,',') descriptions,sqkm
FROM gisco_2020.gisco_admin_2020;
--------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020_lmd;CREATE TABLE  gisco_2020.gisco_admin_2020_lmd AS
SELECT country_id,
ARRAY_AGG(DISTINCT country_pid ORDER BY country_pid) country_pids,
iso2,iso3,name_eng,status,
ARRAY_AGG(DISTINCT source ORDER BY source) sources,
cntr_code_stat,name_gaul,poli_org_code,
ARRAY_REMOVE(ARRAY_AGG(DISTINCT description ORDER BY description),NULL) descriptions,
ARRAY_AGG(tid ORDER BY tid) tids,
ST_MULTI(ST_COLLECT(geom)) geom,
SUM(sqkm) sqkm
FROM gisco_2020.land_marine
GROUP BY country_id,iso2,iso3,name_eng,status,cntr_code_stat,name_gaul,poli_org_code
ORDER BY country_id;

DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020_lmd_atts;CREATE TABLE gisco_2020.gisco_admin_2020_lmd_atts AS
SELECT country_id,country_pids,iso2,iso3,name_eng,status,cntr_code_stat,name_gaul,poli_org_code,ARRAY_TO_STRING(descriptions,',') descriptions,sqkm
FROM gisco_2020.gisco_admin_2020_lmd;

-----------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS inputs;CREATE TEMPORARY TABLE inputs AS
SELECT country_pid,country_id,iso2,iso3,name_eng,source,CASE source WHEN 'gisco' THEN FALSE WHEN 'eez' THEN TRUE END is_marine,(ST_DUMP(geom)).*
FROM gisco_2020.gisco_admin_2020 ORDER BY country_id,country_pid;

DROP TABLE IF EXISTS input_land;CREATE TEMPORARY TABLE input_land AS
SELECT * FROM inputs WHERE is_marine IS FALSE ORDER BY country_id,country_pid;

DROP TABLE IF EXISTS input_marine;CREATE TEMPORARY TABLE input_marine AS
SELECT * FROM inputs WHERE is_marine IS TRUE ORDER BY country_id,country_pid;

DROP TABLE IF EXISTS gisco_2020.input_land;CREATE TABLE gisco_2020.input_land AS SELECT * FROM input_land;

DROP TABLE IF EXISTS gisco_2020.input_marine;CREATE TABLE gisco_2020.input_marine AS SELECT * FROM input_marine;

DROP TABLE IF EXISTS gisco_2020.input_abnj;CREATE TABLE gisco_2020.input_abnj AS SELECT * FROM gisco_2020.abnj_poly;

DROP TABLE IF EXISTS gisco_2020.input_grid;CREATE TABLE gisco_2020.input_grid AS SELECT qid,1 id,geom FROM cep.grid_vector ORDER BY qid;
--------------------------------------------------------------------------------
CREATE TEMPORARY TABLE input_land AS SELECT country_pid,ST_TRANSFORM(geom,4326) geom FROM gisco_2020.input_land ORDER BY country_id,country_pid,path;
INSERT INTO gisco_2020_flat.a_input_land(fid,geom) SELECT * FROM input_land;

CREATE TEMPORARY TABLE input_marine AS SELECT country_pid,ST_TRANSFORM(geom,4326) geom FROM gisco_2020.input_marine ORDER BY country_id,country_pid,path;
INSERT INTO gisco_2020_flat.a_input_marine(fid,geom) SELECT * FROM input_marine;
