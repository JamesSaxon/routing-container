#!/bin/bash

states="17 18 55"

mkdir tb2015

# shp2pgsql -I -s 4269:4326 -p -n -W "latin1" tl_2015_01_tabblock10.shp public.block15

psql -d network -U jsaxon << EOD
  -- Shapefile type: Polygon
  -- Postgis type: MULTIPOLYGON[2]
  SET CLIENT_ENCODING TO UTF8;
  SET STANDARD_CONFORMING_STRINGS TO ON;
  BEGIN;

  DROP TABLE IF EXISTS block15;
  CREATE TABLE "public"."block15" (gid serial,
      "statefp10" smallint,
      "countyfp10" smallint,
      "tractce10" integer,
      "blockce10" smallint,
      "geoid10" varchar(15),
      "name10" varchar(10),
      "mtfcc10" varchar(5),
      "ur10" varchar(1),
      "uace10" varchar(5),
      "uatype" varchar(1),
      "funcstat10" varchar(1),
      "aland10" float8,
      "awater10" float8,
      "intptlat10" float8,
      "intptlon10" float8);

  COMMIT;

EOD

cd tb2015
for fips in $states; do 
  # wget https://www2.census.gov/geo/tiger/TIGER2015/TABBLOCK/tl_2015_${fips}_tabblock10.zip
  # unzip tl_2015_${fips}_tabblock10.zip

  shp2pgsql -I -s 4269:4326 -a -n -W "latin1" tl_2015_${fips}_tabblock10.shp public.block15 | psql -d network -U jsaxon
done
cd -


psql -d network -U jsaxon << EOD

  ALTER TABLE block15 RENAME COLUMN statefp10  TO state;
  ALTER TABLE block15 RENAME COLUMN countyfp10 TO county;
  ALTER TABLE block15 RENAME COLUMN tractce10  TO tract;
  ALTER TABLE block15 RENAME COLUMN blockce10  TO block;
  ALTER TABLE block15 DROP COLUMN gid,
                      DROP COLUMN name10,
                      DROP COLUMN mtfcc10,
                      DROP COLUMN ur10,
                      DROP COLUMN uace10,
                      DROP COLUMN funcstat10;
  ALTER TABLE block15 RENAME COLUMN aland10  TO area;
  ALTER TABLE block15 RENAME COLUMN awater10 TO awater;
  ALTER TABLE block15 ADD PRIMARY KEY (state, county, tract, block);

  SELECT AddGeometryColumn('public','block15','geom','4326','POINT',2);
  UPDATE block15 SET geom = ST_Transform(ST_SetSRID(ST_Point(intptlon10, intptlat10), 4269), 4326);
  ALTER TABLE block15 DROP COLUMN intptlon10, DROP COLUMN intptlat10;
  CREATE INDEX ON "public"."block15" USING GIST ("geom");
  ANALYZE "public"."block15";

EOD


