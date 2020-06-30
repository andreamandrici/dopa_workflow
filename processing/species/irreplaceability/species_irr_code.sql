-- TODO - add template for this and for the script that calls it to 00_create_infrastructure.sh

-- I gridded the species using the CEP approach with just one TOPIC, as follows:
-- TOPIC_1="mammals"
-- VERSION_TOPIC_1="test_data.mammals_select_italy"
-- FID_TOPIC_1="id_no"
-- The species selected are: 12848,14124,17314,21311,23062,29656,3746,41479,41688,44856,60354712,70207409,81633057,90389138

-- DEFINITION of the table produced (in script): unique_id text, qid integer, id_no integer, pa integer, area_km2 double precision

-- flat cep table has 757 rows
-- species table (14 mammal species) has 7 rows
-- From the species intersection, we get 528 geometries, each with a list of species, and a list of pas (or no protection)

-- 23 seconds to intersect 3 tiles for 14 species

--13985 ms to also unnest 14 mammals for tile 48074 (370 rows), - ( 12028 ms (less time!) to also unnest pas -> 652 rows )
-- for 3 tiles (5074 rows) 30458 ms

-- call this function with the attached script a_sii_intersect_species.sh, which sources workflow_spirr_parameters.conf

----------------------------------------------------------------------------------------------

-- DROP FUNCTION species_irreplaceability.f_intersect_species_pa(integer);
CREATE OR REPLACE FUNCTION species_irreplaceability.f_intersect_species_pa(iqid integer)
  RETURNS void AS
$BODY$
BEGIN
INSERT INTO species_irreplaceability.species_cep_intersection
(qid, mammals, unique_id, wdpa, country, ecoregion, area_km2)
WITH species AS (SELECT * FROM species_cep_data.h_flat 
WHERE qid = iqid 
),cep AS (
SELECT * FROM cep202003.h_flat 
WHERE qid = iqid 
),combine_layers AS (
SELECT s.qid, mammals, 
-- we need a new geometry id in order to compress down total range area later. for now, let's combine cep and species ID
c.cid::text || '_' || s.qid::text || '_' || s.cid::text AS unique_id,
wdpa,
c.country[1]::integer AS country, c.ecoregion[1]::integer AS ecoregion, 
ST_AREA(ST_TRANSFORM(ST_INTERSECTION(c.geom, s.geom), 54009))/1000000 AS area_km2 
FROM species s, cep c WHERE ST_INTERSECTS(c.geom, s.geom) 
)  --12411 ms to get the nested values and areas for tile 48074 (76 rows)
SELECT * FROM combine_layers;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION species_irreplaceability.f_intersect_species_pa(integer)
  OWNER TO postgres;
COMMENT ON FUNCTION species_irreplaceability.f_intersect_species_pa(integer) IS 'intersects species and cep and inserts results into a new table;input parameter is:
iqid - integer - numeric value from tiled table as selector for the row - number;
eg: SELECT current_schema_name.f_intersect_species_pa(48074) will:
read from cep_schema_name.h_flat and species_schema_name.h_flat tables, selecting rows where qid=48074 - write to species_schema_name.species_cep_intersection table';



------------------------- post-processing of the tiled results table to get range values and irreplaceability --------------------------------------------
-- This step should not need tiling, it is not so computationally heavy and involves just summing, unnesting and grouping.
-- There is some potential for scripting by topic if it is to be reused (e.g. for marine habitats)
------------ summarise ecoregions - could swap in topic name if you want to re-use the same function for countries (see below)

DROP TABLE IF EXISTS species_irreplaceability.output_species_protection_by_ecoregion;
CREATE TABLE species_irreplaceability.output_species_protection_by_ecoregion AS
WITH get_species_areas AS (
SELECT unique_id, qid, 
CASE WHEN wdpa[1] = 0 THEN 0 ELSE 1 END AS protected, 
country, ecoregion, UNNEST(mammals) AS id_no, area_km2 FROM species_irreplaceability.species_cep_intersection
), get_up_species_areas AS (
SELECT protected, ecoregion, id_no, SUM(area_km2) AS area_km2 FROM get_species_areas GROUP BY ecoregion, id_no, protected
)
, get_ecoregion_areas AS (
SELECT id_no, 
CASE WHEN protected = 1 THEN SUM(area_km2) ELSE 0 END AS protected_area_km2, 
CASE WHEN protected = 0 THEN SUM(area_km2) ELSE 0 END AS unprotected_area_km2, 
-- I KNOW there is a way to compress this query and the next into just one stage, I have it in redmine somewhere :-)
ecoregion FROM get_up_species_areas GROUP BY ecoregion, id_no, protected
), get_ecoregion_summary AS (
SELECT id_no, ecoregion, SUM(protected_area_km2) AS protected_area_km2, SUM(unprotected_area_km2) AS unprotected_area_km2 
FROM get_ecoregion_areas GROUP BY id_no, ecoregion
)
SELECT * FROM get_ecoregion_summary ORDER BY id_no, ecoregion;

--------------------- summarise countries: could re-use function above --------------
DROP TABLE IF EXISTS species_irreplaceability.output_species_protection_by_country;
CREATE TABLE species_irreplaceability.output_species_protection_by_country AS
WITH get_species_areas AS (
SELECT unique_id, qid, 
CASE WHEN wdpa[1] = 0 THEN 0 ELSE 1 END AS protected, 
country, ecoregion, UNNEST(mammals) AS id_no, area_km2 FROM species_irreplaceability.species_cep_intersection
), get_up_species_areas AS (
SELECT protected, country, id_no, SUM(area_km2) AS area_km2 FROM get_species_areas GROUP BY country, id_no, protected
)
, get_country_areas AS (
SELECT id_no, 
CASE WHEN protected = 1 THEN SUM(area_km2) ELSE 0 END AS protected_area_km2, 
CASE WHEN protected = 0 THEN SUM(area_km2) ELSE 0 END AS unprotected_area_km2, 
-- I KNOW there is a way to compress this query and the next into just one stage, I have it in redmine somewhere :-)
country FROM get_up_species_areas GROUP BY country, id_no, protected
), get_country_summary AS (
SELECT id_no, country, SUM(protected_area_km2) AS protected_area_km2, SUM(unprotected_area_km2) AS unprotected_area_km2 
FROM get_country_areas GROUP BY id_no, country
)
SELECT * FROM get_country_summary ORDER BY id_no, country;

----- summarise globally: either of the above tables can be used.
DROP TABLE IF EXISTS species_irreplaceability.output_species_protection_globally;
CREATE TABLE species_irreplaceability.output_species_protection_globally AS
SELECT id_no, SUM(protected_area_km2) AS protected_area_km2, SUM(unprotected_area_km2) AS unprotected_area_km2,
SUM(protected_area_km2) + SUM(unprotected_area_km2) AS total_range_area_km2  
FROM species_irreplaceability.output_species_protection_by_country GROUP BY id_no;

-------------- Create the completely unnested table that will be used for PA-level irreplaceability ----------------------

DROP TABLE IF EXISTS species_irreplaceability.species_pa_intersection;
CREATE TABLE species_irreplaceability.species_pa_intersection AS SELECT 
unique_id, UNNEST(wdpa) AS pa, UNNEST(mammals) AS id_no, area_km2 
FROM species_irreplaceability.species_cep_intersection;


-- CHECKING SCRIPT BEFORE THE FINAL STEP   first check the reliability of the outputs ---------------------------
--CREATE TABLE species_irreplaceability.check_species_range_areas AS
WITH calculate_unprotected_species_range_area AS
(SELECT id_no, SUM(area_km2) as u_area FROM species_irreplaceability.species_pa_intersection 
WHERE pa=0
GROUP BY id_no) -- or could do this from the h_flat table - worth checking
,calculate_protected_species_range_area AS
(SELECT COUNT(unique_id) as dupes, id_no, SUM(area_km2) as p_area FROM 
(SELECT unique_id, id_no, MIN(area_km2) AS area_km2 FROM species_irreplaceability.species_pa_intersection WHERE pa!=0 GROUP BY id_no, unique_id) a
GROUP BY id_no) -- or could do this from the h_flat table - worth checking
,calculate_all_range_areas AS
(SELECT a.id_no, a.unprotected_area_km2-u.u_area as u_diff, a.protected_area_km2-p.p_area as p_diff, a.total_range_area_km2-(u.u_area + p.p_area) AS total_diff
FROM species_irreplaceability.output_species_protection_globally a 
LEFT JOIN calculate_protected_species_range_area p ON a.id_no = p.id_no 
LEFT JOIN calculate_unprotected_species_range_area u ON a.id_no = u.id_no)
SELECT * FROM calculate_all_range_areas;

-- 942 ms for these postprocessing steps on 3 tiles with 14 species

------------- FINAL STEP -------------------------------------------------------------------------------------

----- IF these areas are all in acceptable range of each other, then it is ok to go ahead  -----------------------------------

DROP TABLE IF EXISTS species_irreplaceability.output_pa_species_protection;
CREATE TABLE species_irreplaceability.output_pa_species_protection AS
WITH get_summary_areas AS (
SELECT id_no, pa, SUM(area_km2) as pa_protects_species_km2 FROM species_irreplaceability.species_pa_intersection WHERE pa != 0 GROUP BY id_no,pa
-- this is the point at which one might filter out very tiny areas or proportions which could be considered to be geometric accidents
), get_area_proportions AS ( 
select a.id_no, a.pa, (a.pa_protects_species_km2/b.total_range_area_km2)*100.0 as percent_range_proportion_protected,
(a.pa_protects_species_km2/b.protected_area_km2)*100.0 AS percent_protection_this_pa 
FROM get_summary_areas a, species_irreplaceability.output_species_protection_globally b WHERE a.id_no = b.id_no
)
SELECT id_no, pa, percent_protection_this_pa, 
percent_range_proportion_protected,
-- irreplaceability weighted value from Le Saout et al 2013
1/(1+(exp(-((least(100,percent_range_proportion_protected)-39)/9.5)))) AS irr_value FROM get_area_proportions;

-------------------------- DATA CHECK ------------------------------------------------------------------
--- sanity check on this data - because we have a closed system, some values should fall within particular limits
--Percentage protection should not be below 100 (it can be more because of overlapping PAs)
SELECT id_no, SUM(percent_protection_this_pa) as overall_protection, COUNT(*) AS num_pas  
FROM species_irreplaceability.output_pa_species_protection GROUP BY id_no;
-----------------------------------------------------------------------------------------------------

-- The irreplaceability values can now be summed by taxon, ranked etc as in previous DOPA analyses  -------------------

