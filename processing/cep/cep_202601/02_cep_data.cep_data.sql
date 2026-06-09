DROP SCHEMA IF EXISTS cep_data_202601 CASCADE;CREATE SCHEMA cep_data_202601;
---------------------------------------------------------------------------------------
-- COUNTRY GISCO
DROP TABLE IF EXISTS cep_data_202601.country;CREATE TABLE cep_data_202601.country AS
SELECT * FROM gisco_26.country;--<-- CHECK
---------------------------------------------------------------------------------------
-- ATTS COUNTRY
DROP TABLE IF EXISTS cep_data_202601.atts_country;CREATE TABLE cep_data_202601.atts_country AS -- COUNTRY ATTRIBUTES
SELECT * FROM cep_data_202601.country;
ALTER TABLE cep_data_202601.atts_country DROP COLUMN geom;
---------------------------------------------------------------------------------------
-- ATTS PA
DROP TABLE IF EXISTS cep_data_202601.atts_pa;CREATE TABLE cep_data_202601.atts_pa AS -- WDPA ATTRIBUTES
SELECT site_id pa,name pa_name,desig_eng,iucn_cat,marine,CASE WHEN metadataid=1832 THEN TRUE ELSE FALSE END is_n2k,prnt_iso3,iso3,type,area_geo
FROM protected_sites.wdpa_wdoecm_202601;--<-- CHECK
---------------------------------------------------------------------------------------
--CEP
DROP TABLE IF EXISTS cep_data_202601.cep;CREATE TABLE cep_data_202601.cep AS
SELECT qid,cid,geom,country,wdpa pa,sqkm FROM cep202601.h_flat ORDER BY qid,cid;--<-- CHECK
ALTER TABLE cep_data_202601.cep ADD PRIMARY KEY(qid,cid);
CREATE INDEX cep_geom_idx ON cep_data_202601.cep USING gist(geom);
CREATE INDEX cep_country_idx ON cep_data_202601.cep USING gin(country);
CREATE INDEX cep_pa_idx ON cep_data_202601.cep USING gin(pa);
---------------------------------------------------------------------------------------
--CEP INDEX
DROP TABLE IF EXISTS cep_data_202601.cep_index;CREATE TABLE cep_data_202601.cep_index AS
WITH
a1 AS (SELECT qid,cid,UNNEST(country)country FROM cep_data_202601.cep),
a2 AS (SELECT qid,cid,UNNEST(pa)pa FROM cep_data_202601.cep),
a AS (SELECT qid,cid,a1.country,a2.pa,sqkm FROM cep_data_202601.cep a JOIN a1 USING(qid,cid) JOIN a2 USING(qid,cid))
SELECT qid,cid,country_id,country country_pid,svrgn_country_uri,svrgn_country_name,country_uri,country_name,
CASE WHEN source = 'land' THEN FALSE WHEN source = 'marine' THEN TRUE ELSE source::bool END is_marine,
CASE WHEN pa = 0 THEN FALSE WHEN pa > 0 THEN TRUE ELSE pa::bool END is_protected,
pa,pa_name,a.sqkm
FROM a
LEFT JOIN cep_data_202601.atts_country b ON a.country=b.country_pid
LEFT JOIN cep_data_202601.atts_pa c USING(pa)
ORDER BY qid,cid,country_pid,pa;
---------------------------------------------------------------------------------------
-- COUNTRY_CEP INDEX
DROP TABLE IF EXISTS cep_data_202601.index_country_cep;CREATE TABLE cep_data_202601.index_country_cep AS
WITH
a AS (SELECT DISTINCT country_id,country_pid,svrgn_country_uri,svrgn_country_name,country_uri,country_name,qid,cid FROM cep_data_202601.cep_index)
SELECT a.*,b.sqkm FROM a JOIN cep_data_202601.cep b USING(qid,cid) ORDER BY country,qid,cid;
---------------------------------------------------------------------------------------
-- PA_CEP INDEX
DROP TABLE IF EXISTS cep_data_202601.index_pa_cep;CREATE TABLE cep_data_202601.index_pa_cep AS
WITH
a AS (SELECT DISTINCT pa,qid,cid FROM cep_data_202601.cep_index WHERE pa !=0)
SELECT a.pa,pa_name,prnt_iso3,iso3,marine,type,is_n2k,qid,cid,sqkm FROM a
JOIN cep_data_202601.atts_pa b USING(pa) 
JOIN cep_data_202601.cep c USING(qid,cid)
ORDER BY pa,qid,cid;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- PA_MASK
DROP TABLE IF EXISTS cep_data_202601.pa_mask;CREATE TABLE cep_data_202601.pa_mask AS
SELECT * FROM cep202601_pa_mask.o_vector ORDER BY qid,cid;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- PA_BUFFERS
DROP TABLE IF EXISTS cep_data_202601.pa_buffers;CREATE TABLE cep_data_202601.pa_buffers AS
SELECT qid,cid,pa_buffers,geom,sqkm
FROM cep_202601_pa_buff.h_flat
ORDER BY qid,cid,pa_buffers;
-- PA_BUFFERS INDEX
DROP TABLE IF EXISTS cep_data_202601.index_pa_buffers;CREATE TABLE cep_data_202601.index_pa_buffers AS
WITH
a AS (SELECT DISTINCT qid,cid,UNNEST(pa_buffers)pa FROM cep_data_202601.pa_buffers)
SELECT a.pa,qid,cid,sqkm FROM a JOIN cep_data_202601.pa_buffers USING(qid,cid) ORDER BY pa,qid,cid;
