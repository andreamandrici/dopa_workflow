# Pollutants 2026

## PURPOSE OF THE WORK 

To propose a method for assessing the impact of facilities that release chemical compounds on amphibians that are sensitive to pollutants. 
Since this is the third round of calculations, we need to discard the illogical steps that were present in earlier attempts. 

## DATASETS 
20260212 – AM, GD 

- EEA Natura2K and Pollutants - https://sdi.eea.europa.eu/datastore/public?path=/eea_v_3035_100_k_natura2000_p_2024_v01_r00 (spatial, vector) 
- Industrial Emissions Directive 2010/75/EU and European Pollutant Release and Transfer Register Regulation (EC) No 166/2006 - ver. 15.0 Dec. 2025 (Tabular data, MSAccess) https://sdi.eea.europa.eu/webdav/datastore/public/eea_t_ied-eprtr_p_2007-2023_v15_r00 
- Crnobrnja-Isailović et al. 2025. Measuring the Pulse of European Biodiversity. European Red List of Amphibians. The IUCN Red List of Threatened Species: European Amphibian Dataset. https://www.iucnredlist.org/resources/data-repository#ERL%20Amphibians 
- EU DEM and related hydrologic model https://ec.europa.eu/eurostat/web/gisco/geodata/digital-elevation-model/eu-dem - https://gisco-services.ec.europa.eu/dem/5degree/mosaic/EU_DEM_mosaic_5deg.ZIP 

## DATA PROCESSING

### Facilities

A georeferenced list of facilities (point locations) with variable resolution (the smallest is ~1 km) is provided. 

From this list we: 
- Use pollutantName as identifier 
- Discarded those with georeferencing errors 
  - coord 0,0 4 points 
  - AQUADATA georeferenced wrong: 4 points 
- Selected the facilities that: 
  - emit compounds into the WATER medium, and 
  - have NOT NULL (0 is valid value) reports for 2018 and/or 2022. 
