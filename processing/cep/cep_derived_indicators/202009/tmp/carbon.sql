WITH
a AS (
SELECT
country_id,country_name,country_iso3,status,
ROUND(carbon_tot_c_pg_total,6) carbon_tot_c_pg_total,
ROUND(carbon_tot_c_pg_prot,6) carbon_tot_c_pg_prot,
carbon_tot_c_pg_unprot,
ROUND(((carbon_tot_c_pg_prot/NULLIF(carbon_tot_c_pg_total,0))*100),6) prot_perc
FROM administrative_units.get_country_all_inds()
WHERE country_iso3 !='ABNJ' AND carbon_tot_c_pg_total > 0 AND carbon_tot_c_pg_total IS NOT NULL
ORDER BY prot_perc NULLS FIRST,carbon_tot_c_pg_total),
b AS (SELECT SUM(carbon_tot_c_pg_total) global_carbon FROM a),
c AS (SELECT SUM(carbon_tot_c_pg_prot) global_prot_carbon FROM a),
d AS (SELECT global_prot_carbon/global_carbon*100 global_prot_carbon_perc FROM b,c),
e AS (
SELECT
a.*,ROUND(global_carbon,6) global_carbon,ROUND(global_prot_carbon,6) global_prot_carbon,
ROUND(global_prot_carbon_perc,6) global_prot_carbon_perc,
ROUND(carbon_tot_c_pg_total/global_carbon*100,6) total_carbon_as_perc_of_global_carbon,
ROUND(carbon_tot_c_pg_prot/global_carbon*100,6) protected_carbon_as_perc_of_global_carbon,
ROUND(carbon_tot_c_pg_prot/global_prot_carbon*100,6) protected_carbon_as_perc_of_global_protected_carbon
FROM a,b,c,d
ORDER BY protected_carbon_as_perc_of_global_protected_carbon DESC NULLS LAST)
SELECT
--*,
country_id,country_name,country_iso3,status,
global_carbon global_carbon_pg,global_prot_carbon global_prot_carbon_pg, global_prot_carbon_perc,
carbon_tot_c_pg_total country_carbon_pg,
carbon_tot_c_pg_prot country_carbon_prot_pg,
ROUND(((carbon_tot_c_pg_prot/NULLIF(carbon_tot_c_pg_total,0))*100),6) country_carbon_prot_on_country_carbon_perc,
total_carbon_as_perc_of_global_carbon country_carbon_on_global_carbon_perc,
protected_carbon_as_perc_of_global_carbon country_carbon_prot_on_global_carbon_perc,
protected_carbon_as_perc_of_global_protected_carbon country_carbon_prot_on_global_carbon_prot_perc
FROM e