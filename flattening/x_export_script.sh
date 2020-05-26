#!/bin/bash

source workflow_parameters.conf

timeout 15s top -b -d 5 >> ./logs/top.log
wait

rm ./logs/cep202003.csv
touch ./logs/cep202003.csv
psql ${dbpar2} -t -c "\COPY (SELECT qid,cid,country,ecoregion,wdpa,sqkm FROM cep202003.h_flat) TO './logs/cep202003.csv' DELIMITER '|' CSV HEADER;"

rm ./logs/cep202003_cids.csv
touch ./logs/cep202003_cids.csv
psql ${dbpar2} -t -c "\COPY (SELECT * FROM cep202003.fb_atts_all) TO './logs/cep202003_cids.csv' DELIMITER '|' CSV HEADER;"

