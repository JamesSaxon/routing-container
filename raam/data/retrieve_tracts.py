#!/usr/bin/env python 

import os    

import geopandas as gpd

from fiona.crs import from_epsg

import psycopg2
from netrc import netrc
user, acct, passwd = netrc().authenticators("harris")

con = psycopg2.connect(database = "census", user = user, password = passwd,
                       host = "saxon.harris.uchicago.edu", port = 5432)

query = """
SELECT state::bigint * 1000000000 + county * 1000000 + tract geoid, 
       ST_Transform(geom, 3528) geometry
FROM   census_tracts_2010
WHERE  state IN (17, 18, 19, 26, 27, 29, 55);"""
#        ST_DWithin(ST_Transform(geom, 3528),
#                   ST_Transform(ST_SetSRID(ST_MakePoint(-87.6298, 41.8781), 4326), 3528),
#                   150000);"""

gdf = gpd.GeoDataFrame.from_postgis(query, con, geom_col='geometry', crs = from_epsg(3528))
gdf.geoid = gdf.geoid.astype(str)

try: os.remove("tracts.geojson")
except OSError: pass

gdf.to_file("tracts.geojson", driver = "GeoJSON")


