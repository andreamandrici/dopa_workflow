-- creates table IUCN_SPATIAL_ATTRIBUTES as selection of attributes from spatial data
DROP TABLE IF EXISTS species_202001.attributes_sp_iucn; 
CREATE TABLE species_202001.attributes_sp_iucn AS
SELECT DISTINCT
id_no,
binomial::text,
kingdom::text,
phylum::text,
class::text,
order_::text,
family::text,
genus::text,
category::text,
-- aggregates marine,terrestRial and freshwater ecosystems in ecosystem_mtf (marine,terrestrial,freshwater). IUCN field name "terrestial" is wrong at origin: it misses an R in the name.
CONCAT(
(CASE WHEN marine = 'true' THEN 1 ELSE 0 END),
(CASE WHEN terrestial = 'true' THEN 1 ELSE 0 END),
(CASE WHEN freshwater = 'true' THEN 1 ELSE 0 END)) ecosystem_mtf
FROM

(
	SELECT * FROM species_202001.reef_forming_corals
	UNION
	SELECT * FROM species_202001.sharks_rays_chimaeras
	UNION
	SELECT * FROM species_202001.amphibians
	UNION
	SELECT * FROM species_202001.mammals
) a
ORDER BY id_no;
