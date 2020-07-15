CREATE VIEW species_202001.v_lt_species_202001.conservation_needed AS
 SELECT DISTINCT (conservation_needed.internaltaxonid)::bigint AS internaltaxonid,
    (conservation_needed.code)::text AS code
   FROM species_202001.conservation_needed
  ORDER BY (conservation_needed.internaltaxonid)::bigint, (conservation_needed.code)::text;


CREATE VIEW species_202001.v_lt_species_202001.countries AS
 SELECT DISTINCT (countries.internaltaxonid)::bigint AS internaltaxonid,
    countries.code
   FROM species_202001.countries
  ORDER BY (countries.internaltaxonid)::bigint, countries.code;

CREATE VIEW species_202001.v_lt_species_202001.habitats AS
 SELECT DISTINCT (habitats.internaltaxonid)::bigint AS internaltaxonid,
    (habitats.code)::text AS code
   FROM species_202001.habitats
  ORDER BY (habitats.internaltaxonid)::bigint, (habitats.code)::text;

CREATE VIEW species_202001.v_lt_species_202001.research_needed AS
 SELECT DISTINCT (research_needed.internaltaxonid)::bigint AS internaltaxonid,
    (research_needed.code)::text AS code
   FROM species_202001.research_needed
  ORDER BY (research_needed.internaltaxonid)::bigint, (research_needed.code)::text;

CREATE VIEW species_202001.v_lt_species_202001.stresses AS
 SELECT DISTINCT (threats.internaltaxonid)::bigint AS internaltaxonid,
    unnest(string_to_array((threats.stresscode)::text, '|'::text)) AS code
   FROM species_202001.threats
  ORDER BY (threats.internaltaxonid)::bigint, (unnest(string_to_array((threats.stresscode)::text, '|'::text)));

CREATE VIEW species_202001.v_lt_species_202001.threats AS
 SELECT DISTINCT (threats.internaltaxonid)::bigint AS internaltaxonid,
    (threats.code)::text AS code
   FROM species_202001.threats
  ORDER BY (threats.internaltaxonid)::bigint, (threats.code)::text;

CREATE VIEW species_202001.v_lt_species_202001.usetrade AS
 SELECT DISTINCT (usetrade.internaltaxonid)::bigint AS internaltaxonid,
    (usetrade.code)::text AS code
   FROM species_202001.usetrade
  ORDER BY (usetrade.internaltaxonid)::bigint, (usetrade.code)::text;








