----------------------------
DROP TABLE IF EXISTS att_1;
CREATE TEMPORARY TABLE att_1 AS (SELECT cid,sharks_rays_chimaeras species,CARDINALITY(sharks_rays_chimaeras) richness FROM species_202001_sharks_rays_chimaeras.fb_atts_all);
-----------------------------
DROP TABLE IF EXISTS att_2;
CREATE TEMPORARY TABLE att_2 AS (SELECT DISTINCT id_no::integer id_no FROM species.mt_species_output WHERE endemic IS TRUE AND threatened IS TRUE);
DROP TABLE IF EXISTS att_3;
CREATE TEMPORARY TABLE att_3 AS (SELECT ARRAY_AGG(DISTINCT id_no ORDER BY id_no) endemic_threatened FROM att_2);
DROP TABLE IF EXISTS att_4;
CREATE TEMPORARY TABLE att_4 AS (SELECT att_1.cid,att_1.species FROM att_1,att_3 WHERE att_3.endemic_threatened && att_1.species);
DROP TABLE IF EXISTS att_5;
CREATE TEMPORARY TABLE att_5 AS (SELECT DISTINCT cid,UNNEST(species) id_no FROM att_4 ORDER BY cid,id_no); 
DROP TABLE IF EXISTS att_6;
CREATE TEMPORARY TABLE att_6 AS (SELECT * FROM att_5 WHERE id_no IN (SELECT DISTINCT id_no FROM att_2));
DROP TABLE IF EXISTS att_7;
CREATE TEMPORARY TABLE att_7 AS (SELECT cid,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) id_no FROM att_6 GROUP BY cid ORDER BY cid,id_no);
DROP TABLE IF EXISTS att_8;
CREATE TEMPORARY TABLE att_8 AS (SELECT cid,id_no endemic_threatened,CARDINALITY(id_no) richness_endemic_threatened FROM att_7);
SELECT * FROM att_1 LEFT JOIN att_8 USING(cid) ORDER BY cid;								 
								 