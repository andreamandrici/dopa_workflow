DROP TABLE IF EXISTS habitats_and_biotopes.eco1701;CREATE TABLE habitats_and_biotopes.eco1701 AS
WITH
a AS (
SELECT
CASE realm::text WHEN 'N/A' THEN NULL::text ELSE realm::text END realm,
CASE realm::text WHEN 'Afrotropic' THEN 1 WHEN 'Antarctica' THEN 2 WHEN 'Australasia' THEN 3 WHEN 'Indomalayan' THEN 4 WHEN 'Nearctic' THEN 5 WHEN 'Neotropic' THEN 6 WHEN 'Oceania' THEN 7 WHEN 'Palearctic' THEN 8 ELSE NULL::integer END realm_code,
CASE eco_biome_::text WHEN 'N/A' THEN NULL::text ELSE eco_biome_::text END eco_biome_,
biome_num::integer,
CASE biome_name::text WHEN 'N/A' THEN NULL::text ELSE biome_name::text END biome_name,
eco_id::integer,
eco_name::text,
nnh::integer,
nnh_name::text,
color::text,
color_bio::text,
color_nnh::text,
geom
FROM habitats_and_biotopes.ecoregions2017_oneearth
ORDER BY realm,eco_biome_,biome_num,eco_id
)
SELECT * FROM a ORDER BY eco_id;
UPDATE habitats_and_biotopes.eco1701 SET biome_num=99::integer,eco_id=9999 WHERE eco_id = 0;
--SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.eco1701;
--SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.eco1701;
DROP TABLE IF EXISTS habitats_and_biotopes.eco1702;CREATE TABLE habitats_and_biotopes.eco1702 AS
SELECT eco_id,(ST_DUMP(GEOM)).*,NULL::boolean v FROM habitats_and_biotopes.eco1701 ORDER BY eco_id,path;
UPDATE habitats_and_biotopes.eco1702 SET v=FALSE WHERE ST_ISVALID(geom) IS FALSE;
UPDATE habitats_and_biotopes.eco1702 SET geom=ST_MAKEVALID(geom) WHERE v IS FALSE;
ALTER TABLE habitats_and_biotopes.eco1702 ADD COLUMN sqkm double precision;
UPDATE habitats_and_biotopes.eco1702 SET sqkm=ST_AREA(geom::geography)/1000000;
DROP TABLE IF EXISTS habitats_and_biotopes.eco1703;CREATE TABLE habitats_and_biotopes.eco1703 AS
SELECT eco_id,ST_COLLECT(geom) geom,SUM(sqkm) sqkm FROM habitats_and_biotopes.eco1702 GROUP BY eco_id;
--SELECT DISTINCT ST_GEOMETRYTYPE(geom),ST_ISVALID(geom) FROM habitats_and_biotopes.eco1703;
DROP TABLE IF EXISTS habitats_and_biotopes.ecoregions2017_oneearth_clean;CREATE TABLE habitats_and_biotopes.ecoregions2017_oneearth_clean AS
SELECT a.*,b.geom,b.sqkm
FROM (SELECT DISTINCT realm,realm_code,eco_biome_,biome_num,biome_name,eco_id,eco_name,nnh,nnh_name,color,color_bio,color_nnh FROM habitats_and_biotopes.eco1701 ORDER BY eco_id) a
JOIN habitats_and_biotopes.eco1703 b USING(eco_id)
ORDER BY eco_id;
ALTER TABLE habitats_and_biotopes.ecoregions2017_oneearth_clean ADD PRIMARY KEY(eco_id);
CREATE INDEX ON habitats_and_biotopes.ecoregions2017_oneearth_clean USING GIST(geom);
DROP TABLE IF EXISTS habitats_and_biotopes.eco1701;
DROP TABLE IF EXISTS habitats_and_biotopes.eco1702;
DROP TABLE IF EXISTS habitats_and_biotopes.eco1703;
