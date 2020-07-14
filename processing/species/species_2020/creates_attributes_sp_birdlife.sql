-- creates table BIRDLIFE_SPATIAL_ATTRIBUTES as selection of attributes from spatial data
DROP TABLE IF EXISTS species_202001.attributes_sp_birdlife; 
CREATE TABLE species_202001.attributes_sp_birdlife AS
WITH 
a AS (
SELECT DISTINCT
id_no::bigint,
binomial::text,
kingdom::text,
phylum::text,
class::text,
order_::text,
family::text,
genus::text,
category::text,
-- aggregates biome_marine,biome_terrestrial and biome_freshwater ecosystems in ecosystem_mtf (marine,terrestrial,freshwater).
CONCAT(
(CASE WHEN biome_marine = 'true' THEN 1 ELSE 0 END),
(CASE WHEN biome_terrestrial = 'true' THEN 1 ELSE 0 END),
(CASE WHEN biome_freshwater = 'true' THEN 1 ELSE 0 END)) ecosystem_mtf
FROM species_202001.birds_additional_atts
-- DO NOT INCLUDE SENSITIVE SPECIES!!!
WHERE id_no::bigint NOT IN (22694585,22732350)
ORDER BY id_no)
-- select only attributes matching geometric objects
SELECT DISTINCT * FROM a WHERE id_no IN (SELECT DISTINCT sisid FROM species_202001.birds_all_species) ORDER BY id_no;