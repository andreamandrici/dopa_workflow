DROP FUNCTION IF EXISTS species.get_list_species_output(bigint,text,text,text,text,text,text,bool,text,text,text,bool,text,text,text,text,text);
CREATE OR REPLACE FUNCTION species.get_list_species_output(
a_id_no bigint DEFAULT NULL::bigint,
b_class text DEFAULT NULL::text,
c_order text DEFAULT NULL::text,
d_family text DEFAULT NULL::text,
e_genus text DEFAULT NULL::text,
f_binomial text DEFAULT NULL::text,
g_category text DEFAULT NULL::text,
h_threatened bool DEFAULT NULL::bool,
i_ecosystems text DEFAULT NULL::text,
j_habitats text DEFAULT NULL::text,
k_country text DEFAULT NULL::text,
l_endemic bool DEFAULT NULL::bool,
m_stresses text DEFAULT NULL::text,
n_threats text DEFAULT NULL::text,
o_research_needed text DEFAULT NULL::text,
p_conservation_needed text DEFAULT NULL::text,
q_usetrade text DEFAULT NULL::text
)
RETURNS SETOF species.mt_species_output
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
mg_category text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(g_category, ',') AS a) tb);
mi_ecosystems text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(LOWER(i_ecosystems), ',') AS a) tb);
mj_habitats text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(j_habitats, ',') AS a) tb);
mk_country text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(UPPER(k_country), ',') AS a) tb);
mm_stresses text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(m_stresses, ',') AS a) tb);
mn_threats text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(n_threats, ',') AS a) tb);
mo_research_needed text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(o_research_needed, ',') AS a) tb);
mp_conservation_needed text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(p_conservation_needed, ',') AS a) tb);
mq_usetrade text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(a),',') FROM (SELECT a FROM regexp_split_to_table(q_usetrade, ',') AS a) tb);

sql TEXT;
BEGIN

sql :='
SELECT * FROM species.mt_species_output
WHERE id_no IS NOT NULL';
IF a_id_no IS NOT NULL THEN sql := sql || ' AND id_no = $1 '; END IF;
IF b_class IS NOT NULL THEN sql := sql || ' AND class ILIKE '''||b_class||'%'' '; END IF;
IF c_order IS NOT NULL THEN sql := sql || ' AND order_ ILIKE '''||c_order||'%'' '; END IF;
IF d_family IS NOT NULL THEN sql := sql || ' AND family ILIKE '''||d_family||'%'' '; END IF;
IF e_genus IS NOT NULL THEN sql := sql || ' AND genus ILIKE '''||d_family||'%'' '; END IF;
IF f_binomial IS NOT NULL THEN sql := sql || ' AND binomial ILIKE '''||e_genus||'%''  '; END IF;
IF g_category IS NOT NULL THEN sql := sql || ' AND category IN ('||mg_category||') '; END IF;
IF h_threatened IS NOT NULL THEN sql := sql || ' AND threatened IS '||h_threatened||' '; END IF;
IF i_ecosystems IS NOT NULL THEN sql := sql || ' AND ARRAY['||mi_ecosystems||'] && ecosystems  '; END IF;
IF j_habitats IS NOT NULL THEN sql := sql || ' AND ARRAY['||mj_habitats||'] && habitats  '; END IF;
IF k_country IS NOT NULL THEN sql := sql || ' AND ARRAY['||mk_country||'] && country  '; END IF;
IF l_endemic IS NOT NULL THEN sql := sql || ' AND endemic IS '||l_endemic||' '; END IF;
IF m_stresses IS NOT NULL THEN sql := sql || ' AND ARRAY['||mm_stresses||'] && stresses  '; END IF;
IF n_threats IS NOT NULL THEN sql := sql || ' AND ARRAY['||mn_threats||'] && threats  '; END IF;
IF o_research_needed IS NOT NULL THEN sql := sql || ' AND ARRAY['||mo_research_needed||'] && research_needed  '; END IF;
IF p_conservation_needed IS NOT NULL THEN sql := sql || ' AND ARRAY['||mp_conservation_needed||'] && conservation_needed  '; END IF;
IF q_usetrade IS NOT NULL THEN sql := sql || ' AND ARRAY['||mq_usetrade||']::integer[] && usetrade  '; END IF;


sql := sql || ' ORDER BY id_no;';
RETURN QUERY EXECUTE sql;
END;
$BODY$;
-- --COMMENT ON FUNCTION species.get_list_species_output(bigint) IS 'Shows all species direct and relate attributes';
SELECT * FROM species.get_list_species_output(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'12,14');



