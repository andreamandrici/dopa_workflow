-- find taxa with missing ecosystems in the birdlife table "taxonomic"
WITH
missing_ecosystems AS
(SELECT DISTINCT sisrecid
FROM species_202001.birds_taxonomic
WHERE marine IS NULL OR freshwater IS NULL OR terrestrial IS NULL)
-- find, in IUCN table "assessments", missing ecosystems for those taxa that lack this information in the BIRDLIFE table "taxonomic"
SELECT internaltaxonid,systems FROM species_202001.assessments JOIN missing_ecosystems ON internaltaxonid::integer = sisrecid;

-- fill, in the BIRDLIFE table "taxonomic", the missing ecosystems (they are all terrestrial).
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
