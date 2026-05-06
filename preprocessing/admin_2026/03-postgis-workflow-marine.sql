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
SELECT DISTINcT mrgid FROM eez_valid;

DROP TABLE IF EXISTS eez_geom;CREATE TEMPORARY TABLE eez_geom AS
SELECT mrgid,ST_COLLECT(geom) geom
FROM eez_valid GROUP BY mrgid ORDER BY mrgid;
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM eez_geom;
SELECT DISTINcT mrgid FROM eez_geom;


DROP TABLE IF EXISTS gisco_26.country_marine_geom;CREATE TABLE gisco_26.country_marine_geom AS
SELEcT mrgid,geom::geometry(MultiPolygon,4326) FROM eez_geom;
ALTER TABLE gisco_26.country_marine_geom ADD PRIMARY KEY (mrgid);
CREATE INDEX ON gisco_26.country_marine_geom USING GIST(geom);
SELECT DISTIncT ST_ISVALID(geom),ST_GeOMETRYTYPE(geom) FROM gisco_26.country_marine_geom;

--------------
--- TEMPORARY
DROP TABLE IF EXISTS eez_geom;CREATE TEMPORARY TABLE eez_geom AS
SELECT * FROM gisco_26.country_marine_geom;

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

SELECT * FROM country_marine_atts WHERE mrgid = 8319;
DROP TABLE IF EXISTS gisco_26.country_marine_geom_atts;CREATE TABLE gisco_26.country_marine_geom_atts AS
SELECT * FROM gisco_26.country_marine_geom JOIN country_marine_atts USING(mrgid);
--------------------------------------------------------------
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

DROP TABLE IF EXISTS country_marine_sovereign;CREATE TEMPORARY TABLE country_marine_sovereign AS
SELECT * FROM country_marine_sov3;

SELECT * FROM country_marine_sovereign; --288
SELECT DISTINCT mrgid FROM country_marine_sovereign; --288
SELECT DISTINCT eez_id FROM country_marine_sovereign; --202
SELECT DISTINCT svrgn_country_uri FROM country_marine_sovereign; --199
SELECT DISTINCT svrgn_country_name FROM country_marine_sovereign; --199
SELECT DISTINCT svrgn_country_uri,svrgn_country_name FROM country_marine_sovereign; --199

DROP TABLE IF EXISTS country_marine_sovereign_check;CREATE TEMPORARY TABLE country_marine_sovereign_check AS
WITH
a AS (
SELECT svrgn_country_uri,svrgn_country_name,ARRAY_AGG(eez_id) eez_id,ARRAY_AGG(mrgid) mrgid FROM country_marine_sovereign
GROUP BY svrgn_country_uri,svrgn_country_name
)
SELECT *,CARDINALITY(eez_id) c_eez_id,CARDINALITY(mrgid) c_mrgid FROM a
ORDER BY svrgn_country_uri,svrgn_country_name; --199
SELECT * FROM country_marine_sovereign_check WHERE c_eez_id !=1 OR c_mrgid != 1; --21
SELECT * FROM country_marine_sovereign_check WHERE c_eez_id != c_mrgid; --0

--------------------
-- sovereing and territory reported a 1,2,3; joined with whatever matches
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
UPDATE country_marine_ter_sov SET uri_sov = 'GRE' WHERE uri_sov = 'GRC';
UPDATE country_marine_ter_sov SET uri_ter = 'GRE' WHERE uri_ter = 'GRC';
SELECT DISTINCT mrgid FROM country_marine_ter_sov;--288

SELECT DISTINCT * FROM country_marine_ter_sov WHERE mrgid = 8319;
SELECT DISTINCT * FROM country_marine_ter_sov WHERE uri_sov = 'MHL';

SELECT * FROM country_marine_atts WHERE mrgid = 8319;
SELECT mrgid,eez_id,uri_sov1,cntr_id_sov1,sovereign1,uri_ter1,cntr_id_ter1,territory1 FROM country_marine_atts WHERE mrgid = 8319
UNION
SELECT mrgid,eez_id,uri_sov2,cntr_id_sov2,sovereign2,uri_ter2,cntr_id_ter2,territory2 FROM country_marine_atts WHERE mrgid = 8319

;

----------------------------------------------------------------------------------------------------------
-- match by 4 original attributes: a marine, b land
-- a.uri_sov=b.svrgn_country_uri
-- a.uri_ter = b.country_uri
-- a.cntr_id_ter = b.cntr_id
-- a.territory = b.name_engl;

DROP TABLE IF EXISTS country_marine_ter_sov_matched1;CREATE TEMPORARY TABLE country_marine_ter_sov_matched1 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov a 
JOIN country_land_atts_reference b ON a.uri_sov=b.svrgn_country_uri AND a.uri_ter = b.country_uri AND a.cntr_id_ter = b.cntr_id AND a.territory = b.name_engl;

--SELEcT * FROM country_marine_ter_sov_matched1;

WITH
a AS (
SELECT
mrgid,
ARRAY_AGG(svrgn_country_uri ORDER BY pos) svrgn_country_uri,
ARRAY_AGG(country_uri ORDER BY pos) country_uri,
ARRAY_AGG(name_engl ORDER BY pos) name_engl,
ARRAY_AGG(territory ORDER BY pos) territory
FROM country_marine_ter_sov_matched1
GROUP BY mrgid
ORDER BY mrgid
),
b AS (
SELECT
mrgid, 
ARRAY_TO_STRING(svrgn_country_uri,'_') svrgn_country_uri,
ARRAY_TO_STRING(country_uri,'_') country_uri,
ARRAY_TO_STRING(name_engl,';') name_engl,
ARRAY_TO_STRING(territory,';') territory
FROM a
)
SELECT * FROM b WHERE name_engl != territory
ORDER BY mrgid
;


DROP TABLE IF EXISTS mmatched;CREATE TEMPORARY TABLE mmatched AS
SELECT DISTINCT mrgid,pos,TRUE m FROM country_marine_ter_sov_matched1;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched1;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched1 AS
SELECT * FROM (SELECT * FROM country_marine_ter_sov a LEFT JOIN mmatched b USING(mrgid,pos)) c
WHERE m IS NULL ORDER BY mrgid,pos;

--SELECT * FROM country_marine_ter_sov_unmatched1;

----------------------------------------------------------------------------------------------------------
-- match by 3 of the original attributes: a marine, b land
-- a.uri_sov=b.svrgn_country_uri
-- a.uri_ter = b.country_uri
-- a.cntr_id_ter = b.cntr_id;

DROP TABLE IF EXISTS country_marine_ter_sov_matched2;CREATE TEMPORARY TABLE country_marine_ter_sov_matched2 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov_unmatched1 a 
JOIN country_land_atts_reference b ON a.uri_sov=b.svrgn_country_uri AND a.uri_ter = b.country_uri AND a.cntr_id_ter = b.cntr_id;

--SELEcT * FROM country_marine_ter_sov_matched2;

INsErT INTO mmatched SELECT DISTINCT mrgid,pos,TRUE m FROM country_marine_ter_sov_matched2;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched2;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched2 AS
SELECT * FROM (SELECT * FROM country_marine_ter_sov a LEFT JOIN mmatched b USING(mrgid,pos)) c
WHERE m IS NULL ORDER BY mrgid,pos;

--SELECT * FROM country_marine_ter_sov_unmatched2;

----------------------------------------------------------------------------------------------------------
-- match by 2 of the original attributes: a marine, b land
-- a.uri_ter = b.country_uri
-- a.cntr_id_ter = b.cntr_id;

DROP TABLE IF EXISTS country_marine_ter_sov_matched3;CREATE TEMPORARY TABLE country_marine_ter_sov_matched3 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov_unmatched2 a 
JOIN country_land_atts_reference b ON a.uri_ter = b.country_uri AND a.cntr_id_ter = b.cntr_id;

--SELEcT * FROM country_marine_ter_sov_matched3;

INsErT INTO mmatched SELECT DISTINCT mrgid,pos,TRUE m FROM country_marine_ter_sov_matched3;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched3;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched3 AS
SELECT * FROM (SELECT * FROM country_marine_ter_sov a LEFT JOIN mmatched b USING(mrgid,pos)) c
WHERE m IS NULL ORDER BY mrgid,pos;

--SELECT * FROM country_marine_ter_sov_unmatched3;

----------------------------------------------------------------------------------------------------------
-- match by 2 of the original attributes: a marine, b land
-- a.uri_sov=b.svrgn_country_uri
-- a.uri_ter = b.country_uri;
DROP TABLE IF EXISTS country_marine_ter_sov_matched4;CREATE TEMPORARY TABLE country_marine_ter_sov_matched4 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov_unmatched3 a 
JOIN country_land_atts_reference b ON a.uri_sov=b.svrgn_country_uri AND a.uri_ter = b.country_uri;

--SELEcT * FROM country_marine_ter_sov_matched4;

INsErT INTO mmatched SELECT DISTINCT mrgid,pos,TRUE m FROM country_marine_ter_sov_matched4;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched4;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched4 AS
SELECT * FROM (SELECT * FROM country_marine_ter_sov a LEFT JOIN mmatched b USING(mrgid,pos)) c
WHERE m IS NULL ORDER BY mrgid,pos;

SELECT * FROM country_marine_ter_sov_unmatched4;

----------------------------------------------------------------------------------------------------------
-- match by 1 of the original attributes: a marine, b land
-- a.cntr_id_ter = b.cntr_id;
DROP TABLE IF EXISTS country_marine_ter_sov_matched5;CREATE TEMPORARY TABLE country_marine_ter_sov_matched5 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov_unmatched4 a 
JOIN country_land_atts_reference b ON a.cntr_id_ter = b.cntr_id;

INsErT INTO mmatched SELECT DISTINCT mrgid,pos,TRUE m FROM country_marine_ter_sov_matched5;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched5;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched5 AS
SELECT * FROM (SELECT * FROM country_marine_ter_sov a LEFT JOIN mmatched b USING(mrgid,pos)) c
WHERE m IS NULL ORDER BY mrgid,pos;

SELECT * FROM country_marine_ter_sov_unmatched5;



DROP TABLE IF EXISTS country_marine_ter_sov_matched6;CREATE TEMPORARY TABLE country_marine_ter_sov_matched6 AS
SELECT a.mrgid,a.pos,b.svrgn_country_uri,b.country_uri,b.name_engl,a.territory
FROM country_marine_ter_sov_unmatched5 a 
JOIN country_land_atts_reference b ON a.uri_sov = b.cntr_id;

--------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS country_marine_ter_sov_matched;CREATE TEMPORARY TABLE country_marine_ter_sov_matched AS
WITH
a AS (
SEleCT * FROM country_marine_ter_sov_matched1
UNION
SEleCT * FROM country_marine_ter_sov_matched2
UNION
SEleCT * FROM country_marine_ter_sov_matched3
UNION
SEleCT * FROM country_marine_ter_sov_matched4
UNION
SEleCT * FROM country_marine_ter_sov_matched5
),
b AS (
SELECT mrgid,
ARRAY_AGG(svrgn_country_uri ORDER BY pos) svrgn_country_uri,
ARRAY_AGG(country_uri ORDER BY pos) country_uri,
ARRAY_AGG(name_engl ORDER BY pos) name_engl,
ARRAY_AGG(territory ORDER BY pos) territory
FROM a GROUP BY mrgid ORDER BY mrgid
)
SELECT
mrgid,
ARRAY_TO_STRING(svrgn_country_uri,'_') m_svrgn_country_uri,
CARDINALITY(svrgn_country_uri) m_sov_count,
ARRAY_TO_STRING(country_uri,'_') m_country_uri,
CARDINALITY(country_uri) m_cntr_count,
ARRAY_TO_STRING(name_engl,';') m_name_engl,
CARDINALITY(name_engl) m_name_count,
ARRAY_TO_STRING(territory,';') m_territory,
CARDINALITY(territory) m_territory_count,
TRUE::bool m_matched
FROM b
ORDER BY mrgid;
SELECT * FROM country_marine_ter_sov_matched;

DROP TABLE IF EXISTS country_marine_ter_sov_unmatched;CREATE TEMPORARY TABLE country_marine_ter_sov_unmatched AS
WITH
a AS (
SELECT mrgid,
ARRAY_AGG(uri_sov ORDER BY pos) uri_sov,
ARRAY_AGG(uri_ter ORDER BY pos) uri_ter,
ARRAY_AGG(cntr_id_ter ORDER BY pos) cntr_id_ter,
ARRAY_AGG(territory ORDER BY pos) territory
FROM country_marine_ter_sov_unmatched5 GROUP BY mrgid ORDER BY mrgid
)
SELECT
mrgid,
ARRAY_TO_STRING(uri_sov,'_') u_uri_sov,
CARDINALITY(uri_sov) u_uri_sov_count,
ARRAY_TO_STRING(uri_ter,'_') u_uri_ter,
CARDINALITY(uri_ter) u_uri_ter_count,
ARRAY_TO_STRING(cntr_id_ter,';') u_cntr_id_ter,
CARDINALITY(cntr_id_ter) u_cntr_id_ter_count,
ARRAY_TO_STRING(territory,';') u_territory,
CARDINALITY(territory) u_territory_count,
FALSE::bool u_matched
FROM a
ORDER BY mrgid;
SELECT * FROM country_marine_ter_sov_unmatched;

DROP TABLE IF EXISTS country_marine_ter_sov_matched_unmatched;CREATE TEMPORARY TABLE country_marine_ter_sov_matched_unmatched AS
SELECT * FROM (
SELECT mrgid,eez_id,svrgn_country_uri,svrgn_country_name
FROM country_marine_sovereign
) a
LEFT JOIN (
SELECT mrgid,m_country_uri,m_cntr_count,m_name_engl,m_name_count,m_territory,m_territory_count,m_matched
FROM country_marine_ter_sov_matched) b USING(mrgid)
LEFT JOIN country_marine_ter_sov_unmatched c USING(mrgid)
ORDER BY mrgid;
SELECT * FROM country_marine_ter_sov_matched_unmatched;

UPdATE country_marine_ter_sov_matched_unmatched SET m_territory = NULL WHERE m_name_engl = m_territory;
UPdATE country_marine_ter_sov_matched_unmatched SET m_territory = SPLIT_PART(m_territory,';',1) WHERE SPLIT_PART(m_territory,';',1) = SPLIT_PART(m_territory,';',2);
UPdATE country_marine_ter_sov_matched_unmatched SET m_name_engl = SPLIT_PART(m_name_engl,';',1) WHERE SPLIT_PART(m_name_engl,';',1) = SPLIT_PART(m_name_engl,';',2);
UPdATE country_marine_ter_sov_matched_unmatched SET m_country_uri = SPLIT_PART(m_country_uri,'_',1) WHERE SPLIT_PART(m_country_uri,'_',1) = SPLIT_PART(m_country_uri,'_',2);
UPdATE country_marine_ter_sov_matched_unmatched SET m_territory = NULL
WHERE m_territory IN (
'Antarctic','Cocos Islands','Comores','Republic of the Congo','Ivory Coast','Democratic Republic of the Congo','Falkland / Malvinas Islands',
'Faeroe','Faeroe;Iceland','Guyane;Venezuela','Heard and McDonald Islands','Iceland;Jan Mayen','Liancourt Rocks','Republic of Mauritius',
'Myanmar','Norway;Russia','Pitcairn','Russia','Saint-Barthélemy','Saint-Pierre and Miquelon','Saint Vincent and the Grenadines',
'Sao Tome and Principe','São Tomé and Principe;Nigeria','Federal Republic of Somalia','South Georgia and the South Sandwich Islands','East Timor',
'Turkey','United Kingdom;Faeroe','Tanzania','United States;Russia','United States Virgin Islands','Vietnam');


SELECT * FROM country_marine_ter_sov_matched_unmatched 
WHERE m_cntr_count != 1 AND (m_name_count = 1 OR m_territory_count = 1)
WHERE svrgn_country_uri != m_country_uri
WHERE m_name_engl != m_territory
ORDER BY m_name_engl,m_territory

SELECT * FROM country_marine_ter_sov_matched_unmatched 
WHERE u_matched IS FALSE

WHERE SPLIT_PART(m_country_uri,'_',1) = SPLIT_PART(m_country_uri,'_',2)





SEleCT * FROM country_marine_ter_sov_unmatched4 whERE uri_ter != ''  AND uri_sov = 'FRA' AND uri_ter IN (
SELECT DISTINCT country_uri FROM country_land_atts_reference WHERE svrgn_country_uri ='FRA');

SELECT * FROM country_land_atts_reference WHERE name_engl ILIKE 'Greece' OR name_engl ILIKE 'UNited King%';




UPDATE country_marine_sov1 SET iso3_code = 'GBR' WHERE iso3_code = 'UK';

DROP TABLE IF EXISTS country_marine_sov2;CREATE TEMPORARY TABLE country_marine_sov2 AS
SELECT mrgid, eez_id, pos, iso3_code, svrgn_country_uri, country_uri, cntr_id, name_engl
FROM country_marine_sov1 a LEFT JOIN country_land_atts_reference b USING(iso3_code);

