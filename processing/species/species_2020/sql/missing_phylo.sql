---CREATES A NEW PHYLO SCHEMA
DROP SCHEMA IF EXISTS species_phylo CASCADE;
CREATE SCHEMA species_phylo;
---IMPORTS ALL Marine's TABLES IN THE NEW SCHEMA
CREATE TABLE species_phylo.phyloamphibiansnotiniucn  (binomial text);
COPY species_phylo.phyloamphibiansnotiniucn 
FROM '/home/felixwolf/wip/data/list_of_missing_species_IUCN-VertLife/list_phyloamphibiansnotiniucn.csv' DELIMITER '|' CSV HEADER;
CREATE TABLE species_phylo.phylobirdsnotiniucn (binomial text);
COPY species_phylo.phylobirdsnotiniucn
FROM '/home/felixwolf/wip/data/list_of_missing_species_IUCN-VertLife/list_phylobirdsnotiniucn.csv' DELIMITER '|' CSV HEADER;
CREATE TABLE species_phylo.phylomammalsnotiniucn (binomial text);
COPY species_phylo.phylomammalsnotiniucn
FROM '/home/felixwolf/wip/data/list_of_missing_species_IUCN-VertLife/list_phylomammalsnotiniucn.csv' DELIMITER '|' CSV HEADER;
CREATE TABLE species_phylo.phylosharksnotiniucn (binomial text);
COPY species_phylo.phylosharksnotiniucn
FROM '/home/felixwolf/wip/data/list_of_missing_species_IUCN-VertLife/list_phylosharksnotiniucn.csv' DELIMITER '|' CSV HEADER;
CREATE TABLE species_phylo.traitmammalsnotiniucn (binomial text);
COPY species_phylo.traitmammalsnotiniucn
FROM '/home/felixwolf/wip/data/list_of_missing_species_IUCN-VertLife/list_traitmammalsnotiniucn.csv' DELIMITER '|' CSV HEADER;
-- APPEND ALL THE Marine's TABLES IN UNA UNIQUE MISSING-CLASSES TABLE
CREATE TABLE species_phylo.phylo_missing_classes AS
SELECT *,'AMPHIBIANS'::text AS class,SPLIT_PART(binomial,' ',1) genus,SPLIT_PART(binomial,' ',2) species,
'phylo'::text AS source FROM species_phylo.phyloamphibiansnotiniucn
UNION
SELECT *,'AVES'::text AS class,SPLIT_PART(binomial,' ',1) genus,SPLIT_PART(binomial,' ',2) species,
'phylo'::text AS source FROM species_phylo.phylobirdsnotiniucn
UNION
SELECT *,'MAMMALIA'::text AS class,SPLIT_PART(binomial,' ',1) genus,SPLIT_PART(binomial,' ',2) species,
'phylo'::text AS source FROM species_phylo.phylomammalsnotiniucn
UNION
SELECT *,'MAMMALIA'::text AS class,SPLIT_PART(binomial,' ',1) genus,SPLIT_PART(binomial,' ',2) species,
'trait'::text AS source FROM species_phylo.traitmammalsnotiniucn
UNION
SELECT *,'CHONDRICHTHYES'::text AS class,SPLIT_PART(binomial,' ',1) genus,SPLIT_PART(binomial,' ',2) species,
'phylo'::text AS source FROM species_phylo.phylosharksnotiniucn
ORDER BY class,genus,binomial,source;

--- PROCESS THE IUCN SYNONYMS TABLE TO BE COMPARED (IF NEEDED) WITH THE MISSING CLASSES TABLE
CREATE TABLE species_phylo.aliases AS
WITH
synonyms AS (
SELECT * FROM species_202001.synonyms WHERE speciesname IS NOT NULL
UNION
SELECT fid,internaltaxonid,scientificname,name,SPLIT_PART(genusname,' ',1) genusname,SPLIT_PART(genusname,' ',2) speciesname,speciesauthor,infratype,infrarankauthor
FROM species_202001.synonyms WHERE speciesname IS NULL
),
b AS (SELECT DISTINCT internaltaxonid::bigint id_no,genusname::text genus,speciesname::text species,genusname::text||' '||speciesname::text binomial,name::text,infratype::text FROM synonyms),
c AS (
SELECT *,FALSE dopa FROM b WHERE id_no NOT IN (SELECT DISTINCT id_no FROM species.mt_attributes)
UNION
SELECT *,TRUE dopa FROM b WHERE id_no IN (SELECT DISTINCT id_no FROM species.mt_attributes)
)
SELECT * FROM c ORDER BY id_no,genus,species;