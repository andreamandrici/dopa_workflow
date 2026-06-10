--------------------------------------------------------------------------------------------------------------------
-- import from 321p to 247p
--------------------------------------------------------------------------------------------------------------------
SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema = 'remote_wolfe';
--------------------------------------------------------------------------------------------------------------------
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema = 'remote_wolfe') LOOP
        EXECUTE 'DROP FOREIGN  TABLE IF EXISTS remote_wolfe.' || quote_ident(r.foreign_table_name) || '';
    END LOOP;
END $$;
--------------------------------------------------------------------------------------------------------------------
IMPORT FOREIGN SCHEMA cep_data_202601 LIMIT TO (
--cep_index,index_country_cep,pa_mask,pa_buffers,index_pa_buffers,country_all_inds
country_conservation_pa_list_count)
FROM SERVER wolfe_321_17 INTO remote_wolfe;
--------------------------------------------------------------------------------------------------------------------
-- DROP TABLE IF EXISTS cep_data_202601.cep_index;CREATE TABLE cep_data_202601.cep_index AS SELECT * FROM remote_wolfe.cep_index;
-- DROP TABLE IF EXISTS cep_data_202601.index_country_cep;CREATE TABLE cep_data_202601.index_country_cep AS SELECT * FROM remote_wolfe.index_country_cep;
-- DROP TABLE IF EXISTS cep_data_202601.pa_mask;CREATE TABLE cep_data_202601.pa_mask AS SELECT * FROM remote_wolfe.pa_mask;
-- DROP TABLE IF EXISTS cep_data_202601.index_pa_buffers;CREATE TABLE cep_data_202601.index_pa_buffers AS SELECT * FROM remote_wolfe.index_pa_buffers;
-- DROP TABLE IF EXISTS cep_data_202601.pa_buffers;CREATE TABLE cep_data_202601.pa_buffers AS SELECT * FROM remote_wolfe.pa_buffers;
-- DROP TABLE IF EXISTS cep_data_202601.country_all_inds;CREATE TABLE cep_data_202601.country_all_inds AS SELECT * FROM remote_wolfe.country_all_inds;
DROP TABLE IF EXISTS cep_data_202601.country_conservation_pa_list_count;CREATE TABLE cep_data_202601.country_conservation_pa_list_count AS SELECT * FROM remote_wolfe.country_conservation_pa_list_count;
