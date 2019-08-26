#!/bin/bash

cities="new_york los_angeles chicago houston phoenix philadelphia san_antonio san_diego dallas san_jose austin jacksonville san_francisco columbus fort_worth indianapolis charlotte seattle denver washington"

for c in $cities; do 

  if [[ -f cities/${c}.osm ]]; then
    cp cities/${c}.osm scripts/input/osm.osm;
  fi

  cp cities/${c}_park_points.csv scripts/input/locations.csv

  docker run --rm -i --name routing-instance \
             -v $(pwd)/scripts/:/scripts \
             -e POSTGRES_PASSWORD=mysecretpassword route postgres 

  if [[ -f scripts/input/osm.osm && ! -f cities/${c}.osm ]]; then
    mv scripts/input/osm.osm cities/${c}.osm;
  fi

  mv scripts/output/cost_matrix.csv cities/${c}_costs.csv

done 

