-- -- CALCULATE N2K RASTER SURFACE
-- CREATE TABLE forest.n2k_raster_surface AS
-- WITH
-- -- list qid,cid,esa_cat raster surface
-- a AS (SELECT * FROM forest.cep_esa WHERE cid IN (SELECT cid FROM forest.n2k_cid)),
-- -- cid raster surface
-- b AS (SELECT cid,SUM(sqkm) sqkm FROM a GROUP BY cid ORDER BY cid)
-- -- N2k raster surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN b GROUP BY wdpaid ORDER BY wdpaid;
----------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST SURFACE
-- CREATE TABLE forest.n2k_forest_surface AS
-- WITH
-- -- list qid,cid,esa_cat raster surface
-- a AS (SELECT * FROM forest.cep_esa WHERE cid IN (SELECT cid FROM forest.n2k_cid) AND val IN (50,60,61,62,70,71,72,80,81,82,90)),
-- -- cid raster surface
-- b AS (SELECT cid,SUM(sqkm) sqkm FROM a GROUP BY cid ORDER BY cid)
-- -- N2k raster surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN b GROUP BY wdpaid ORDER BY wdpaid;
----------------------------------------------------------------------------
-- -- CALCULATE N2K PROTECTED SURFACE
-- CREATE TABLE forest.n2k_protected_surface AS
-- WITH
-- -- list qid,cid,esa_cat raster surface
-- a AS (SELECT * FROM forest.cep_esa WHERE cid IN (SELECT cid FROM forest.n2k_pa_cid)),
-- -- cid raster surface
-- b AS (SELECT cid,SUM(sqkm) sqkm FROM a GROUP BY cid ORDER BY cid)
-- -- N2k raster surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN b GROUP BY wdpaid ORDER BY wdpaid;
----------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST SURFACE
-- CREATE TABLE forest.n2k_forest_protected_surface AS
-- WITH
-- -- list qid,cid,esa_cat raster surface
-- a AS (SELECT * FROM forest.cep_esa WHERE cid IN (SELECT cid FROM forest.n2k_pa_cid) AND val IN (50,60,61,62,70,71,72,80,81,82,90)),
-- -- cid raster surface
-- b AS (SELECT cid,SUM(sqkm) sqkm FROM a GROUP BY cid ORDER BY cid)
-- -- N2k raster surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN b GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------------------
-- CALCULATES N2K COVERAGES: vector area, raster area (300 sqkm ESA resolution), protected area, forest area, forest protected area  
CREATE TABLE forest.n2k_coverages AS
WITH
a AS (SELECT wdpaid,name,area_geo v_sqkm FROM protected_sites.wdpa_201905 WHERE wdpaid IN (SELECT DISTINCT wdpaid FROM forest.n2k)),
b AS (SELECT * FROM forest.n2k_raster_surface),
c AS (SELECT * FROM forest.n2k_protected_surface),
d AS (SELECT * FROM forest.n2k_forest_surface),
e AS (SELECT * FROM forest.n2k_forest_protected_surface),
f AS (
SELECT
a.*,
b.sqkm r_sqkm,
c.sqkm f_sqkm,
d.sqkm p_sqkm,
e.sqkm fp_sqkm
FROM a
LEFT JOIN b USING(wdpaid)
LEFT JOIN c USING(wdpaid)
LEFT JOIN d USING(wdpaid)
LEFT JOIN e USING(wdpaid)
),
g AS (
SELECT wdpaid,name,v_sqkm,COALESCE(r_sqkm,0) r_sqkm,COALESCE(f_sqkm,0) f_sqkm,COALESCE(p_sqkm,0) p_sqkm,COALESCE(fp_sqkm,0) fp_sqkm
FROM f
)
SELECT * FROM g