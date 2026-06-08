--------------------------------------------------------------------------------------------------------------------
-- import from 247p to 321p
--------------------------------------------------------------------------------------------------------------------
SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema = 'remote_247p_wolfe';
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT foreign_table_name FROM information_schema.foreign_tables WHERE foreign_table_schema = 'remote_247p_wolfe') LOOP
        EXECUTE 'DROP FOREIGN  TABLE IF EXISTS remote_247p_wolfe.' || quote_ident(r.foreign_table_name) || '';
    END LOOP;
END $$;

--IMPORT FOREIGN SCHEMA protected_sites LIMIT TO (wdpa_wdoecm_o1_buffers_202601)
--FROM SERVER remote_247p_wolfe INTO remote_247p_wolfe;

--DROP TABLE IF EXISTS protected_sites.wdpa_wdoecm_o1_buffers_202601;CREATE TABLE protected_sites.wdpa_wdoecm_o1_buffers_202601 AS
--SELECT * FROM remote_247p_wolfe.wdpa_wdoecm_o1_buffers_202601;

IMPORT FOREIGN SCHEMA pa_buff_202601 LIMIT TO (da_tiled_pa_buffers)
FROM SERVER remote_247p_wolfe INTO remote_247p_wolfe;

DROP TABLE IF EXISTS cep_202601_pa_buff.z_da_tiled_pa_buffers;CREATE TABLE cep_202601_pa_buff.z_da_tiled_pa_buffers AS
SELECT * FROM remote_247p_wolfe.da_tiled_pa_buffers;
