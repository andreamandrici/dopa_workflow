DROP TABLE IF EXISTS cntr_atts;CREATE TEMPORARY TABLE cntr_atts AS
SELECT country_id,svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso3,iso2,
CASE WHEN svrg_un IN ('Overlapping claim','Joint regime','Sovereignty unsettled','Non-member observer state')  AND  country_id != 10 THEN 'complex' ELSE NULL END status,
SUM(sqkm) vsqkm
FROM cep_data_202601.atts_country
GROUP BY country_id,svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso3,iso2,status
ORDER BY country_id,status;--319
SELECT * FROM cntr_atts ;

--total country surface
DROP TABLE IF EXISTS cntr_prt1; CREATE TEMPORARY TABLE cntr_prt1 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--320

--protected country surface
DROP TABLE IF EXISTS cntr_prt2; CREATE TEMPORARY TABLE cntr_prt2 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index WHERE is_protected IS TRUE),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--279


--land country surface
DROP TABLE IF EXISTS cntr_prt3; CREATE TEMPORARY TABLE cntr_prt3 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index WHERE is_marine IS FALSE),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--263

--protected land country surface
DROP TABLE IF EXISTS cntr_prt4; CREATE TEMPORARY TABLE cntr_prt4 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index WHERE is_protected IS TRUE AND is_marine IS FALSE),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--247

--marine country surface
DROP TABLE IF EXISTS cntr_prt5; CREATE TEMPORARY TABLE cntr_prt5 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index WHERE is_marine IS TRUE),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--248

--protected marine country surface
DROP TABLE IF EXISTS cntr_prt6; CREATE TEMPORARY TABLE cntr_prt6 AS
WITH
a AS (SELECT DISTINCT country_id,qid,cid FROM cep_data_202601.cep_index WHERE is_protected IS TRUE AND is_marine IS TRUE),
b AS (SELECT DISTINCT qid,cid,sqkm FROM cep_data_202601.cep_index)
SELECT country_id,SUM(sqkm) sqkm FROM a JOIN b USING(qid,cid) GROUP BY country_id ORDER BY country_id;
--218

---check from here
DROP TABLE IF EXISTS cep_index_country_protection;CREATE TEMPORARY TABLE cep_index_country_protection AS
SELECT z.*,
a.sqkm country_tot_sqkm,
COALESCE(b.sqkm,0) country_tot_prot_sqkm,
COALESCE(c.sqkm,0) country_land_sqkm,
COALESCE(d.sqkm,0) country_land_prot_sqkm,
COALESCE(e.sqkm,0) country_marine_sqkm,
COALESCE(f.sqkm,0) country_marine_prot_sqkm
FROM cntr_atts z
LEFT JOIN cntr_prt1 a USING(country_id)
LEFT JOIN cntr_prt2 b USING(country_id)
LEFT JOIN cntr_prt3 c USING(country_id)
LEFT JOIN cntr_prt4 d USING(country_id)
LEFT JOIN cntr_prt5 e USING(country_id)
LEFT JOIN cntr_prt6 f USING(country_id)
;
SELECT * FROM cep_index_country_protection;

DROP TABLE IF EXISTS cep_data_202601.country_all_inds;CREATE TABLE cep_data_202601.country_all_inds AS
SELECT
    country_id,svrgn_country_uri,svrgn_country_name,country_uri,country_name,iso3,iso2,status,vsqkm country_tot_v_sqkm,
    country_tot_sqkm,country_tot_prot_sqkm,country_tot_prot_sqkm / NULLIF(country_tot_sqkm, 0) * 100 AS country_prot_perc_country_tot,
    country_land_sqkm,country_land_sqkm / NULLIF(country_tot_sqkm, 0) * 100 AS country_land_perc_country_tot,
    country_land_prot_sqkm,country_land_prot_sqkm / NULLIF(country_land_sqkm, 0) * 100 AS country_land_prot_perc_country_land,
	country_marine_sqkm,country_marine_sqkm / NULLIF(country_tot_sqkm, 0) * 100 AS country_marine_perc_country_tot,
	country_marine_prot_sqkm,country_marine_prot_sqkm / NULLIF(country_marine_sqkm, 0) * 100 AS country_marine_prot_perc_country_marine
FROM cep_index_country_protection
ORDER BY country_id;
SELECT * FROM cep_data_202601.country_all_inds;
