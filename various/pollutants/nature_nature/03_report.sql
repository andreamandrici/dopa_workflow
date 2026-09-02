SELECT 'PA' AS tipo, COUNT(*) FROM pollutants.firm_pa
UNION ALL
SELECT 'N2K', COUNT(*) FROM pollutants.firm_n2k;

DROP TABLE IF EXISTS pollutants.firm_distance;
CREATE TABLE pollutants.firm_distance AS
SELECT
    pa.ffid,
    pa.r_yr,
    pa.site_id   AS pa_site_id,
    pa.distance  AS pa_distance,
    n2k.site_id   AS n2k_site_id,
    n2k.distance  AS n2k_distance
FROM pollutants.firm_pa pa
JOIN pollutants.firm_n2k n2k
  ON n2k.ffid = pa.ffid
 AND n2k.r_yr = pa.r_yr;

ALTER TABLE pollutants.firm_distance
ADD PRIMARY KEY (ffid, r_yr);

ANALYZE pollutants.firm_distance;

DROP TABLE IF EXISTS pollutants.firm_final_report;
CREATE TABLE pollutants.firm_final_report AS
SELECT
ffid,facility_inspire_id,r_yr,
pa_site_id,pa_distance,
c.site_type pa_site_type,c.name_eng::text pa_name,c.desig_eng::text pa_desig,c.desig_type::text pa_desig_type,c.status_yr pa_status_yr,c.iso3 pa_iso3,
n2k_site_id,n2k_distance,
'N2K' n2k_site_type,d.name_eng::text n2k_name,d.desig_eng::text n2k_desig,d.desig_type::text n2k_desig_type,d.status_yr n2k_status_yr,d.iso3 n2k_iso3
FROM pollutants.firm_distance a
JOIN pollutants.firm_facility b USING(ffid)
JOIN pollutants.wdpa_wdoecm_202601 c ON pa_site_id=c.site_id
JOIN pollutants.wdpa_wdoecm_202601 d ON n2k_site_id=d.site_id
ORDER BY ffid,r_yr;
SELECT * FROM pollutants.firm_final_report;
