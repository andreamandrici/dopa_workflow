### Spatial proximity to protected and conserved areas

We quantified the spatial proximity of industrial facilities to protected and conserved areas on an annual basis. The analysis included 99,264 georeferenced facilities and covered the reporting period 2007–2024. Because facilities did not necessarily report in every year, the analysis comprised 873,062 facility–year observations, which represented the spatial and temporal units of analysis.

Spatial data on protected and conserved areas were obtained from the January 2026 release of the *World Database on Protected and Conserved Areas (WDPCA)* (UNEP-WCMC and IUCN, 2026). The dataset was downloaded on 15 December 2025 as the file `WDPA_WDOECM_Jan2026_public`.

The spatial processing was performed using the same GIS and spatial database infrastructure used for the Global Biodiversity Data Viewer (GBDV; formerly DOPA), following the methodological and data-processing framework described by Juffe-Bignoli et al. (2024), with additional *ad-hoc* analyses described below.

Natura 2000 sites were identified directly within the WDPCA dataset using the `METADATAID` field, which links records to their source metadata. Records with `METADATAID = 1832` correspond to the Natura 2000 data source, described as “Natura 2000 data - the European network of protected sites. Provided by Directorate-General for Environment (EU) via EEA - Updated in the WDPA on 2025”. Thus, Natura 2000 sites were identified from the WDPCA source data itself rather than from a separate spatial dataset.

Further, for Natura 2000 sites, the `DESIG` and `DESIG_ENG` fields identify *Sites of Community Importance* and *Special Areas of Conservation* (under the Habitats Directive), and *Special Protection Areas* (under the Birds Directive). For non-Natura 2000 sites, the `SITE_TYPE` field identifies Protected Areas (`PA`) and Other Effective Area-Based Conservation Measures (OECM), which include Biological and Ecological Interest Sites, Cultural Parks, Permanent Hunting Reserves, and Voluntary Set-aside Areas.

To account for the temporal availability of protected and conserved areas, sites established after the facility reporting year were excluded from the analysis. Specifically, a site was considered eligible when its `STATUS_YR` was less than or equal to the reporting year (`STATUS_YR ≤ reporting year`), where `STATUS_YR` represents the year in which the site was established in the WDPA. Thus, for each reporting year, the analysis included all eligible sites established in that year or in previous years, rather than only sites established in the same year.

For computational efficiency, the search area was defined as the global convex hull of all facility locations, buffered by 1° (approximately 111 km at the equator). This buffer was used as a computational filter to select protected and conserved sites whose geometries intersected the resulting area.

For each facility–year observation, the nearest eligible site was identified independently for the protected-area and Natura 2000 subsets. Nearest-neighbour searches were performed in PostGIS using the K-nearest-neighbour (`<->`) operator and GiST spatial indexes. The candidate site with the smallest indexed spatial distance was selected for each facility–year observation.

The protected-area and Natura 2000 calculations were performed separately using parallel processing and subsequently combined by `facility_inspire_id` and reporting year (`r_yr`). For each facility–year combination, the resulting dataset contains the information corresponding to the nearest protected area and, independently, to the nearest Natura 2000 site. For each of these two comparisons, the corresponding site identifier (`site_id`), distance from the facility (`distance`), site type (`type`), site name (`name`), designation (`desig`), designation type (`desig_type`), year of establishment (`status_yr`), and country code (`ISO3`) were retained.

All Bash and SQL code used for data preparation, spatial processing, parallel nearest-neighbour calculations and reporting is available in the author's GitHub repository: https://github.com/andreamandrici/dopa_workflow/tree/master/various/pollutants/nature_nature

The resulting facility–year dataset therefore provides, for each facility and reporting year, the distance and associated attributes of the nearest eligible protected area and of the nearest eligible Natura 2000 site.

### Data sources and references

UNEP-WCMC and IUCN (2026), *Protected Planet: The World Database on Protected and Conserved Areas (WDPCA)* [On-line], January 2026, Cambridge, UK: UNEP-WCMC and IUCN. Available at: [www.protectedplanet.net](http://www.protectedplanet.net). Downloaded 15 December 2025.

Juffe-Bignoli, D., Mandrici, A., Delli, G., Niamir, A. & Dubois, G. (2024), “Delivering Systematic and Repeatable Area-Based Conservation Assessments: From Global to Local Scales”, *Land*, 13, 1506.

