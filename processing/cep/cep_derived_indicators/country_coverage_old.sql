WITH
-- current country
current_country AS (SELECT * FROM administrative_units.gaul_eez_dissolved_201912),--this defines current attributes 
-- raster total surface
a1 AS (SELECT country fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_last) a GROUP BY country ORDER BY country),
-- raster protected surface
a2 AS (SELECT country fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_last WHERE NOT (ARRAY[0] && pa)) a GROUP BY country ORDER BY country),
-- country attributes
b AS (SELECT country_id fid,country_name "name",iso3,iso2,un_m49,status,sqkm FROM current_country ORDER BY fid),
-- objects assigned to multiple countries (by qid) 
c AS (SELECT qid,country,cardinality(country) AS cardinality FROM cep.cep_last WHERE cardinality(country) <> 1),
-- countries assigned to multiple object (by ecoid)
c1 AS (SELECT DISTINCT unnest(country) AS fid,'check_cardinality'::text AS note FROM c),
-- raster statistics by country
d AS (SELECT a1.fid,a1.rtotsqkm,a2.rprotsqkm,b.name,b.sqkm,round((a1.rtotsqkm / b.sqkm * 100::double precision)::numeric, 2) AS ratio_rv,round((a2.rprotsqkm / a1.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1 LEFT JOIN a2 USING (fid) JOIN b USING (fid)),
-- difference within raster and vector total surface 
d1 AS (SELECT d.fid,'check_ratio'::text AS note FROM d WHERE d.ratio_rv >= 100.5 OR d.ratio_rv <= 99.5),
-- vector and raster statistics by country
e AS (SELECT d.fid,d.name,d.sqkm AS tot_vector_sqkm,d.rtotsqkm AS tot_raster_sqkm,d.ratio_rv,d.rprotsqkm AS prot_raster_sqkm,d.perc_prot FROM d),
-- notes by country
notes AS (SELECT DISTINCT a.fid,a.note FROM (SELECT c1.fid,c1.note FROM c1 UNION ALL SELECT d1.fid,d1.note FROM d1) a),
-- complete statistics and notes
f AS (SELECT DISTINCT e.fid,e.name,e.tot_vector_sqkm,e.tot_raster_sqkm,e.ratio_rv,e.prot_raster_sqkm,e.perc_prot,notes.note FROM e LEFT JOIN notes USING (fid) ORDER BY e.fid)
SELECT f.fid,f.name,b.iso3,iso2,un_m49,status,f.tot_vector_sqkm,f.tot_raster_sqkm,f.ratio_rv,f.prot_raster_sqkm,f.perc_prot,f.note FROM f JOIN b USING(fid) ORDER BY f.fid;
