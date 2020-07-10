# PROCESSING 
## [CEP](../README.md) (Country/Ecoregion/Protection) derived indicators

ecoregions_2020.csv: attributes of the current ecoregions
wdpa_202003_oecm_only.sql: creates a table (cep.cep_202003_oecm_cid_non_oecm) containing a list of cids containing OECM ONLY
country_statistics_wdpa_20203_oecm_ecoregions_2020.sql: calculates coverages for countries INCLUDING OR NOT OECMs as protected areas (look at the code)
country_statistics_wdpa_20203_and_oecm_ecoregions_2020.csv (results from above; includes oecm)
country_statistics_wdpa_20203_no_oecm_ecoregions_2020.csv (results from above; does not include oecm)
ecoregion_statistics_wdpa_20203_oecm_ecoregions_2020.sql: calculates coverages for ecoregions INCLUDING OR NOT OECMs as protected areas (look at the code)
ecoregion_statistics_wdpa_20203_and_oecm_ecoregions_2020.csv (results from above; includes oecm)
ecoregion_statistics_wdpa_20203_no_oecm_ecoregions_2020.csv (results from above; includes oecm)





### Countries statistics

Protection Coverage: [country protection coverage sql](./country_coverage.sql) to be manually executed. Fully commented.

### Ecoregions statistics

Protection Coverage: [ecoregion protection coverage sql](./ecoregion_coverage.sql) to be manually executed. Fully commented.

### Protected areas statistics

Ecoregion Coverage





