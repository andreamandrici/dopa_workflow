--country_pa
DROP TABLE IF EXISTS country_conservation_pa_list_count;CREATE TABLE country_conservation_pa_list_count AS
SELECT *,CARDINALITY(pa_list) pa_count
FROM (
	SELECT country_id,ARRAY_AGG(DISTINCT pa ORDER BY pa) pa_list FROM cep_data_202601.cep_index WHERE is_protected IS TRUE GROUP BY country_id ORDER BY country_id
	) a
ORDER BY country_id;
DROP TABLE IF EXISTS cep_data_202601.country_conservation_pa_list_count;CREATE TABLE cep_data_202601.country_conservation_pa_list_count AS
SELECT * FROM country_conservation_pa_list_count;
