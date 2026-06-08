DROP TABLE IF EXISTS cep_202601_pa_buff.h_flat_ori;CREATE TABLE cep_202601_pa_buff.h_flat_ori AS
SELECT * FROM cep_202601_pa_buff.h_flat;
DELETE FROM cep_202601_pa_buff.h_flat WHERE pa && '{1}';
