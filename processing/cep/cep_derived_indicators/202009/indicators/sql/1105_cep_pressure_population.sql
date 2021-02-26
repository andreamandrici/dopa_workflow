DROP TABLE IF EXISTS tfilter; CREATE TEMPORARY TABLE tfilter AS
--SELECT DISTINCT qid FROM arctic.z_arctic_grid;
SELECT DISTINCT qid FROM cep.cep_last;
DROP TABLE IF EXISTS theme; CREATE TEMPORARY TABLE theme AS SELECT * FROM results_202009_cep_in.cid_area_cep202009_ghs_pop_9as_2015 NATURAL JOIN tfilter;
DROP TABLE IF EXISTS pa_index; CREATE TEMPORARY TABLE pa_index AS SELECT * FROM cep.index_pa_cep_last NATURAL JOIN tfilter;
--  write final indicator table
DROP TABLE IF EXISTS results_202009_cep_out.wdpa_pressure_population_pa; CREATE  TABLE results_202009_cep_out.wdpa_pressure_population_pa AS
WITH
a AS (SELECT * FROM pa_index NATURAL JOIN theme),
area_pas AS (SELECT pa wdpaid,pa_name,iso3,marine,
--SUM(sqkm) sqkm, 
SUM(area_m2)/1000000 pa_tot_area_km2 
FROM a GROUP BY pa,pa_name,iso3,marine ORDER BY pa),
density_first_epoch AS 
(SELECT wdpaid, pa_pressure_population_first_epoch_sum, ROUND(pa_pressure_population_first_epoch_sum::numeric/NULLIF(pa_tot_area_km2::numeric,0),2) pa_pressure_population_density_first_epoch
FROM results_202009_cep_out.wdpa_pressure_population_first_epoch JOIN area_pas USING(wdpaid)),
density_last_epoch AS 
(SELECT wdpaid, pa_pressure_population_last_epoch_sum, ROUND(pa_pressure_population_last_epoch_sum::numeric/NULLIF(pa_tot_area_km2::numeric,0),2) pa_pressure_population_density_last_epoch
FROM results_202009_cep_out.wdpa_pressure_population_last_epoch JOIN area_pas USING(wdpaid)),
density_change AS 
(SELECT a.wdpaid,(a.pa_pressure_population_density_last_epoch-b.pa_pressure_population_density_first_epoch) pa_pressure_population_density_change
FROM density_last_epoch a LEFT JOIN density_first_epoch b USING (wdpaid)),
pop_change AS 
(SELECT a.wdpaid,((a.pa_pressure_population_last_epoch_sum-b.pa_pressure_population_first_epoch_sum)/NULLIF(b.pa_pressure_population_first_epoch_sum,0)*100) pa_pressure_population_change_perc
FROM density_last_epoch a LEFT JOIN density_first_epoch b USING (wdpaid))

SELECT a.wdpaid,
a.pa_pressure_population_last_epoch_sum,
a.pa_pressure_population_density_last_epoch,
b.pa_pressure_population_density_change,
c.pa_pressure_population_change_perc
FROM density_last_epoch a LEFT JOIN density_change b USING (wdpaid) LEFT JOIN pop_change c USING (wdpaid)
ORDER BY wdpaid;