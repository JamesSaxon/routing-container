#!/bin/bash


if ! test -f /scripts/input/*osm ; then

  BUFFER=${BUFFER:-0.01}
  coords=$(psql -U postgres -t -A -F"," -c "SELECT ROUND(MIN(y-$BUFFER)::numeric, 3) ymin, ROUND(MIN(x-$BUFFER)::numeric, 3) xmin, ROUND(MAX(y+$BUFFER)::numeric, 3) ymax, ROUND(MAX(x+$BUFFER)::numeric, 3) xmax FROM locations;")

  wget 'http://overpass-api.de/api/interpreter?data=(way["highway"~"road|motorway|trunk|primary|secondary|tertiary|residential|living_street|unclassified|path|lane|cycleway|footway"]('${coords}');>;);out;' -O osm.osm

  # sed -i 's/\\//g' osm.osm
  mv osm.osm /scripts/input/osm.osm


fi

osm2pgrouting -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -f /scripts/input/*osm -c /scripts/input/mapconfig.xml --addnodes --clean --no-index

