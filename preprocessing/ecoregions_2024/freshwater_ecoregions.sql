DROP TABLE IF EXISTS habitats_and_biotopes.freshwater_ecoregions_clean;CREATE TABLE habitats_and_biotopes.freshwater_ecoregions_clean AS
WITH
a As (
SELECT eco_id_u,eco_id::integer,CASE ecoregion::text WHEN ' ' THEN NULL ELSE ecoregion::text END ecoregion,mht_no::integer,mht_txt::text,old_id,globalid::text,geom
FROM habitats_and_biotopes.freshwater_ecoregions)
SELECT mht_no,mht_txt,eco_id_u,eco_id,ecoregion,old_id,globalid,geom,ST_AREA(geom::geography)/1000000 sqkm FROM a ORDER BY mht_no,eco_id;
--SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM habitats_and_biotopes.freshwater_ecoregions_clean;
--SELECT DISTINCT ST_ISVALID(geom) FROM habitats_and_biotopes.freshwater_ecoregions_clean;
ALTER TABLE habitats_and_biotopes.freshwater_ecoregions_clean ADD PRIMARY KEY(eco_id);
CREATE INDEX ON habitats_and_biotopes.freshwater_ecoregions_clean USING GIST(geom);
