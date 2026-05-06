-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- COUNTRY LAND
-----------------------------------------------------------------------------------------------
-- GEOM
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26."CNTR_RG_01M_2024_4326";

--------------------------------------------------------------------------------------------
-- FIx WAKE ISLAND!!!
DROP TABLE IF EXISTS country_land_geom;CREATE TABLE country_land_geom AS
WITH
a AS (SELEcT cntr_id::text,(ST_DUMP(geom)).* FROM gisco_26."CNTR_RG_01M_2024_4326" WHERE cntr_id = 'JP'),-- all JP (wrong) single poly
b AS (SELECT cntr_id,path,ST_POINTONSURFACE(geom) point FROM a), -- all centroids
d AS (
	SELECT DISTINCT b.cntr_id,b.path,c.cntr_id::text p_cntr_id FROM b,gisco_2020."GISCO.CNTR_RG_01M_2020" c
	WHERE ST_INTERSECTS(b.point,c.geom) AND b.cntr_id != c.cntr_id
	),-- correct cntr_id (UM)
e AS (SELECT cntr_id,path,geom FROM a WHERE path NOT IN (SELeCT DISTINCT path FROM d)), --all JP (correct) single poly
f AS (SELECT p_cntr_id cntr_id,geom FROM d NATURAL JOIN a),-- correct cntr_id (UM) and geom
g As (
	SELECT cntr_id,(ST_DUMP(geom)).* FROM gisco_26."CNTR_RG_01M_2024_4326"
	WHERE cntr_id IN (SELECT DISTINCT cntr_id FROM f)
	),-- all UM single poly (missing the corrected one)
h AS (SELECT cntr_id,UNNEST(path) p,geom FROM g), -- all unnested UM paths
i AS (SELECT MAX(p)+1 p FROM h), --UM path to add
j AS (
	SELECT * FROM h
	UNION
	SELECT f.cntr_id,i.p,f.geom FROM f,i ORDER BY p
),-- all UM single poly (including the corrected one)
l AS (
		SEleCT cntr_id, UNNEST(path) p,geom FROM e
		UNION
		SEleCT * FROM j
		ORdER BY cntr_id,p
),
m AS (SELECT cntr_id,ST_COLLECT(geom ORDER BY p) geom FrOM l GROUP BY cntr_id ORDER BY cntr_id),
n AS (SELEcT cntr_id::text,geom FROM gisco_26."CNTR_RG_01M_2024_4326" WHERE cntr_id NOT IN (SEleCT DISTINCT cntr_id FROM m))
SELECT * FROM m
UNION
SELECT * FROM n
ORDER BY cntr_id
;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) ,ST_SRID(geom) FROM country_land_geom;


--DROP TABLE IF EXISTS country_land_geom;CREATE TABLE country_land_geom AS
--SElECT cntr_id::text,geom
--FROM gisco_26."CNTR_RG_01M_2024_4326" ORdER BY cntr_id;
-----------------------------------------------------------------------------------------------
-- ATTS
-----------------------------------------------------------------------------------------------
-- Country code stat
DROP TABLE IF EXISTS country_code_stat;CREATE TEMP TABLE country_code_stat AS
SELECT *
FROM (VALUES
('OA','Officially assigned code element','Code element may be used without restriction'),
('UA','User assigned code element','Code element may be used without restriction'),
('ER','Exceptionally reserved code element','Code element may be used but restrictions may apply'),
('TR','Transitionally reserved code element','Code element deleted from ISO 3166-1; stop using it ASAP'),
('IR','Indeterminately reserved code element','Code element must not be used in ISO 3166-1'),
('NU','Code elements not used at present stage','Code element must not be used in ISO 3166-1'),
('NA','Un-assigned code elements','Code element free for assignment by ISO 3166/MA')
) AS t(cntr_code_stat, cntr_code_stat_desc, cntr_code_stat_note);

-----------------------------------------------------------------------------------------------
-- Country Land Atts
DROP TABLE IF EXISTS country_land_atts;CREATE TEMPORARY TABLE country_land_atts AS
SELECT
country_uri::text,
cntr_id::text,
iso3_code::text,
name_engl::text,
svrg_un::text,
CASE eu_stat WHEN 'T' THEN true ELSE NULL END AS eu_stat,
CASE efta_stat WHEN 'T' THEN true ELSE NULL END AS efta_stat,
CASE cc_stat WHEN 'T' THEN true ELSE NULL END AS cc_stat,
cntr_code_stat::text,
cntr_code_stat_desc,
cntr_code_stat_note
FROM gisco_26."CNTR_AT_2024" a JOIN country_code_stat b USING(cntr_code_stat) ORDER BY country_uri;


DROP TABLE IF EXISTS country_land;CREATE TEMPORARY TABLE country_land AS
SELECT * FROM country_land_atts JOIN country_land_geom USING(cntr_id) ORDER BY country_uri;



SELECT svrg_un,ARRAY_AGG(DISTINCT country_uri ORDER BY country_uri) cu FROM country_land --WHERE svrg_un != 'UN Member State'
GROUP BY svrg_un ORDER BY svrg_un;

DROP TABLE IF EXISTS reference;CREATE TEMPORARY TABLE reference AS
SELECT DISTINCT NULL::TEXT svrgn_country_uri,country_uri,iso3_code,name_engl,CASE WHEN country_uri!=iso3_code THEN true END different_code,cntr_id,svrg_un
FROM country_land
ORDER BY country_uri;

SELECT * FROM reference WHERE svrg_un='UN Member State' AND different_code IS NULL;
SELECT * FROM reference WHERE svrgn_country_uri IS NULL ORDER BY svrg_un;
SELECT DISTINCT svrg_un FROM reference WHERE svrgn_country_uri IS NULL ORDER BY svrg_un;
----
UPDATE reference SET svrgn_country_uri = country_uri WHERE svrg_un='UN Member State';
UPDATE reference SET svrgn_country_uri = 'AUS' WHERE svrgn_country_uri IS NULL AND svrg_un = 'AU Territory';
UPDATE reference SET svrgn_country_uri = 'DNK' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'DK%';
UPDATE reference SET svrgn_country_uri = 'FRA' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'FR%';
UPDATE reference SET svrgn_country_uri = 'NZL' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'NZ%';
UPDATE reference SET svrgn_country_uri = 'NLD' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'NL%';
UPDATE reference SET svrgn_country_uri = 'NOR' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'NO %';
UPDATE reference SET svrgn_country_uri = 'USA' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'US%';
UPDATE reference SET svrgn_country_uri = 'GBR' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'UK%';
UPDATE reference SET svrgn_country_uri = 'CHN' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'CN%';
UPDATE reference SET svrgn_country_uri = 'VAT' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE '%VAT%';
UPDATE reference SET svrgn_country_uri = 'PSE' WHERE svrgn_country_uri IS NULL AND svrg_un ILIKE 'Non-member observer state';
----

SELECT * FROM reference WHERE svrgn_country_uri IS NULL;

DROP TABLE IF EXISTS gisco_26.country_land;CREATE TABLE gisco_26.country_land AS
WITH
a AS (
SELECT
b.svrgn_country_uri,a.country_uri,
a.name_engl,a.cntr_id,a.iso3_code,a.svrg_un,
a.eu_stat,a.efta_stat,cc_stat,cntr_code_stat,cntr_code_stat_desc,cntr_code_stat_note,
'land' source,geom,ST_AREA(geom::geography)/1000000 cntr_sqkm
FROM country_land a JOIN reference b USING(cntr_id) ORDER BY b.svrgn_country_uri,a.country_uri
),
b AS (SELECT DISTINCT svrgn_country_uri,name_engl svrgn_country_name FROM a WHERE svrgn_country_uri=country_uri)
SELECT svrgn_country_uri,svrgn_country_name,country_uri,name_engl,cntr_id,iso3_code,svrg_un,eu_stat,efta_stat,cc_stat,cntr_code_stat,cntr_code_stat_desc,cntr_code_stat_note,source,geom,cntr_sqkm
FROM a LEFT JOIN b USING(svrgn_country_uri)
ORDER BY svrgn_country_uri,country_uri;
ALTER TABLE gisco_26.country_land ADD PRImARY KEY(country_uri);
CREATE INDEX ON gisco_26.country_land USING GIST(geom);
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26.country_land;
SELECT * FROM gisco_26.country_land;

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