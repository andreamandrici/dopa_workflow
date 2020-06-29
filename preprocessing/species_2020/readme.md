# Species 2020

## IUCN spatial tables

Spatial data for **corals, chondrichthyes, amphibians, mammals** are available as foreign tables pointing at shps files in schema **species_iucn_spatial_202001**, and they all contain the fields (relevants in **bold**):

+  fid bigint,
+  **geom geometry(Polygon,4326)**,
+  **id_no** bigint,
+  **binomial** character varying,
+  **presence** integer,
+  **origin** integer,
+  **seasonal** integer,
+  compiler character varying,
+  yrcompiled integer,
+  citation character varying,
+  source character varying,
+  dist_comm character varying,
+  island character varying,
+  subspecies character varying,
+  subpop character varying,
+  legend character varying,
+  tax_comm character varying,
+  **kingdom** character varying,
+  **phylum** character varying,
+  **class** character varying,
+  **order_** character varying,
+  **family** character varying,
+  **genus** character varying,
+  **category** character varying,
+  **marine** character varying,
+  **terrestial** character varying,
+  **freshwater** character varying,
+  shape_leng double precision,
+  shape_area double precision

These fields are (partially?) described on [Mapping and Distribution Data Attribute Standards for the IUCN Red List of Threatened Species](https://www.iucnredlist.org/resources/mappingstandards)

Each foreign table is converted to real geometric table (and/or appended, as for corals) inside the schema **species_202001** using [this sql script](./species_2020_preprocessing.sql), with following parameters:

`SELECT * FROM MAMMALS WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)`

which will include: **Extant** and **Probably Extant** (IUCN will discontinue this code); **Native** and **Reintroduced**; **Resident**, **Breeding Season** and **Non-breeding Season**.

**fid** is a weak temporary serial (is not unique in case of appended corals).The field **id_no** is **unique by species**, but redundant by fields (within the ones of some interest for the analysis): presence, origin, seasonal, subspecies, subpop, (others?), and each row corresponds to a different polygon. The next steps in spatial processing will merge/dissolve these polygons by id_no, making this field unique, Primary Key. 

## BIRDLIFE tables
Spatial and non-spatial data for **birds** are available as foreign table pointing at gdb file in schema **species_birdlife_201903**, and they contain the fields (relevants in **bold**):

### spatial table "All_species"

+  fid bigint,
+  **shape geometry(MultiPolygon,4326)**,
+  **sisid** integer **(corresponds to IUCN spatial table field: id_no)**,
+  **sciname** character varying  **(corresponds to IUCN spatial table field: binomial)**,
+  date_ character varying,
+  source character varying,
+  **presence** integer,
+  **origin** integer,
+  **seasonal** integer,
+  data_sens character varying,
+  sens_comm character varying,
+  compiler character varying,
+  tax_com character varying,
+  dist_com character varying,
+  reviewers character varying,
+  citation character varying,
+  version character varying,
+  shape_length double precision,
+  shape_area double precision,
+  filename character varying,
+  vxcount integer

### non-spatial table "SppListAdditional"

+  fid bigint,
+  **id_no** integer,
+  **binomial** character varying,
+  common_name character varying,
+  **kingdom** character varying,
+  **phylum** character varying,
+  **class** character varying,
+  **order_** character varying,
+  **family** character varying,
+  **genus** character varying,
+  **category** character varying,
+  criteria character varying,
+  assessor character varying,
+  assessment_date timestamp with time zone,
+  **biome_marine** character varying **(corresponds to IUCN spatial table field: marine)**,
+  **biome_terrestrial** character varying **(corresponds to IUCN spatial table field: terrestrial)**,
+  **biome_freshwater** character varying **(corresponds to IUCN spatial table field: freshwater)**,
+  publication_yr smallint,
+  population_trend character varying

### non-spatial table "BirdLife_HBW_Taxonomic_Checklist_V4"

+  fid bigint,
+  sequence integer,
+  **order_** character varying,
+  **family_name** character varying **(corresponds to IUCN spatial table field: family)**,
+  family character varying,
+  subfamily_name character varying,
+  tribe_name character varying,
+  common_name character varying,
+  **scientific_name** character varying **(corresponds to IUCN spatial table field: binomial)**,
+  authority character varying,
+  birdlife_taxonomic_treatment character varying,
+  **f2019_iucn_red_list_category** character varying **(corresponds to IUCN spatial table field: category)**,
+  synonyms character varying,
+  alternative_common_names character varying,
+  taxonomic_notes character varying,
+  taxonomic_source character varying,
+  **sisrecid** integer **(corresponds to IUCN spatial table field: id_no)**,
+  **marine character varying**,
+  **freshwater character varying**,
+  **terrestrial character varying**

An additional non spatial table is available as foreign table pointing at xlsx file in schema/table **species_birdlife_non_spatial_201903.sheet1**, and contains just a list with five species ( **22712690, 22716650, 22732350, 103774724, 103878817**) missing information related to ecosystems.

## IUCN non-spatial tables

Current importing script is `processing_current/species/01_species_input_additional_tables.sh`.

Because of limits (10K records) of the IUCN website, downloads are split in:

*  redlist_species_data_all_except_passeriformes
*  redlist_species_data_only_passeriformes

All the non-spatial tables are:

*  all_other_fields.csv
*  assessments.csv
*  common_names.csv
*  conservation_needed.csv
*  countries.csv
*  credits.csv
*  dois.csv **(only non-birds)**
*  fao.csv
*  habitats.csv
*  lme.csv **(only non-birds)**
*  references.csv
*  research_needed.csv
*  simple_summary.csv
*  synonyms.csv
*  taxonomy.csv
*  threats.csv
*  usetrade.csv
                                        
They are imported in Postgres as:

*  "species.additional_tables_all_other_fields",
*  "species.additional_tables_assessments",
*  "species.additional_tables_common_names",
*  "species.additional_tables_conservation_needed",
*  "species.additional_tables_countries",
*  "species.additional_tables_credits",
*  "species.additional_tables_dois",
*  "species.additional_tables_fao",
*  "species.additional_tables_habitats",
*  "species.additional_tables_lme",
*  "species.additional_tables_references",
*  "species.additional_tables_research_needed",
*  "species.additional_tables_simple_summary",
*  "species.additional_tables_synonyms",
*  "species.additional_tables_taxonomy",
*  "species.additional_tables_threats",
*  "species.additional_tables_usetrade".

The final tables contain the following fields:

*  "species.additional_tables_all_other_fields.assessmentid character varying",
*  "species.additional_tables_all_other_fields.scientificname character varying",
*  "species.additional_tables_all_other_fields.internaltaxonid character varying",
*  "species.additional_tables_all_other_fields.aoo.range character varying",
*  "species.additional_tables_all_other_fields.eoo.range character varying",
*  "species.additional_tables_all_other_fields.depthlower.limit character varying",
*  "species.additional_tables_all_other_fields.depthupper.limit character varying",
*  "species.additional_tables_all_other_fields.congregatory.value character varying",
*  "species.additional_tables_all_other_fields.nothreats.nothreats character varying",
*  "species.additional_tables_all_other_fields.elevationlower.limit character varying",
*  "species.additional_tables_all_other_fields.elevationupper.limit character varying",
*  "species.additional_tables_all_other_fields.populationsize.range character varying",
*  "species.additional_tables_all_other_fields.threatsunknown.value character varying",
*  "species.additional_tables_all_other_fields.locationsnumber.range character varying",
*  "species.additional_tables_all_other_fields.generationlength.range character varying",
*  "species.additional_tables_all_other_fields.movementpatterns.pattern character varying",
*  "species.additional_tables_all_other_fields.subpopulationnumber.range character varying",
*  "species.additional_tables_all_other_fields.arearestricted.isrestricted character varying",
*  "species.additional_tables_all_other_fields.cropwildrelative.isrelative character varying",
*  "species.additional_tables_all_other_fields.yearofpopulationestimate.value character varying",
*  "species.additional_tables_all_other_fields.inplaceeducationcontrolled.value character varying",
*  "species.additional_tables_all_other_fields.severefragmentation.isfragmented character varying",
*  "species.additional_tables_all_other_fields.inplaceresearchrecoveryplan.value character varying",
*  "species.additional_tables_all_other_fields.inplacelandwaterprotectioninpa.value character varying",
*  "species.additional_tables_all_other_fields.inplacespeciesmanagementexsitu.value character varying",
*  "species.additional_tables_all_other_fields.inplaceresearchmonitoringscheme.value character varying",
*  "species.additional_tables_all_other_fields.inplaceeducationsubjecttoprograms.value character varying",
*  "species.additional_tables_all_other_fields.inplacespeciesmanagementharvestplan.value character varying",
*  "species.additional_tables_all_other_fields.inplacelandwaterprotectionareaplanned.value character varying",
*  "species.additional_tables_all_other_fields.inplaceeducationinternationallegislation.value character varying",
*  "species.additional_tables_all_other_fields.inplacelandwaterprotectioninvasivecontrol.value character varying",
*  "species.additional_tables_all_other_fields.inplacelandwaterprotectionsitesidentified.value character varying",
*  "species.additional_tables_all_other_fields.inplacelandwaterprotectionpercentprotected.value character varying",
*  "species.additional_tables_assessments.assessmentid character varying",
*  "species.additional_tables_assessments.internaltaxonid character varying",
*  "species.additional_tables_assessments.scientificname character varying",
*  "species.additional_tables_assessments.redlistcategory character varying",
*  "species.additional_tables_assessments.redlistcriteria character varying",
*  "species.additional_tables_assessments.yearpublished character varying",
*  "species.additional_tables_assessments.assessmentdate character varying",
*  "species.additional_tables_assessments.criteriaversion character varying",
*  "species.additional_tables_assessments.language character varying",
*  "species.additional_tables_assessments.rationale character varying",
*  "species.additional_tables_assessments.habitat character varying",
*  "species.additional_tables_assessments.threats character varying",
*  "species.additional_tables_assessments.population character varying",
*  "species.additional_tables_assessments.populationtrend character varying",
*  "species.additional_tables_assessments.range character varying",
*  "species.additional_tables_assessments.usetrade character varying",
*  "species.additional_tables_assessments.systems character varying",
*  "species.additional_tables_assessments.conservationactions character varying",
*  "species.additional_tables_assessments.realm character varying",
*  "species.additional_tables_assessments.yearlastseen character varying",
*  "species.additional_tables_assessments.possiblyextinct character varying",
*  "species.additional_tables_assessments.possiblyextinctinthewild character varying",
*  "species.additional_tables_assessments.scopes character varying",
*  "species.additional_tables_common_names.internaltaxonid character varying",
*  "species.additional_tables_common_names.scientificname character varying",
*  "species.additional_tables_common_names.name character varying",
*  "species.additional_tables_common_names.language character varying",
*  "species.additional_tables_common_names.main character varying",
*  "species.additional_tables_conservation_needed.assessmentid character varying",
*  "species.additional_tables_conservation_needed.internaltaxonid character varying",
*  "species.additional_tables_conservation_needed.scientificname character varying",
*  "species.additional_tables_conservation_needed.code character varying",
*  "species.additional_tables_conservation_needed.name character varying",
*  "species.additional_tables_conservation_needed.note character varying",
*  "species.additional_tables_countries.assessmentid character varying",
*  "species.additional_tables_countries.internaltaxonid character varying",
*  "species.additional_tables_countries.scientificname character varying",
*  "species.additional_tables_countries.code character varying",
*  "species.additional_tables_countries.name character varying",
*  "species.additional_tables_countries.presence character varying",
*  "species.additional_tables_countries.origin character varying",
*  "species.additional_tables_countries.seasonality character varying",
*  "species.additional_tables_countries.formerlybred character varying",
*  "species.additional_tables_credits.assessmentid character varying",
*  "species.additional_tables_credits.internaltaxonid character varying",
*  "species.additional_tables_credits.scientificname character varying",
*  "species.additional_tables_credits.type character varying",
*  "species.additional_tables_credits.text character varying",
*  "species.additional_tables_credits.full character varying",
*  "species.additional_tables_credits.value character varying",
*  "species.additional_tables_credits.order character varying",
*  "species.additional_tables_dois.assessmentid character varying",
*  "species.additional_tables_dois.scientificname character varying",
*  "species.additional_tables_dois.internaltaxonid character varying",
*  "species.additional_tables_dois.doi character varying",
*  "species.additional_tables_fao.assessmentid character varying",
*  "species.additional_tables_fao.internaltaxonid character varying",
*  "species.additional_tables_fao.scientificname character varying",
*  "species.additional_tables_fao.code character varying",
*  "species.additional_tables_fao.name character varying",
*  "species.additional_tables_fao.formerlybred character varying",
*  "species.additional_tables_fao.origin character varying",
*  "species.additional_tables_fao.presence character varying",
*  "species.additional_tables_fao.seasonality character varying",
*  "species.additional_tables_habitats.assessmentid character varying",
*  "species.additional_tables_habitats.internaltaxonid character varying",
*  "species.additional_tables_habitats.scientificname character varying",
*  "species.additional_tables_habitats.code character varying",
*  "species.additional_tables_habitats.name character varying",
*  "species.additional_tables_habitats.majorimportance character varying",
*  "species.additional_tables_habitats.season character varying",
*  "species.additional_tables_habitats.suitability character varying",
*  "species.additional_tables_lme.assessmentid character varying",
*  "species.additional_tables_lme.internaltaxonid character varying",
*  "species.additional_tables_lme.scientificname character varying",
*  "species.additional_tables_lme.code character varying",
*  "species.additional_tables_lme.name character varying",
*  "species.additional_tables_lme.formerlybred character varying",
*  "species.additional_tables_lme.origin character varying",
*  "species.additional_tables_lme.presence character varying",
*  "species.additional_tables_lme.seasonality character varying",
*  "species.additional_tables_references.assessmentid character varying",
*  "species.additional_tables_references.internaltaxonid character varying",
*  "species.additional_tables_references.scientificname character varying",
*  "species.additional_tables_references.author character varying",
*  "species.additional_tables_references.citation character varying",
*  "species.additional_tables_references.year character varying",
*  "species.additional_tables_references.title character varying",
*  "species.additional_tables_research_needed.assessmentid character varying",
*  "species.additional_tables_research_needed.internaltaxonid character varying",
*  "species.additional_tables_research_needed.scientificname character varying",
*  "species.additional_tables_research_needed.code character varying",
*  "species.additional_tables_research_needed.name character varying",
*  "species.additional_tables_research_needed.note character varying",
*  "species.additional_tables_simple_summary.assessmentid character varying",
*  "species.additional_tables_simple_summary.internaltaxonid character varying",
*  "species.additional_tables_simple_summary.scientificname character varying",
*  "species.additional_tables_simple_summary.kingdomname character varying",
*  "species.additional_tables_simple_summary.phylumname character varying",
*  "species.additional_tables_simple_summary.ordername character varying",
*  "species.additional_tables_simple_summary.classname character varying",
*  "species.additional_tables_simple_summary.familyname character varying",
*  "species.additional_tables_simple_summary.genusname character varying",
*  "species.additional_tables_simple_summary.speciesname character varying",
*  "species.additional_tables_simple_summary.infratype character varying",
*  "species.additional_tables_simple_summary.infraname character varying",
*  "species.additional_tables_simple_summary.infraauthority character varying",
*  "species.additional_tables_simple_summary.authority character varying",
*  "species.additional_tables_simple_summary.redlistcategory character varying",
*  "species.additional_tables_simple_summary.redlistcriteria character varying",
*  "species.additional_tables_simple_summary.criteriaversion character varying",
*  "species.additional_tables_simple_summary.populationtrend character varying",
*  "species.additional_tables_simple_summary.scopes character varying",
*  "species.additional_tables_synonyms.internaltaxonid character varying",
*  "species.additional_tables_synonyms.scientificname character varying",
*  "species.additional_tables_synonyms.name character varying",
*  "species.additional_tables_synonyms.genusname character varying",
*  "species.additional_tables_synonyms.speciesname character varying",
*  "species.additional_tables_synonyms.speciesauthor character varying",
*  "species.additional_tables_synonyms.infratype character varying",
*  "species.additional_tables_synonyms.infrarankauthor character varying",
*  "species.additional_tables_taxonomy.internaltaxonid character varying",
*  "species.additional_tables_taxonomy.scientificname character varying",
*  "species.additional_tables_taxonomy.kingdomname character varying",
*  "species.additional_tables_taxonomy.phylumname character varying",
*  "species.additional_tables_taxonomy.ordername character varying",
*  "species.additional_tables_taxonomy.classname character varying",
*  "species.additional_tables_taxonomy.familyname character varying",
*  "species.additional_tables_taxonomy.genusname character varying",
*  "species.additional_tables_taxonomy.speciesname character varying",
*  "species.additional_tables_taxonomy.infratype character varying",
*  "species.additional_tables_taxonomy.infraname character varying",
*  "species.additional_tables_taxonomy.infraauthority character varying",
*  "species.additional_tables_taxonomy.subpopulationname character varying",
*  "species.additional_tables_taxonomy.authority character varying",
*  "species.additional_tables_taxonomy.taxonomicnotes character varying",
*  "species.additional_tables_threats.assessmentid character varying",
*  "species.additional_tables_threats.internaltaxonid character varying",
*  "species.additional_tables_threats.scientificname character varying",
*  "species.additional_tables_threats.code character varying",
*  "species.additional_tables_threats.name character varying",
*  "species.additional_tables_threats.stresscode character varying",
*  "species.additional_tables_threats.stressname character varying",
*  "species.additional_tables_threats.ancestry character varying",
*  "species.additional_tables_threats.ias character varying",
*  "species.additional_tables_threats.internationaltrade character varying",
*  "species.additional_tables_threats.scope character varying",
*  "species.additional_tables_threats.severity character varying",
*  "species.additional_tables_threats.text character varying",
*  "species.additional_tables_threats.timing character varying",
*  "species.additional_tables_threats.virus character varying",
*  "species.additional_tables_usetrade.assessmentid character varying",
*  "species.additional_tables_usetrade.internaltaxonid character varying",
*  "species.additional_tables_usetrade.scientificname character varying",
*  "species.additional_tables_usetrade.code character varying",
*  "species.additional_tables_usetrade.name character varying",
*  "species.additional_tables_usetrade.international character varying",
*  "species.additional_tables_usetrade.national character varying",
*  "species.additional_tables_usetrade.other character varying",
*  "species.additional_tables_usetrade.subsistence character varying".

**The analysis and selection of the relevant fields out of the total (193) is one of the target of this task.**

