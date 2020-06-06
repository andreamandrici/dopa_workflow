-- -- EXTRACT INVALID WDPAs
-- CREATE TABLE protected_sites.wdpa_geom_202006_nv01 AS SELECT * FROM protected_sites.wdpa_geom_202006 WHERE ST_ISVALID(geom) = FALSE;

---- DUMP AND MARK INVALID SINGLE POLYS
-- DROP TABLE IF EXISTS protected_sites.wdpa_geom_202006_nv02;
-- CREATE TABLE protected_sites.wdpa_geom_202006_nv02 AS
-- SELECT wdpaid,UNNEST(path) ipath,geom,(ST_ISVALIDDETAIL(geom)).* FROM (SELECT wdpaid,(ST_DUMP(geom)).* FROM protected_sites.wdpa_geom_202006_nv01) a1;

-- -- FIX,DUMP,MARK INVALID SINGLE POLYS
-- DROP TABLE IF EXISTS protected_sites.wdpa_geom_202006_nv03; CREATE TABLE protected_sites.wdpa_geom_202006_nv03 AS
-- SELECT wdpaid,ipath,UNNEST(path) opath,geom,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM
-- (SELECT wdpaid,ipath,(ST_DUMP(ST_MULTI(ST_MAKEVALID(geom)))).* FROM protected_sites.wdpa_geom_202006_nv02 WHERE valid = FALSE) a1;

-- -- CHECK RESULTS
-- SELECT * FROM protected_sites.wdpa_geom_202006_nv03 WHERE opath > 1 OR valid = FALSE or st_geometrytype != 'ST_Polygon';

-- -- FIX INVALID WPDAs (merge valid and invalid polys within the same WDPA)
-- DROP TABLE IF EXISTS protected_sites.wdpa_geom_202006_nv04; CREATE TABLE protected_sites.wdpa_geom_202006_nv04 AS
-- SELECT wdpaid,ST_MULTI(ST_COLLECT(geom ORDER BY ipath)) geom FROM (
-- SELECT wdpaid,ipath,geom FROM protected_sites.wdpa_geom_202006_nv02 WHERE valid = TRUE
-- UNION ALL
-- SELECT wdpaid,ipath,geom FROM protected_sites.wdpa_geom_202006_nv03) a1
-- GROUP BY wdpaid ORDER BY wdpaid;

-- -- FIX WPDAs
DROP TABLE IF EXISTS protected_sites.wdpa_geom_202006_fixed; CREATE TABLE protected_sites.wdpa_geom_202006_fixed AS
SELECT a.wdpaid,a.parcels,a.type,b.geom,TRUE FROM protected_sites.wdpa_geom_202006_nv01 a JOIN protected_sites.wdpa_geom_202006_nv04 b USING(wdpaid);
