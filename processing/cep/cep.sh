#!/bin/bash
# SET SOME VARIABLES
VCOUNTRY="gaul_eez_dissolved_201912" # input country
VECO="ecoregions_2019" # input ecoregion
VPA="wdpa_202003" # input wdpa
VCEP="202003" # version of the processed cep; please use always the format "cep"yyyymm (here insert yyyymm)

## database parameters
HOST="localhost" # name or ip address of your host
USER="h05ibex" # your postgres user
DB="wolfe" # your db
SCH="cep"${VCEP} # your processed cep schema; please use always the format "cep"yyyymm (here change "cep", ONLY IF YOU DO NOT RESPECT the suggested format)
PO=5432

# DO NOT TOUCH THE FOLLOWING VALUES
dbpar1="host=${HOST} user=${USER} dbname=${DB} port=${PO}"
dbpar2="-h ${HOST} -U ${USER} -d ${DB} -p ${PO}"

sql_function=$(cat<<EOF
CREATE OR REPLACE FUNCTION cep.f_get_latest_cep()
RETURNS void
LANGUAGE 'plpgsql'
AS \$BODY\$
DECLARE
tname TEXT := (SELECT table_schema::text||'.'||table_name::text FROM information_schema.tables WHERE table_schema='cep' AND table_name LIKE 'cep_20%' ORDER BY table_name DESC LIMIT 1); 
BEGIN
EXECUTE '
DROP TABLE IF EXISTS cep.cep_last;
CREATE TABLE cep.cep_last AS
SELECT * FROM '||tname||'
ORDER BY qid,cid;
ALTER TABLE cep.cep_last ADD PRIMARY KEY(qid,cid);
CREATE INDEX cep_geom_idx ON cep.cep_last USING gist(geom);
CREATE INDEX cep_country_idx ON cep.cep_last USING gin(country);
CREATE INDEX cep_eco_idx ON cep.cep_last USING gin(eco);
CREATE INDEX cep_pa_idx ON cep.cep_last USING gin(pa);
';
END;
\$BODY\$;
EOF
)
psql ${dbpar2} -c "$sql_function"

sql_input=$(cat<<EOF
DROP TABLE IF EXISTS cep.cep_${VCEP};
DROP TABLE IF EXISTS cep.cep_index_${VCEP};
DROP TABLE IF EXISTS cep.cep_last_index;
CREATE TABLE cep.cep_${VCEP} AS SELECT qid,cid,country,ecoregion eco,wdpa pa,sqkm,geom FROM ${SCH}.h_flat ORDER BY qid,cid;
SELECT cep.f_get_latest_cep();
CREATE TABLE cep.cep_index_${VCEP} AS
WITH a AS (SELECT qid,cid,u.* FROM cep.cep_last,UNNEST(country,eco,pa) AS u(country,eco,pa))
SELECT a.qid,a.cid,a.country,b.country_name,b.iso3,a.eco,c.first_level eco_name,
CASE WHEN c.source IN ('teow','eeow') THEN false::bool ELSE true::bool END is_marine,
a.pa,d."name" pa_name,
CASE a.pa WHEN 0 THEN false::bool ELSE true::bool END is_protected
FROM a
LEFT JOIN administrative_units.${VCOUNTRY} b ON a.country=b.country_id
LEFT JOIN habitats_and_biotopes.${VECO} c ON a.eco=c.first_level_code
LEFT JOIN protected_sites.${VPA} d ON a.pa=d.wdpaid
ORDER BY a.qid,a.cid;
CREATE TABLE cep.cep_last_index AS SELECT * FROM cep.cep_index_${VCEP};
EOF
)
psql ${dbpar2} -c "$sql_input"
