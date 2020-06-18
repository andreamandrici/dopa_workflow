WITH
a AS (SELECT * FROM eco2020_input_teow.b_clip_teow_overlaps WHERE note IS NOT NULL),
b AS (SELECT a1.fid,a2.fid fid2,(ST_DUMP(ST_INTERSECTION(a1.geom,a2.geom))).*
FROM a a1 JOIN a a2 ON(ST_INTERSECTS(a1.geom,a2.geom))
WHERE a1.qid=a2.qid AND a1.tid != a2.tid
ORDER BY fid,fid2)
SELECT fid,ARRAY_AGG(DISTINCT fid2 ORDER BY fid2) fid2,ST_GEOMETRYTYPE(geom) gtype,ST_MULTI(ST_COLLECT(geom)) geom
FROM b GROUP BY fid,gtype ORDER BY gtype,fid