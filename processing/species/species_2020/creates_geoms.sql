--create table geom_corals
DROP TABLE IF EXISTS species_202001.geom_corals;
CREATE TABLE species_202001.geom_corals AS
SELECT id_no,geom
FROM species_202001.reef_forming_corals
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;
--create table geom_sharks_rays_chimaeras
DROP TABLE IF EXISTS species_202001.geom_sharks_rays_chimaeras;
CREATE TABLE species_202001.geom_sharks_rays_chimaeras AS
SELECT id_no,geom
FROM species_202001.sharks_rays_chimaeras
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;
--create table geom_amphibians
DROP TABLE IF EXISTS species_202001.geom_amphibians;
CREATE TABLE species_202001.geom_amphibians AS
SELECT id_no,geom
FROM species_202001.amphibians
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;
--create table geom_mammals
DROP TABLE IF EXISTS species_202001.geom_mammals;
CREATE TABLE species_202001.geom_mammals AS
SELECT id_no,geom
FROM species_202001.mammals
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;
--create table geom_birds
DROP TABLE IF EXISTS species_202001.geom_birds;
CREATE TABLE species_202001.geom_birds AS
-- SELECT sisid::bigint id_no,shape geom -- use this only if the field has been already renamed
SELECT sisid::bigint id_no,shape geom
FROM species_202001.birds_all_species
WHERE sisid::bigint IN (SELECT DISTINCT id_no FROM species_202001.attributes)
ORDER BY id_no;




