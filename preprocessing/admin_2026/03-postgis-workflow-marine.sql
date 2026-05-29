-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- COUNTRY MARINE
-----------------------------------------------------------------------------------------------
-- GEOM
SELECT * FROM gisco_26."EEZ_RG_01M_2024";
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26."EEZ_RG_01M_2024";

DROP TABLE IF EXISTS eez_valid;CREATE TEMPORARY TABLE eez_valid AS
SELECT mrgid::integer,ST_Force2D(geom) geom
FROM gisco_26."EEZ_RG_01M_2024"
WHERE ST_ISVALID(geom) IS TRUE AND ST_GeOMETRYTYPE(geom) = 'ST_Polygon'
ORDER BY mrgid::integer;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM eez_valid;
SELECT DISTINcT mrgid FROM eez_valid;

DROP TABLE IF EXISTS eez_geom;CREATE TEMPORARY TABLE eez_geom AS
SELECT mrgid,ST_COLLECT(geom) geom
FROM eez_valid GROUP BY mrgid ORDER BY mrgid;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM eez_geom;
SELECT DISTINcT mrgid FROM eez_geom;

-----------------------------------------------------------------------------------------------
-- gisco_26.country_marine_geom
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_26.country_marine_geom;CREATE TABLE gisco_26.country_marine_geom AS
SELEcT mrgid,geom::geometry(MultiPolygon,4326) FROM eez_geom;
ALTER TABLE gisco_26.country_marine_geom ADD PRIMARY KEY (mrgid);
CREATE INDEX ON gisco_26.country_marine_geom USING GIST(geom);
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26.country_marine_geom;
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- ATTS
DROP TABLE IF EXISTS country_marine_atts;CREATE TEMPORARY TABLE country_marine_atts AS
SELEcT
mrgid::integer,
TRIM(REGEXP_REPLACE(eez_id::text, '\s+', ' ', 'g')) eez_id,
TRIM(REGEXP_REPLACE(geoname::text, '\s+', ' ', 'g')) geoname,
TRIM(REGEXP_REPLACE(pol_type::text, '\s+', ' ', 'g')) pol_type,
TRIM(REGEXP_REPLACE(uri_sov1::text, '\s+', ' ', 'g')) uri_sov1,
TRIM(REGEXP_REPLACE(cntr_id_sov1::text, '\s+', ' ', 'g')) cntr_id_sov1,
TRIM(REGEXP_REPLACE(sovereign1::text, '\s+', ' ', 'g')) sovereign1,
TRIM(REGEXP_REPLACE(uri_ter1::text, '\s+', ' ', 'g')) uri_ter1,
TRIM(REGEXP_REPLACE(cntr_id_ter1::text, '\s+', ' ', 'g')) cntr_id_ter1,
TRIM(REGEXP_REPLACE(territory1::text, '\s+', ' ', 'g')) territory1,
TRIM(REGEXP_REPLACE(uri_sov2::text, '\s+', ' ', 'g')) uri_sov2,
TRIM(REGEXP_REPLACE(cntr_id_sov2::text, '\s+', ' ', 'g')) cntr_id_sov2,
TRIM(REGEXP_REPLACE(sovereign2::text, '\s+', ' ', 'g')) sovereign2,
TRIM(REGEXP_REPLACE(uri_ter2::text, '\s+', ' ', 'g')) uri_ter2,
TRIM(REGEXP_REPLACE(cntr_id_ter2::text, '\s+', ' ', 'g')) cntr_id_ter2,
TRIM(REGEXP_REPLACE(territory2::text, '\s+', ' ', 'g')) territory2,
TRIM(REGEXP_REPLACE(uri_sov3::text, '\s+', ' ', 'g')) uri_sov3,
TRIM(REGEXP_REPLACE(cntr_id_sov3::text, '\s+', ' ', 'g')) cntr_id_sov3,
TRIM(REGEXP_REPLACE(sovereign3::text, '\s+', ' ', 'g')) sovereign3,
TRIM(REGEXP_REPLACE(uri_ter3::text, '\s+', ' ', 'g')) uri_ter3,
TRIM(REGEXP_REPLACE(cntr_id_ter3::text, '\s+', ' ', 'g')) cntr_id_ter3,
TRIM(REGEXP_REPLACE(territory3::text, '\s+', ' ', 'g')) territory3
FROM gisco_26."EEZ_AT_2024"
WHERE mrgid::integer IN (SELECT DISTINcT mrgid FROM eez_geom)
ORDER BY mrgid::integer;


-----------------------------------------------------------------------------------------------
-- gisco_26.country_marine_atts
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_26.country_marine_atts;CREATE TABLE gisco_26.country_marine_atts AS
SELECT * FROM country_marine_atts;
ALTER TABLE gisco_26.country_marine_atts ADD PRIMARY KEY (mrgid);
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS country_land_atts_reference;CREATE TEMPORARY TABLE country_land_atts_reference AS
SELECT svrgn_country_uri,svrgn_country_name,country_uri,cntr_id,name_engl,iso3_code,svrg_un
FROM gisco_26.country_land
ORDER BY svrgn_country_uri,country_uri;
SElECT * FROM country_land_atts_reference;
--------------------------------------------------------------
--SOV based on eez_id <--> land iso3 --> country_uri

DROP TABLE IF EXISTS country_marine_sov1;CREATE TEMPORARY TABLE country_marine_sov1 AS
SELECT * FROM (
    SELECT DISTINCT mrgid, eez_id, 1 AS pos, SPLIT_PART(eez_id,'_',1) iso3_code FROM country_marine_atts
    UNION ALL
    SELECT DISTINCT mrgid, eez_id, 2 AS pos, SPLIT_PART(eez_id,'_',2) iso3_code FROM country_marine_atts
    UNION ALL
    SELECT DISTINCT mrgid, eez_id, 3 AS pos, SPLIT_PART(eez_id,'_',3) iso3_code FROM country_marine_atts
) a WHERE iso3_code != '' ORDER BY mrgid, pos;
UPDATE country_marine_sov1 SET iso3_code = 'GBR' WHERE iso3_code = 'UK';

--SELECT * FROM country_marine_sov1;

DROP TABLE IF EXISTS country_marine_sov2;CREATE TEMPORARY TABLE country_marine_sov2 AS
SELECT mrgid, eez_id, pos,b.*
FROM country_marine_sov1 a LEFT JOIN country_land_atts_reference b USING(iso3_code);
SELECT * FROM country_marine_sov2;

DROP TABLE IF EXISTS country_marine_sov3;CREATE TEMPORARY TABLE country_marine_sov3 AS
SELECT
mrgid,
eez_id,
ARRAY_TO_STRING(svrgn_country_uri,'_') svrgn_country_uri,
CARDINALITY(svrgn_country_uri) svrgn_country_uri_count,
ARRAY_TO_STRING(svrgn_country_name,';') svrgn_country_name,
CARDINALITY(svrgn_country_name) svrgn_country_name_count,
NULL::boolean svrgn_country_diff
FROM
(SELECT mrgid,eez_id,ARRAY_AGG(svrgn_country_uri ORDER BY pos) AS svrgn_country_uri, ARRAY_AGG(svrgn_country_name ORDER BY pos) AS svrgn_country_name
FROM country_marine_sov2 GROUP BY mrgid,eez_id) a ORDER BY mrgid;
UPDATE country_marine_sov3 SET svrgn_country_diff = TRUE WHERE svrgn_country_uri != eez_id;


-- SELECT * FROM country_marine_sov3; --288
-- SELECT DISTINCT mrgid FROM country_marine_sov3; --288
-- SELECT DISTINCT eez_id FROM country_marine_sov3; --202
-- SELECT DISTINCT svrgn_country_uri FROM country_marine_sov3; --200
-- SELECT DISTINCT svrgn_country_name FROM country_marine_sov3; --200
-- SELECT DISTINCT svrgn_country_uri,svrgn_country_name FROM country_marine_sov3; --200
-- WITH
-- a AS (SELECT DISTINCT svrgn_country_uri,svrgn_country_name,eez_id FROM country_marine_sov3),
-- b AS (SELECT svrgn_country_uri,svrgn_country_name,ARRAY_AGG(eez_id) eez_ids FROM a GROUP BY svrgn_country_uri,svrgn_country_name)
-- SELECT *,CARDINALITY(eez_ids) c_eez_ids FROM b ORDER BY c_eez_ids DESC;

------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS country_marine_sovereign;CREATE TEMPORARY TABLE country_marine_sovereign AS
SELECT svrgn_country_uri,svrgn_country_name,ARRAY_AGG(mrgid ORDER BY mrgid) mrgid
FROM country_marine_sov3 a
GROUP BY svrgn_country_uri,svrgn_country_name
ORDER BY svrgn_country_uri;
SELECT * FROM country_marine_sovereign; --200
SELECT DISTINCT svrgn_country_uri,svrgn_country_name FROM country_marine_sovereign; --200

DROP TABLE IF EXISTS country_marine_sovereign_geom;CREATE TEMPORARY TABLE country_marine_sovereign_geom AS
SELECT svrgn_country_uri,svrgn_country_name,ARRAY_AGG(mrgid ORDER BY mrgid) mrgid,ST_UnaryUnion(ST_COLLECT(geom)) geom
FROM country_marine_sov3 a
JOIN eez_valid b USING(mrgid)
GROUP BY svrgn_country_uri,svrgn_country_name
ORDER BY svrgn_country_uri;
UPDATE country_marine_sovereign_geom SET geom = ST_MULTI(geom) WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon';
SELECT * FROM country_marine_sovereign_geom;
SELECT DISTINCT ST_GEOMETRYTYPE(geom),ST_ISVALID(geom),ST_SRID(geom) FROM country_marine_sovereign_geom;

-----------------------------------------------------------------------------------------------
-- gisco_26.country_marine_sovereign
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_26.country_marine_sovereign;CREATE TABLE gisco_26.country_marine_sovereign AS
SELECT *,ST_AREA(geom::geography)/1000000 sqkm FROM country_marine_sovereign_geom ORDER BY svrgn_country_uri;
ALTER TABLE gisco_26.country_marine_sovereign ADD PRIMARY KEY (svrgn_country_uri);
CREATE INDEX ON gisco_26.country_marine_sovereign USING GIST(geom);
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS country_marine_ter_sov;CREATE TEMPORARY TABLE country_marine_ter_sov AS
WITH
a AS (SELECT mrgid, generate_series(1,3) AS pos FROM country_marine_atts),
b AS (SELecT mrgid,1 pos, territory1 territory,uri_sov1 uri_sov,uri_ter1 uri_ter,cntr_id_ter1 cntr_id_ter FROM country_marine_atts),
c AS (SELecT mrgid,2 pos, territory2 territory,uri_sov2 uri_sov,uri_ter2 uri_ter,cntr_id_ter2 cntr_id_ter FROM country_marine_atts WHERE territory2 != '' OR uri_sov2 != ''),
d AS (SELecT mrgid,3 pos, territory3 territory,uri_sov3 uri_sov,uri_ter3 uri_ter,cntr_id_ter3 cntr_id_ter FROM country_marine_atts WHERE territory3 != ''),
b1 AS (SELECT * FROM a JOIN b UsiNG (mrgid,pos)),
c1 AS (SELECT * FROM a JOIN c UsiNG (mrgid,pos)),
d1 AS (SELECT * FROM a JOIN d UsiNG (mrgid,pos))
SELECT * FROM b1
UNION ALL
SELECT * FROM c1
UNION ALL
SELECT * FROM d1
ORDER BY mrgid,pos;
SELECT * FROM country_marine_ter_sov;--343
-- SELECT DISTINCT mrgid FROM country_marine_ter_sov;--288
-- SELECT DISTINCT uri_sov FROM country_marine_ter_sov;--159
-- SELECT DISTINCT uri_ter FROM country_marine_ter_sov;--210
-- SELECT DISTINCT uri_sov,uri_ter FROM country_marine_ter_sov;--241
-- SELECT DISTINCT cntr_id_ter FROM country_marine_ter_sov;--210
-- SELECT DISTINCT territory FROM country_marine_ter_sov;--257
-- SELECT DISTINCT uri_sov,uri_ter,cntr_id_ter FROM country_marine_ter_sov;--243
-- SELECT DISTINCT uri_ter,cntr_id_ter FROM country_marine_ter_sov;--212
-- SELECT DISTINCT  FROM country_marine_ter_sov;--210


DROP TABLE IF EXISTS country_marine_uri_sov_agg;CREATE TEMPORARY TABLE country_marine_uri_sov_agg AS
WITH dedup AS (
	SELECT * FROM
	(
	SELECT mrgid,uri_sov,pos,ROW_NUMBER() OVER (PARTITION BY mrgid,uri_sov ORDER BY pos) AS rn
	FROM country_marine_ter_sov
	WHERE uri_sov IS NOT NULL AND btrim(uri_sov) <> ''
	) t
	WHERE rn = 1
)
SELECT mrgid,ARRAY_AGG(uri_sov ORDER BY pos) AS uri_sov
FROM dedup GROUP BY mrgid ORDER BY mrgid;

DROP TABLE IF EXISTS country_marine_uri_ter_agg;CREATE TEMPORARY TABLE country_marine_uri_ter_agg AS
WITH dedup AS (
	SELECT * FROM
	(
	SELECT mrgid,uri_ter,pos,ROW_NUMBER() OVER (PARTITION BY mrgid, uri_ter ORDER BY pos) AS rn
	FROM country_marine_ter_sov
	WHERE uri_ter IS NOT NULL AND btrim(uri_ter) <> ''
	) t
	WHERE rn = 1
	)
SELECT mrgid,ARRAY_AGG(uri_ter ORDER BY pos) AS uri_ter
FROM dedup GROUP BY mrgid ORDER BY mrgid;

DROP TABLE IF EXISTS country_marine_cntr_id_ter_agg;CREATE TEMPORARY TABLE country_marine_cntr_id_ter_agg AS
WITH dedup AS (
	SELECT * FROM
	(
	SELECT mrgid,cntr_id_ter,pos,ROW_NUMBER() OVER (PARTITION BY mrgid, cntr_id_ter ORDER BY pos) AS rn
	FROM country_marine_ter_sov
	WHERE cntr_id_ter IS NOT NULL AND btrim(cntr_id_ter) <> ''
	) t
	WHERE rn = 1
	)
SELECT mrgid,ARRAY_AGG(cntr_id_ter ORDER BY pos) AS cntr_id_ter
FROM dedup GROUP BY mrgid ORDER BY mrgid;

DROP TABLE IF EXISTS country_marine_territory_agg;CREATE TEMPORARY TABLE country_marine_territory_agg AS
WITH dedup AS (
	SELECT * FROM
	(
	SELECT mrgid,territory,pos,ROW_NUMBER() OVER (PARTITION BY mrgid, territory ORDER BY pos) AS rn
	FROM country_marine_ter_sov
	WHERE territory IS NOT NULL AND btrim(territory) <> ''
	) t
	WHERE rn = 1
	)
SELECT mrgid,ARRAY_AGG(territory ORDER BY pos) AS territory
FROM dedup GROUP BY mrgid ORDER BY mrgid;

DROP TABLE IF EXISTS country_marine_agg1;CREATE TEMPORARY TABLE country_marine_agg1 AS
WITH
z AS (SELECT DISTINCT mrgid FROM country_marine_ter_sov),
a AS (
SELECT * FROM z
LEFT JOIN country_marine_uri_sov_agg USING (mrgid)
LEFT JOIN country_marine_uri_ter_agg USING (mrgid)
LEFT JOIN country_marine_cntr_id_ter_agg USING (mrgid)
LEFT JOIN country_marine_territory_agg USING (mrgid)
ORDER BY mrgid
)
SELECT * FROM a oRDER BY mrgid;
SELECT * FROM country_marine_agg1;
----
DROP TABLE IF EXISTS country_marine_agg2;CREATE TEMPORARY TABLE country_marine_agg2 AS
SELECT mrgid,
ARRAY_TO_STRING(uri_sov,'_')uri_sov,
ARRAY_TO_STRING(uri_ter,'_')uri_ter,
ARRAY_TO_STRING(cntr_id_ter,'_')cntr_id_ter,
ARRAY_TO_STRING(territory,';')territory,
CASE
    WHEN COALESCE(CARDINALITY(uri_sov),0) > 1
	OR COALESCE(CARDINALITY(uri_ter),0) > 1
	OR COALESCE(CARDINALITY(cntr_id_ter),0) > 1
	OR COALESCE(CARDINALITY(territory),0) > 1
    THEN TRUE
    ELSE NULL
END AS cc
FROM country_marine_agg1;
SELECT * FROM country_marine_agg2;

DROP TABLE IF EXISTS country_marine_agg3;CREATE TEMPORARY TABLE country_marine_agg3 AS
WITH
a AS(SELECT svrgn_country_uri,svrgn_country_name,UNNEST(mrgid) mrgid FROM country_marine_sovereign),
b AS (SELECT * FROM a LEFT JOIN country_marine_agg2 b USING(mrgid)),
c AS (SELEcT DIsTINCT country_uri uri_ter,name_engl country_uri_country_name FROM country_land_atts_reference),
d AS (SELEcT DIsTINCT cntr_id cntr_id_ter,name_engl cntr_id_country_name FROM country_land_atts_reference)
SELECT 
mrgid,cc,
svrgn_country_uri,svrgn_country_name,
uri_ter,country_uri_country_name,
cntr_id_ter,cntr_id_country_name,
territory
FROM b
LEFT JOIN c USING(uri_ter)
LEFT JOIN d USING(cntr_id_ter)
ORDER BY svrgn_country_uri,mrgid;

DROP TABLE IF EXISTS country_marine_agg4;CREATE TEMPORARY TABLE country_marine_agg4 AS
SELECT ROW_NUMBER () OVER () tid,
svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name,ARRAY_TO_STRING(territory,';') territory,mrgid,
NULL::integer ok
FROM 
(SELECT svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name,
ARRAY_AGG(territory ORDER BY mrgid) territory,
ARRAY_AGG(mrgid ORDER BY mrgid) mrgid
FROM country_marine_agg3
GROUP BY svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name
ORDER BY svrgn_country_uri,svrgn_country_name);

UPDATE country_marine_agg4 SET cntr_id_ter = 'CO',uri_ter='COL',country_uri_country_name = 'Colombia' WHERE mrgid && '{62598,48984,48985,62596}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'CN',uri_ter='CHN',country_uri_country_name = 'China' WHERE mrgid && '{8321}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'AU',uri_ter='AUS',country_uri_country_name = 'Australia' WHERE mrgid && '{8311}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'CL',uri_ter='CHL',country_uri_country_name = 'Chile' WHERE mrgid && '{21787}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'EC',uri_ter='ECU',country_uri_country_name = 'Ecuador' WHERE mrgid && '{8403}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'ES',uri_ter='ESP',country_uri_country_name = 'Spain' WHERE mrgid && '{8364,48997,48998,48999,49001}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'IN',uri_ter='IND',country_uri_country_name = 'India' WHERE mrgid && '{8333}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'PT',uri_ter='PRT',country_uri_country_name = 'Portugal' WHERE mrgid && '{8361,8363}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'TL',uri_ter='TLS',country_uri_country_name = 'Timor-Leste' WHERE mrgid && '{21791}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'US',uri_ter='USA',country_uri_country_name = 'United States' WHERE mrgid && '{8453,8463}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'ZA',uri_ter='ZAF',country_uri_country_name = 'South Africa' WHERE mrgid && '{8384}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'TF',uri_ter='ATF',country_uri_country_name = 'French Southern and Antarctic Lands' WHERE mrgid && '{48945}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'FR',uri_ter='FRA',country_uri_country_name = 'France' WHERE mrgid && '{48948}';
UPDATE country_marine_agg4 SET cntr_id_ter = 'EA',country_uri_country_name = 'Melilla and Ceuta' WHERE mrgid && '{49000,49002}';
------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE country_marine_agg4 SET country_uri_country_name = territory WHERE mrgid && '{8338,8462,8495,33177,33178,48944}';
------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE country_marine_agg4 SET country_uri_country_name = 'Faroes;Iceland' WHERE mrgid && '{48973}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'United Kingdom;Faroes' WHERE mrgid && '{48967}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Gibraltar;Spain' WHERE mrgid && '{8365}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Guyana;Venezuela' WHERE mrgid && '{64461}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Honduras;Cayman Islands' WHERE mrgid && '{48972}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Iceland;Svalbard and Jan Mayen' WHERE mrgid && '{48975}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Norway;Russian Federation' WHERE mrgid && '{64459}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'São Tomé and Príncipe;Nigeria' WHERE mrgid && '{21797}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Puerto Rico;Dominican Republic' WHERE mrgid && '{48982}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'United States;Russian Federation' WHERE mrgid && '{48978}';
UPDATE country_marine_agg4 SET country_uri_country_name = 'Venezuela;Aruba;Dominican Republic' WHERE mrgid && '{48965}';
---------------------------------------------------------------------------------------------------------------------------
UPDATE country_marine_agg4 SET ok = 1 WHERE svrgn_country_uri IS NOT DISTINCT FROM uri_ter AND svrgn_country_name IS NOT DISTINCT FROM country_uri_country_name;
UPDATE country_marine_agg4 SET territory = NULL WHERE ok = 1 AND svrgn_country_name = territory;
UPDATE country_marine_agg4 SET territory = NULL WHERE ok = 1 AND NOT (mrgid && '{8311,8321,8333,8361,8363,8364,8381,8384,8403,8441,8450,8453,8463,8464,8465,8488,21787,21791,21797,22756,48948,48978,48984,48985,48997,48998,48999,49001,62596,62598,64459,64461}');
UPDATE country_marine_agg4 SET ok = 2 WHERE ok IS NULL AND svrgn_country_uri != uri_ter AND country_uri_country_name IS NOT NULL;
UPDATE country_marine_agg4 SET territory = NULL WHERE ok = 2 AND NOT (mrgid && '{8319,8339,8340,8341,8365,8383,8385,8386,8387,8389,8442,8443,8451,8452,48945,48946,48965,48967,48968,48972,48973,48975,48982,49000,49002}');
UPDATE country_marine_agg4 SET ok = 3 WHERE ok IS NULL AND svrgn_country_uri=uri_ter AND svrgn_country_name=territory;
UPDATE country_marine_agg4 SET country_uri_country_name = svrgn_country_name,territory=NULL WHERE ok = 3;
UPDATE country_marine_agg4 SET ok = 4 WHERE ok IS NULL;

DROP TABLE IF EXISTS country_marine_agg5;CREATE TEMPORARY TABLE country_marine_agg5 AS
WITH
a AS (
SELECT svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name,
UNNEST(STRING_TO_ARRAY(territory,';'))territory,
UNNEST(mrgid)mrgid,
CASE WHEN ok = 4 THEN TRUE ELSE NULL END tocheck
FROM country_marine_agg4)
SELECT svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name,ARRAY_AGG(territory ORDER BY mrgid) territory,ARRAY_AGG(mrgid ORDER BY mrgid)mrgid,tocheck
FROM a
GROUP BY svrgn_country_uri,svrgn_country_name,cntr_id_ter,uri_ter,country_uri_country_name,tocheck
ORDER BY svrgn_country_uri,cntr_id_ter,uri_ter,tocheck;

UPDATE country_marine_agg5
SET
mrgid = array_remove(mrgid, NULL),
territory =
CASE
	WHEN array_remove(territory, NULL) = '{}'::text[] THEN '{}'::text[]
    WHEN array_position(territory, NULL) IS NOT NULL THEN array_append(array_remove(territory, NULL),'Main')
	ELSE territory
END;

DROP TABLE IF EXISTS country_marine_agg6;CREATE TEMPORARY TABLE country_marine_agg6 AS
SELECT ROW_NUMBeR () oVER () tid,* FROM (
SELEcT svrgn_country_uri,svrgn_country_name,uri_ter country_uri,cntr_id_ter cntr_id,country_uri_country_name name_engl,uri_ter iso3_code,ARRAY_TO_STRING(territory,';') territory,mrgid,tocheck
FROM country_marine_agg5
ORDER BY svrgn_country_uri,country_uri,cntr_id);
UPDATE country_marine_agg6 SET iso3_code = svrgn_country_uri WHERE iso3_code IS NULL;
UPDATE country_marine_agg6 SET name_engl = svrgn_country_name WHERE iso3_code IS NULL;
SELECT * FROM country_marine_agg6;

DROP TABLE IF EXISTS country_marine_agg7;CREATE TEMPORARY TABLE country_marine_agg7 AS
WITH
a AS (SELECT tid,UNNEST(mrgid)  mrgid FROM country_marine_agg6),
b AS (SELECT a.*,pol_type FROM a JOIN country_marine_atts UsiNG(mrgid)),
d AS (SELECT tid,ARRAY_TO_STRING(ARRAY_AGG(DISTINCT pol_type ORDER BY pol_type),';') svrg_un FROM b GROUP BY tid ORdER BY tid),
e AS (SELECT a.*,geom FROM a JOIN eez_geom UsiNG(mrgid)),
f AS (SELECT tid,ST_UnaryUnion(ST_COLLECT(geom)) geom FROM e GROUP BY tid ORdER BY tid)
SELECT * FROM country_marine_agg6
JOIN d USING(tid)
JOIN f USING(tid)
ORDER BY tid;

SELECT * FROM country_marine_agg7 LIMIT 1;
SELECT DISTINCT ST_GEOMETRYTYPE(geom),ST_ISVALID(geom),ST_SRID(geom) FROM country_marine_agg7;
UPDATE country_marine_agg7 SET geom = ST_MULTI(geom) WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon';

-----------------------------------------------------------------------------------------------
-- gisco_26.country_marine
-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS gisco_26.country_marine;CREATE TABLE gisco_26.country_marine AS
SELECT *,ST_AREA(geom::geography)/1000000 sqkm FROM country_marine_agg7 ORDER BY tid;
ALTER TABLE gisco_26.country_marine ADD PRIMARY KEY (tid);
CREATE INDEX ON gisco_26.country_marine USING GIST(geom);
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
