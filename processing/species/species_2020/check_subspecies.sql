WITH
nsp AS (
	SELECT DISTINCT
	internaltaxonid::bigint id_no,
	scientificname::text AS binomial,
	kingdomname::text AS kingdom,
	phylumname::text AS phylum,
	classname::text AS class,
	ordername::text AS order_,
	familyname::text AS family,
	genusname::text AS genus
	FROM species_202001.taxonomy
	),
--SELECT * FROM nsp WHERE internaltaxonid NOT IN (SELECT DISTINCT id_no FROM species_202001.attributes_sp)
j AS (SELECT id_no,a.binomial binomial_geom,b.binomial binomial_atts FROM species_202001.attributes_sp a FULL OUTER JOIN nsp b USING (id_no))
SELECT * FROM j WHERE binomial_atts IS NULL ORDER BY id_no
