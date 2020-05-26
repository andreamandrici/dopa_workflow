DELETE FROM administrative_units.gaul_eez_dissolved_dev;
DROP INDEX IF EXISTS administrative_units.gaul_eez_dissolved_dev_geom_idx;
DROP TABLE IF EXISTS gaul_eez_dissolved_dev;
CREATE TEMPORARY TABLE gaul_eez_dissolved_dev AS
WITH
a AS (SELECT qid,geom FROM cep202003.z_grid where qfilter is null),
b AS (SELECT ST_BUFFER(ST_UNION(geom),1) geom FROM a),
d AS (SELECT c.*,ST_INTERSECTION(c.geom,b.geom) ngeom FROM administrative_units.gaul_eez_dissolved_201912 c,b WHERE ST_INTERSECTS(c.geom,b.geom))
SELECT * FROM d;
UPDATE gaul_eez_dissolved_dev
SET
geom=ST_MULTI(ngeom),
sqkm=(ST_AREA(ngeom::geography)/1000000);
ALTER TABLE gaul_eez_dissolved_dev DROP COLUMN ngeom;
INSERT INTO administrative_units.gaul_eez_dissolved_dev
SELECT * FROM gaul_eez_dissolved_dev;
CREATE INDEX gaul_eez_dissolved_dev_geom_idx
ON administrative_units.gaul_eez_dissolved_dev USING gist(geom);

DELETE FROM habitats_and_biotopes.ecoregions_dev;
DROP INDEX IF EXISTS habitats_and_biotopes.ecoregions_dev_geom_idx;
DROP TABLE IF EXISTS ecoregions_dev;
CREATE TEMPORARY TABLE ecoregions_dev AS
WITH
a AS (SELECT qid,geom FROM cep202003.z_grid where qfilter is null),
b AS (SELECT ST_BUFFER(ST_UNION(geom),1) geom FROM a),
d AS (SELECT c.*,ST_INTERSECTION(c.geom,b.geom) ngeom FROM habitats_and_biotopes.ecoregions_2019 c,b WHERE ST_INTERSECTS(c.geom,b.geom))
SELECT * FROM d;
UPDATE ecoregions_dev
SET
geom=ST_MULTI(ngeom),
sqkm=(ST_AREA(ngeom::geography)/1000000);
ALTER TABLE ecoregions_dev DROP COLUMN ngeom;
INSERT INTO habitats_and_biotopes.ecoregions_dev
SELECT * FROM ecoregions_dev;
CREATE INDEX ecoregions_dev_geom_idx
ON habitats_and_biotopes.ecoregions_dev USING gist(geom);

DELETE FROM protected_sites.wdpa_dev;
DROP INDEX IF EXISTS protected_sites.wdpa_dev_geom_idx;
DROP TABLE IF EXISTS wdpa_dev;
CREATE TEMPORARY TABLE wdpa_dev AS
WITH
a AS (SELECT qid,geom FROM cep202003.z_grid where qfilter is null),
b AS (SELECT ST_BUFFER(ST_UNION(geom),1) geom FROM a),
d AS (SELECT c.*,ST_INTERSECTION(c.geom,b.geom) ngeom FROM protected_sites.wdpa_202003 c,b WHERE ST_INTERSECTS(c.geom,b.geom))
SELECT * FROM d;
UPDATE wdpa_dev
SET
geom=ST_MULTI(ngeom),
area_geo=(ST_AREA(ngeom::geography)/1000000);
ALTER TABLE wdpa_dev DROP COLUMN ngeom;
INSERT INTO protected_sites.wdpa_dev
SELECT * FROM wdpa_dev;
CREATE INDEX wdpa_dev_geom_idx
ON protected_sites.wdpa_dev USING gist(geom);

