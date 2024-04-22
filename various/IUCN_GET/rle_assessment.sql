DROP TABLE IF EXISTS rle_assessment_point;CREATE TEMPORARY TABLE rle_assessment_point AS
SELECT id,ST_SETSRID(ST_Point(pin_longitude,pin_latitude),4326) point
FROM iucn_get_last.rle_assessment_20240419;

DROP TABLE IF EXISTS rle_assessment_poly;CREATE TEMPORARY TABLE rle_assessment_poly AS
WITH a AS (SELECT id,
"envelope_ll-x"::double precision ll_x,"envelope_ll-y"::double precision ll_y,
"envelope_ur-x"::double precision ur_x,"envelope_ur-y"::double precision ur_y
FROM iucn_get_last.rle_assessment_20240419 WHERE "envelope_ll-x" NOT IN (' ','None'))
SELECT id,ST_SETSRID(ST_ENVELOPE(ST_MakeLine(ST_Point(ll_y,ll_x),ST_Point(ur_y,ur_x))),4326) geom
FROM a;

DROP TABLE IF EXISTS rle_assessment_atts;CREATE TEMPORARY TABLE rle_assessment_atts AS
SELECT 
id,
assessment_type::text,
assessment_name::text,
ecosystem_name::text,
"get_level 1"::text get_level_1,
"get_level 2"::text get_level_2,
"get_level 3"::text get_level_3,
SPLIT_PART("get_level 3"::text,' ',1) c3,
overall_risk::text,
supp_subcriteria::text,
assessment_year::text,
risk_protocol,
protocol_version,
authors::text,
citation::text,
url::text
FROM iucn_get_last.rle_assessment_20240419;

DROP TABLE IF EXISTS iucn_get_last.rle_assessment;CREATE TABLE iucn_get_last.rle_assessment AS
SELECT * FROM rle_assessment_atts LEFT JOIN rle_assessment_point USING(id) LEFT JOIN rle_assessment_poly USING(id)
ORDER BY id;
ALTER TABLE iucn_get_last.rle_assessment ADD PRIMARY KEY(id);
CREATE INDEX ON iucn_get_last.rle_assessment USING GIST(geom);
