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
----------------------
DROP TABLE IF EXISTS pollutants.firm_facility_output;

CREATE TABLE pollutants.firm_facility_output AS
SELECT
    f.facility_inspire_id,
    f.countrycode,
    f.point,
    f.ryears,
    y.year,

    -- ========================================================
    -- N2K
    -- ========================================================
    n.site_id        AS n2k_site_id,
    n.site_pid       AS n2k_site_pid,
    n.site_type      AS n2k_site_type,
    n.name_eng       AS n2k_name_eng,
    n.name           AS n2k_name,
    n.desig          AS n2k_desig,
    n.desig_eng      AS n2k_desig_eng,
    n.desig_type     AS n2k_desig_type,
    n.iucn_cat       AS n2k_iucn_cat,
    n.int_crit       AS n2k_int_crit,
    n.realm          AS n2k_realm,
    n.inlnd_wtrs     AS n2k_inlnd_wtrs,
    n.rep_m_area     AS n2k_rep_m_area,
    n.gis_m_area     AS n2k_gis_m_area,
    n.rep_area       AS n2k_rep_area,
    n.gis_area       AS n2k_gis_area,
    n.no_take        AS n2k_no_take,
    n.no_tk_area     AS n2k_no_tk_area,
    n.status         AS n2k_status,
    n.status_yr      AS n2k_status_yr,
    n.gov_type       AS n2k_gov_type,
    n.own_type       AS n2k_own_type,
    n.mang_auth      AS n2k_mang_auth,
    n.mang_plan      AS n2k_mang_plan,
    n.verif          AS n2k_verif,
    n.metadataid     AS n2k_metadataid,
    n.govsubtype     AS n2k_govsubtype,
    n.ownsubtype     AS n2k_ownsubtype,
    n.prnt_iso3      AS n2k_prnt_iso3,
    n.iso3           AS n2k_iso3,
    n.wdpaid         AS n2k_wdpaid,
    n.wdpa_pid       AS n2k_wdpa_pid,
    n.pa_def         AS n2k_pa_def,
    n.marine         AS n2k_marine,
    n.type           AS n2k_type,
    n.parcels        AS n2k_parcels,
    n.area_geo       AS n2k_area_geo,
    n.distance       AS n2k_distance,

    -- ========================================================
    -- NON N2K
    -- ========================================================
    p.site_id        AS site_id,
    p.site_pid       AS site_pid,
    p.site_type      AS site_type,
    p.name_eng       AS name_eng,
    p.name           AS name,
    p.desig          AS desig,
    p.desig_eng      AS desig_eng,
    p.desig_type     AS desig_type,
    p.iucn_cat       AS iucn_cat,
    p.int_crit       AS int_crit,
    p.realm          AS realm,
    p.inlnd_wtrs     AS inlnd_wtrs,
    p.rep_m_area     AS rep_m_area,
    p.gis_m_area     AS gis_m_area,
    p.rep_area       AS rep_area,
    p.gis_area       AS gis_area,
    p.no_take        AS no_take,
    p.no_tk_area     AS no_tk_area,
    p.status         AS status,
    p.status_yr      AS status_yr,
    p.gov_type       AS gov_type,
    p.own_type       AS own_type,
    p.mang_auth      AS mang_auth,
    p.mang_plan      AS mang_plan,
    p.verif          AS verif,
    p.metadataid     AS metadataid,
    p.govsubtype     AS govsubtype,
    p.ownsubtype     AS ownsubtype,
    p.prnt_iso3      AS prnt_iso3,
    p.iso3           AS iso3,
    p.wdpaid         AS wdpaid,
    p.wdpa_pid       AS wdpa_pid,
    p.pa_def         AS pa_def,
    p.marine         AS marine,
    p.type           AS type,
    p.parcels        AS parcels,
    p.area_geo       AS area_geo,
    p.distance       AS distance

FROM pollutants.firm_facility f

CROSS JOIN LATERAL
    unnest(f.ryears) AS y(year)

-- ============================================================
-- NEAREST N2K PA
-- ============================================================
LEFT JOIN LATERAL (
    SELECT
        a.*,
        ST_Distance(
            f.point::geography,
            a.geom::geography
        ) AS distance
    FROM pollutants.wdpa_wdoecm_202601 a
    WHERE a.is_selected IS TRUE
      AND a.n2k IS TRUE
      AND a.status_yr <= y.year
    ORDER BY f.point <-> a.geom
    LIMIT 1
) n ON TRUE

-- ============================================================
-- NEAREST NON-N2K PA
-- ============================================================
LEFT JOIN LATERAL (
    SELECT
        a.*,
        ST_Distance(
            f.point::geography,
            a.geom::geography
        ) AS distance
    FROM pollutants.wdpa_wdoecm_202601 a
    WHERE a.is_selected IS TRUE
      AND a.n2k IS NOT TRUE
      AND a.status_yr <= y.year
    ORDER BY f.point <-> a.geom
    LIMIT 1
) p ON TRUE

ORDER BY f.facility_inspire_id, y.year;
