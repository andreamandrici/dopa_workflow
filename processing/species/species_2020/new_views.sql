CREATE VIEW species.v_mt_categories AS
 SELECT
        CASE a.redlistcategory
            WHEN 'Extinct'::text THEN 'EX'::text
            WHEN 'Extinct in the Wild'::text THEN 'EW'::text
            WHEN 'Critically Endangered'::text THEN 'CR'::text
            WHEN 'Endangered'::text THEN 'EN'::text
            WHEN 'Vulnerable'::text THEN 'VU'::text
            WHEN 'Extinct in the Wild'::text THEN 'EW'::text
            WHEN 'Near Threatened'::text THEN 'NT'::text
            WHEN 'Least Concern'::text THEN 'LC'::text
            WHEN 'Data Deficient'::text THEN 'DD'::text
            WHEN 'Lower Risk/conservation dependent'::text THEN 'LR/cd'::text
            WHEN 'Lower Risk/near threatened'::text THEN 'LR/nt'::text
            WHEN 'Lower Risk/near threatened'::text THEN 'LR/nt'::text
            WHEN 'Regionally Extinct'::text THEN 'rEX'::text
            WHEN 'Not Applicable'::text THEN 'NA'::text
            ELSE NULL::text
        END AS code,
    a.redlistcategory
   FROM ( SELECT DISTINCT additional_tables_assessments.redlistcategory
           FROM species.additional_tables_assessments) a;

CREATE VIEW species.v_lt_species_categories AS
 WITH a AS (
         SELECT DISTINCT additional_tables_assessments.internaltaxonid,
            additional_tables_assessments.redlistcategory
           FROM species.additional_tables_assessments
        )
 SELECT (a.internaltaxonid)::bigint AS internaltaxonid,
    v_mt_categories.code
   FROM (a
     JOIN species.v_mt_categories USING (redlistcategory))
  ORDER BY (a.internaltaxonid)::bigint, v_mt_categories.code;

CREATE VIEW species.v_lt_species_conservation_needed AS
 SELECT DISTINCT (additional_tables_conservation_needed.internaltaxonid)::bigint AS internaltaxonid,
    (additional_tables_conservation_needed.code)::text AS code
   FROM species.additional_tables_conservation_needed
  ORDER BY (additional_tables_conservation_needed.internaltaxonid)::bigint, (additional_tables_conservation_needed.code)::text;


CREATE VIEW species.v_lt_species_countries AS
 SELECT DISTINCT (additional_tables_countries.internaltaxonid)::bigint AS internaltaxonid,
    additional_tables_countries.code
   FROM species.additional_tables_countries
  ORDER BY (additional_tables_countries.internaltaxonid)::bigint, additional_tables_countries.code;

CREATE VIEW species.v_lt_species_habitats AS
 SELECT DISTINCT (additional_tables_habitats.internaltaxonid)::bigint AS internaltaxonid,
    (additional_tables_habitats.code)::text AS code
   FROM species.additional_tables_habitats
  ORDER BY (additional_tables_habitats.internaltaxonid)::bigint, (additional_tables_habitats.code)::text;

CREATE VIEW species.v_lt_species_research_needed AS
 SELECT DISTINCT (additional_tables_research_needed.internaltaxonid)::bigint AS internaltaxonid,
    (additional_tables_research_needed.code)::text AS code
   FROM species.additional_tables_research_needed
  ORDER BY (additional_tables_research_needed.internaltaxonid)::bigint, (additional_tables_research_needed.code)::text;

CREATE VIEW species.v_lt_species_stresses AS
 SELECT DISTINCT (additional_tables_threats.internaltaxonid)::bigint AS internaltaxonid,
    unnest(string_to_array((additional_tables_threats.stresscode)::text, '|'::text)) AS code
   FROM species.additional_tables_threats
  ORDER BY (additional_tables_threats.internaltaxonid)::bigint, (unnest(string_to_array((additional_tables_threats.stresscode)::text, '|'::text)));

CREATE VIEW species.v_lt_species_threats AS
 SELECT DISTINCT (additional_tables_threats.internaltaxonid)::bigint AS internaltaxonid,
    (additional_tables_threats.code)::text AS code
   FROM species.additional_tables_threats
  ORDER BY (additional_tables_threats.internaltaxonid)::bigint, (additional_tables_threats.code)::text;

CREATE VIEW species.v_lt_species_usetrade AS
 SELECT DISTINCT (additional_tables_usetrade.internaltaxonid)::bigint AS internaltaxonid,
    (additional_tables_usetrade.code)::text AS code
   FROM species.additional_tables_usetrade
  ORDER BY (additional_tables_usetrade.internaltaxonid)::bigint, (additional_tables_usetrade.code)::text;

CREATE VIEW species.v_mt_conservation_needed AS
 WITH a AS (
         SELECT DISTINCT additional_tables_conservation_needed.code,
            additional_tables_conservation_needed.name
           FROM species.additional_tables_conservation_needed
          ORDER BY additional_tables_conservation_needed.code
        ), b AS (
         SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS conservation_needed_cl1,
            (split_part((a.code)::text, '.'::text, 2))::integer AS conservation_needed_cl2,
                CASE
                    WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
                    ELSE 0
                END AS conservation_needed_cl3,
            a.code,
            a.name
           FROM a
        ), conservation_needed AS (
         SELECT b.conservation_needed_cl1,
            b.conservation_needed_cl2,
            b.conservation_needed_cl3,
            b.code,
            b.name
           FROM b
          ORDER BY b.conservation_needed_cl1, b.conservation_needed_cl2, b.conservation_needed_cl3
        )
 SELECT conservation_needed.conservation_needed_cl1,
    conservation_needed.conservation_needed_cl2,
    conservation_needed.conservation_needed_cl3,
    conservation_needed.code,
    conservation_needed.name
   FROM conservation_needed;

CREATE VIEW species.v_mt_countries AS
 WITH a AS (
         SELECT DISTINCT additional_tables_countries.code,
            additional_tables_countries.name
           FROM species.additional_tables_countries
          ORDER BY additional_tables_countries.code
        ), countries AS (
         SELECT a.code,
            a.name
           FROM a
        )
 SELECT countries.code,
    countries.name
   FROM countries;

CREATE VIEW species.v_mt_habitats AS
 WITH a AS (
         SELECT DISTINCT additional_tables_habitats.code,
            additional_tables_habitats.name
           FROM species.additional_tables_habitats
          ORDER BY additional_tables_habitats.code
        ), b AS (
         SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS habitats_cl1,
                CASE
                    WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
                    ELSE 0
                END AS habitats_cl2,
                CASE
                    WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
                    ELSE 0
                END AS habitats_cl3,
            a.code,
            a.name
           FROM a
        ), habitats AS (
         SELECT b.habitats_cl1,
            b.habitats_cl2,
            b.habitats_cl3,
            b.code,
            b.name
           FROM b
          ORDER BY b.habitats_cl1, b.habitats_cl2, b.habitats_cl3
        )
 SELECT habitats.habitats_cl1,
    habitats.habitats_cl2,
    habitats.habitats_cl3,
    habitats.code,
    habitats.name
   FROM habitats;

CREATE VIEW species.v_mt_research_needed AS
 WITH a AS (
         SELECT DISTINCT additional_tables_research_needed.code,
            additional_tables_research_needed.name
           FROM species.additional_tables_research_needed
          ORDER BY additional_tables_research_needed.code
        ), b AS (
         SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS research_needed_cl1,
                CASE
                    WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
                    ELSE 0
                END AS research_needed_cl2,
                CASE
                    WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
                    ELSE 0
                END AS research_needed_cl3,
            a.code,
            a.name
           FROM a
        ), research_needed AS (
         SELECT b.research_needed_cl1,
            b.research_needed_cl2,
            b.research_needed_cl3,
            b.code,
            b.name
           FROM b
          ORDER BY b.research_needed_cl1, b.research_needed_cl2, b.research_needed_cl3
        )
 SELECT research_needed.research_needed_cl1,
    research_needed.research_needed_cl2,
    research_needed.research_needed_cl3,
    research_needed.code,
    research_needed.name
   FROM research_needed;

CREATE VIEW species.v_mt_stresses AS
 WITH a AS (
         SELECT DISTINCT additional_tables_threats.stresscode,
            additional_tables_threats.stressname
           FROM species.additional_tables_threats
        ), b AS (
         SELECT string_to_array((a.stresscode)::text, '|'::text) AS stresscode,
            string_to_array((a.stressname)::text, '|'::text) AS stressname
           FROM a
        ), c AS (
         SELECT DISTINCT u.code,
            u.name
           FROM b,
            LATERAL UNNEST(b.stresscode, b.stressname) WITH ORDINALITY u(code, name, ordinality)
          ORDER BY u.code
        ), d AS (
         SELECT (split_part(c.code, '.'::text, 1))::integer AS stress_cl1,
                CASE
                    WHEN (c.code ~~ '%.%'::text) THEN (split_part(c.code, '.'::text, 2))::integer
                    ELSE 0
                END AS stress_cl2,
                CASE
                    WHEN (c.code ~~ '%.%.%'::text) THEN (split_part(c.code, '.'::text, 3))::integer
                    ELSE 0
                END AS stress_cl3,
            c.code,
            c.name
           FROM c
        ), stress AS (
         SELECT d.stress_cl1,
            d.stress_cl2,
            d.stress_cl3,
            d.code,
            d.name
           FROM d
          ORDER BY d.stress_cl1, d.stress_cl2, d.stress_cl3
        )
 SELECT stress.stress_cl1,
    stress.stress_cl2,
    stress.stress_cl3,
    stress.code,
    stress.name
   FROM stress;

CREATE VIEW species.v_mt_taxonomy AS
 WITH a AS (
         SELECT (additional_tables_taxonomy.phylumname)::text AS phylumname,
            (additional_tables_taxonomy.ordername)::text AS ordername,
            (additional_tables_taxonomy.classname)::text AS classname,
            (additional_tables_taxonomy.familyname)::text AS familyname,
            (additional_tables_taxonomy.genusname)::text AS genusname,
            (additional_tables_taxonomy.speciesname)::text AS speciesname,
            (additional_tables_taxonomy.scientificname)::text AS scientificname,
            (additional_tables_taxonomy.internaltaxonid)::bigint AS internaltaxonid,
            (additional_tables_taxonomy.taxonomicnotes)::text AS taxonomicnotes
           FROM species.additional_tables_taxonomy
        )
 SELECT a.phylumname,
    a.ordername,
    a.classname,
    a.familyname,
    a.genusname,
    a.speciesname,
    a.scientificname,
    a.internaltaxonid,
    a.taxonomicnotes
   FROM a
  ORDER BY a.internaltaxonid;

CREATE VIEW species.v_mt_threats AS
 WITH a AS (
         SELECT DISTINCT additional_tables_threats.code,
            additional_tables_threats.name
           FROM species.additional_tables_threats
          ORDER BY additional_tables_threats.code
        ), b AS (
         SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS threats_cl1,
                CASE
                    WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
                    ELSE 0
                END AS threats_cl2,
                CASE
                    WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
                    ELSE 0
                END AS threats_cl3,
            a.code,
            a.name
           FROM a
        ), threats AS (
         SELECT b.threats_cl1,
            b.threats_cl2,
            b.threats_cl3,
            b.code,
            b.name
           FROM b
          ORDER BY b.threats_cl1, b.threats_cl2, b.threats_cl3
        )
 SELECT threats.threats_cl1,
    threats.threats_cl2,
    threats.threats_cl3,
    threats.code,
    threats.name
   FROM threats;

CREATE VIEW species.v_mt_usetrade AS
 SELECT DISTINCT (additional_tables_usetrade.code)::integer AS code,
    (additional_tables_usetrade.name)::text AS name
   FROM species.additional_tables_usetrade
  ORDER BY (additional_tables_usetrade.code)::integer;

