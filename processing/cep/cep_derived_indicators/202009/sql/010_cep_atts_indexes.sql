-------------------------------------------------------------------------------------
-- SETTINGS BLOCK: CHANGE HERE TO UPDATE DATA (BACKUP THE current cep,cep_indexes,t_atts)
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep.atts_country_last;CREATE TABLE cep.atts_country_last AS -- COUNTRY ATTRIBUTES
SELECT country_id country,country_name,iso3,iso2,un_m49,status FROM administrative_units.gaul_eez_dissolved_201912;
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep.atts_ecoregion_last;CREATE TABLE cep.atts_ecoregion_last AS -- ECOREGION ATTRIBUTES
SELECT first_level_code ecoregion,first_level ecoregion_name,second_level_code,second_level,third_level_code,third_level,source,
CASE WHEN source IN ('eeow','teow') THEN FALSE ELSE TRUE END is_marine
FROM habitats_and_biotopes.ecoregions_2020_atts;
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep.atts_pa_last;CREATE TABLE cep.atts_pa_last AS -- WDPA ATTRIBUTES
SELECT wdpaid pa,name pa_name,desig_eng,iucn_cat,marine,CASE WHEN metadataid=1832 THEN TRUE ELSE FALSE END is_n2k,iso3,type,area_geo
FROM protected_sites.wdpa_202009;
-----------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep.grid_vector;CREATE TABLE cep.grid_vector AS
SELECT eid::text||'_'||qid::text eid_qid,eid,qid,row,col,ST_YMAX(geom) y_max,ST_YMIN(geom) y_min,ST_XMAX(geom) x_max,ST_XMIN(geom) x_min,qfilter,sqkm,geom
FROM cep202009.z_grid -- GRID EID-QID
ORDER BY eid,qid;
ALTER TABLE cep.grid_vector ADD PRIMARY KEY (qid);CREATE INDEX ON cep.grid_vector USING gist(geom);
---------------------------------------------------------------------------------------
-- END OF SETTINGS BLOCK
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS cep.grid_raster;CREATE TABLE cep.grid_raster AS
SELECT eid,ST_UNION(ST_AsRaster(geom,rast,'16BUI',qid,0)) rast
FROM cep.grid_vector a,
(SELECT ST_MakeEmptyRaster(360,180,-180,90,(1::double precision),(-1::double precision),0,0,4326) rast) b
WHERE ST_INTERSECTS(a.geom,b.rast) GROUP BY eid ORDER BY eid;
ALTER TABLE cep.grid_raster ADD PRIMARY KEY(eid);
CREATE INDEX ON cep.grid_raster USING gist(ST_ConvexHull(rast));
SELECT AddRasterConstraints('cep'::name,'grid_raster'::name,'rast'::name);
SELECT (ST_MetaData(rast)).* FROM cep.grid_raster;
---------------------------------------------------------------------------------------
DROP TABLE IF EXISTS country_eco;CREATE TEMPORARY TABLE country_eco AS
WITH
a AS (SELECT qid,cid,UNNEST(country) country,UNNEST(eco) ecoregion,CASE WHEN 0=ANY(pa) THEN false ELSE true END is_protected, sqkm FROM cep.cep_last),
b AS (SELECT country,country_name,iso3 FROM cep.atts_country_last),
c AS (SELECT ecoregion,ecoregion_name,source,is_marine FROM cep.atts_ecoregion_last),
d AS (SELECT qid,cid,country,country_name,iso3,ecoregion,ecoregion_name,source,is_marine,is_protected,sqkm FROM a JOIN b USING (country) JOIN c USING (ecoregion))
SELECT * FROM d;
---------------------------------------------------------------------------------------
-- OUTPUT BLOCK
---------------------------------------------------------------------------------------
-- COUNTRY
DROP TABLE IF EXISTS cep.index_country_cep_last;CREATE TABLE cep.index_country_cep_last AS
SELECT country,country_name,iso3,is_marine,is_protected,qid,cid,sqkm FROM country_eco ORDER BY country,qid,cid;
-- ECOREGION
DROP TABLE IF EXISTS cep.index_ecoregion_cep_last;CREATE TABLE cep.index_ecoregion_cep_last AS
SELECT ecoregion,ecoregion_name,source,is_marine,is_protected,qid,cid,sqkm FROM country_eco ORDER BY ecoregion,qid,cid;
-- PA
DROP TABLE IF EXISTS cep.index_pa_cep_last;CREATE TABLE cep.index_pa_cep_last AS
WITH
a AS (SELECT UNNEST(pa) pa,qid,cid,sqkm FROM cep.cep_last WHERE 0!=ANY(pa))
SELECT pa,pa_name,iso3,marine,type,qid,cid,sqkm FROM a JOIN cep.atts_pa_last b USING(pa) ORDER BY pa,qid,cid;
