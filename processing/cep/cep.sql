DROP TABLE IF EXISTS cep.cep_202003;
DROP TABLE IF EXISTS cep.cep_202003_total_index;
CREATE TABLE cep.cep_202003
(
    qid integer,
    cid bigint,
    country integer[],
    eco integer[],
    pa integer[],
    sqkm double precision,
    geom geometry
);
INSERT INTO cep.cep_202003 SELECT qid,cid,country,ecoregion,wdpa,sqkm,geom FROM cep202003.h_flat ORDER BY qid,cid;
SELECT cep.f_get_latest_cep();
DROP TABLE IF EXISTS cep.cep_last_index;
CREATE TABLE cep.cep_202003_total_index AS
WITH
a AS (SELECT qid,cid,u.* FROM cep.cep_last,UNNEST(country,eco,pa) AS u(country,eco,pa))
SELECT
a.qid,
a.cid,
a.country,
b.country_name,
b.iso3,
a.eco,
c.first_level eco_name,
CASE WHEN c.source IN ('teow','eeow') THEN false::bool ELSE true::bool END is_marine,
a.pa,
d."name" pa_name,
CASE a.pa WHEN 0 THEN false::bool ELSE true::bool END is_protected
FROM a
LEFT JOIN administrative_units.gaul_eez_dissolved_201912 b ON a.country=b.country_id
LEFT JOIN habitats_and_biotopes.ecoregions_2019 c ON a.eco=c.first_level_code
LEFT JOIN protected_sites.wdpa_202003 d ON a.pa=d.wdpaid
ORDER BY a.qid,a.cid;
CREATE TABLE cep.cep_last_index AS SELECT * FROM cep.cep_202003_total_index;
