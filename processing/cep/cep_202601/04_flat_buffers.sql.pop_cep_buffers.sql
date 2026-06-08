--DROP SCHEMA cep_202601_pa_buff CASCADE;
INSERT INTO cep_202601_pa_buff.da_tiled_pa(qid,fid,path,geom)
SELECT qid,cid,UNNEST(path) p,geom
FROM (SELECT qid,cid,(ST_DUMP(geom)).* FROM cep_data_202601.pa_mask) a;
SELECT DISTINCT ST_ISVALID(geom),ST_GEOMETRYTYPE(geom) FROM cep_202601_pa_buff.da_tiled_pa;

INSERT INTO cep_202601_pa_buff.da_tiled_pa_buffers
SELECT * FROM cep_202601_pa_buff.z_da_tiled_pa_buffers;
SELECT DISTINCT ST_ISVALID(geom),ST_GEOMETRYTYPE(geom) FROM cep_202601_pa_buff.da_tiled_pa;
