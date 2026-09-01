--firms
DROP TABLE IF EXISTS pollutants.firm_facility;
CREATE TABLE pollutants.firm_facility AS
SELECT facility_inspire_id::text,countrycode::text,ARRAY_AGG(reportingyear::integer ORDER BY reportingyear::integer) ryears,
ST_SETSRID(ST_MAKEPOINT(pointgeometrylon::double precision,pointgeometrylat::double precision), 4326) point
FROM pollutants.firm_facility_16_input
GROUP BY facility_inspire_id,countrycode,pointgeometrylon,pointgeometrylat
ORDER BY facility_inspire_id::text;

ALTER TABLE pollutants.firm_facility ADD PRIMARY KEY(facility_inspire_id);
CREATE INDEX ON pollutants.firm_facility USING GIST(point);
CREATE EXTENSION IF NOT EXISTS btree_gin;
SELECT * FROM pg_extension WHERE extname = 'btree_gin';
CREATE INDEX ON pollutants.firm_facility USING GIN(ryears);

--buffer
DROP TABLE IF EXISTS pollutants.firm_facility_buffer;
CREATE TABLE pollutants.firm_facility_buffer AS
SELECT ST_BUFFER(ST_CONVEXHULL(ST_COLLECT(point)),1) geom FROM pollutants.firm_facility;
CREATE INDEX ON pollutants.firm_facility_buffer USING GIST (geom);

SELECT * FROM pollutants.firm_facility_buffer;

-- PAs
--WDPAID includes N2000
--SELECT metadataid FROM protected_sites.meta_202501 WHERE data_title ILIKE '%natura 2000%';
--id=1832
ALTER TABLE pollutants.wdpa_wdoecm_202601 ADD COLUMN n2k boolean;
UPDATE pollutants.wdpa_wdoecm_202601 SET n2k=TRUE WHERE metadataid = 1832;

ALTER TABLE  pollutants.wdpa_wdoecm_202601 ADD PRIMARY KEY(site_id);
CREATE INDEX ON pollutants.wdpa_wdoecm_202601 USING GIST(geom);

CREATE TEMPORARY TABLE selected AS
SELECT DISTINCT a.site_id
FROM pollutants.wdpa_wdoecm_202601 a,pollutants.firm_facility_buffer b
WHERE ST_INTERSECTS(a.geom,b.geom)
ORDER BY site_id;

ALTER TABLE pollutants.wdpa_wdoecm_202601 ADD COLUMN is_selected boolean;
UPDATE pollutants.wdpa_wdoecm_202601 SET is_selected=TRUE WHERE site_id IN (SELECT DISTINCT site_id FROM selected);
