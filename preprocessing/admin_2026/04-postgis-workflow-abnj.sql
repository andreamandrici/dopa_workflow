-------------------------------------------------------------------------------------

DROP TABLE IF EXISTS gisco_26.grid;CREATE TABLE gisco_26.grid AS
SELECT 
row_number() OVER (ORDER BY lat, lon) AS gid,
ST_MakeEnvelope(lon, lat, lon+90, lat+90)::geometry(Polygon,4326) geom
FROM generate_series(-180,  90, 90) AS lon,
     generate_series( -90,   0, 90) AS lat;
ALTeR TABLE gisco_26.grid ADD PRIMaRY KEY(gid);
CReatE INDEX ON gisco_26.grid USING GIST(geom);
SElEcT * FROM gisco_26.grid;