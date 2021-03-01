+  All NON-CEP derived indicators (ready to be included in final tables) go inside SCHEMA results_yyyymm_non_cep;
+  All CEP derived outputs (to be aggregated) go inside SCHEMA results_yyyymm_cep_in;
+  All CEP derived indicators (already aggregated) go (automatically, as outputs of the script indicators.sh) inside SCHEMA results_yyyymm_cep_out;

+  All FINAL TABLES (all indicators in final form) go (automatically, as outputs of the script outputs.sh) inside SCHEMA DOPA_X_XX.
