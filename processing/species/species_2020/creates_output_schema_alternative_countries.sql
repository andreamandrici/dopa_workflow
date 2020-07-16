

--- CHECK RESULTS
WITH 
a AS (
SELECT *
FROM species.mt_attributes a
LEFT JOIN species.dt_country_endemics b USING(id_no)
),
b AS (SELECT internaltaxonid::bigint id_no,* FROM species_202001.countries)
SELECT * FROM b WHERE id_no IN (SELECT DISTINCT id_no FROM a WHERE country IS NULL)

