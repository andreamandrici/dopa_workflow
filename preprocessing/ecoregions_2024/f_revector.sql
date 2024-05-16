CREATE OR REPLACE FUNCTION ecoregions_2024.f_revector(
	iqid integer,
	ischema text)
    RETURNS void
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
sql text;

BEGIN
sql :='
INSERT INTO '||ischema||'.q_revector_temp(qid,cid,geom,sqkm)
SELECT '||iqid||' qid,* FROM
(SELECT val::bigint cid,ST_MULTI(ST_COLLECT(geom)) geom,SUM(ST_AREA(geom::geography)/1000000) sqkm
FROM (SELECT (ST_DUMPASPOLYGONS(rast)).* FROM '||ischema||'.o_raster WHERE qid = '||iqid||') a GROUP BY cid) b
ORDER BY cid;';
EXECUTE sql USING iqid,ischema;
END;
$BODY$;

COMMENT ON FUNCTION ecoregions_2024.f_revector(integer, text) IS
're-vectorise back o_raster table; inputs parameters are:
iqid - integer - input qid: tile unique id - number;
ischema - text - processing schema - ''schema_name'';';

