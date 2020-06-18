-- clean atts
DROP TABLE IF EXISTS eco2020.temporary_atts;CREATE TABLE eco2020.temporary_atts AS
SELECT cid,UNNEST(teow) first_level_code,'teow' source,'originally teow' note FROM eco2020.fb_atts_all WHERE teow <> '{0}' AND meow = '{0}' AND ppow = '{0}'
UNION
SELECT cid,UNNEST(meow) first_level_code,'meow' source,'originally meow' note FROM eco2020.fb_atts_all WHERE teow = '{0}' AND meow <> '{0}' AND ppow = '{0}'
UNION
SELECT cid,UNNEST(ppow) first_level_code,'ppow' source,'originally ppow' note FROM eco2020.fb_atts_all WHERE teow = '{0}' AND meow = '{0}' AND ppow <> '{0}'
UNION
SELECT cid,UNNEST(eeow) first_level_code,'eeow' source,'originally eeow' note FROM eco2020.fb_atts_all WHERE teow = '{0}' AND meow = '{0}' AND ppow = '{0}'
ORDER BY cid;

-- additional atts
DROP TABLE IF EXISTS eco2020.additional_atts;CREATE TABLE eco2020.additional_atts AS
WITH a AS (SELECT * FROM eco2020.fb_atts_all WHERE cid NOT IN (SELECT cid FROM eco2020.temporary_atts))
SELECT cid,UNNEST(teow) first_level_code,'teow' source,'assigned to teow' note FROM a WHERE teow && ARRAY[60172,61318]
UNION
SELECT cid,UNNEST(meow) first_level_code,'meow' source,'assigned to meow' note FROM a WHERE NOT (teow && ARRAY[60172,61318]) AND meow <> '{0}' AND ppow = '{0}'
UNION
SELECT cid,UNNEST(ppow) first_level_code,'ppow' source,'assigned to ppow' note FROM a WHERE NOT (teow && ARRAY[60172,61318]) AND meow = '{0}' AND ppow <> '{0}'
ORDER BY cid;

-- Final geoms
DROP TABLE IF EXISTS eco2020.temporary_done;CREATE TABLE eco2020.temporary_done AS
SELECT a.qid,a.cid,b.first_level_code,b.source,b.note,a.geom,a.sqkm
FROM eco2020.h_flat a JOIN eco2020.temporary_atts b USING(cid)
UNION
SELECT a.qid,a.cid,b.first_level_code,b.source,b.note,a.geom,a.sqkm
FROM eco2020.h_flat a JOIN eco2020.additional_atts b USING(cid)
ORDER BY cid

--FINAL ATTS
DROP TABLE IF EXISTS eco2020.final_atts;CREATE TABLE eco2020.final_atts AS
WITH
a AS (SELECT qid,cid,d.teow,d.meow,d.ppow,d.eeow,sqkm FROM eco2020.h_flat,UNNEST(teow,meow,ppow,eeow) AS d(teow,meow,ppow,eeow)),
b AS (SELECT qid,cid,first_level_code,source,note FROM eco2020.temporary_done)
SELECT * FROM b NATURAL JOIN a ORDER BY qid,cid,first_level_code;