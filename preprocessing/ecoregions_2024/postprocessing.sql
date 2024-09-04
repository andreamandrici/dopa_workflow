--CREATE TABLE habitats_and_biotopes.ecoregions_2024_atts_old AS SELECT * FROM habitats_and_biotopes.ecoregions_2024_atts;
--CREATE TABLE habitats_and_biotopes.ecoregions_2024_old AS SELECT * FROM habitats_and_biotopes.ecoregions_2024;

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024_atts;CREATE TABLE habitats_and_biotopes.ecoregions_2024_atts AS
WITH a AS (
SELECT * FROM habitats_and_biotopes.ecoregions_2024_atts_old
UNION
SELECT 1,'terrestrial',1141,'119|9999','Dronning Maud Land tundra|Rock and Ice'
UNION
SELECT 1,'terrestrial',1142,'124|9999','Marie Byrd Land tundra|Rock and Ice'
UNION
SELECT 1,'terrestrial',1143,'134|9999','Transantarctic Mountains tundra|Rock and Ice'
)
SELECT eco_id,eco_name,source,ord,original_eco_id FROM a ORDER BY ord,eco_id;
SELECT * FROM habitats_and_biotopes.ecoregions_2024_atts;

DROP TABLE IF EXISTS ecoregions_2024_qid_cid;CREATE TEMPORARY TABLE ecoregions_2024_qid_cid AS
SELECT DISTINCT qid,cid,ord,source,ARRAY_TO_STRING(eco_id,'|') original_eco_id
FROM habitats_and_biotopes.ecoregions_2024
ORDER BY qid,cid,ord,original_eco_id;
SELECT * FROM ecoregions_2024_qid_cid;

DROP TABLE IF EXISTS ecoregions_2024_qid_cid_atts;CREATE TEMPORARY TABLE ecoregions_2024_qid_cid_atts AS
SELECT qid,cid,eco_id,eco_name,ord,source,original_eco_id
FROM ecoregions_2024_qid_cid a
JOIN habitats_and_biotopes.ecoregions_2024_atts b USING(ord,source,original_eco_id)
ORDER BY qid,eco_id;
SELECT * FROM ecoregions_2024_qid_cid_atts;

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024_reagg1;CREATE TABLE habitats_and_biotopes.ecoregions_2024_reagg1 AS
SELECT a.qid,a.eco_id,a.eco_name,b.geom,NULL::double precision sqkm
FROM ecoregions_2024_qid_cid_atts a
JOIN habitats_and_biotopes.ecoregions_2024 b USING(qid,cid)
ORDER BY a.qid,a.eco_id;

SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg1;
SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg1;

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024_reagg2;CREATE TABLE habitats_and_biotopes.ecoregions_2024_reagg2 AS
SELECT qid,eco_id,(ST_DUMP(geom)).*,sqkm
FROM habitats_and_biotopes.ecoregions_2024_reagg1
ORDER BY qid,eco_id,path;

SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg2;
SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg2;

UPDATE habitats_and_biotopes.ecoregions_2024_reagg2
SET sqkm=(ST_AREA(geom::geography))/1000000;
---	
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024_reagg3;CREATE TABLE habitats_and_biotopes.ecoregions_2024_reagg3 AS
SELECT qid,eco_id,ST_UNION(geom) geom,SUM(sqkm) sqkm
FROM habitats_and_biotopes.ecoregions_2024_reagg2
GROUP BY qid,eco_id
ORDER BY qid,eco_id;

SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg3;
SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg3;

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024_reagg4;CREATE TABLE habitats_and_biotopes.ecoregions_2024_reagg4 AS
SELECT qid,eco_id,ST_MULTI(geom) geom,sqkm FROM habitats_and_biotopes.ecoregions_2024_reagg3 WHERE ST_GEOMETRYTYPE(geom) = 'ST_Polygon'
UNION
SELECT qid,eco_id,geom,sqkm FROM habitats_and_biotopes.ecoregions_2024_reagg3 WHERE ST_GEOMETRYTYPE(geom) != 'ST_Polygon'
ORDER BY qid,eco_id;

SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg4;
SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.ecoregions_2024_reagg4;

SELECT * FROM habitats_and_biotopes.ecoregions_2024_atts LIMIT 1

DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions_2024;CREATE TABLE habitats_and_biotopes.ecoregions_2024 AS
SELECT qid,eco_id,eco_name,ord,source,geom,sqkm FROM habitats_and_biotopes.ecoregions_2024_reagg4 JOIN habitats_and_biotopes.ecoregions_2024_atts USING(eco_id)
ORDER BY qid,ord,eco_id;
ALTER TABLE habitats_and_biotopes.ecoregions_2024 ADD PRIMARY KEY(qid,eco_id);
CREATE INDEX ON habitats_and_biotopes.ecoregions_2024 USING GIST(geom);
