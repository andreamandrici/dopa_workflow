-- DROP TABLE results.dopa_indicators;
CREATE TABLE results.dopa_indicators
(
    stid integer,
    schema_name text,
    function_name text,
    parameter_name text,
    parameter_description text,
    reporting_level text,
    source text,
    rest boolean,
    xls_template boolean,
    progress_code integer,
    xls_column_name_lv_1 character varying,
    xls_column_name_lv_2 character varying
);
-- DROP TABLE results.themes;
CREATE TABLE results.themes
(
    tid numeric,
    theme text,
    theme_description text,
    stid integer NOT NULL,
    subtheme text,
    subtheme_description text,
    CONSTRAINT themes_pkey PRIMARY KEY (stid)
);
--DROP TABLE results.reporting_level_codes;
CREATE TABLE results.reporting_level_codes
(
    reporting_level text,
    reporting_level_description text
);
--DROP TABLE results.progress_codes;
CREATE TABLE results.progress_codes
(
    progress_code integer,
    progress_code_description text
);