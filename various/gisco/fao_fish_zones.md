20240410

Used GISCO restricted version FAO_FISH 2020
+  GISCO.FAO_FISH_RG_100K_2020.gpkg
+  GISCO.FAO__FISH_AT_2020.csv

The global geographic object is hierarchical at 5 levels (major, subarea, division, subdivision, subunit - this last undocumented), but is redundant (all the layers are present in the same object).
The target is to get a topology (single flat layer, where for each object all layers are present as attributes).
Hierarchical naming is used to join the nested levels one to another.

*Processing*
+  Imported in PostGIS and joined geoms+atts
+  geometry fixed (27 geometries had ESRI flag)
+  geometry with attribute X (overlapping division 47.1.1) is removed
+  attributes modified in both :
   +  f_code '21.5.Z.c' and '21.5.Z.u' are declared subunits (V level in the hierarchy) but code has only 4 elements. They are geographically interpreted as sub-elements of subdivision 21.5.Z.e, and renamed as ='21.5.Z.e.c','21.5.Z.e.u'
 
      | subdivision | old_subunit_code | new_subunit_code |
      |-------------|------------------|------------------|
      | 21.5.Z.e | 21.5.Z.c | 21.5.Z.e.c |
      | 21.5.Z.e | 21.5.Z.u | 21.5.Z.e.u |
   +  f_code='27.3.b, c' is renamed as '27.3.b,c';
   +  f_code='27.3.b.23' and '27.3.c.22' are geographically interpreted as sub-elements of division '27.3.b,c', and renamed as '27.3.b,c.22','27.3.b,c.23'
 
      | sdivision | old_subdivision_code | new_subdivision_code |
      |-------------|------------------|------------------|
      | 27.3.b,c | 27.3.b.23 | 27.3.b,c.23 |
      | 27.3.b,c | 27.3.c.22 | 27.3.b,c.22 |
   +  f_code: '34.1.11','34.1.12','34.1.13','34.1.31','34.1.32','34.3.11','34.3.12','34.3.13','87.1.11','87.1.12','87.1.13','87.1.14','87.1.15','87.1.21','87.1.22','87.1.23','87.1.24','87.1.25','87.2.11','87.2.12','87.2.13','87.2.14','87.2.15','87.2.16','87.2.17','87.2.21','87.2.22','87.2.23','87.2.24','87.2.25','87.2.26','87.2.27','87.3.11','87.3.12','87.3.13','87.3.21','87.3.22','87.3.23' are declared subdivisions (IV level) but code has only 3 elements (the french name is correct). The third level in the code is split, and the objects are nested in the higher level (eg: '34.1.11' becomes '34.1.1.1'; consequently the division '34.1.1' is created).
 
       | new_division_code | old_subdivision_code | new_subdivision_code |
       |---------------|----------------------|----------------------|
       | 34.1.1        | 34.1.11              | 34.1.1.1             |
       | 34.1.1        | 34.1.12              | 34.1.1.2             |
       | 34.1.1        | 34.1.13              | 34.1.1.3             |
       | 34.1.3        | 34.1.31              | 34.1.3.1             |
       | 34.1.3        | 34.1.32              | 34.1.3.2             |
       | 34.3.1        | 34.3.11              | 34.3.1.1             |
       | 34.3.1        | 34.3.12              | 34.3.1.2             |
       | 34.3.1        | 34.3.13              | 34.3.1.3             |
       | 87.1.1        | 87.1.11              | 87.1.1.1             |
       | 87.1.1        | 87.1.12              | 87.1.1.2             |
       | 87.1.1        | 87.1.13              | 87.1.1.3             |
       | 87.1.1        | 87.1.14              | 87.1.1.4             |
       | 87.1.1        | 87.1.15              | 87.1.1.5             |
       | 87.1.2        | 87.1.21              | 87.1.2.1             |
       | 87.1.2        | 87.1.22              | 87.1.2.2             |
       | 87.1.2        | 87.1.23              | 87.1.2.3             |
       | 87.1.2        | 87.1.24              | 87.1.2.4             |
       | 87.1.2        | 87.1.25              | 87.1.2.5             |
       | 87.2.1        | 87.2.11              | 87.2.1.1             |
       | 87.2.1        | 87.2.12              | 87.2.1.2             |
       | 87.2.1        | 87.2.13              | 87.2.1.3             |
       | 87.2.1        | 87.2.14              | 87.2.1.4             |
       | 87.2.1        | 87.2.15              | 87.2.1.5             |
       | 87.2.1        | 87.2.16              | 87.2.1.6             |
       | 87.2.1        | 87.2.17              | 87.2.1.7             |
       | 87.2.2        | 87.2.21              | 87.2.2.1             |
       | 87.2.2        | 87.2.22              | 87.2.2.2             |
       | 87.2.2        | 87.2.23              | 87.2.2.3             |
       | 87.2.2        | 87.2.24              | 87.2.2.4             |
       | 87.2.2        | 87.2.25              | 87.2.2.5             |
       | 87.2.2        | 87.2.26              | 87.2.2.6             |
       | 87.2.2        | 87.2.27              | 87.2.2.7             |
       | 87.3.1        | 87.3.11              | 87.3.1.1             |
       | 87.3.1        | 87.3.12              | 87.3.1.2             |
       | 87.3.1        | 87.3.13              | 87.3.1.3             |
       | 87.3.2        | 87.3.21              | 87.3.2.1             |
       | 87.3.2        | 87.3.22              | 87.3.2.2             |
       | 87.3.2        | 87.3.23              | 87.3.2.3             |

[dopa_gisco_fao_fish.csv](./dopa_gisco_fao_fish.csv)

[dopa_gisco_fao_fish.sql](./dopa_gisco_fao_fish.sql)

