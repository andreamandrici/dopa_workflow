# CEP

## 01_flat_cep

Flat 2 layer:

- Country =  country_26 from GISCO
- PA = WCMC PA 202601

## 02_cep_data

Sources, results and indexes.

## 03_flat_cep_protected_mask

Flat 1 layer:

- source layer is a placeholder
- generate infrastructure
- import pa from cep (sql/pop_pa_mask.sql)
- run in z_do_it_all.sh: 
  - o_raster.sh
  - p_export_raster.sh
  - o_vector.sh: derives binary vector protection layer from o_raster (this is very static!!! Check names!!!) 

1. *workflow_parameters.conf:* conf file for flattening
2. *check_cep.sql:* check missing pixels in the output (not fixed)
3. *cep_data.sql:* creates export schema
4. *create_pa_mask.sql:* to be used with flat
