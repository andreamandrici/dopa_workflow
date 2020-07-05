DROP TABLE IF EXISTS species_202001.attributes;CREATE TABLE species_202001.attributes AS
WITH
--SELECT SPECIES FROM NON SPATIAL TABLES
non_spatial AS (
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
-- SELECT SPECIES WHICH ARE PRESENT IN BOTH SPATIAL AND NON SPATIAL TABLES
sp_n_sp AS (
SELECT id_no,a.binomial binomial_geom,a.class class_geom,b.binomial binomial_atts,b.class class_atts
FROM species_202001.attributes_sp a FULL OUTER JOIN non_spatial b USING (id_no)
),
-- SELECT IDS
ids AS (
SELECT DISTINCT id_no FROM sp_n_sp
WHERE binomial_geom IS NOT NULL AND binomial_atts IS NOT NULL
ORDER BY id_no
)
SELECT * FROM species_202001.attributes_sp WHERE id_no IN (SELECT DISTINCT id_no FROM ids) ORDER BY class,order_,family,genus,id_no;
ALTER TABLE species_202001.attributes ADD PRIMARY KEY(id_no);