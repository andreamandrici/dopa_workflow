INSERT INTO eco2020_output.b_clip_meow(tid,qid,fid,path,geom)
SELECT ROW_NUMBER () OVER () tid,* FROM 
(SELECT qid,fid,UNNEST(path) path,geom
FROM
(SELECT qid,fid,(ST_DUMP(geom)).* FROM
(SELECT qid,UNNEST(meow) fid,geom FROM eco2020_input_meow.h_flat ORDER BY qid,fid) a1
ORDER BY qid,fid,path) a2
ORDER BY qid,fid,path) a3
ORDER BY qid,fid,path;

DROP TABLE IF EXISTS validz; CREATE TEMPORARY TABLE validz AS
SELECT tid,(ST_ISVALIDDETAIL(geom)).* FROM eco2020_output.b_clip_meow WHERE ST_ISVALID(geom);
DROP TABLE IF EXISTS geomz; CREATE TEMPORARY TABLE geomz AS
SELECT tid,ST_GEOMETRYTYPE(geom) FROM eco2020_output.b_clip_meow WHERE ST_GEOMETRYTYPE(geom) !='ST_Polygon';

SELECT DISTINCT valid FROM validz;
SELECT DISTINCT(st_geometrytype) FROM geomz;