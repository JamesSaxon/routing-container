#!/bin/bash

mkdir tmp
cd tmp
# wget ftp://ftp2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_17_tract_500k.zip 
# wget ftp://ftp2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_18_tract_500k.zip 
# wget ftp://ftp2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_55_tract_500k.zip 
# mv ftp2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_* .
# for x in `ls *zip`; do unzip $x; done


psql -d network -U jsaxon << EOD
  -- Shapefile type: Polygon
  -- Postgis type: MULTIPOLYGON[2]
  SET CLIENT_ENCODING TO UTF8;
  SET STANDARD_CONFORMING_STRINGS TO ON;
  BEGIN;

  DROP TABLE IF EXISTS tracts15;
  CREATE TABLE "public"."tracts15" (gid serial,
      "statefp" smallint,
      "countyfp" smallint,
      "tractce" int,
      "affgeoid" varchar(20),
      "geoid" bigint,
      "name" varchar(100),
      "lsad" varchar(2),
      "aland" float8,
      "awater" float8);
  SELECT AddGeometryColumn('public','tracts15','geom','4326','MULTIPOLYGON',2);
  COMMIT;
EOD


### shp2pgsql -I -s 4269:4326 -p -W "latin1" cb_2015_23_tract_500k public.tracts15

for x in $(ls cb_2015_*shp | sed "s/.shp//"); do 
  echo $x
  shp2pgsql -I -s 4269:4326 -a -W "latin1" $x public.tracts15 | grep -v "GIST\|ANALYZE" | psql -d network -U jsaxon
done

psql -d network -U jsaxon << EOD

  ALTER TABLE tracts15 DROP COLUMN gid,
                       DROP COLUMN affgeoid,
                       DROP COLUMN name,
                       DROP COLUMN lsad,
                       DROP COLUMN aland,
                       DROP COLUMN awater;

  ALTER TABLE tracts15 RENAME COLUMN statefp  TO state;
  ALTER TABLE tracts15 RENAME COLUMN countyfp TO county;
  ALTER TABLE tracts15 RENAME COLUMN tractce  TO tract;

  ALTER TABLE tracts15 ADD PRIMARY KEY (geoid);
  CREATE INDEX sct_idx ON tracts15 (state, county, tract);
  
  SELECT AddGeometryColumn('public','tracts15','centroid','4326','POINT',2);
  UPDATE tracts15 SET centroid = ST_Centroid(geom);

  ALTER TABLE tracts15 ADD COLUMN area float;
  UPDATE tracts15 SET area = ST_Area(geom);

  CREATE INDEX ON "public"."tracts15" USING GIST ("geom");

  ANALYZE "public"."tracts15";

EOD

cd ../

## rm -rf tmp


