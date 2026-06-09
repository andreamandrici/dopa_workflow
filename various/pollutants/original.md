






 
Once the facility–N2K–species relationships are established, we will need to recompute (with external help) pollutant concentrations and evaluate the impacts. 
 
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


  
From the N2K data we extracted the list of amphibians present in all the sites: SPECIES table reports for species in Habitat Directive, OTHERSPECIES reports for all the other species. 
I wrote in the past that these tables shows big limits (mistakes, old nomenclature, etc): I deleted all plants, fishes, reptiles, mammals reported as Amphibians. 
 
I do not correct the scientific names, but I try to integrate/recover the information using PULSE dataset, from which I have extracted the list and the assessment of European amphibians. 
I am sending you a preliminary list of potential species so you can evaluate which ones might be suitable targets. 
Later we will perform a spatial correlation to see which species actually fall within the influence range of the facilities. 
Once the facility–N2K–species relationships are established, we will need to recompute (with external help) pollutant concentrations and evaluate the impacts. 
 
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
