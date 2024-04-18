#!/bin/bash
# renamer1.sh
for file in *.json
do
  mv -- "$file" "${file//./_}"
done
wait
echo "renaming done"

# renamer2.sh
for file in *
do
  mv -- "$file" "${file//_json/.json}"
done
wait
echo "extension added"

# import.sh
# NOTE : Quote it else use array to avoid problems #
export OGR_GEOJSON_MAX_OBJ_SIZE=1000MB
echo "$OGR_GEOJSON_MAX_OBJ_SIZE"
for f in *.json

do
  echo "Processing $f file..."
  n1="${f%%.*}"
  n="${n1,,}"
  echo "table name is $n"
  ogr2ogr -f "PostgreSQL" PG:"host=localhost dbname=wolfe user=h05ibex" $f -lco SCHEMA=iucn_get_last -nln "$n" -progress &
done &
wait
echo "all files imported"



