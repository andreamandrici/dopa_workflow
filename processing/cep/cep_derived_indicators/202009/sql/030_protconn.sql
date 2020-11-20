DROP TABLE IF EXISTS results_202009.country_protconn;CREATE TABLE results_202009.country_protconn AS
SELECT country country_id,protconn FROM cep.atts_country_last JOIN results_202009.protconn_results_countries_202009 USING(iso3);
DROP TABLE IF EXISTS results_202009.ecoregion_protconn;CREATE TABLE results_202009.ecoregion_protconn AS
SELECT eco_id,protconn FROM results_202009.protconn_results_eco_202009 WHERE protconn IS NOT NULL;