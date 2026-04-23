-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- COUNTRY LAND
-----------------------------------------------------------------------------------------------
-- GEOM
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26."CNTR_RG_01M_2024_4326";

DROP TABLE IF EXISTS gisco_26.country_land_geom;CREATE TABLE gisco_26.country_land_geom AS
SElECT
fid,
geom,
cntr_id::text,
iso3_code::text,
--cntr_name,
name_engl::text,
--name_fren,
svrg_un::text,
--capt,
eu_stat::bool,
efta_stat::bool,
cc_stat::bool--,name_germ
FROM gisco_26."CNTR_RG_01M_2024_4326" ORdER BY cntr_id;
ALTER TABLE gisco_26.country_land_geom ADD PRImARY KEY(fid);
CREATE INDEX ON gisco_26.country_land_geom USING GIST(geom);
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26.country_land_geom;

-----------------------------------------------------------------------------------------------
-- ATTS
DROP TABLE IF EXISTS gisco_26.country_land_atts;CREATE TABLE gisco_26.country_land_atts AS
WITH
b AS (
SELEcT
cntr_id::text,
name_engl::text,
iso3_code::text,
svrg_un::text,
cntr_code_stat::text,
eu_stat::bool,
efta_stat::bool,
cc_stat::bool,
country_uri::text
FROM gisco_26."CNTR_AT_2024"
WHERE cntr_id IN (SELECT DISTIncT cntr_id FROM gisco_26.country_land_geom))--(XXY,XXt,XXW are missing)
SELECT cntr_id,a.name_engl,a.svrg_un,a.iso3_code,a.eu_stat,a.efta_stat,a.cc_stat,cntr_code_stat,b.country_uri
FROM gisco_26.country_land_geom a
LEFT JOIN b USING(cntr_id)
ORDEr BY cntr_id;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- COUNTRY MARINE
-----------------------------------------------------------------------------------------------
-- GEOM
SELECT * FROM gisco_26."EEZ_RG_01M_2024";
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26."EEZ_RG_01M_2024_valid_single_poly";

DROP TABLE IF EXISTS eez_valid;CREATE TEMPORARY TABLE eez_valid AS
SELECT mrgid::integer,ST_Force2D(geom) geom
FROM gisco_26."EEZ_RG_01M_2024"
WHERE ST_ISVALID(geom) IS TRUE AND ST_GeOMETRYTYPE(geom) = 'ST_Polygon'
ORDER BY mrgid::integer;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM eez_valid;

DROP TABLE IF EXISTS eez_fixed;CREATE TEMPORARY TABLE eez_fixed AS
SELECT mrgid,ST_COLLECT(geom) geom FROM eez_valid GROUP BY mrgid ORDER BY mrgid;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM eez_fixed;

DROP TABLE IF EXISTS gisco_26.country_marine_geom;CREATE TABLE gisco_26.country_marine_geom AS
SELEcT mrgid,geom::geometry(MultiPolygon,4326) FROM eez_fixed;
ALTER TABLE gisco_26.country_marine_geom ADD PRIMARY KEY (mrgid);
CREATE INDEX ON gisco_26.country_marine_geom USING GIST(geom);
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26.country_marine_geom;

-----------------------------------------------------------------------------------------------
-- ATTS
DROP TABLE IF EXISTS gisco_26.country_marine_atts;CREATE TABLE gisco_26.country_marine_atts AS
SELEcT
mrgid::integer,
eez_id::text,
geoname::text,
pol_type::text,
cntr_id_sov1::text,uri_sov1::text,sovereign1::text,
cntr_id_ter1::text,uri_ter1::text,territory1::text,
cntr_id_sov2::text,uri_sov2::text,sovereign2::text,
cntr_id_ter2::text,uri_ter2::text,territory2::text,
cntr_id_sov3::text,uri_sov3::text,sovereign3::text,
cntr_id_ter3::text,uri_ter3::text,territory3::text
FROM gisco_26."EEZ_AT_2024"
WHERE mrgid::integer IN (SELECT DISTIncT mrgid FROM gisco_26.country_marine_geom)
ORDER BY mrgid::integer;

-------------------------------------------------------------------------------------

DROP TABLE IF EXISTS gisco_26.grid;CREATE TABLE gisco_26.grid AS
SELECT 
row_number() OVER (ORDER BY lat, lon) AS gid,
ST_MakeEnvelope(lon, lat, lon+90, lat+90)::geometry(Polygon,4326) geom
FROM generate_series(-180,  90, 90) AS lon,
     generate_series( -90,   0, 90) AS lat;
ALTeR TABLE gisco_26.grid ADD PRIMaRY KEY(gid);
CReatE INDEX ON gisco_26.grid USING GIST(geom);
SElEcT * FROM gisco_26.grid;