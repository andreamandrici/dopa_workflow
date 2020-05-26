WITH
-- raster total surface
a1 AS (SELECT a.ecoregion AS fid,sum(a.sqkm) AS rtotsqkm FROM (SELECT unnest(h_flat.ecoregion) AS ecoregion,h_flat.sqkm FROM cep202003_keep.h_flat) a GROUP BY a.ecoregion ORDER BY a.ecoregion),
-- raster protected surface
a2 AS (SELECT a.ecoregion AS fid,sum(a.sqkm) AS rprotsqkm FROM (SELECT unnest(h_flat.ecoregion) AS ecoregion,h_flat.sqkm FROM cep202003_keep.h_flat WHERE 0 <> ANY (h_flat.wdpa)) a GROUP BY a.ecoregion ORDER BY a.ecoregion),
-- ecoregion attributes
b AS (SELECT ecoregions_atts.fid,ecoregions_atts.name,ecoregions_atts.source,ecoregions_atts.sqkm FROM habitats_and_biotopes.ecoregions_atts),
-- objects assigned to multiple ecoregions (by qid) 
c AS (SELECT h_flat.qid,h_flat.ecoregion,cardinality(h_flat.ecoregion) AS cardinality FROM cep202003_keep.h_flat WHERE cardinality(h_flat.ecoregion) <> 1),
-- ecoregions assigned to multiple object (by ecoid)
c1 AS (SELECT DISTINCT unnest(c.ecoregion) AS fid,'check_cardinality'::text AS note FROM c),
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