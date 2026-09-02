--firms
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS firm_facility;CREATE TEMPORARY TABLE firm_facility AS
SELECT facility_inspire_id::text,countrycode::text,ARRAY_AGG(reportingyear::integer ORDER BY reportingyear::integer) ryears,
ST_SETSRID(ST_MAKEPOINT(pointgeometrylon::double precision,pointgeometrylat::double precision), 4326) point
FROM pollutants.firm_facility_16_input
GROUP BY facility_inspire_id,countrycode,pointgeometrylon,pointgeometrylat
ORDER BY facility_inspire_id::text;

DROP TABLE IF EXISTS pollutants.firm_facility CASCADE;CREATE TABLE pollutants.firm_facility AS
SELECT ROW_NUMBER() OVER () ffid,* FROM firm_facility;
ALTER TABLE pollutants.firm_facility ADD PRIMARY KEY(ffid);
CREATE INDEX ON pollutants.firm_facility (facility_inspire_id);
CREATE INDEX ON pollutants.firm_facility USING GIST(point);
CREATE EXTENSION IF NOT EXISTS btree_gin;
SELECT * FROM pg_extension WHERE extname = 'btree_gin';
CREATE INDEX ON pollutants.firm_facility USING GIN(ryears);
ANALYZE pollutants.firm_facility;

--buffer
------------------------------------------------------------------
DROP TABLE IF EXISTS pollutants.firm_facility_buffer;
CREATE TABLE pollutants.firm_facility_buffer AS
SELECT ST_BUFFER(ST_CONVEXHULL(ST_COLLECT(point)),1) geom FROM pollutants.firm_facility;
CREATE INDEX ON pollutants.firm_facility_buffer USING GIST (geom);

--firm_years
DROP TABLE IF EXISTS pollutants.firm_years;CREATE TABLE pollutants.firm_years AS
SELECT ffid,UNNEST(ryears) r_yr FROM pollutants.firm_facility ORDER BY ffid,r_yr;
CREATE INDEX ON pollutants.firm_years (r_yr);
------------------------------------------------------------------
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
----------------------
--pa
DROP TABLE IF EXISTS pollutants.pa;CREATE TABLE pollutants.pa AS
SELECT status_yr,site_id,site_type,geom FROM pollutants.wdpa_wdoecm_202601
WHERE is_selected IS TRUE AND n2k IS NULL
ORDER BY status_yr,site_id;
ALTER TABLE pollutants.pa ADD PRIMARY KEY (site_id);
CREATE INDEX ON pollutants.pa USING GIST(geom);
CREATE INDEX pa_status_yr_idx ON pollutants.pa (status_yr);
--n2k
DROP TABLE IF EXISTS pollutants.n2k;CREATE TABLE pollutants.n2k AS
SELECT status_yr,site_id,site_type,geom FROM pollutants.wdpa_wdoecm_202601
WHERE is_selected IS TRUE AND n2k IS TRUE
ORDER BY status_yr,site_id;
ALTER TABLE pollutants.n2k ADD PRIMARY KEY (site_id);
CREATE INDEX ON pollutants.n2k USING GIST(geom);
CREATE INDEX n2k_status_yr_idx ON pollutants.n2k (status_yr);

ANALYZE pollutants.pa;
ANALYZE pollutants.n2k;
ANALYZE pollutants.firm_years;

--pa_yr
DROP TABLE IF EXISTS pollutants.pa_year;
CREATE TABLE pollutants.pa_year AS
SELECT
    y.r_yr,
    n.site_id
FROM (
    SELECT DISTINCT r_yr
    FROM pollutants.firm_years
) y
JOIN pollutants.pa n
  ON n.status_yr <= y.r_yr;
CREATE INDEX pa_year_yr_site_idx
ON pollutants.pa_year (r_yr, site_id);

ANALYZE pollutants.pa_year;

--n2k_yr
DROP TABLE IF EXISTS pollutants.n2k_year;
CREATE TABLE pollutants.n2k_year AS
SELECT
    y.r_yr,
    n.site_id
FROM (
    SELECT DISTINCT r_yr
    FROM pollutants.firm_years
) y
JOIN pollutants.n2k n
  ON n.status_yr <= y.r_yr;
CREATE INDEX n2k_year_yr_site_idx
ON pollutants.n2k_year (r_yr, site_id);

ANALYZE pollutants.n2k_year;
---------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS pollutants.firm_pa;
CREATE TABLE pollutants.firm_pa AS
SELECT
    fy.ffid,
    fy.r_yr,
    p.site_id,
    ST_Distance(f.point::geography, p.geom::geography) AS distance
FROM pollutants.firm_years fy
JOIN pollutants.firm_facility f
    ON f.ffid = fy.ffid
LEFT JOIN LATERAL (
    SELECT
        pa.site_id,
        pa.geom
    FROM pollutants.pa_year py
    JOIN pollutants.pa
        ON pollutants.pa.site_id = py.site_id
    WHERE py.r_yr = fy.r_yr
    ORDER BY f.point <-> pollutants.pa.geom
    LIMIT 1
) p ON TRUE;
