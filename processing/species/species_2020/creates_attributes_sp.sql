DROP TABLE IF EXISTS species_202001.attributes_sp;CREATE TABLE species_202001.attributes_sp AS
SELECT * FROM species_202001.attributes_sp_birdlife
UNION
SELECT * FROM species_202001.attributes_sp_iucn
ORDER BY class,order_,family,genus,id_no;
