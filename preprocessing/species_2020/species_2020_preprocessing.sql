-- SCHEMA
DROP SCHEMA IF EXISTS species_202001 CASCADE; CREATE SCHEMA species_202001;

-- SPATIAL IUCN
SELECT * INTO species_202001.reef_forming_corals FROM
(SELECT * FROM species_iucn_spatial_202001.reef_forming_corals_part1 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM species_iucn_spatial_202001.reef_forming_corals_part2 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM species_iucn_spatial_202001.reef_forming_corals_part3 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid
) a
ORDER BY id_no,fid;
SELECT * INTO species_202001.sharks_rays_chimaeras FROM species_iucn_spatial_202001.sharks_rays_chimaeras WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;
SELECT * INTO species_202001.amphibians FROM species_iucn_spatial_202001.amphibians WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;
SELECT * INTO species_202001.mammals FROM species_iucn_spatial_202001.mammals WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;

-- NON SPATIAL IUCN
SELECT * INTO species_202001.all_other_fields FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.all_other_fields
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.all_other_fields
) a;
SELECT * INTO species_202001.assessments FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.assessments
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.assessments
) a;
SELECT * INTO species_202001.common_names FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.common_names
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.common_names
) a;
SELECT * INTO species_202001.conservation_needed FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.conservation_needed
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.conservation_needed
) a;
SELECT * INTO species_202001.countries FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.countries
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.countries
) a;
SELECT * INTO species_202001.credits FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.credits
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.credits
) a;
SELECT * INTO species_202001.habitats FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.habitats
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.habitats
) a;
SELECT * INTO species_202001.references FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.references
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.references
) a;
SELECT * INTO species_202001.research_needed FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.research_needed
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.research_needed
) a;
SELECT * INTO species_202001.simple_summary FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.simple_summary
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.simple_summary
) a;
SELECT * INTO species_202001.synonyms FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.synonyms
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.synonyms
) a;
SELECT * INTO species_202001.taxonomy FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.taxonomy
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.taxonomy
) a;
SELECT * INTO species_202001.threats FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.threats
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.threats
) a;
SELECT * INTO species_202001.usetrade FROM (
SELECT * FROM species_iucn_non_spatial_non_passeriformes_202001.usetrade
UNION 
SELECT * FROM species_iucn_non_spatial_only_passeriformes_202001.usetrade
) a;
SELECT * INTO species_202001.dois FROM species_iucn_non_spatial_non_passeriformes_202001.dois;
SELECT * INTO species_202001.fao FROM species_iucn_non_spatial_non_passeriformes_202001.fao;
SELECT * INTO species_202001.lme FROM species_iucn_non_spatial_non_passeriformes_202001.lme;
SELECT * INTO species_202001.plant_specific FROM species_iucn_non_spatial_non_passeriformes_202001.plant_specific;