WITH a AS (
SELECT DISTINCT
id_no,
binomial,
kingdom,
phylum,
class,
order_,
family,
genus,
category,CONCAT(
(CASE WHEN marine = 'true' THEN 1 ELSE 0 END),
(CASE WHEN terrestial = 'true' THEN 1 ELSE 0 END),
(CASE WHEN freshwater = 'true' THEN 1 ELSE 0 END)) ecosystem
FROM species_202001.amphibians ORDER BY id_no)
SELECT * FROM a