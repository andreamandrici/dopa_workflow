# COUNTRIES (V2024)

A flat topological corrected admin layer has been obtained in PostGIS, using the SQL scripts:
  +  [admin 2024 preprocessing](./admin_2024/preprocessing.sql)
  +  [admin 2024 flattening](./admin_2024/flattening)
  +  [admin 2024 postprocessing](./admin_2024/postprocessing.sql)

## problems

DOPA needs a global admin geographic object reporting by iso2,iso3,un_m49 codes.

The used version is CNTR_REG 2024 (documented by GISCO as DRAFT) 1:1M, and related CNTR_AT, AND EEZ 2020 1:1M.

The target is to NOT manually correct any inconsistency, to avoid ending up again with "correct", but not shared data.

Listed below are a number of problems encountered in using these datasets. We have already checked that the following problems happen also on

  +  1:100K version
  +  2020 version
    
therefore, using one of the above older/higher resolutions cannot be a solution.
 
  +  The coastaline within LAND (CNTR) and MARINE (EEZ) are not harmonized:
     +  each other
     +  with the additional COAS_REG 2020 object (global land polygon) 
  +  There are numerous holes in the derived ABNJ object, made as difference between global surface (-180,180,-90,90) and union of land and marine.
  +  The field POLI_ORG_CODE (Political Organisation Code)
     +  According to documentation should contain 4 codes (1,2,3,99); the real table contains 5 codes (1,2,3, 4,99) (code 4 is missing in the documentation)
     +  According to documentation should be linked to lookup table POLI_ORG_DOM; Table POLI_ORG_DOM does not exist
  +  Country coding using:
     +  UA (User assigned code elements)
        +  do not match any UN object
        +  almost all of them use 2 characters for ISO3 code (this will break our REST services)
  +  ER (Exceptionally reserved code element):
        +  Clipperton Island: does not exists in UN standard coding.

The following GISCO LAND objects do not match standard UN codes:

|name_engl|svrg_un|cntr_id|iso3_code|note|
|---------|-------|-------|--------|-----|
|Greece|UN Member State|EL|GRC|different iso2|
|United Kingdom|UN Member State|UK|GBR|different iso2|
|Clipperton Island|FR Territory|CP|CPT||
|Paracel Islands|Sovereignty unsettled|XA|XA||
|Spratly Islands|Sovereignty unsettled|XB|XB||
|Aksai Chin|Sovereignty unsettled|XC|XC||
|Arunachal Pradesh|Sovereignty unsettled|XD|XD||
|China/India|Sovereignty unsettled|XE|XE||
|Hala'Ib Triangle|Sovereignty unsettled|XF|XF||
|Ilemi Triangle|Sovereignty unsettled|XG|XG||
|Jammu Kashmir|Sovereignty unsettled|XH|XH||
|Kuril Islands|Sovereignty unsettled|XI|XI||
|No mans land|Sovereignty unsettled|XJL|XJL||
|Navassa Island|US Territory|XL|XL||	
|Scarborough Reef|Sovereignty unsettled|XM|XM||
|Senkaku Islands|Sovereignty unsettled|XN|XN||
|Bassas Da India|FR Territory|XO|XO||	
|Abyei|Sovereignty unsettled|XU|XU||
|Bir Tawil (Disputed Territory)|Sovereignty unsettled|XV|XV||
|Equatorial Guinea/Gabon (disputed territory)|Sovereignty unsettled|XXR|XXR||
|Chagos Islands (disputed territory)|Sovereignty unsettled|XXS|XXS||

The following standard UN codes do not match GISCO LAND objects:

|country_name|iso3|iso2|note|
|------------|----|----|----|
|Greece|GRC|GR|different iso2
|United Kingdom of Great Britain and Northern Ireland|GBR|GB|different iso2|
|Åland Islands|ALA|AX||
|British Indian Ocean Territory|IOT|IO||
|French Guiana|GUF|GF||
|Guadeloupe|GLP|GP||
|Martinique|MTQ|MQ||
|Mayotte|MYT|YT||
|Réunion|REU|RE||
|Saint Martin (French Part)|MAF|MF||	


The following GISCO MARINE objects
+  present a unique verbose description,but are redundant by ISO2 (EEZ_ID)
+  some of these objects exist with different code
   +  in GISCO LAND (EG: Bassas da India exists as object in GISCO LAND with code XO, in GISCO MARINE with code FR) and/or
   +  in UN Codes (EG: Reunion has official iso codes RE/REU, and sovereign iso code FR):

| eez_id | svrg_flag | description                                                                                |
| ------ | --------- | ------------------------------------------------------------------------------------------ |
| FR     |           | Amsterdam Island & St. Paul Island Exclusive Economic Zone                                 |
| FR     |           | Bassas da India Exclusive Economic Zone                                                    |
| FR     |           | Clipperton Exclusive Economic Zone                                                         |
| FR     |           | Crozet Islands Exclusive Economic Zone                                                     |
| FR     |           | French Exclusive Economic Zone                                                             |
| FR     |           | French Guiana Exclusive Economic Zone                                                      |
| FR     |           | French Polynesian Exclusive Economic Zone                                                  |
| FR     |           | Guadeloupean Exclusive Economic Zone                                                       |
| FR     |           | Ile Europa Exclusive Economic Zone                                                         |
| FR     |           | Juan de Nova Exclusive Economic Zone                                                       |
| FR     |           | Kerguelen Exclusive Economic Zone                                                          |
| FR     |           | Martinican Exclusive Economic Zone                                                         |
| FR     |           | New Caledonian Exclusive Economic Zone                                                     |
| FR     |           | Réunion Exclusive Economic Zone                                                            |
| FR     |           | Saint-Barthélemy Exclusive Economic Zone                                                   |
| FR     |           | Saint-Martin Exclusive Economic Zone                                                       |
| FR     |           | Saint-Pierre and Miquelon Exclusive Economic Zone                                          |
| FR     |           | Wallis and Futuna Exclusive Economic Zone                                                  |
| UK     |           | Anguilla Exclusive Economic Zone                                                           |
| UK     |           | Ascension Exclusive Economic Zone                                                          |
| UK     |           | Bermudian Exclusive Economic Zone                                                          |
| UK     |           | British Virgin Islands Exclusive Economic Zone                                             |
| UK     |           | Cayman Islands Exclusive Economic Zone                                                     |
| UK     |           | Guernsey Exclusive Economic Zone                                                           |
| UK     |           | Jersey Exclusive Economic Zone                                                             |
| UK     |           | Montserrat Exclusive Economic Zone                                                         |
| UK     |           | Pitcairn Islands Exclusive Economic Zone                                                   |
| UK     |           | St. Helena Exclusive Economic Zone                                                         |
| UK     |           | Tristan Da Cunha Exclusive Economic Zone                                                   |
| UK     |           | Turks and Caicos Exclusive Economic Zone                                                   |
| UK     |           | United Kingdom Exclusive Economic Zone                                                     |
| US     |           | American Samoa Exclusive Economic Zone                                                     |
| US     |           | Guam Exclusive Economic Zone                                                               |
| US     |           | Howland and Baker Islands Exclusive Economic Zone                                          |
| US     |           | Jarvis Island Exclusive Economic Zone                                                      |
| US     |           | Johnston Atoll Exclusive Economic Zone                                                     |
| US     |           | Northern Mariana Exclusive Economic Zone                                                   |
| US     |           | Palmyra Atoll Exclusive Economic Zone                                                      |
| US     |           | Puerto Rican Exclusive Economic Zone                                                       |
| US     |           | United States Exclusive Economic Zone                                                      |
| US     |           | United States Exclusive Economic Zone (Alaska)                                             |
| US     |           | United States Exclusive Economic Zone (Hawaii)                                             |
| US     |           | Virgin Islander Exclusive Economic Zone                                                    |
| US     |           | Wake Island Exclusive Economic Zone                                                        |
| AU     |           | Australian Exclusive Economic Zone                                                         |
| AU     |           | Australian Exclusive Economic Zone (Macquarie Island)                                      |
| AU     |           | Christmas Island Exclusive Economic Zone                                                   |
| AU     |           | Cocos Islands Exclusive Economic Zone                                                      |
| AU     |           | Heard and McDonald Islands Exclusive Economic Zone                                         |
| AU     |           | Norfolk Island Exclusive Economic Zone                                                     |
| CO     |           | Colombian Exclusive Economic Zone                                                          |
| CO     |           | Colombian Exclusive Economic Zone (Bajo Nuevo)                                             |
| CO     |           | Colombian Exclusive Economic Zone (Quitasueño)                                             |
| CO     |           | Colombian Exclusive Economic Zone (Serrana)                                                |
| CO     |           | Colombian Exclusive Economic Zone (Serranilla)                                             |
| ES_MA  | D         | Overlapping claim Alhucemas Islands: Spain / Morocco                                       |
| ES_MA  | D         | Overlapping claim Chafarinas Islands: Spain / Morocco                                      |
| ES_MA  | D         | Overlapping claim Melilla: Spain / Morocco                                                 |
| ES_MA  | D         | Overlapping claim Peñón de Vélez de la Gomera: Spain / Morocco                             |
| ES_MA  | D         | Overlapping claim Perejil Island: Spain / Morocco                                          |
| BQ     |           | Bonaire Exclusive Economic Zone                                                            |
| BQ     |           | Saba Exclusive Economic Zone                                                               |
| BQ     |           | Sint-Eustatius Exclusive Economic Zone                                                     |
| CL     |           | Chilean Exclusive Economic Zone                                                            |
| CL     |           | Chilean Exclusive Economic Zone (Easter Island)                                            |
| CL     |           | Chilean Exclusive Economic Zone (San Felix and San Ambrosio islands)                       |
| KI     |           | Kiribati Exclusive Economic Zone (Gilbert Islands)                                         |
| KI     |           | Kiribati Exclusive Economic Zone (Line Islands)                                            |
| KI     |           | Kiribati Exclusive Economic Zone (Phoenix Islands)                                         |
| NO     |           | Jan Mayen Exclusive Economic Zone                                                          |
| NO     |           | Norwegian Exclusive Economic Zone                                                          |
| NO     |           | Svalvard Exclusive Economic Zone                                                           |
| PT     |           | Portuguese Exclusive Economic Zone                                                         |
| PT     |           | Portuguese Exclusive Economic Zone (Azores)                                                |
| PT     |           | Portuguese Exclusive Economic Zone (Madeira)                                               |
| BR     |           | Brazilian Exclusive Economic Zone                                                          |
| BR     |           | Brazilian Exclusive Economic Zone (Trindade)                                               |
| CN     | D         | Overlapping claim South China Sea                                                          |
| CN     |           | Chinese Exclusive Economic Zone                                                            |
| EC     |           | Ecuadorian Exclusive Economic Zone                                                         |
| EC     |           | Ecuadorian Exclusive Economic Zone (Galapagos)                                             |
| ES     |           | Spanish Exclusive Economic Zone                                                            |
| ES     |           | Spanish Exclusive Economic Zone (Canary Islands)                                           |
| IN     |           | Indian Exclusive Economic Zone                                                             |
| IN     |           | Indian Exclusive Economic Zone (Andaman and Nicobar Islands)                               |
| MU     |           | Chagos Archipelago Exclusive Economic Zone                                                 |
| MU     |           | Mauritian Exclusive Economic Zone                                                          |
| NL     |           | Dutch Exclusive Economic Zone                                                              |
| NL     |           | Sint-Maarten Exclusive Economic Zone                                                       |
| TL     |           | East Timorian Exclusive Economic Zone                                                      |
| TL     |           | Oecussi Ambeno Exclusive Economic Zone                                                     |
| UK_AR  | D         | Overlapping claim Falkland / Malvinas Islands Exclusive Economic Zone: UK / Argentina      |
| UK_AR  | D         | Overlapping claim South Georgia and South Sandwich Exclusive Economic Zone: UK / Argentina |
| ZA     |           | South African Exclusive Economic Zone                                                      |
| ZA     |           | South African Exclusive Economic Zone (Prince Edward Islands)                              |
 
The following is the comparison of the two sources (GISCO LAND and MARINE), joined by common fields cntr_id/eez_id (iso2).
Source of land/marine names is gisco land; rendundant codes in marine values are aggregated  by code (this could be managed differently: EG CP-Clipperton Island code exists in land, but do not exists in marine; anyway the geographical marine object exists, and it is characterized by the description; This condition may not be homogeneous with other geographic objects and codes). 

| cntr_id  | land                                         | marine                                  |
| -------- | -------------------------------------------- | --------------------------------------- |
| AD       | Andorra                                      |                                         |
| AE       | United Arab Emirates                         | United Arab Emirates                    |
| AE_IR    |                                              | United Arab Emirates_Iran               |
| AF       | Afghanistan                                  |                                         |
| AG       | Antigua and Barbuda                          | Antigua and Barbuda                     |
| AI       | Anguilla                                     |                                         |
| AL       | Albania                                      | Albania                                 |
| AM       | Armenia                                      |                                         |
| AO       | Angola                                       | Angola                                  |
| AQ       | Antarctica                                   | Antarctica                              |
| AR       | Argentina                                    | Argentina                               |
| AS       | American Samoa                               |                                         |
| AT       | Austria                                      |                                         |
| AU       | Australia                                    | Australia                               |
| AU_TL    |                                              | Australia_Timor-Leste                   |
| AW       | Aruba                                        | Aruba                                   |
| AZ       | Azerbaijan                                   | Azerbaijan                              |
| BA       | Bosnia and Herzegovina                       | Bosnia and Herzegovina                  |
| BB       | Barbados                                     | Barbados                                |
| BB_GY    |                                              | Barbados_Guyana                         |
| BD       | Bangladesh                                   | Bangladesh                              |
| BE       | Belgium                                      | Belgium                                 |
| BF       | Burkina Faso                                 |                                         |
| BG       | Bulgaria                                     | Bulgaria                                |
| BH       | Bahrain                                      | Bahrain                                 |
| BI       | Burundi                                      |                                         |
| BJ       | Benin                                        | Benin                                   |
| BL       | Saint Barthélemy                             |                                         |
| BM       | Bermuda                                      |                                         |
| BN       | Brunei                                       | Brunei                                  |
| BO       | Bolivia                                      |                                         |
| BQ       | Bonaire, Sint Eustatius and Saba             | Bonaire, Sint Eustatius and Saba        |
| BR       | Brazil                                       | Brazil                                  |
| BS       | Bahamas                                      | Bahamas                                 |
| BT       | Bhutan                                       |                                         |
| BV       | Bouvet Island                                | Bouvet Island                           |
| BW       | Botswana                                     |                                         |
| BY       | Belarus                                      |                                         |
| BZ       | Belize                                       | Belize                                  |
| CA       | Canada                                       | Canada                                  |
| CA_US    |                                              | Canada_United States                    |
| CC       | Cocos (Keeling) Islands                      |                                         |
| CD       | Democratic Republic of The Congo             | Democratic Republic of The Congo        |
| CF       | Central African Republic                     |                                         |
| CG       | Congo                                        | Congo                                   |
| CH       | Switzerland                                  |                                         |
| CI       | Côte D’Ivoire                                | Côte D’Ivoire                           |
| CK       | Cook Islands                                 | Cook Islands                            |
| CL       | Chile                                        | Chile                                   |
| CM       | Cameroon                                     | Cameroon                                |
| CN       | China                                        | China                                   |
| CO       | Colombia                                     | Colombia                                |
| CO_DO_VE |                                              | Colombia_Dominican Republic_Venezuela   |
| CP       | Clipperton Island                            |                                         |
| CR       | Costa Rica                                   | Costa Rica                              |
| CR_EC    |                                              | Costa Rica_Ecuador                      |
| CU       | Cuba                                         | Cuba                                    |
| CV       | Cape Verde                                   | Cape Verde                              |
| CW       | Curaçao                                      | Curaçao                                 |
| CX       | Christmas Island                             |                                         |
| CY       | Cyprus                                       | Cyprus                                  |
| CZ       | Czechia                                      |                                         |
| DE       | Germany                                      | Germany                                 |
| DJ       | Djibouti                                     | Djibouti                                |
| DK       | Denmark                                      | Denmark                                 |
| DM       | Dominica                                     | Dominica                                |
| DO       | Dominican Republic                           |                                         |
| DO_CO    |                                              | Dominican Republic_Colombia             |
| DZ       | Algeria                                      | Algeria                                 |
| EC       | Ecuador                                      | Ecuador                                 |
| EC_CO    |                                              | Ecuador_Colombia                        |
| EE       | Estonia                                      | Estonia                                 |
| EG       | Egypt                                        | Egypt                                   |
| EH       | Western Sahara                               |                                         |
| EH_MA    |                                              | Western Sahara_Morocco                  |
| EL       | Greece                                       | Greece                                  |
| ER       | Eritrea                                      | Eritrea                                 |
| ER_DJ    |                                              | Eritrea_Djibouti                        |
| ES       | Spain                                        | Spain                                   |
| ES_MA    |                                              | Spain_Morocco                           |
| ET       | Ethiopia                                     |                                         |
| FI       | Finland                                      | Finland                                 |
| FJ       | Fiji                                         | Fiji                                    |
| FK       | Falkland Islands                             |                                         |
| FM       | Micronesia                                   | Micronesia                              |
| FO       | Faroes                                       | Faroes                                  |
| FO_IS    |                                              | Faroes_Iceland                          |
| FR       | France                                       | France                                  |
| FR_ES    |                                              | France_Spain                            |
| FR_IT    |                                              | France_Italy                            |
| FR_KM    |                                              | France_Comoros                          |
| FR_MU    |                                              | France_Mauritius                        |
| FR_VU    |                                              | France_Vanuatu                          |
| GA       | Gabon                                        | Gabon                                   |
| GD       | Grenada                                      | Grenada                                 |
| GE       | Georgia                                      | Georgia                                 |
| GG       | Guernsey                                     |                                         |
| GH       | Ghana                                        | Ghana                                   |
| GI       | Gibraltar                                    |                                         |
| GL       | Greenland                                    | Greenland                               |
| GM       | Gambia                                       | Gambia                                  |
| GN       | Guinea                                       | Guinea                                  |
| GQ       | Equatorial Guinea                            | Equatorial Guinea                       |
| GS       | South Georgia and The South Sandwich Islands |                                         |
| GT       | Guatemala                                    | Guatemala                               |
| GU       | Guam                                         |                                         |
| GW       | Guinea-Bissau                                | Guinea-Bissau                           |
| GY       | Guyana                                       | Guyana                                  |
| GY_TT_VE |                                              | Guyana_Trinidad and Tobago_Venezuela    |
| HK       | Hong Kong                                    |                                         |
| HM       | Heard Island and Mcdonald Islands            |                                         |
| HN       | Honduras                                     | Honduras                                |
| HN_UK    |                                              | Honduras_United Kingdom                 |
| HR       | Croatia                                      | Croatia                                 |
| HR_SI    |                                              | Croatia_Slovenia                        |
| HT       | Haiti                                        | Haiti                                   |
| HT_US    |                                              | Haiti_United States                     |
| HU       | Hungary                                      |                                         |
| ID       | Indonesia                                    | Indonesia                               |
| IE       | Ireland                                      | Ireland                                 |
| IL       | Israel                                       | Israel                                  |
| IM       | Isle of Man                                  |                                         |
| IN       | India                                        | India                                   |
| IQ       | Iraq                                         | Iraq                                    |
| IR       | Iran                                         | Iran                                    |
| IS       | Iceland                                      | Iceland                                 |
| IS_NO    |                                              | Iceland_Norway                          |
| IT       | Italy                                        | Italy                                   |
| JE       | Jersey                                       |                                         |
| JM       | Jamaica                                      | Jamaica                                 |
| JM_CO    |                                              | Jamaica_Colombia                        |
| JO       | Jordan                                       | Jordan                                  |
| JP       | Japan                                        | Japan                                   |
| JP_KR    |                                              | Japan_South Korea                       |
| JP_RU    |                                              | Japan_Russian Federation                |
| KE       | Kenya                                        | Kenya                                   |
| KE_SO    |                                              | Kenya_Somalia                           |
| KG       | Kyrgyzstan                                   |                                         |
| KH       | Cambodia                                     | Cambodia                                |
| KI       | Kiribati                                     | Kiribati                                |
| KM       | Comoros                                      | Comoros                                 |
| KN       | Saint Kitts and Nevis                        | Saint Kitts and Nevis                   |
| KP       | North Korea                                  | North Korea                             |
| KR       | South Korea                                  | South Korea                             |
| KR_JP    |                                              | South Korea_Japan                       |
| KW       | Kuwait                                       | Kuwait                                  |
| KY       | Cayman Islands                               |                                         |
| KZ       | Kazakhstan                                   | Kazakhstan                              |
| LA       | Laos                                         |                                         |
| LB       | Lebanon                                      | Lebanon                                 |
| LC       | Saint Lucia                                  | Saint Lucia                             |
| LI       | Liechtenstein                                |                                         |
| LK       | Sri Lanka                                    | Sri Lanka                               |
| LR       | Liberia                                      | Liberia                                 |
| LS       | Lesotho                                      |                                         |
| LT       | Lithuania                                    | Lithuania                               |
| LU       | Luxembourg                                   |                                         |
| LV       | Latvia                                       | Latvia                                  |
| LY       | Libya                                        | Libya                                   |
| MA       | Morocco                                      | Morocco                                 |
| MC       | Monaco                                       | Monaco                                  |
| MD       | Moldova                                      |                                         |
| ME       | Montenegro                                   | Montenegro                              |
| MG       | Madagascar                                   | Madagascar                              |
| MG_FR    |                                              | Madagascar_France                       |
| MH       | Marshall Islands                             | Marshall Islands                        |
| MK       | North Macedonia                              |                                         |
| ML       | Mali                                         |                                         |
| MM       | Myanmar/Burma                                | Myanmar/Burma                           |
| MN       | Mongolia                                     |                                         |
| MO       | Macau                                        |                                         |
| MP       | Northern Mariana Islands                     |                                         |
| MR       | Mauritania                                   | Mauritania                              |
| MS       | Montserrat                                   |                                         |
| MT       | Malta                                        | Malta                                   |
| MU       | Mauritius                                    | Mauritius                               |
| MV       | Maldives                                     | Maldives                                |
| MW       | Malawi                                       |                                         |
| MX       | Mexico                                       | Mexico                                  |
| MY       | Malaysia                                     | Malaysia                                |
| MZ       | Mozambique                                   | Mozambique                              |
| NA       | Namibia                                      | Namibia                                 |
| NC       | New Caledonia                                |                                         |
| NE       | Niger                                        |                                         |
| NF       | Norfolk Island                               |                                         |
| NG       | Nigeria                                      | Nigeria                                 |
| NI       | Nicaragua                                    | Nicaragua                               |
| NL       | Netherlands                                  | Netherlands                             |
| NO       | Norway                                       | Norway                                  |
| NO_SE    |                                              | Norway_Sweden                           |
| NP       | Nepal                                        |                                         |
| NR       | Nauru                                        | Nauru                                   |
| NU       | Niue                                         | Niue                                    |
| NZ       | New Zealand                                  | New Zealand                             |
| OM       | Oman                                         | Oman                                    |
| PA       | Panama                                       | Panama                                  |
| PE       | Peru                                         | Peru                                    |
| PE_EC    |                                              | Peru_Ecuador                            |
| PF       | French Polynesia                             |                                         |
| PG       | Papua New Guinea                             | Papua New Guinea                        |
| PG_AU    |                                              | Papua New Guinea_Australia              |
| PH       | Philippines                                  | Philippines                             |
| PK       | Pakistan                                     | Pakistan                                |
| PL       | Poland                                       | Poland                                  |
| PM       | Saint Pierre and Miquelon                    |                                         |
| PN       | Pitcairn Islands                             |                                         |
| PR       | Puerto Rico                                  |                                         |
| PS       | Palestine                                    |                                         |
| PS_IL    |                                              | Palestine_Israel                        |
| PT       | Portugal                                     | Portugal                                |
| PW       | Palau                                        | Palau                                   |
| PY       | Paraguay                                     |                                         |
| QA       | Qatar                                        | Qatar                                   |
| QA_SA_AE |                                              | Qatar_Saudi Arabia_United Arab Emirates |
| RO       | Romania                                      | Romania                                 |
| RS       | Serbia                                       |                                         |
| RU       | Russian Federation                           | Russian Federation                      |
| RW       | Rwanda                                       |                                         |
| SA       | Saudi Arabia                                 | Saudi Arabia                            |
| SB       | Solomon Islands                              | Solomon Islands                         |
| SC       | Seychelles                                   | Seychelles                              |
| SD       | Sudan                                        | Sudan                                   |
| SD_EG    |                                              | Sudan_Egypt                             |
| SE       | Sweden                                       | Sweden                                  |
| SG       | Singapore                                    | Singapore                               |
| SH       | Saint Helena, Ascension and Tristan Da Cunha |                                         |
| SI       | Slovenia                                     | Slovenia                                |
| SJ       | Svalbard and Jan Mayen                       |                                         |
| SK       | Slovakia                                     |                                         |
| SL       | Sierra Leone                                 | Sierra Leone                            |
| SM       | San Marino                                   |                                         |
| SN       | Senegal                                      | Senegal                                 |
| SN_GW    |                                              | Senegal_Guinea-Bissau                   |
| SO       | Somalia                                      | Somalia                                 |
| SR       | Suriname                                     | Suriname                                |
| SS       | South Sudan                                  |                                         |
| ST       | São Tomé and Príncipe                        | São Tomé and Príncipe                   |
| ST_NG    |                                              | São Tomé and Príncipe_Nigeria           |
| SV       | El Salvador                                  | El Salvador                             |
| SX       | Sint-Maarten                                 |                                         |
| SY       | Syria                                        | Syria                                   |
| SZ       | Eswatini                                     |                                         |
| TC       | Turks and Caicos Islands                     |                                         |
| TD       | Chad                                         |                                         |
| TF       | French Southern and Antarctic Lands          |                                         |
| TG       | Togo                                         | Togo                                    |
| TH       | Thailand                                     | Thailand                                |
| TJ       | Tajikistan                                   |                                         |
| TK       | Tokelau                                      | Tokelau                                 |
| TL       | Timor-Leste                                  | Timor-Leste                             |
| TM       | Turkmenistan                                 | Turkmenistan                            |
| TN       | Tunisia                                      | Tunisia                                 |
| TO       | Tonga                                        | Tonga                                   |
| TR       | Türkiye                                      | Türkiye                                 |
| TT       | Trinidad and Tobago                          | Trinidad and Tobago                     |
| TV       | Tuvalu                                       | Tuvalu                                  |
| TW       |                                              | Taiwan                                  |
| TW_JP_CN |                                              | Taiwan_Japan_China                      |
| TZ       | United Republic of Tanzania                  | United Republic of Tanzania             |
| UA       | Ukraine                                      | Ukraine                                 |
| UG       | Uganda                                       |                                         |
| UK       | United Kingdom                               | United Kingdom                          |
| UK_AR    |                                              | United Kingdom_Argentina                |
| UK_ES    |                                              | United Kingdom_Spain                    |
| UK_FO    |                                              | United Kingdom_Faroes                   |
| UM       | United States Minor Outlying Islands         |                                         |
| US       | United States                                | United States                           |
| US_DO    |                                              | United States_Dominican Republic        |
| US_RU    |                                              | United States_Russian Federation        |
| UY       | Uruguay                                      | Uruguay                                 |
| UY_AR    |                                              | Uruguay_Argentina                       |
| UZ       | Uzbekistan                                   |                                         |
| VA       | Vatican City                                 |                                         |
| VC       | Saint Vincent and The Grenadines             | Saint Vincent and The Grenadines        |
| VE       | Venezuela                                    | Venezuela                               |
| VE_AW_DO |                                              | Venezuela_Aruba_Dominican Republic      |
| VG       | British Virgin Islands                       |                                         |
| VI       | Us Virgin Islands                            |                                         |
| VN       | Viet nam                                     | Viet nam                                |
| VU       | Vanuatu                                      | Vanuatu                                 |
| WF       | Wallis and Futuna                            |                                         |
| WS       | Samoa                                        | Samoa                                   |
| XA       | Paracel Islands                              |                                         |
| XB       | Spratly Islands                              |                                         |
| XC       | Aksai Chin                                   |                                         |
| XD       | Arunachal Pradesh                            |                                         |
| XE       | China/India                                  |                                         |
| XF       | Hala'Ib Triangle                             |                                         |
| XG       | Ilemi Triangle                               |                                         |
| XH       | Jammu Kashmir                                |                                         |
| XI       | Kuril Islands                                |                                         |
| XJL      | No mans land                                 |                                         |
| XL       | Navassa Island                               |                                         |
| XM       | Scarborough Reef                             |                                         |
| XN       | Senkaku Islands                              |                                         |
| XO       | Bassas Da India                              |                                         |
| XU       | Abyei                                        |                                         |
| XV       | Bir Tawil (Disputed Territory)               |                                         |
| XXR      | Equatorial Guinea/Gabon (disputed territory) |                                         |
| XXS      | Chagos Islands (disputed territory)          |                                         |
| YE       | Yemen                                        | Yemen                                   |
| ZA       | South Africa                                 | South Africa                            |
| ZM       | Zambia                                       |                                         |
| ZW       | Zimbabwe                                     |                                         |



The main differences within GISCO CNTR/EEZ and GAUL/EEZ are given by: 
+  the many officially registered UN codes present in CEP (eg: Guadeloupe, Mayotte, Martinique, Guyana, Reunion, etc…), and reassigned to the sovereign country in GISCO (eg: France). 
+  the non-officially registred UN codes present in GISCO
+  Inconsistencies within GISCO itself, land and marine:
   +  CODES: I have deeply checked only UMI code, which is thousands of times smaller in GISCO respect to CEP: this because it is assigned to US in GISCO-EEZ, and to UMI in GISCO-LAND (in GAUL/EEZ both land and marine are assigned to UMI)… The same happens (I see it graphically, on the map) with Heard and McDonald Islands/Australia, French Southern and Antarctic Lands/France, New Caledonia/France, etc..
   +  COASTLINE: non matching coastline produce holes, which
      +  will slow a lot every intersection
      +  produce an ABNJ which should not exists south and over Antarctica.

Results won’t be comparable with previous releases, there won’t be correspondence with WDPA (WCMC for protected areas correctly reports both country and sovereign country code, using only UN officially registered codes).

We will need to adapt ALL the REST functions (it will be a long task) to the different and missing fields (EG: UN_M49), and records (the already listed missing officially registered codes).

Specific inconsistencies are:

+  DOM-COM: is a geometry error in GISCO-EEZ (missing DOM marine)
+  TWN-CHN: inconsistence within GISCO-LAND/MARINE (Taiwan: CHI in Land, TWN in Marine)
+  PRI-USA: inconsistence within GISCO-LAND/MARINE (Puerto Rico: PRI in Land, USA in Marine).
 

# COUNTRIES (V2019)

A flat topological corrected layer for EEZ has been obtained in PostGIS, using the SQL script [eez_2019](./eez_2019.sql).
Update of Countries is pending since November 2019, waiting for decision on Land dataset.

# ECOREGIONS (V2024)

Dataset is given by intersection of (more details in [Sources/Base Layers](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html):

+ OneEarth Terrestrial Ecoregions (TE)
+ Marine Ecoregions of the World (ME)
+ Pelagic Provinces Of the World (PE)
+ Freshwater Ecoregions of the World (FE).

The version of MEOW/PPOW without coastline is used.
TEOW is overlayed on top of MEOW/PPOW, and MEOW is clipped by TEOW's coastline.
"Holes" (big lakes) are filled by FEOW.

After the intersections, the overlapping classes are assigned as:

+  TEOW⋂MEOW/PPOW/FEOW=TEOW
+  MEOW⋂PPOW/FEOW=MEOW
+  PPOW⋂FEOW=PPOW;

## preprocessing scripts

### inputs

+   [ecoregions_2017](./ecoregions_2024/ecoregions_2017.sql)
+   [freshwater_ecoregions](./ecoregions_2024/freshwater_ecoregions.sql)
+   [marine+pelagic_ecoregions](./ecoregions_2024/meow_ppow.sql)

### flattening 

+   [flattening sequence and mods](./ecoregions_2024/flattening_sequence_and_mods.sql)
+   [workflow parameters](./ecoregions_2024/workflow_parameters.conf)
+   [f_revector postigs function](./ecoregions_2024/f_revector.sql)
+   [f_revector bash launcher](./ecoregions_2024/q_revector.sh)



# ECOREGIONS (V2020)
Calculation of [Country/Ecoregion/Protection (CEP) layer for March 2020](https://andreamandrici.github.io/dopa_workflow/processing/cep/#version-202003) highlighted several (incorrect) geometric overlaps in the original [Terrestrial Ecoregions Dataset](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html#ecoregions-v2019), not identified by the relaxed ArcGIS PRO topological model, which led to the inclusion of a post-processing  [patch](../processing/cep/202003_fix_cep_overlaps.sql) to correct the data.
To avoid endlessly replicating the application of the above patch, ecoregions dataset has been regenerated from scratch, resolving the topological problems, abandoning ArcGIS and using the [flattening](../flattening/) scripts chain.

General approach is the same of [Ecoregions 2019](https://andreamandrici.github.io/dopa_workflow/sources/Base_Layers.html#ecoregions-v2019) (for further details please refer to it):
+  dataset is given by intersection of TEOW/MEOW/PPOW
+  the version of MEOW/PPOW with complete coastline version is used
+  MEOW/PPOW is overlayed on topo of TEOW, and MEOW coastline substitutes TEOW's one
+  "holes" are filled by an empty layer covering the whole globe, named EEOW (Empty Ecoregions of the World!), flagged as "unassigned land ecoregion".

To simplify the outputs and the following processing steps, few classes have been recoded:

+  PPOW code 0 reclassed to 37
+  TEOW code -9998 reclassed to 9998
+  TEOW code -9999 to 9999.

After the intersections, the classes are assigned as:

+  MEOW⋂EEOW=MEOW
+  MEOW⋂TEOW=MEOW; exception: 2 MEOW objects in classes 20073,20077 have been respectively assigned to the intersecting TEOW classes 61318,60172
+  PPOW⋂EEOW=PPOW; exception: 1 PPOW object in class 9 has been assigned to the intersecting TEOW class 61318
+  PPOW⋂TEOW=PPOW
+  TEOW⋂EEOW=TEOW
+  EEOW⋂=EEOW; these have been considered "unassigned land ecoregion", and (**differently from Ecoregions V2019**) have not been partially assigned to adjoining TEOW classes.

Detailed step-by-step description is in [ecoregions_2020](./ecoregions_2020).

# ECOREGIONS (V2019)

MEOW/PPOW version with complete coastline has been used (previously the NoCoast one was used), because of the better coastline (eg: in previous versions a stripe of about 1000x1 Km was missing from the Adriatic coast), and because "Saint Pierre et Michelon" and "Tokealu" islands were obliterated by the NoCoast version.

A flat topological corrected layer, integrating the 3 sources [teow+(meow+ppow)] has been obtained:
1. assigning unique numeric id to each class in the original layers:
   +  for TEOW the original ECO_ID field has been used. The REALM info "AT" (Afrotropics) and "NT" (Neotropics) for ECO_IDs -9999 (Rock and Ice) and -9998 (Lake) is not included because, since for polar regions is NULL, it produces redundancy on the ECO_ID field (primary key in the final dataset).
   +  for MEOW and PPOW, for historical reasons, the same IDs previously assigned by JRC (reviewed with Bastian Bertzky in 2015) has been used, with a JOIN based on multiple fields (ECOREGION,PROVINC,BIOME or REALM, depending from the source), adapting original names when needed.
   +  correspondence table within original fields and final attributes is saved in the final output as "lookup_attribute_table", where the boolean fields "eco/pro/bio_is_mod" identify rows where ECOREGION/PROVINC/BIOME content has been modified (respect to "ORIGINAL_*" fields, included) to match the names in the final attributes (first_level, second_level, third_level), allowing this way the join.
      +  first_level corresponds to TEOW Ecoregion, MEOW Ecoregion, PPOW Province
      +  second_level corresponds to TEOW Biome, MEOW Province, PPOW Biome
      +  third_level corresponds to REALM for TEOW, MEOW and PPOW.
2. overlapping (ArcGIS PRO UNION) MEOW_PPOW with a Bounding Box Polygon (±180/90) as EEOW source (Empty Ecoregions of the World!), with the code 100001-"unassigned land ecoregion"
3. assigning MEOW/PPOW polygons intersecting EEOW to MEOW/PPOW. EEOW only polygons are left untouched
4. overlapping (ArcGIS PRO UNION) the TEOW+MEOW_PPOW_EEOW from the previous step
5. assigning:
   +  TEOW, MEOW or PPOW only polygons to TEOW, MEOW or PPOW
   +  TEOW polygons intersecting EEOW to TEOW
   +  TEOW polygons intersecting MEOW or PPOW to MEOW or PPOW. __This is different from previous version, where TEOW overlapped MEOW/PPOW. This is due to the better MEOW/PPOW coastline.__
      *  __exception to the above: 5 polygons intersecting both meow/ppow (codes ppow-9 and meow-20073,20077) and teow have been assigned to teow, because they were the only polygons assigned to teow 61318-"St. Peter and St. Paul rocks" and 60172-"Trindade-Martin Vaz Islands tropical forests".__
   +  To identify features not reaching ±180/90, EEOW only have been exploded to singlepart, then intersected with a multiline created at -0.5 arcsec (about 15 meters at equator) from extremes. This way:
   +  an unassigned stripe of 360dx15 Km has been flagged as real antarctic land (teow),
   +  few polygons (11 originally) have been manually split (20 polygons), then:
      *  the 14 parts adjoining TEOW and extremes have been assigned to the correspondent TEOW classes
      *  the other 6 parts have been left unchanged (EEOW).

The result of the above is included in the final geopackage as ecoregions_2019_raw spatial layer as undissolved, single part polygons, where for each of them is reported:
+  source (teow, meow, ppow, eeow)
+  eco_id (first_level_code)
+  notes:
   +  "originally teow/meow/ppow/eeow" = attribute unchanged
   +  "assigned to meow/ppow" = originally teow, assigned to meow/ppow
   +  "assigned to teow" = originally meow/ppow, assigned to teow (codes ppow-9 and meow-20073,20077; assigned to teow 61318-"St. Peter and St. Paul rocks" and 60172-"Trindade-Martin Vaz Islands tropical forests")
   +  "reassigned to teow" = originally eeow, assigned to adjacent teow classes (eg: antarctic land adjoining south pole), some with with manual split (14 parts crossing ±180)
   +  "reassigned to eeow" = originally eeow, split in the previous step.

Above object has been dissolved in ArcGIS PRO (returing the expected 1097 classes) then exploded as single part polygons. __NB: any correction to ecoregions should be applied to teow_meow_ppow_eeow_raw, then dissolve it again to get the final version.__

This version has been imported in PostGIS, then checked for geometry validity, fixed, finalized (single and multiparts) with the SQL script [ecoregions_2019](./ecoregions_2019.sql).
The same script contains also method to calculate statistics (source and ecoregions change), as discussed with Luca Battistella, available in xlsx [ecoregions_2019_statistics](./ecoregions_2019_statistics.xlsx).

The final version is exported as geopackage, wich includes:
+  ecoregions_2019 multipart
+  ecoregions_2019_raw (undissolved, single part polygons)
+  lookup_attribute_table (correspondence table within original fields and final attributes).



