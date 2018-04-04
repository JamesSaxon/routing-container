#!/bin/bash

createdb network -O jsaxon -D brobspace

sudo -u postgres psql network -c "CREATE EXTENSION postgis; CREATE EXTENSION pgrouting; CREATE EXTENSION postgis_topology;"

# Covering the LiveRamp area, all the way to Wisconsin.
wget 'http://overpass-api.de/api/interpreter?data=(way["highway"]["highway"!~"pedestrian|footway|steps|path"]["service"!~"parking_aisle|driveway"](41.57,-88.29,42.49,-87.30);>;);out;' -O chicago.osm

osm2pgrouting -U jsaxon -d network --f chicago.osm --password MYPASSWD

# OR --- then you also have to do pgr_createTopology();
# osm2pgsql -s -U jsaxon -d network -c hp.osm
