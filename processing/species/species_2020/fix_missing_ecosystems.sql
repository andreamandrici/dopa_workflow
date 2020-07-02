-- find taxa with missing ecosystems in the birdlife table "taxonomic"
WITH
missing_ecosystems AS
(SELECT DISTINCT sisrecid
FROM species_202001.birds_taxonomic
WHERE marine IS NULL OR freshwater IS NULL OR terrestrial IS NULL)
-- find, in IUCN table "assessments", missing ecosystems for those taxa that lack this information in the BIRDLIFE table "taxonomic"
SELECT internaltaxonid,systems FROM species_202001.assessments JOIN missing_ecosystems ON internaltaxonid::integer = sisrecid;

-- Add, in the BIRDLIFE table "additional_atts", the missing information related to missing ecosystems
-- IMPORTANT! THIS HAS BEEN USED TO FILL THE FINAL TABLE
DROP TABLE IF EXISTS missing;CREATE TEMPORARY TABLE missing AS SELECT sisrecid,marine,freshwater,terrestrial FROM species_birdlife_201903.birdlife_hbw_taxonomic_checklist_v4 ORDER BY sisrecid;
DELETE FROM missing WHERE marine IS NOT NULL OR freshwater IS NOT NULL OR terrestrial IS NOT NULL;
INSERT INTO species_202001.birds_additional_atts(id_no,binomial,kingdom,phylum,class,order_,family,genus,category,biome_marine,biome_terrestrial,biome_freshwater)
SELECT DISTINCT
a.sisrecid id_no,
a.scientific_name AS binomial,
'ANIMALIA' AS kingdom,
'CHORDATA' AS phylum,
'AVES' AS class,
a.order_,
UPPER(a.family_name) AS "family",
SPLIT_PART(a.scientific_name, ' ', 1) AS genus,
a.f2019_iucn_red_list_category AS category,
'false'::text AS biome_marine,
'true'::text AS biome_terrestrial,
'false'::text AS biome_freshwater
FROM species_202001.birds_taxonomic a JOIN missing b USING(sisrecid);

-- fill, in the BIRDLIFE table "taxonomic", the missing ecosystems (they are all terrestrial)
-- Useful, but this has not been used for filling the final table
WITH
missing_ecosystems AS
(SELECT DISTINCT sisrecid,'F' marine,'F' freshwater,'T'terrestrial
FROM species_202001.birds_taxonomic
WHERE marine IS NULL OR freshwater IS NULL OR terrestrial IS NULL)
UPDATE species_202001.birds_taxonomic
SET
marine=b.marine,
freshwater=b.freshwater,
terrestrial=b.terrestrial
FROM missing_ecosystems b
WHERE birds_taxonomic.sisrecid=b.sisrecid;


