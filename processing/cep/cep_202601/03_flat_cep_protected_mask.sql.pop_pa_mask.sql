----------------------------------------------------------------
DROP TABLE IF EXISTS cep202601_pa_mask.step1;CREATE TABLE cep202601_pa_mask.step1 AS
SELECT qid,1 ncid,(ST_DUMP(geom)).geom
FROM cep_data_202601.cep
WHERE pa !='{0}'
ORDER BY qid;
----------------------------------------------------------------
DROP TABLE IF EXISTS cep202601_pa_mask.step2;CREATE TABLE cep202601_pa_mask.step2 AS
SELECT qid,ncid cid,ST_MULTI(ST_COLLECT(geom)) geom FROM cep202601_pa_mask.step1 GROUP BY qid,cid ORDER BY qid,cid;
----------------------------------------------------------
TRUNCATE TABLE cep202601_pa_mask.h_flat;
INSERT INTO cep202601_pa_mask.h_flat(qid,cid,geom) SELECT * FROM cep202601_pa_mask.step2;

------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cep202601_pa_mask.o_vector
(
    qid integer NOT NULL,
    cid integer NOT NULL,
    geom geometry,
    CONSTRAINT o_vector_pkey PRIMARY KEY (qid, cid)
);

ALTER TABLE cep202601_pa_mask.o_vector
    OWNER to h05ibex;
-- Index: o_vector_geom_idx

-- DROP INDEX cep202601_pa_mask.o_vector_geom_idx;

CREATE INDEX o_vector_geom_idx
    ON cep202601_pa_mask.o_vector USING gist
    (geom)
    TABLESPACE pg_default;
-- Index: o_vector_qid_idx

-- DROP INDEX cep202601_pa_mask.o_vector_qid_idx;

CREATE INDEX o_vector_qid_idx
    ON cep202601_pa_mask.o_vector USING btree
    (qid ASC NULLS LAST)
    TABLESPACE pg_default;
