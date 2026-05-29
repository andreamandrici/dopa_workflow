-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- COUNTRY
-----------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS country_land;CREATE TEMPORARY TABLE country_land AS
SELECT 
svrgn_country_uri,svrgn_country_name,country_uri,name_engl country_name,cntr_id iso2,iso3_code iso3,svrg_un,source,
geom,
NULL::text territory,NULL::integer[] orig_id,
cntr_sqkm sqkm
FROM gisco_26.country_land;
SELECT * FROM country_land;

DROP TABLE IF EXISTS country_marine;CREATE TEMPORARY TABLE country_marine AS
SELECT 
svrgn_country_uri,svrgn_country_name,country_uri,name_engl country_name,cntr_id iso2,iso3_code iso3,svrg_un,'marine'::text source,
geom,
territory,mrgid orig_id,sqkm
FROM gisco_26.country_marine;
SELECT * FROM country_marine;


DROP TABLE IF EXISTS abnj1;CREATE TEMPORARY TABLE abnj1 AS
SELECT ST_UNARYUNION(ST_COLLECT(geom)) geom,SUM(sqkm) sqkm,ARRAY_AGG(nid) orig_id FROM gisco_26.abnj;
SELECT ST_GEOMETRYTYPE(geom),ST_ISVALID(geom),ST_SRID(geom) FROM abnj1;

DROP TABLE IF EXISTS abnj;CREATE TEMPORARY TABLE abnj AS
SELECT
'ABNJ' svrgn_country_uri,
'Area Beyond National Jurisdiction' svrgn_country_name,
'ABNJ' country_uri,
'Area Beyond National Jurisdiction' country_name,
'ABNJ' iso2,
'ABNJ' iso3,
'Area Beyond National Jurisdiction' svrg_un,
'marine'::text source,
geom,
'ABNJ' territory,
orig_id,
sqkm
FROM abnj1;


DROP TABLE IF EXISTS country1;CREATE TEMPORARY TABLE country1 AS
SELECT ROW_NUMBeR () oVER () country_id,* FROM (
SELECT DISTINCT svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso2,iso3 FROM country_land
UNION
SELECT DISTINCT svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso2,iso3 FROM country_marine
UNION
SELECT DISTINCT svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso2,iso3 FROM abnj
ORdER BY svrgn_country_uri,country_uri) a
ORDER BY country_id;
SELECT * FROM country1;

DROP TABLE IF EXISTS country2;CREATE TEMPORARY TABLE country2 AS
SELECT a.*,source,svrg_un,territory,orig_id,geom,sqkm 
FROM country1 a
JOIN country_land b
ON  a.svrgn_country_uri  IS NOT DISTINCT FROM b.svrgn_country_uri
AND a.svrgn_country_name IS NOT DISTINCT FROM b.svrgn_country_name
AND a.country_uri        IS NOT DISTINCT FROM b.country_uri
AND a.country_name       IS NOT DISTINCT FROM b.country_name
AND a.iso2               IS NOT DISTINCT FROM b.iso2
AND a.iso3               IS NOT DISTINCT FROM b.iso3
UNION
SELECT a.*,source,svrg_un,territory,orig_id,geom,sqkm 
FROM country1 a
JOIN country_marine c
ON  a.svrgn_country_uri  IS NOT DISTINCT FROM c.svrgn_country_uri
AND a.svrgn_country_name IS NOT DISTINCT FROM c.svrgn_country_name
AND a.country_uri        IS NOT DISTINCT FROM c.country_uri
AND a.country_name       IS NOT DISTINCT FROM c.country_name
AND a.iso2               IS NOT DISTINCT FROM c.iso2
AND a.iso3               IS NOT DISTINCT FROM c.iso3
UNION
SELECT a.*,source,svrg_un,territory,orig_id,geom,sqkm 
FROM country1 a
JOIN abnj d
ON  a.svrgn_country_uri  IS NOT DISTINCT FROM d.svrgn_country_uri
AND a.svrgn_country_name IS NOT DISTINCT FROM d.svrgn_country_name
AND a.country_uri        IS NOT DISTINCT FROM d.country_uri
AND a.country_name       IS NOT DISTINCT FROM d.country_name
AND a.iso2               IS NOT DISTINCT FROM d.iso2
AND a.iso3               IS NOT DISTINCT FROM d.iso3
ORDER BY country_id,source;

DROP TABLE IF EXISTS country3;CREATE TEMPORARY TABLE country3 AS
SELECT ROW_NUMBeR() OVER () country_pid,* FROM country2;

DROP TABLE IF EXISTS country4;CREATE TEMPORARY TABLE country4 AS
SELECT country_id,country_pid,svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso2,iso3,
source,svrg_un,territory,orig_id,geom,sqkm
FROM country3 ORDER BY country_id,country_pid;
UPDATE country4 SET iso2 = 'GR' WHERE country_uri= 'GRC' AND iso2 = 'EL';
UPDATE country4 SET iso2 = 'GB' WHERE country_uri= 'GBR' AND iso2 = 'UK';
UPDATE country4 SET territory = NULL WHERE territory = '';

-----------------------------------------------------------------------------------------------
-- gisco_26.country
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_26.country;CREATE TABLE gisco_26.country AS
SELECT * FROM country4 ORDER BY country_pid;
ALTER TABLE gisco_26.country ADD PRIMARY KEY (country_pid);
CREATE INDEX ON gisco_26.country USING GIST(geom);
SELECT DISTINCT ST_GEOMETRYTYPE(geom),ST_ISVALID(geom),ST_SRID(geom) FROM gisco_26.country;
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


