
 
We selected Natura 2000 sites within a maximum distance of 5 km from each facility (point‑to‑boundary). 
 
For each facility–N2K pair we assigned a distance category: 
0= 0-100 m (coincident), 

1 = ≤ 1 000 m, 

2 = ≤ 2 000 m, 

3 = ≤ 3 000 m, 

5 = ≤ 5 000 m. 

The facility–N2K relationship is many‑to‑many (one facility can impact more than one N2K; each N2K can be impacted by multiple facilities). 
Each combination appears only once, in the lowest applicable category (if a N2K site is ≤ 100 m from a facility is in cat 0, and won’t appear also in the larger‑distance categories 1,2,3,5). 

From the EU‑DEM we extracted elevation for the facilities (absolute) and for the N2K polygons (minimum, maximum, mean). 
We excluded N2K sites whose minimum elevation was higher than the facility in the distances table at the previous step. 

From the N2K data we extracted the list of amphibians present in all the sites: SPECIES table reports for species in Habitat Directive, OTHERSPECIES reports for all the other species. 
These tables shows big limits (mistakes, old nomenclature, etc): I deleted all plants, fishes, reptiles, mammals reported as Amphibians. 
 
I do not correct the scientific names, but I try to integrate/recover the information using PULSE dataset, from which I have extracted the list and the assessment of European amphibians. 

 
A preliminary list of potential species to evaluate which ones might be suitable targets. 

Later a spatial correlation will be performed to see which species actually fall within the influence range of the facilities. 

 

Further refinement to evaluate: refining the selection by using spatial relationships among: 

facilities / hydrological basins / N2K, 

facilities / hydrological basins / river reaches / N2K, 

facilities / hydrological basins / river reaches / N2K / habitats. 

 
Once the facility–N2K–species relationships are established, we will need to recompute (with external help) pollutant concentrations and evaluate the impacts. 
 
Sharing the following tables as preliminary results, to start exploring the pollutant-species relationships in more detail. 

original_pollutants.csv: the list of ALL the pollutants in ALL the facilities emitting into the WATER medium 

n2k_species_list_full.csv: the list of all the species (with a bit of cleaning from me) reported for ALL the N2K sites 

n2k_speciesname is the reported name (the other fields are derived): can be wrong, obsolete 

source: table 

1 SPECIES (in Habitat Directive) 

2 OTHERSPECIES 

Pulse_amphibians_checklist.csv: the list of amphibians recently assessed and mapped by IUCN in EU27, Europe and , Mediterranean area 

Id_no: solid unique id for the species 

sci_name: this is the current, reliable taxonomy 

category: extinction risk: Extinct (EX), Extinct in the Wild (EW), Critically Endangered (CR), Endangered (EN), Vulnerable (VU), Near Threatened (NT), Least Concern (LC), Data Deficient (DD), and Not Evaluated (NE). Categories CR, EN, and VU constitute "threatened" species. 

Pulse_amphibians_synonyms.csv: crosswalk table within new and old taxonomy 

Internal_taxon_id: same as above id_no 

Internal_taxon_name: same as above sci_name 

Name: previous name used for the species 

Sci_name: cleaned-up version of the above field name. Can be correlated with above n2k_speciesname 

Source: different spatial datasets: endemic to Europe (GE), endemic to European and Med zones (GEM), not endemic to Europe region (REG) 

n2k_species_pulse_synonyms.csv: my attempt to correlate the two sources (EEA and IUCN) 

This last table is redundant: many reported names (n2k_speciesname) can refer to one species (id_no, sci_name) 

I focused more on compiling all species in List 1 (SPECIES) and less on those in List 2 (OTHERSPECIES) 

It will be further refined using spatial data, by: 

checking the correspondence between species reported in N2K and the PULSE range, and 

verifying the distance from facilities. 

 

Update of March 4, 2026 2:19 PM 
 
Hi all, 
a brief update and a status summary (please point out where I’m wrong or where you think changes are needed). I’ll put this text also in the shared Teams notes. 

  

Purpose of the work: To propose a method for assessing the impact of facilities that release chemical compounds on amphibians that are sensitive to pollutants. Since this is the third round of calculations, we need to discard the illogical steps that were present in earlier attempts. 

 

We can use very up‑to‑date data 

  

Facilities 2024 

EEA Natura 2000 2024 

IUCN PULSE Amphibians 2025 – species ranges/assessments 

EU‑DEM 30 m (this is Giacomo’s domain), and related hydrologic model. 

Data processing 

Dominik supplied a georeferenced list of facilities (point locations) with variable resolution (the smallest is ~1 km).  

  

From this list we: 

  

Discarded those with georeferencing errors (~4?) 

Selected the facilities that: 

emit compounds into the WATER medium, and 

have reports for 2018 and/or 2022. 

 

We selected Natura 2000 sites within a maximum distance of 5 km from each facility (point‑to‑boundary). 
 
For each facility–N2K pair we assigned a distance category: 
0= 0-100 m (coincident), 

1 = ≤ 1 000 m, 

2 = ≤ 2 000 m, 

3 = ≤ 3 000 m, 

5 = ≤ 5 000 m. 

  

The facility–N2K relationship is many‑to‑many (one facility can impact more than one N2K; each N2K can be impacted by multiple facilities). 
Each combination appears only once, in the lowest applicable category (if a N2K site is ≤ 100 m from a facility is in cat 0, and won’t appear also in the larger‑distance categories 1,2,3,5). 

  

From the EU‑DEM we extracted elevation for the facilities (absolute) and for the N2K polygons (minimum, maximum, mean). 
We excluded N2K sites whose minimum elevation was higher than the facility in the distances table at the previous step. 

  

From the N2K data we extracted the list of amphibians present in all the sites: SPECIES table reports for species in Habitat Directive, OTHERSPECIES reports for all the other species. 
I wrote in the past that these tables shows big limits (mistakes, old nomenclature, etc): I deleted all plants, fishes, reptiles, mammals reported as Amphibians. 
 
I do not correct the scientific names, but I try to integrate/recover the information using PULSE dataset, from which I have extracted the list and the assessment of European amphibians. 

 

I am sending you a preliminary list of potential species so you can evaluate which ones might be suitable targets. 

Later we will perform a spatial correlation to see which species actually fall within the influence range of the facilities. 

  

Further refinement (with Giacomo’s help): refining the selection by using spatial relationships among: 

  

facilities / hydrological basins / N2K, 

facilities / hydrological basins / river reaches / N2K, 

facilities / hydrological basins / river reaches / N2K / habitats. 

 

Once the facility–N2K–species relationships are established, we will need to recompute (with external help) pollutant concentrations and evaluate the impacts. 
 
Best, 
Andrea 

  

original_pollutants.csv: the list of ALL the pollutants in ALL the facilities emitting into the WATER medium 

n2k_species_list_full.csv: the list of all the species (with a bit of cleaning from me) reported for ALL the N2K sites 

n2k_speciesname is the reported name (the other fields are derived): can be wrong, obsolete 

source: table 

1 SPECIES (in Habitat Directive) 

2 OTHERSPECIES 

Pulse_amphibians_checklist.csv: the list of amphibians recently assessed and mapped by IUCN in EU27, Europe and , Mediterranean area 

Id_no: solid unique id for the species 

sci_name: this is the current, reliable taxonomy 

category: extinction risk: Extinct (EX), Extinct in the Wild (EW), Critically Endangered (CR), Endangered (EN), Vulnerable (VU), Near Threatened (NT), Least Concern (LC), Data Deficient (DD), and Not Evaluated (NE). Categories CR, EN, and VU constitute "threatened" species. 

Pulse_amphibians_synonyms.csv: crosswalk table within new and old taxonomy 

Internal_taxon_id: same as above id_no 

Internal_taxon_name: same as above sci_name 

Name: previous name used for the species 

Sci_name: cleaned-up version of the above field name. Can be correlated with above n2k_speciesname 

Source: different spatial datasets: endemic to Europe (GE), endemic to European and Med zones (GEM), not endemic to Europe region (REG) 

n2k_species_pulse_synonyms.csv: my attempt to correlate the two sources (EEA and IUCN) 

This last table is redundant: many reported names (n2k_speciesname) can refer to one species (id_no, sci_name) 

I focused more on compiling all species in List 1 (SPECIES) and less on those in List 2 (OTHERSPECIES) 

It will be further refined using spatial data, by: 

checking the correspondence between species reported in N2K and the PULSE range, and 

verifying the distance from facilities. 

I’m sharing this as a preliminary result, so you can start exploring the pollutant-species relationships in more detail. 

  

 

 

 
 
 
 

 
 
OUTPUTS 
-- facilities_n2k_distances_elevations 
Calculated distances between facilities and N2K sites (ST_DISTANCE: point to boundary), up to a maximum of 10 km. For each match, only the shortest distance in meters is retained: an N2K site intersecting a facility at multiple points, or continuously over a greater distance, is reported only once. Distances are reported in km. Distance categories are coded as 0 (0–100 meters), 1, 2, 3, 5, and 10 (within 1, 2, 3, 5, and 10 km) and are mutually exclusive. 
Input facilities and n2k (exploded as single poly) are intersected with EUDEM (point sampling and zonal statistics): elevation is reported for facilities, min/max/mean is reported for N2K. Elevation and min/max/avg are compared 
WHEN 
	elevation < min THEN 0 (N2K is always higher than facility: not included) 
	elevation > max THEN 3 (N2K is always lower than facility: always included 
	elevation >= min AND elevation < avg THEN 2 (facility is partially over N2k)  
	elevation >= avg AND elevation <= max THEN 1 (facility is partially below N2K) 
 
 
id --> facilities 
sitecode --> N2K 
min_distance_m 
km 
d --> distance category 
elevation --> facility elevation from EUDEM 
min --> n2k min elevation (min of the min in each polygon if multi), from EUDEM 
max --> n2k max elevation (max of the max in each polygon if multi), from EUDEM 
avg --> n2k mean elevation (avg of the means in each polygon if multi), from EUDEM 
compare --> comparison within elevation and min/max/avg: 
 
 
--original_facilities  

Iso2  
company  
id  
d --> DELETED 
X 
Y 
Geom 
selected-->TRUE IF within 10 Km from N2K 
Elevation--> calculated using the EU DEM. 
 
--original_n2k_geom 

Iso2 
Sitecode 
sitename 
sitetype 
geom 
selected-->TRUE IF within 10 Km from facilities 
 
-- selected_facilities_n2k 

AOI, calculated as 
10km buffers around selected facilities 
Unioned and dissolved with 
selected N2K 
 
-- selected_facilities_n2k_mcp 
Convex Hull Calculated on AOI 
 
-- selected_facilities_n2k_bbox 
Bounding Box calculated on MCP 

 

--facilities_n2k_distances_elevations 

 

____________________________________ 
FINAL (TEMPORARY) OUTPUTS 
 
facilities have been selected according 

Distance not over 5 km from N2K sites 

3262 id 

Releases reported for years 2018 and 2022 

3051 id 

year 2018: 2663 id 

year 2022: 2087 id 

Combination of the above provides 1775 id. 

N2K sites have been selected according to 

Distance not over 5 km from N2K sites 

Elevation at least partially lower than the facility (N2k higher than facility are deleted) 

Final n2k  are 2383 
Final combinations of id-n2k (within distance 5 km, lower than facility) are 4244 
