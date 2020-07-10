# PROCESSING 
## [CEP](../README.md) (Country/Ecoregion/Protection) derived indicators

### OECM related

Specific 202003 CEP version which includes ecoregions 2020 and OECMs from WCMC (added to standard WDPA).

+  **ecoregions_2020.csv**: attributes of the current ecoregions
+  `wdpa_202003_oecm_only.sql`: creates a table (**cep.cep_202003_oecm_cid_non_oecm**) containing a list of cids containing OECM ONLY
+  `country_statistics_wdpa_20203_oecm_ecoregions_2020.sql`: calculates coverages for countries INCLUDING OR NOT OECMs as protected areas (look at the code)
   +  **country_statistics_wdpa_20203_and_oecm_ecoregions_2020.csv** (results from above; includes oecm)
   +  **country_statistics_wdpa_20203_no_oecm_ecoregions_2020.csv** (results from above; does not include oecm)
+  `ecoregion_statistics_wdpa_20203_oecm_ecoregions_2020.sql`: calculates coverages for ecoregions INCLUDING OR NOT OECMs as protected areas (look at the code)
   +  **ecoregion_statistics_wdpa_20203_and_oecm_ecoregions_2020.csv** (results from above; includes oecm)
   +  **ecoregion_statistics_wdpa_20203_no_oecm_ecoregions_2020.csv** (results from above; does not include oecm)

