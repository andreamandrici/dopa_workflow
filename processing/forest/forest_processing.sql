-- -- CALCULATE N2K RASTER SURFACE
-- DROP TABLE IF EXISTS forest.n2k_raster_surface;
-- CREATE TABLE forest.n2k_raster_surface AS
-- WITH
-- -- list qid,cid,esa_cat raster surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k) GROUP BY cid)
-- -- N2k raster surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST SURFACE
-- CREATE TABLE forest.n2k_forest_surface AS
-- WITH
-- -- list qid,cid,esa_cat forest surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k)
-- 	  AND val IN (50,60,61,62,70,71,72,80,81,82,90)
-- 	 GROUP BY cid)
-- -- N2k forest surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K PROTECTED SURFACE
-- CREATE TABLE forest.n2k_protected_surface AS
-- WITH
-- -- list cid,esa_cat protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K PROTECTED I SURFACE
-- CREATE TABLE forest.n2k_protected_surface_I AS
-- WITH
-- -- list cid,esa_cat protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa WHERE wdpaid_I IS NOT NULL)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- CALCULATE N2K PROTECTED II SURFACE
-- CREATE TABLE forest.n2k_protected_surface_II AS
-- WITH
-- -- list cid,esa_cat protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa WHERE wdpaid_II IS NOT NULL)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST PROTECTED SURFACE
-- CREATE TABLE forest.n2k_forest_protected_surface AS
-- WITH
-- -- list cid,esa_cat forest protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa)
-- 	  AND val IN (50,60,61,62,70,71,72,80,81,82,90)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST PROTECTED I SURFACE
-- CREATE TABLE forest.n2k_forest_protected_surface_I AS
-- WITH
-- -- list cid,esa_cat forest protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa WHERE wdpaid_I IS NOT NULL)
-- 	  AND val IN (50,60,61,62,70,71,72,80,81,82,90)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- CALCULATE N2K FOREST PROTECTED II SURFACE
-- CREATE TABLE forest.n2k_forest_protected_surface_II AS
-- WITH
-- -- list cid,esa_cat forest protected surface
-- a AS (SELECT cid,SUM(sqkm) sqkm FROM forest.cep_esa
-- 	  WHERE cid IN (SELECT DISTINCT cid FROM forest.cid_n2k_pa WHERE wdpaid_II IS NOT NULL)
-- 	  AND val IN (50,60,61,62,70,71,72,80,81,82,90)
-- 	  GROUP BY cid)
-- -- N2k protected surface
-- SELECT wdpaid,SUM(sqkm) sqkm FROM forest.cid_n2k NATURAL JOIN a GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- IDENTIFY N2K OVERLAPPING N2K
-- CREATE TABLE forest.n2k_overlaps AS
-- SELECT
-- a.wdpaid,ARRAY_AGG(DISTINCT b.wdpaid ORDER BY b.wdpaid) overlapping_n2k
-- FROM forest.cid_n2k a JOIN forest.cid_n2k b USING(cid) WHERE a.wdpaid <> b.wdpaid GROUP BY a.wdpaid ORDER BY a.wdpaid;
------------------------------------------------------------------------
-- -- IDENTIFY N2K OVERLAPPING PA I
-- DROP TABLE IF EXISTS forest.n2k_overlaps_IUCN_I;
-- CREATE TABLE forest.n2k_overlaps_IUCN_I AS
-- SELECT wdpaid,ARRAY_AGG(DISTINCT wdpaid_i ORDER BY wdpaid_i) overlapping_IUCN_I
-- FROM (SELECT DISTINCT wdpaid,UNNEST(wdpaid_i) wdpaid_I FROM forest.cid_n2k a JOIN forest.cid_n2k_pa b USING(cid) WHERE wdpaid_I IS NOT NULL) a
-- GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- -- IDENTIFY N2K OVERLAPPING PA II
-- DROP TABLE IF EXISTS forest.n2k_overlaps_IUCN_II;
-- CREATE TABLE forest.n2k_overlaps_IUCN_II AS
-- SELECT wdpaid,ARRAY_AGG(DISTINCT wdpaid_ii ORDER BY wdpaid_ii) overlapping_IUCN_II
-- FROM (SELECT DISTINCT wdpaid,UNNEST(wdpaid_ii) wdpaid_II FROM forest.cid_n2k a JOIN forest.cid_n2k_pa b USING(cid) WHERE wdpaid_II IS NOT NULL) a
-- GROUP BY wdpaid ORDER BY wdpaid;
------------------------------------------------------------------------
-- FINAL TABLE
DROP TABLE IF EXISTS forest.n2k_coverages;
CREATE TABLE forest.n2k_coverages AS
SELECT
a.*,
j.overlapping_n2k,
k.overlapping_IUCN_I,
l.overlapping_IUCN_II,
b.sqkm r_sqkm,
c.sqkm f_sqkm,
d.sqkm p_sqkm,
e.sqkm pI_sqkm,
f.sqkm pII_sqkm,
g.sqkm fp_sqkm,
h.sqkm fpI_sqkm,
i.sqkm fpII_sqkm
FROM forest.n2k a
LEFT JOIN forest.n2k_raster_surface b USING(wdpaid)
LEFT JOIN forest.n2k_forest_surface c USING(wdpaid)
LEFT JOIN forest.n2k_protected_surface d USING(wdpaid)
LEFT JOIN forest.n2k_protected_surface_I e USING(wdpaid)
LEFT JOIN forest.n2k_protected_surface_II f USING(wdpaid)
LEFT JOIN forest.n2k_forest_protected_surface g USING(wdpaid)
LEFT JOIN forest.n2k_forest_protected_surface_I h USING(wdpaid)
LEFT JOIN forest.n2k_forest_protected_surface_II i USING(wdpaid)
LEFT JOIN forest.n2k_overlaps j USING(wdpaid)
LEFT JOIN forest.n2k_overlaps_IUCN_I k USING(wdpaid)
LEFT JOIN forest.n2k_overlaps_IUCN_II l USING(wdpaid)
ORDER BY wdpaid;


