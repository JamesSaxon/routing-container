#!/bin/bash


if ! test -f /scripts/input/*osm ; then

  BUFFER=${BUFFER:-10000}
  coords=$(psql -U postgres -t -A -F"," -c "SELECT ST_YMin(g), ST_XMin(g), ST_YMax(g), ST(XMax(g) FROM (SELECT ST_Transform(ST_Buffer(ST_Transform(geometry, 2163), $BUFFER), 4326)) g FROM region);")

  wget 'http://overpass-api.de/api/interpreter?data=(way["highway"~"road|motorway|trunk|primary|secondary|tertiary|residential|living_street|unclassified|path|lane|cycleway|footway"]('${coords}');>;);out;' -O osm.osm

  # sed -i 's/\\//g' osm.osm
  mv osm.osm /scripts/input/osm.osm

fi

osm2pgrouting -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -f /scripts/input/*osm -c /scripts/input/mapconfig.xml --addnodes --clean --no-index


