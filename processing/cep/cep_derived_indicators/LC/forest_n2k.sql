---- ANALYISIS OF FOREST IN NATURA 2000 SITES OVERLAPPING EFFECTIVE PROTECTED AREAS
---- SETUP SOURCES ------------------------------------------------------------------------------------
---- country source
DROP TABLE IF EXISTS s_country; CREATE TEMPORARY TABLE s_country AS (SELECT * FROM
administrative_units.gaul_eez_dissolved_201905);
---- protection source
DROP TABLE IF EXISTS s_protection; CREATE TEMPORARY TABLE s_protection AS (SELECT * FROM
protected_sites.wdpa_201905);
---- cep source
DROP TABLE IF EXISTS s_cep; CREATE TEMPORARY TABLE s_cep AS (SELECT * FROM
cep.cep_201905);
---- cep_landcover source
DROP TABLE IF EXISTS s_cep_esa; CREATE TEMPORARY TABLE s_cep_esa AS (SELECT * FROM
results.cep_esa_cci_ll); -- this is cep_201905 intersected with esa lc 1995-2015
------GET N2K AND PAS LISTS ----------------------------------------------------------------------------
---- get list of N2K from wdpa
DROP TABLE IF EXISTS n2k_list;
CREATE TEMPORARY TABLE n2k_list AS (SELECT DISTINCT wdpaid,name,iso3,area_geo FROM s_protection WHERE metadataid=1832 ORDER BY wdpaid);
---- get list of ePas (effective pas) from wdpa
DROP TABLE IF EXISTS pas_list; CREATE TEMPORARY TABLE pas_list AS (SELECT DISTINCT wdpaid,name,iso3,area_geo FROM s_protection WHERE iucn_cat IN ('Ia','Ib','II') ORDER BY wdpaid);
-----GET QID/CIDS LISTS------------------------------------------------------------------------------
---- get list of N2K qid,cid from cep
DROP TABLE IF EXISTS n2k_cid_list;
CREATE TEMPORARY TABLE n2k_cid_list AS (
SELECT DISTINCT qid,cid FROM n2k_list
NATURAL JOIN (SELECT DISTINCT UNNEST(pa) wdpaid,qid,cid FROM s_cep WHERE pa != ARRAY[NULL::integer]) a
);
---- get list of ePas cid from cep
DROP TABLE IF EXISTS pas_cid_list;
CREATE TEMPORARY TABLE pas_cid_list AS (
SELECT DISTINCT qid,cid FROM pas_list
NATURAL JOIN (SELECT DISTINCT UNNEST(pa) wdpaid,qid,cid FROM s_cep WHERE pa != ARRAY[NULL::integer]) a
);
---- get list of FOREST cid from cep_esa - extract year (band 5 = year 2015) and aggregate surfaces by cid
DROP TABLE IF EXISTS forest_cid_list;
CREATE TEMPORARY TABLE forest_cid_list AS (
SELECT DISTINCT qid,cid FROM s_cep_esa WHERE band=5 AND val IN (50,60,61,62,70,71,72,80,81,82,90)
);
-----JOIN QID/CIDS LISTS------------------------------------------------------------------------------
---- N2K and Forest qid-cid
DROP TABLE IF EXISTS N2K_forest_cid_list;
CREATE TEMPORARY TABLE N2K_forest_cid_list AS (
SELECT DISTINCT qid,cid FROM n2k_cid_list NATURAL JOIN forest_cid_list
);
---- N2K and Forest and ePAS qid-cid
DROP TABLE IF EXISTS N2K_forest_pas_cid_list;
CREATE TEMPORARY TABLE N2K_forest_pas_cid_list AS (
SELECT DISTINCT qid,cid FROM n2k_cid_list NATURAL JOIN forest_cid_list NATURAL JOIN pas_cid_list
);
---- N2K and Forest qid-cid with country labels
DROP TABLE IF EXISTS N2K_forest_cid_country_list;
CREATE TEMPORARY TABLE N2K_forest_cid_country_list AS (
SELECT DISTINCT country_name,iso3,qid,cid
FROM s_country NATURAL JOIN
(SELECT DISTINCT UNNEST(country) country_id,qid,cid FROM s_cep NATURAL JOIN N2K_forest_cid_list) a);
---- N2K and Forest and ePAS qid-cid with country labels
DROP TABLE IF EXISTS N2K_forest_pas_cid_country_list;
CREATE TEMPORARY TABLE N2K_forest_pas_cid_country_list AS (
SELECT DISTINCT country_name,iso3,qid,cid
FROM s_country NATURAL JOIN
(SELECT DISTINCT UNNEST(country) country_id,qid,cid FROM s_cep NATURAL JOIN N2K_forest_pas_cid_list) a);
-----AGGREGATE SURFACES -------------------------------------------------------------------------------------
WITH
a AS (SELECT country_name,iso3,SUM(sqkm) n2k_forest_sqkm FROM N2K_forest_cid_country_list NATURAL JOIN s_cep_esa WHERE band =5  AND val IN (50,60,61,62,70,71,72,80,81,82,90) GROUP BY country_name,iso3 ORDER BY iso3),
b AS (SELECT country_name,iso3,SUM(sqkm) n2k_forest_pa_sqkm FROM N2K_forest_pas_cid_country_list NATURAL JOIN s_cep_esa WHERE band =5  AND val IN (50,60,61,62,70,71,72,80,81,82,90) GROUP BY country_name,iso3 ORDER BY iso3)
SELECT * FROM a LEFT JOIN b USING (country_name,iso3) 
