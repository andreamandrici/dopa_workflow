# CEP

## 01_flat_cep

Flat 2 layers:

- Country =  country_26 from GISCO
- PA = WCMC PA 202601

## 02_cep_data

- Generates (for export) sources, results and indexes.
- Execute according to the stage (eg: buffer index can be generated only after having generated buffers).
- Use import_schema_x.sql to move within servers.

## 03_flat_cep_protected_mask

Flat 1 layer:

- source layer is a placeholder
- generate infrastructure
- import pa from cep (sql/pop_pa_mask.sql)
- run in z_do_it_all.sh: 
  - o_raster.sh
  - p_export_raster.sh
  - o_vector.sh: derives binary vector protection layer from o_raster (this is very static!!! Check names!!!) 

## 04_flat_buffers

Flat 2 layers:
- pa source layer is a placeholder
- generate infrastructure
- import pa mask from 03_cep_pa_mask (sql/pop_cep_buffers.sql)
- uses pa_buffers (over 1 sqkm)
- run z_do_it_all.sh accordingly:
  -  db_tiled_all.sh
  -  e_flat_all.sh
  -  f_attributes_all.sh
  -  g_final_all.sh
  -  h_output.sh
- remove pa from flat (sql/erase_cep_buffers.sql)
- run z_do_it_all.sh accordingly:
  -  o_raster.sh
  -  p_export_raster.sh

