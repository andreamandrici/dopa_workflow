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

SELECT * FROM problems WHERE ido = 4;
UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,UNNEST(land) final_class FROM problems WHERE ido = 4) a
WHERE problems.cid=a.cid;

SELECT * FROM problems WHERE ido = 3;
UPDATE problems SET final_class=a.final_class
FROM (SELECT cid,UNNEST(land) final_class FROM problems WHERE ido = 3) a
WHERE problems.cid=a.cid;

DROP TABLE IF EXISTS gisco_2020.gisco_flat1;CREATE TABLE gisco_2020.gisco_flat1 AS
SELECT a.*,b.ido,b.deso,b.final_class FROM gisco_2020_flat.h_flat a JOIN problems b USING(cid) ORDER BY qid,cid;

DROP TABLE IF EXISTS gisco_2020.gisco_flat1_atts;CREATE TABLE gisco_2020.gisco_flat1_atts AS
SELECT * FROM problems ORDER BY cid;
-------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS hole;CREATE TEMPORARY TABLE hole AS
SELECT qid,ido,geom,sqkm FROM gisco_2020.gisco_flat1 WHERE ido = 2 ORDER BY qid,sqkm;
CREATE INDEX ON hole USING GIST(geom);

DROP TABLE IF EXISTS checkz;CREATE TEMPORARY TABLE checkz AS
SELECT qid,final_class,geom,sqkm FROM gisco_2020.gisco_flat1 WHERE ido != 2 OR ido IS NULL ORDER BY qid,final_class,sqkm;
CREATE INDEX ON checkz USING GIST(geom);

DROP TABLE IF EXISTS holecheckz;CREATE TEMPORARY TABLE holecheckz AS
SELECT a.qid,a.sqkm,b.final_class FROM hole a,checkz b WHERE ST_TOUCHES(a.geom,b.geom) ORDER BY a.qid,b.qid,a.sqkm;

SELECT * FROM holecheckz WHERE final_class = 465;

UPDATE gisco_2020.gisco_flat1 SET final_class=a.final_class
FROM holecheckz a
WHERE gisco_flat1.ido=2  AND a.final_class=465 AND gisco_flat1.qid=a.qid AND gisco_flat1.sqkm=a.sqkm;

UPDATE gisco_2020.gisco_flat1 SET final_class=466
WHERE ido=2  AND final_class IS NULL;

DROP TABLE IF EXISTS gisco_2020.gisco_flat2a;CREATE TABLE gisco_2020.gisco_flat2a AS
SELECT qid,final_class,(ST_DUMP(geom)).* FROM gisco_2020.gisco_flat1 ORDER BY qid,final_class;

DROP TABLE IF EXISTS gisco_2020.gisco_flat2;CREATE TABLE gisco_2020.gisco_flat2 AS
SELECT qid,final_class,ST_MULTI(ST_UNION(geom)) geom FROM gisco_2020.gisco_flat2a GROUP BY qid,final_class ORDER BY qid,final_class;

SELECT DISTINCT final_class FROM gisco_2020.gisco_flat2 ORDER BY final_class;
SELECT DISTINCT ST_GEOMETRYTYPE(geom) FROM gisco_2020.gisco_flat2;
SELECT DISTINCT ST_ISVALID(geom) FROM gisco_2020.gisco_flat2;

DROP TABLE IF EXISTS gisco_2020.gisco_flat3a;CREATE TABLE gisco_2020.gisco_flat3a AS
SELECT qid,final_class pid,geom,(ST_AREA(geom::geography)/1000000) sqkm FROM gisco_2020.gisco_flat2a ORDER BY qid,pid;

DROP TABLE IF EXISTS gisco_2020.gisco_flat3atts;CREATE TABLE gisco_2020.gisco_flat3atts AS
SELECT pid,SUM(sqkm) sqkm FROM gisco_2020.gisco_flat3a GROUP BY pid ORDER BY pid;

SELECT * FROM gisco_2020.gisco_flat3atts;

------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS vector_abnj;CREATE TEMPORARY TABLE vector_abnj AS
SELECT 304+cat country_id,464+cat country_pid,ST_COLLECT(geom) geom FROM gisco_2020.input_abnj GROUP BY cat ORDER BY cat;

DROP TABLE IF EXISTS vector_admin;CREATE TEMPORARY TABLE vector_admin AS
SELECT country_id,country_pid,iso2,iso3,name_eng,status,source,cntr_code_stat,name_gaul,poli_org_code,descriptions,tids,ST_TRANSFORM(geom,4326) geom
FROM gisco_2020.gisco_admin_2020 WHERE country_pid < 465;

INSERT INTO vector_admin(country_id,country_pid,geom) SELECT * FROM vector_abnj ORDER BY country_pid;

UPDATE vector_admin SET iso2='ABNJ',iso3='ABNJ',name_eng='Area Beyond National Jurisdiction',source='dopa' WHERE country_pid=465;
UPDATE vector_admin SET iso2='INCO',iso3='INCO',name_eng='Inconsistent Coastline',source='dopa' WHERE country_pid=466;
UPDATE vector_admin SET iso2='MICO',iso3='MICO',name_eng='Missing Coverage',source='dopa' WHERE country_pid=467;

ALTER TABLE vector_admin ADD COLUMN sqkm double precision;
UPDATE vector_admin SET sqkm = ST_AREA(geom::geography)/1000000;

DROP TABLE IF EXISTS updated_countryt_atts;CREATE TEMPORARY TABLE updated_countryt_atts AS
WITH
a AS (
SELECT
country_id,country_pid,iso2,iso3,name_eng,status,source,
CASE
	WHEN source='gisco' THEN FALSE
	WHEN source='eez' THEN TRUE
	WHEN source='dopa' AND iso2='ABNJ' THEN TRUE
	WHEN source='dopa' AND iso2='MICO' THEN FALSE
END is_marine,
cntr_code_stat,name_gaul,poli_org_code,descriptions,tids,sqkm
FROM vector_admin)
SELECT a.*,b.sqkm rsqkm FROM a JOIN gisco_2020.gisco_flat3atts b ON a.country_pid=b.pid ORDER BY country_pid;

SELECT * FROM updated_countryt_atts;

--ALTER TABLE gisco_2020.gisco_admin_2020_atts RENAME TO gisco_admin_2020_atts_ori;
--CREATE TABLE gisco_2020.gisco_admin_2020_atts AS SELECT * FROM updated_countryt_atts;

ALTER TABLE gisco_2020.gisco_admin_2020 RENAME TO gisco_admin_2020_ori;
CREATE TABLE gisco_2020.gisco_admin_2020 AS
SELECT b.*,a.geom FROM vector_admin a JOIN updated_countryt_atts b USING(country_id,country_pid)
ORDER BY country_id,country_pid;

DROP TABLE IF EXISTS gisco_admin_2020_single_poly1;CREATE TEMPORARY TABLE gisco_admin_2020_single_poly1 AS
SELECT country_id,country_pid,(ST_DUMP(geom)).* FROM gisco_2020.gisco_admin_2020 ORDER BY country_id,country_pid;
DROP TABLE IF EXISTS gisco_admin_2020_single_poly2;CREATE TEMPORARY TABLE gisco_admin_2020_single_poly2 AS
SELECT * FROM gisco_admin_2020_single_poly1 JOIN gisco_2020.gisco_admin_2020_atts USING(country_id,country_pid) ORDER BY country_id,country_pid;
DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020_single_poly;CREATE TABLE gisco_2020.gisco_admin_2020_single_poly AS
SELECT * FROM gisco_admin_2020_single_poly2;

ALTER TABLE gisco_2020.gisco_admin_2020_single_poly ADD COLUMN psqkm double precision;
UPDATE gisco_2020.gisco_admin_2020_single_poly SET psqkm = (ST_AREA(geom::geography))/1000000;

DROP TABLE IF EXISTS gisco_2020.gisco_admin_2020_tiled;CREATE TABLE gisco_2020.gisco_admin_2020_tiled AS
SELECT a.qid,b.*,a.geom,a.sqkm rpsqkm FROM gisco_2020.gisco_flat3a a JOIN administrative_units.gisco_admin_2020_atts b ON a.pid=b.country_pid ORDER BY qid,country_pid;

------------------------------------------------------
-----------------------------------------------------

DROP TABLE IF EXISTS administrative_units.gisco_admin_2020;CREATE TABLE administrative_units.gisco_admin_2020 AS
SELECT * FROM gisco_2020.gisco_admin_2020 ORDER BY country_id,country_pid;
ALTER TABLE administrative_units.gisco_admin_2020 ADD PRIMARY KEY (country_pid);
CREATE INDEX ON administrative_units.gisco_admin_2020 USING GIST(geom);

DROP TABLE IF EXISTS administrative_units.gisco_admin_2020_atts;CREATE TABLE administrative_units.gisco_admin_2020_atts AS
SELECT * FROM gisco_2020.gisco_admin_2020_atts ORDER BY country_id,country_pid;
ALTER TABLE administrative_units.gisco_admin_2020_atts ADD PRIMARY KEY (country_pid);

DROP TABLE IF EXISTS administrative_units.gisco_admin_2020_single_poly;CREATE TABLE administrative_units.gisco_admin_2020_single_poly AS
SELECT * FROM gisco_2020.gisco_admin_2020_single_poly ORDER BY country_id,country_pid,path;
CREATE INDEX ON administrative_units.gisco_admin_2020_single_poly USING GIST(geom);

DROP TABLE IF EXISTS administrative_units.gisco_admin_2020_tiled;CREATE TABLE administrative_units.gisco_admin_2020_tiled AS
SELECT * FROM gisco_2020.gisco_admin_2020_tiled ORDER BY qid,country_id,country_pid;
CREATE INDEX ON administrative_units.gisco_admin_2020_tiled USING GIST(geom);
