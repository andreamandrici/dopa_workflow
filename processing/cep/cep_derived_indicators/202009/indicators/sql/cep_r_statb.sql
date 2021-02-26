-- SELECT THE THEME;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS
SELECT * FROM results_202009.r_stats_cep_builtup;
DROP TABLE IF EXISTS country_index; CREATE TEMPORARY TABLE country_index AS SELECT * FROM cep.index_country_cep_last;
DROP TABLE IF EXISTS ecoregion_index; CREATE TEMPORARY TABLE ecoregion_index AS SELECT * FROM cep.index_ecoregion_cep_last;
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last;

SELECT country country_id,cat,SUM(area_m2)/1000000 cat_ext,SUM(sqkm) sqkm
FROM country_index JOIN theme USING(qid,cid)
GROUP BY country,cat
ORDER BY country,cat