WITH
-- SELECT non protected areas AND oecm wdpaid to be filtered out  
no_prot AS (
SELECT cid FROM cep.cep_202003_oecm WHERE ARRAY[0] && pa
---------------------------------------------------------------------------------------------------------------------
-- !!! UNCOMMENT THE FOLLOWING TWO LINES TO INCLUDE OR NOT OECMs !!!!
---------------------------------------------------------------------------------------------------------------------
--UNION	
--SELECT * FROM (SELECT * FROM cep.cep_202003_oecm_cid_non_oecm) oecm -- this table is calculated in an external step
---------------------------------------------------------------------------------------------------------------------	
ORDER BY cid),
-- current ecoregions
current_ecoregion AS (SELECT * FROM habitats_and_biotopes.ecoregions_2020),--this defines current attributes 
-- raster total surface
a1 AS (SELECT ecoregion fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(ecoregion) ecoregion,sqkm FROM cep.cep_202003_oecm) a GROUP BY ecoregion ORDER BY ecoregion),
-- raster protected surface
a2 AS (SELECT ecoregion fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(ecoregion) ecoregion,sqkm FROM cep.cep_202003_oecm WHERE cid NOT IN (SELECT DISTINCT cid FROM no_prot)) a GROUP BY ecoregion ORDER BY ecoregion),
-- ecoregion attributes
b AS (SELECT first_level_code fid,first_level "name","source",r_sqkm sqkm FROM current_ecoregion ORDER BY fid),
-- raster statistics by ecoregions
d AS (SELECT a1.fid,a1.rtotsqkm,a2.rprotsqkm,b.name,b.source,b.sqkm,round((a1.rtotsqkm / b.sqkm * 100::double precision)::numeric, 2) AS ratio_rv,round((a2.rprotsqkm / a1.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1 LEFT JOIN a2 USING (fid) JOIN b USING (fid)),
-- vector and raster statistics by ecoregions
e AS (SELECT d.fid,d.name,d.source,d.sqkm AS tot_vector_sqkm,d.rtotsqkm AS tot_raster_sqkm,d.ratio_rv,d.rprotsqkm AS prot_raster_sqkm,d.perc_prot FROM d)
SELECT * FROM e

