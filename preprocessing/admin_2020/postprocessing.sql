--------------------------------------
---POST_FLAT
--------------------------------------------
SELECT * FROM gisco_2020_flat.fb_atts_all;

SELECT * FROM gisco_2020_flat.fb_atts_all WHERE (CARDINALITY(land)+CARDINALITY(marine)+CARDINALITY(abnj)) > 3; --this is overlapping land-land
SELECT * FROM gisco_2020_flat.fb_atts_all WHERE land && '{0}' AND marine && '{0}' AND abnj && '{0}'; --this should be abnj 3
SELECT * FROM gisco_2020_flat.fb_atts_all WHERE NOT (land && '{0}' OR marine && '{0}'); -- this is overlapping land_marine
SELECT * FROM gisco_2020_flat.fb_atts_all WHERE NOT (land && '{0}') AND NOT (abnj && '{0}'); -- overlap land and abnj;
SELECT * FROM gisco_2020_flat.fb_atts_all WHERE NOT (marine && '{0}') AND NOT (abnj && '{0}'); -- overlap marine and abnj;

DROP TABLE IF EXISTS problems;CREATE TEMPORARY TABLE problems AS
WITH
gisco_flat AS (SELECT DISTINCT cid,l,m,a,g FROM gisco_2020_flat.h_flat,UNNEST(land,marine,abnj,grid) AS u(l,m,a,g) ORDER BY cid),
problems AS (
SELECT *,1 ido,'land-land overlap' deso FROM gisco_flat WHERE cid = 263 
UNION
SELECT *,2 ido,'missing overlap' deso FROM gisco_flat WHERE l+m+a=0 AND g=1
UNION
SELECT *,3 ido,'land-marine overlap' deso FROM gisco_flat WHERE l!=0 AND m!=0
UNION
SELECT *,4 ido,'land-abnj overlap' deso FROM gisco_flat WHERE l!=0 AND a!=0
UNION
SELECT *,5 ido,'marine-abnj overlap' deso FROM gisco_flat WHERE m!=0 AND a!=0
),
less_problems AS (SELECT DISTINCT cid,ido,deso FROM problems ORDER BY cid,ido)
SELECT *,NULL::integer final_class FROM gisco_2020_flat.fb_atts_all LEFT JOIN less_problems USING(cid) ORDER BY cid;

SELECT * FROM problems
WHERE ido IS NULL AND final_class IS NULL AND NOT (land && '{0}');

UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,UNNEST(land) final_class FROM problems WHERE ido IS NULL AND final_class IS NULL AND NOT (land && '{0}')) a
WHERE problems.cid=a.cid;

SELECT * FROM problems
WHERE ido IS NULL AND final_class IS NULL AND NOT (marine && '{0}');

UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,UNNEST(marine) final_class FROM problems WHERE ido IS NULL AND final_class IS NULL AND NOT (marine && '{0}')) a
WHERE problems.cid=a.cid;

SELECT * FROM problems
WHERE ido IS NULL AND final_class IS NULL AND NOT (abnj && '{0}');

SELECT MAX(id) FROM (SELECT DISTINCT UNNEST(land) id FROM problems UNION SELECT DISTINCT UNNEST(marine) id FROM problems ORDER BY id) a;
	
UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,464+UNNEST(abnj) final_class FROM problems WHERE ido IS NULL AND final_class IS NULL AND NOT (abnj && '{0}')) a
WHERE problems.cid=a.cid;

SELECT DISTINCT ido,deso FROM problems WHERE ido IS NOT NULL AND final_class IS NULL;
SELECT ido,deso,COUNT(*) FROM problems WHERE ido IS NOT NULL AND final_class IS NULL GROUP BY ido,deso;

SELECT * FROM problems WHERE ido = 1;
UPDATE problems SET final_class=464
WHERE  ido = 1;

SELECT * FROM problems WHERE ido = 5;
UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,UNNEST(marine) final_class FROM problems WHERE ido = 5) a
WHERE problems.cid=a.cid;

DROP TABLE IF EXISTS gisco_2020.gisco_flat1;CREATE TABLE gisco_2020.gisco_flat1 AS
SELECT a.*,b.ido,b.deso,b.final_class FROM gisco_2020_flat.h_flat a JOIN problems b USING(cid) ORDER BY qid,cid;

DROP TABLE IF EXISTS gisco_2020.gisco_flat1_atts;CREATE TABLE gisco_2020.gisco_flat1_atts AS
SELECT * FROM problems ORDER BY cid;

SELECT ido,deso,COUNT(*) FROM gisco_2020.gisco_flat1
WHERE ido != 1 AND ido IS NOT NULL AND final_class IS NULL GROUP BY ido,deso;
