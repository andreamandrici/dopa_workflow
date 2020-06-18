DROP TABLE IF EXISTS eco2020_input.teow_ogr_check;
CREATE TABLE eco2020_input.teow_ogr_check AS
SELECT ogc_fid gid,(ST_ISVALIDDETAIL(wkb_geometry)).*,ST_GEOMETRYTYPE(wkb_geometry) FROM eco2020_input.teow_ogr;

DROP TABLE IF EXISTS eco2020_input.teow_shp_check;
CREATE TABLE eco2020_input.teow_shp_check AS
SELECT gid,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM eco2020_input.teow_shp;

DROP TABLE IF EXISTS eco2020_input.teow_shp_d_check;
CREATE TABLE eco2020_input.teow_shp_d_check AS
SELECT gid,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM eco2020_input.teow_shp_d;

DROP TABLE IF EXISTS eco2020_input.meow_ppow_ogr_check;
CREATE TABLE eco2020_input.meow_ppow_ogr_check AS
SELECT ogc_fid gid,(ST_ISVALIDDETAIL(wkb_geometry)).*,ST_GEOMETRYTYPE(wkb_geometry) FROM eco2020_input.meow_ppow_ogr;

DROP TABLE IF EXISTS eco2020_input.meow_ppow_shp_check;
CREATE TABLE eco2020_input.meow_ppow_shp_check AS
SELECT gid,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM eco2020_input.meow_ppow_shp;

DROP TABLE IF EXISTS eco2020_input.meow_ppow_shp_d_check;
CREATE TABLE eco2020_input.meow_ppow_shp_d_check AS
SELECT gid,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM eco2020_input.meow_ppow_shp_d;

SELECT 'teow_ogr' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.teow_ogr_check GROUP BY valid,st_geometrytype
UNION
SELECT 'teow_shp' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.teow_shp_check GROUP BY valid,st_geometrytype
UNION
SELECT 'teow_shp_d' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.teow_shp_d_check GROUP BY valid,st_geometrytype
UNION
SELECT 'meow_ppow_ogr' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.meow_ppow_ogr_check GROUP BY valid,st_geometrytype
UNION
SELECT 'meow_ppow_shp' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.meow_ppow_shp_check GROUP BY valid,st_geometrytype
UNION
SELECT 'meow_ppow_shp_d' source,COUNT(*),valid,st_geometrytype FROM eco2020_input.meow_ppow_shp_d_check GROUP BY valid,st_geometrytype
ORDER BY source,valid,st_geometrytype;
