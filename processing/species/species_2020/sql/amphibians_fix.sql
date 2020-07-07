DROP TABLE IF EXISTS species_202001.amphibians_non_valid;
CREATE TABLE species_202001.amphibians_non_valid AS
SELECT * FROM species_202001_amphibians.a_input_amphibians WHERE valid IS false;

DROP TABLE IF EXISTS species_202001.amphibians_non_valid_fix;
CREATE TABLE species_202001.amphibians_non_valid_fix AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom),ST_AREA(geom::geography)/1000000 FROM 
(SELECT fid id_no,path opath,(ST_DUMP(ST_MAKEVALID(geom))).* FROM species_202001.amphibians_non_valid) tf
ORDER BY id_no,opath,path;

DROP TABLE IF EXISTS species_202001.amphibians_valid;
CREATE TABLE species_202001.amphibians_valid AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom FROM 
(SELECT fid id_no,geom FROM species_202001_amphibians.a_input_amphibians WHERE valid IS NULL
UNION
SELECT id_no,geom FROM species_202001.amphibians_non_valid_fix) tv
GROUP BY id_no ORDER BY id_no;









