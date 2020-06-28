DROP SCHEMA IF EXISTS species_202001 CASCADE; CREATE SCHEMA species_202001;
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

