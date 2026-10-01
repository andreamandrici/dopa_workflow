SELECT * FROM ecoregions_2017.ecoregions_2017_original_valid LIMIT 10;

SELECT DISTINCT ST_ISVALID(geom),ST_GEOMETRYTYPE(geom) FROM ecoregions_2017.ecoregions_2017_original_valid;
--"st_isvalid"	"st_geometrytype"
--true	"ST_MultiPolygon"

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1;CREATE TABLE ecoregions_2017.eco17_preproc1 AS
SELECT
CASE
	eco_id::integer
	WHEN 0 THEN 1000
	WHEN 119 THEN 1119
	WHEN 124 THEN 1124
	ELSE
	eco_id::integer
END
eco_id,
CASE
eco_id
	WHEN 119 THEN 'Dronning Maud Land tundra/Rock and Ice - (Overlapping eco_id: 119,0)'
	WHEN 124 THEN 'Marie Byrd Land tundra/Rock and Ice - (Overlapping eco_id: 124,0)'
	ELSE
	eco_name::text
END
eco_name,
eco_id::text original_eco_id,geom,ST_AREA(geom::geography)/1000000 v_sqkm
FROM ecoregions_2017.ecoregions_2017_original_valid ORDER BY eco_id;
SELECT * FROM ecoregions_2017.eco17_preproc1 WHERE eco_id != original_eco_id::integer;
CREATE INDEX ON ecoregions_2017.eco17_preproc1 USING GIST(geom);

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_overlaps;CREATE TABLE ecoregions_2017.eco17_preproc1_overlaps AS
SELECT 
    a.eco_id AS eco_id_p1, 
    b.eco_id AS eco_id_p2
FROM 
    ecoregions_2017.eco17_preproc1 a
JOIN 
    ecoregions_2017.eco17_preproc1 b ON ST_Intersects(a.geom, b.geom)
WHERE 
    a.eco_id < b.eco_id
	AND a.eco_id NOT IN (1119,1124)
	AND b.eco_id NOT IN (1119,1124)
	AND NOT ST_Touches(a.geom, b.geom);
--SELECT 28
--Query returned successfully in 1 min 15 secs.
SELECT * FROM ecoregions_2017.eco17_preproc1_overlaps;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_overlaps_geom1;CREATE TABLE ecoregions_2017.eco17_preproc1_overlaps_geom1 AS
SELECT 
    row_number() OVER () AS gid,
    c.eco_id_p1,
    c.eco_id_p2,
    ST_Intersection(a.geom, b.geom) geom
FROM 
    ecoregions_2017.eco17_preproc1_overlaps c
JOIN 
     ecoregions_2017.eco17_preproc1 a ON c.eco_id_p1 = a.eco_id
JOIN 
     ecoregions_2017.eco17_preproc1 b ON c.eco_id_p2 = b.eco_id
WHERE 
    ST_Dimension(ST_Intersection(a.geom, b.geom)) = 2;

SELECT DISTINCT ST_ISVALID(geom),ST_GEOMETRYTYPE(geom) FROM ecoregions_2017.eco17_preproc1_overlaps_geom1;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_overlaps_geom2;CREATE TABLE ecoregions_2017.eco17_preproc1_overlaps_geom2 AS
SELECT gid,eco_id_p1,eco_id_p2,(ST_DUMP(geom)).*
FROM ecoregions_2017.eco17_preproc1_overlaps_geom1;

SELECT DISTINCT ST_ISVALID(geom),ST_GEOMETRYTYPE(geom) FROM ecoregions_2017.eco17_preproc1_overlaps_geom2;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_overlaps_geom3;CREATE TABLE ecoregions_2017.eco17_preproc1_overlaps_geom3 AS
SELECT *,ST_AREA(geom::geography)/1000000 v_sqkm
FROM ecoregions_2017.eco17_preproc1_overlaps_geom2 WHERE ST_GEOMETRYTYPE(geom)='ST_Polygon';

WITH
a AS (
SELECT eco_id_p1,eco_id_p2,SUM(v_sqkm) tv_sqkm
FROM ecoregions_2017.eco17_preproc1_overlaps_geom3
GROUP BY eco_id_p1,eco_id_p2
ORDER BY tv_sqkm
)
SELECT * FROM a WHERE tv_sqkm > 0.001;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_overlaps_geom;
CREATE TABLE ecoregions_2017.eco17_preproc1_overlaps_geom AS
SELECT 951 eco_id,ST_COLLECT(geom) geom,SUM(v_sqkm) v_sqkm
FROM ecoregions_2017.eco17_preproc1_overlaps_geom3
WHERE eco_id_p1 = 9 AND eco_id_p2 = 51
GROUP BY eco_id;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_non_overlaps_geom_9;
CREATE TABLE ecoregions_2017.eco17_preproc1_non_overlaps_geom_9 AS
SELECT a.eco_id,ST_DIFFERENCE(a.geom,b.geom) geom
FROM
	(SELECT eco_id,geom FROM ecoregions_2017.eco17_preproc1 a WHERE eco_id = 9) a,
	ecoregions_2017.eco17_preproc1_overlaps_geom b;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_non_overlaps_geom_51;
CREATE TABLE ecoregions_2017.eco17_preproc1_non_overlaps_geom_51 AS
SELECT a.eco_id,ST_DIFFERENCE(a.geom,b.geom) geom
FROM
	(SELECT eco_id,geom FROM ecoregions_2017.eco17_preproc1 a WHERE eco_id = 51) a,
	ecoregions_2017.eco17_preproc1_overlaps_geom b;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc1_fixed_overlaps;
CREATE TABLE ecoregions_2017.eco17_preproc1_fixed_overlaps AS
SELECT *,ST_AREA(geom::geography)/1000000 v_sqkm FROM ecoregions_2017.eco17_preproc1_non_overlaps_geom_9
UNION
SELECT *,ST_AREA(geom::geography)/1000000 v_sqkm FROM ecoregions_2017.eco17_preproc1_non_overlaps_geom_51
UNION
SELECT * FROM ecoregions_2017.eco17_preproc1_overlaps_geom;

SELECT * FROM ecoregions_2017.eco17_preproc1_fixed_overlaps;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc2;CREATE TABLE ecoregions_2017.eco17_preproc2 AS
SELECT
eco_id,
CASE eco_id
WHEN 9 THEN 'Eastern Arc forests'
WHEN 51 THEN 'Northern Acacia-Commiphora bushlands and thickets'
WHEN 951 THEN 'Eastern Arc forests/Northern Acacia-Commiphora bushlands and thickets - (Overlapping eco_id: 9,51)'
END eco_name,
CASE eco_id WHEN 951 THEN '9,51' ELSE eco_id::text END original_eco_id,
geom,v_sqkm FROM ecoregions_2017.eco17_preproc1_fixed_overlaps
UNION ALL
SELECT eco_id,eco_name,original_eco_id,geom,v_sqkm
FROM ecoregions_2017.eco17_preproc1
WHERE eco_id NOT IN (9,51)
ORDER BY eco_id;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc3;CREATE TABLE ecoregions_2017.eco17_preproc3 AS
SELECT eco_id,eco_name,original_eco_id,
CASE
	WHEN eco_id = 9 THEN 'FIXED: erased the overlap with 51'	
	WHEN eco_id = 51 THEN 'FIXED: ring self-intersection in the original topology; FIXED: erased the overlap with 9'
	WHEN eco_id = 134 THEN 'NON-FIXED: small overlap with 1000'
	WHEN eco_id = 219 THEN 'NON-FIXED: small overlap with 220'
	WHEN eco_id = 220 THEN 'NON-FIXED: small overlap with 219 and 313'	
	WHEN eco_id = 313 THEN 'FIXED: ring self-intersection in the original topology; NON-FIXED: small overlap with 220'	
	WHEN eco_id = 951 THEN 'FIXED: created as intersection from the partial overlap between 9 and 51'	
	WHEN eco_id = 1000 THEN 'FIXED: ring self-intersection in the original topology; NON-FIXED: small overlap with 134'
	WHEN eco_id = 1119 THEN 'FIXED: total overlap between 119 and 1000-rock and ice'
	WHEN eco_id = 1124 THEN 'FIXED: total overlap between 124 and 1000-rock and ice'
	WHEN eco_id IN (1,5,8,12,25,28,33,39,42,43,45,46,55,57,59,61,65,66,76,78,79,84,88,89,90,107,108,109,110,111,112,114,115,120,125,161,176,221,233,234,286,309,320,378,394,428,448,465,466,469,473,481,483,503,505,512,518,554,722,723,769,791,809,810,811,837,840)
			THEN 'FIXED: ring self-intersection in the original topology;'
END note,
geom,v_sqkm
FROM ecoregions_2017.eco17_preproc2
ORDER BY eco_id;

DROP TABLE IF EXISTS ecoregions_2017.eco17_preproc4;
CREATE TABLE ecoregions_2017.eco17_preproc4 AS
WITH
a AS (SELECT realm::text,eco_biome_::text,biome_name::text,CASE WHEN eco_id::integer IN (119,124) THEN 1000+eco_id ELSE eco_id::integer END eco_id,nnh::integer
FROM ecoregions_2017.ecoregions_2017_original_valid)
SELECT * FROM a FULL OUTER JOIN ecoregions_2017.eco17_preproc3 USING (eco_id)
ORDER BY eco_biome_,eco_id;
UPDATE ecoregions_2017.eco17_preproc4
SET
	realm='Afrotropic',
	eco_biome_='AF-01/07',
	biome_name='Tropical & Subtropical Moist Broadleaf Forests/Tropical & Subtropical Grasslands, Savannas & Shrublands',
	nnh=3
WHERE eco_id=951;

DROP TABLE IF EXISTS ecoregions_2017.ecoregions_2017_preprocessed;CREATE TABLE ecoregions_2017.ecoregions_2017_preprocessed AS
SELECT
* FROM ecoregions_2017.eco17_preproc4
ORDER BY eco_biome_,eco_id;
ALTER TABLE ecoregions_2017.ecoregions_2017_preprocessed ADD PRIMARY KEY (eco_id);
CREATE INDEX ON ecoregions_2017.ecoregions_2017_preprocessed USING GIST(geom);

SELECT 'DROP TABLE ecoregions_2017.' || quote_ident(tablename) || ' CASCADE;'
FROM pg_tables
WHERE schemaname = 'ecoregions_2017'
  AND tablename LIKE 'eco17_preproc%';

DROP TABLE ecoregions_2017.eco17_preproc1 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_fixed_overlaps CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_non_overlaps_geom_51 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_non_overlaps_geom_9 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_overlaps CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_overlaps_geom CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_overlaps_geom1 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_overlaps_geom2 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc1_overlaps_geom3 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc2 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc3 CASCADE;
DROP TABLE ecoregions_2017.eco17_preproc4 CASCADE;


