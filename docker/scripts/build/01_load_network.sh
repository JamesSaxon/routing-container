#!/bin/bash


if [ -f /scripts/input/*osm ]; then

  sed -i 's/\\//g' /scripts/input/*osm
  osm2pgrouting -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -f /scripts/input/*osm

else

  BUFFER=${BUFFER:-0.01}
  coords=$(psql -U postgres -t -A -F"," -c "SELECT ROUND(MIN(y-$BUFFER)::numeric, 3) ymin, ROUND(MIN(x-$BUFFER)::numeric, 3) xmin, ROUND(MAX(y+$BUFFER)::numeric, 3) ymax, ROUND(MAX(x+$BUFFER)::numeric, 3) xmax FROM locations;")

  wget 'http://overpass-api.de/api/interpreter?data=(way["highway"~"road|motorway|trunk|primary|secondary|tertiary|residential|living_street|unclassified"]('${coords}');>;);out;' -O osm.osm

  sed -i 's/\\//g' /scripts/input/*osm
  osm2pgrouting -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -f osm.osm

fi

