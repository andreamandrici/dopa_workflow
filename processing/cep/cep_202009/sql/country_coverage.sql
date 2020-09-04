DROP TABLE IF EXISTS cep202009.country_stats;CREATE TABLE cep202009.country_stats AS
WITH
-- current country; change this one to update data sources
current_country AS (SELECT * FROM administrative_units.gaul_eez_dissolved_201912),
-- terrestrial
ter AS (SELECT DISTINCT cid FROM cep.cep_202009 a,
(SELECT ARRAY_AGG(DISTINCT first_level_code ORDER BY first_level_code) f FROM habitats_and_biotopes.ecoregions_2020_atts WHERE "source" IN ('teow','eeow')) b WHERE b.f && a.eco
),
-- marine
mar AS (SELECT DISTINCT cid FROM cep.cep_202009 a,
(SELECT ARRAY_AGG(DISTINCT first_level_code ORDER BY first_level_code) f FROM habitats_and_biotopes.ecoregions_2020_atts WHERE "source" IN ('meow','ppow')) b WHERE b.f && a.eco
),
-- raster total surface
a1 AS (SELECT country fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009) a GROUP BY country ORDER BY country),
-- raster protected surface
a2 AS (SELECT country fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009 WHERE NOT (ARRAY[0] && pa)) a GROUP BY country ORDER BY country),
-- raster total terrestrial surface
a1_ter AS (SELECT country fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009 NATURAL JOIN ter) a GROUP BY country ORDER BY country),
-- raster protected terrestrial surface
a2_ter AS (SELECT country fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009 NATURAL JOIN ter WHERE NOT (ARRAY[0] && pa)) a GROUP BY country ORDER BY country),
-- raster total marine surface
a1_mar AS (SELECT country fid,SUM(a.sqkm) rtotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009 NATURAL JOIN mar) a GROUP BY country ORDER BY country),
-- raster protected marine surface
a2_mar AS (SELECT country fid,SUM(a.sqkm) rprotsqkm FROM (SELECT UNNEST(country) country,sqkm FROM cep.cep_202009 NATURAL JOIN mar WHERE NOT (ARRAY[0] && pa)) a GROUP BY country ORDER BY country),
-- country attributes
b AS (SELECT country_id fid,country_name "name",iso3,iso2,un_m49,status,sqkm FROM current_country ORDER BY fid),
-- raster statistics by country
d AS (SELECT a1.fid,a1.rtotsqkm,a2.rprotsqkm,round((a2.rprotsqkm / a1.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1 LEFT JOIN a2 USING (fid)),
d_ter AS (SELECT a1_ter.fid,a1_ter.rtotsqkm,a2_ter.rprotsqkm,round((a2_ter.rprotsqkm / a1_ter.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1_ter LEFT JOIN a2_ter USING (fid)),
d_mar AS (SELECT a1_mar.fid,a1_mar.rtotsqkm,a2_mar.rprotsqkm,round((a2_mar.rprotsqkm / a1_mar.rtotsqkm * 100::double precision)::numeric, 2) AS perc_prot FROM a1_mar LEFT JOIN a2_mar USING (fid)),
e AS (
SELECT
d.fid,b.name,b.iso3,b.iso2,b.un_m49,b.status,b.sqkm tot_vector_sqkm,
d.rtotsqkm tot_sqkm,d.rprotsqkm tot_prot_sqkm,d.perc_prot tot_perc_prot,
d_ter.rtotsqkm ter_sqkm,d_ter.rprotsqkm ter_prot_sqkm,d_ter.perc_prot ter_perc_prot,
d_mar.rtotsqkm mar_sqkm,d_mar.rprotsqkm mar_prot_sqkm,d_mar.perc_prot mar_perc_prot
FROM b
JOIN d USING(fid)
LEFT JOIN d_ter USING(fid)
LEFT JOIN d_mar USING(fid)
ORDER BY d.fid)
SELECT * FROM e;
--SELECT *,tot_sqkm-(ter_sqkm+mar_sqkm) d FROM e ORDER BY d DESC NULLS LAST

