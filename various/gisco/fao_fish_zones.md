20240410

Used GISCO restricted version FAO_FISH 2020
+  GISCO.FAO_FISH_RG_100K_2020.gpkg
+  GISCO.FAO__FISH_AT_2020.csv

The global geographic object is hierarchical at 5 levels (major, subarea, division, subdivision, subunit - this last undocumented), but is redundant (all the layers are present in the same object).
The target is to get a topology (single flat layer, where for each object all layers are present as attributes).
Hierarchical naming is used to join the nested levels one to another.

*Processing*
+  Imported in PostGIS
+  geometry fixed (27 geometries had ESRI flag)
+  attributes modified:
   +  f_code '21.5.Z.c' and '21.5.Z.u' are declared subunits (V level in the hierarchy) but code have been moved ='21.5.Z.e.c'
UPDATE fao_fish_dopa_attributes SET f_code='21.5.Z.e.u' WHERE f_code='21.5.Z.u';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c' WHERE f_code='27.3.b, c';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c.23' WHERE f_code='27.3.b.23';
UPDATE fao_fish_dopa_attributes SET f_code='27.3.b,c.22' WHERE f_code='27.3.c.22';
UPDATE fao_fish_dopa_attributes
SET f_code=SPLIT_PART(f_code,'.',1)||'.'||SPLIT_PART(f_code,'.',2)||'.'||(SPLIT_PART(f_code,'.',3)::double precision/10)::text
WHERE f_code IN ('34.1.11','34.1.12','34.1.13','34.1.31','34.1.32','34.3.11','34.3.12','34.3.13','87.1.11','87.1.12','87.1.13','87.1.14','87.1.15','87.1.21','87.1.22','87.1.23','87.1.24','87.1.25','87.2.11','87.2.12','87.2.13','87.2.14','87.2.15','87.2.16','87.2.17','87.2.21','87.2.22','87.2.23','87.2.24','87.2.25','87.2.26','87.2.27','87.3.11','87.3.12','87.3.13','87.3.21','87.3.22','87.3.23');
  

