DROP TABLE IF EXISTS ecoregions_2017.ecoregions_2017;CREATE TABLE ecoregions_2017.ecoregions_2017 AS
SELECT
CASE eco_id WHEN 0 THEN 1000 ELSE eco_id::integer END eco_id,
eco_name::text,
nnh::integer,
realm::text,
biome_num::integer,
biome_name::text,
eco_biome_::text eco_biome,
_errors::text||' fixed' note,
geom,
(ST_AREA(geom::geography))/1000000 v_sqkm
FROM ecoregions_2017.ecoregions_2017_original_valid
ORDER BY eco_id;
ALTER TABLE ecoregions_2017.ecoregions_2017 ADD PRIMARY KEY(eco_id);
CREATE INDEX ON ecoregions_2017.ecoregions_2017 USING GIST(geom);
UPDATE ecoregions_2017.ecoregions_2017 SET note = note||'; original 0 eco_id renamed as 1000;'
