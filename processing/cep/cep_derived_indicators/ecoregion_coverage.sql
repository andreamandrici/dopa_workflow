DROP TABLE IF EXISTS cep202009.ecoregion_stats;CREATE TABLE cep202009.ecoregion_stats AS -- this defines output table; change it accordingly
-- current ecoregions
WITH current_ecoregion AS (SELECT * FROM habitats_and_biotopes.ecoregions_2020_atts),-- this defines current attributes; change it accordingly
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
-- raster total surface
a1 AS (SELECT ecoregion fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(eco) ecoregion,sqkm FROM cep.cep_last) a GROUP BY ecoregion ORDER BY ecoregion),
-- raster protected surface
a2 AS (SELECT ecoregion fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(eco) ecoregion,sqkm FROM cep.cep_last WHERE NOT (ARRAY[0] && pa)) a GROUP BY ecoregion ORDER BY ecoregion),
-- ecoregion attributes
b AS (SELECT first_level_code fid,first_level "name","source",sqkm FROM current_ecoregion ORDER BY fid),
-- objects assigned to multiple ecoregions (by qid) 
c AS (SELECT qid,eco,cardinality(eco) AS cardinality FROM cep.cep_last WHERE cardinality(eco) <> 1),
-- ecoregions assigned to multiple object (by ecoid)
c1 AS (SELECT DISTINCT unnest(eco) AS fid,'check_cardinality'::text AS note FROM c),
-- raster statistics by ecoregions
d AS (SELECT a1.fid,a1.rtotsqkm,a2.rprotsqkm,b.name,b.source,b.sqkm,round((a1.rtotsqkm / b.sqkm * 100::double precision)::numeric, 2) AS ratio_rv,round((a2.rprotsqkm / a1.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1 LEFT JOIN a2 USING (fid) JOIN b USING (fid)),
-- difference within raster and vector total surface 
d1 AS (SELECT d.fid,'check_ratio'::text AS note FROM d WHERE d.ratio_rv >= 100.5 OR d.ratio_rv <= 99.5),
-- vector and raster statistics by ecoregions
e AS (SELECT d.fid,d.name,d.source,d.sqkm AS tot_vector_sqkm,d.rtotsqkm AS tot_raster_sqkm,d.ratio_rv,d.rprotsqkm AS prot_raster_sqkm,d.perc_prot FROM d),
-- notes by ecoregion
notes AS (SELECT DISTINCT a.fid,a.note FROM (SELECT c1.fid,c1.note FROM c1 UNION ALL SELECT d1.fid,d1.note FROM d1) a),
-- complete statistics and notes
f AS (SELECT DISTINCT e.fid,e.name,e.source,e.tot_vector_sqkm,e.tot_raster_sqkm,e.ratio_rv,e.prot_raster_sqkm,e.perc_prot,notes.note FROM e LEFT JOIN notes USING (fid) ORDER BY e.fid)
SELECT f.fid,f.name,f.source,f.tot_vector_sqkm,f.tot_raster_sqkm,f.ratio_rv,f.prot_raster_sqkm,f.perc_prot,f.note FROM f ORDER BY fid;
