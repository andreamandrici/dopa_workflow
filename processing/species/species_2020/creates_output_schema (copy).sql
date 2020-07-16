-- CREATE SCHEMA ---------------------------------------------
DROP SCHEMA IF EXISTS species CASCADE; CREATE SCHEMA species;

------ MT_ATTRIBUTES ---------------------------------------------
DROP TABLE IF EXISTS species.mt_attributes CASCADE;
CREATE TABLE species.mt_attributes AS
SELECT * FROM species_202001.attributes ORDER BY id_no;

------ MT_CATEGORIES ---------------------------------------------
DROP TABLE IF EXISTS species.mt_categories CASCADE;
CREATE TABLE species.mt_categories AS
SELECT * FROM species_202001.v_mt_categories
--WHERE code IN (SELECT DISTINCT category FROM species.mt_attributes)
ORDER BY code;
------ LT_SPECIES_CATEGORIES (useless?) ---------------------------------------------
-- DROP TABLE IF EXISTS species.lt_species_categories CASCADE; 
-- CREATE TABLE species.lt_species_categories AS SELECT * FROM species_202001.v_lt_species_categories
-- WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_COUNTRIES ---------------------------------------------
DROP TABLE IF EXISTS species.mt_countries CASCADE;
CREATE TABLE species.mt_countries AS
SELECT * FROM species_202001.v_mt_countries
ORDER BY code;
------ LT_SPECIES_COUNTRIES ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_countries CASCADE; 
CREATE TABLE species.lt_species_countries AS SELECT * FROM species_202001.v_lt_species_countries
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_CONSERVATION_NEEDED ---------------------------------------------
DROP TABLE IF EXISTS species.mt_conservation_needed CASCADE; 
CREATE TABLE species.mt_conservation_needed AS
SELECT * FROM species_202001.v_mt_conservation_needed;
------ LT_SPECIES_CONSERVATION_NEEDED ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_conservation_needed CASCADE; 
CREATE TABLE species.lt_species_conservation_needed AS SELECT * FROM species_202001.v_lt_species_conservation_needed
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_HABITATS ---------------------------------------------
DROP TABLE IF EXISTS species.mt_habitats CASCADE; 
CREATE TABLE species.mt_habitats AS
SELECT * FROM species_202001.v_mt_habitats;
------ LT_SPECIES_HABITATS ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_habitats CASCADE; 
CREATE TABLE species.lt_species_habitats AS SELECT * FROM species_202001.v_lt_species_habitats
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_RESEARCH_NEEDED ---------------------------------------------
DROP TABLE IF EXISTS species.mt_research_needed CASCADE; 
CREATE TABLE species.mt_research_needed AS
SELECT * FROM species_202001.v_mt_research_needed;
------ LT_SPECIES_RESEARCH_NEEDED ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_research_needed CASCADE; 
CREATE TABLE species.lt_species_research_needed AS SELECT * FROM species_202001.v_lt_species_research_needed
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_STRESSES ---------------------------------------------
DROP TABLE IF EXISTS species.mt_stresses CASCADE; 
CREATE TABLE species.mt_stresses AS
SELECT * FROM species_202001.v_mt_stresses;
------ LT_SPECIES_STRESSES ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_stresses CASCADE; 
CREATE TABLE species.lt_species_stresses AS SELECT * FROM species_202001.v_lt_species_stresses
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_THREATS ---------------------------------------------
DROP TABLE IF EXISTS species.mt_threats CASCADE; 
CREATE TABLE species.mt_threats AS
SELECT * FROM species_202001.v_mt_threats;
------ LT_SPECIES_THREATS ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_threats CASCADE; 
CREATE TABLE species.lt_species_threats AS SELECT * FROM species_202001.v_lt_species_threats
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;

------ MT_USETRADE ---------------------------------------------
DROP TABLE IF EXISTS species.mt_usetrade CASCADE; 
CREATE TABLE species.mt_usetrade AS SELECT * FROM species_202001.v_mt_usetrade;
------ LT_SPECIES_USETRADE ---------------------------------------------
DROP TABLE IF EXISTS species.lt_species_usetrade CASCADE; 
CREATE TABLE species.lt_species_usetrade AS SELECT * FROM species_202001.v_lt_species_usetrade
WHERE id_no IN (SELECT DISTINCT id_no FROM species_202001.attributes) ORDER BY id_no;
