-- CREATES FINAL OUTPUT TABLE ------------------------------------------------
DROP TABLE IF EXISTS species.mt_species_output CASCADE;
CREATE TABLE species.mt_species_output AS
SELECT
a.id_no,
a.class,
a.order_,
a.family,
a.genus,
a.binomial,
a.category,
c.threatened,
h.ecosystems,
e.habitats,
b.country,
b.n_country,
b.endemic,
j.stresses,
d.threats,
g.research_needed,
f.conservation_needed,
i.usetrade
FROM species.mt_attributes a
LEFT JOIN species.dt_species_country_endemics b USING(id_no)
LEFT JOIN species.dt_species_threatened c USING(id_no)
LEFT JOIN species.dt_species_threats d USING(id_no)
LEFT JOIN species.dt_species_habitats e USING(id_no)
LEFT JOIN species.dt_species_conservation_needed f USING(id_no)
LEFT JOIN species.dt_species_research_needed g USING(id_no)
JOIN species.dt_species_ecosystems h USING(id_no)
LEFT JOIN species.dt_species_usetrade i USING(id_no)
LEFT JOIN species.dt_species_stresses j USING(id_no)
ORDER BY a.id_no;

-- CREATES FINAL FUNCTIONS ---------------------------------------------
-------FN_GET_LIST_SPECIES_OUTPUT--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_species_output()
RETURNS SETOF species.mt_species_output
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE '
SELECT * FROM species.mt_species_output
WHERE id_no IS NOT NULL
-- AND id_no=18
-- AND class ILIKE ''mammalia''
-- AND order_ ILIKE ''carnivora''
-- AND family ILIKE ''FELIDAE''
-- AND genus ILIKE ''felis''
-- AND binomial ILIKE ''Abrocoma%''
-- AND category IN (''VU'')
-- AND threatened IS TRUE
-- AND ARRAY[''marine''] && ecosystems
-- AND ARRAY[''IT''] && country
-- AND endemic IS TRUE
-- AND ARRAY[''1.2.0''] && stresses
-- AND ARRAY[''2.4.3''] && threats
-- AND ARRAY[''2.1''] && conservation_needed
-- AND ARRAY[''2.1''] && research_needed
-- AND ARRAY[1,5] && usetrade
ORDER BY id_no;
';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_species_output() IS 'Shows all species direct and relate attributes';

-------FN_GET_LIST_CATEGORIES--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_categories()
RETURNS SETOF species.mt_categories
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_categories;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_categories() IS 'Shows list of EXISTING categories';


-------FN_GET_LIST_CONSERVATION_NEEDED--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_conservation_needed()
RETURNS SETOF species.mt_conservation_needed
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_conservation_needed;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_conservation_needed() IS 'Shows list of EXISTING conservation needed';

-------FN_GET_LIST_COUNTRIES --------------------------------
CREATE OR REPLACE FUNCTION species.get_list_countries()
RETURNS SETOF species.mt_countries
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_countries;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_countries() IS 'Shows list of EXISTING countries';

-------FN_GET_LIST_HABITATS --------------------------------
CREATE OR REPLACE FUNCTION species.get_list_habitats()
RETURNS SETOF species.mt_habitats
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_habitats;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_habitats() IS 'Shows list of EXISTING habitats;';

-------FN_GET_LIST_RESEARCH_NEEDED--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_research_needed()
RETURNS SETOF species.mt_research_needed
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_research_needed;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_research_needed() IS 'Shows list of EXISTING research needed';


-------FN_GET_LIST_STRESSES--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_stresses()
RETURNS SETOF species.mt_stresses
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_stresses;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_stresses() IS 'Shows list of EXISTING stresses';

-------FN_GET_LIST_THREATS--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_threats()
RETURNS SETOF species.mt_threats
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_threats;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_threats() IS 'Shows list of EXISTING threats';

-------FN_GET_LIST_USETRADE--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_usetrade()
RETURNS SETOF species.mt_usetrade
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_usetrade;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_usetrade() IS 'Shows list of EXISTING uses and trades';


--------- GRANTS FOR DOPA REST -------------------------------------------------------------
GRANT USAGE ON SCHEMA species TO h05ibexro;
GRANT SELECT ON ALL TABLES IN SCHEMA species TO h05ibexro;

