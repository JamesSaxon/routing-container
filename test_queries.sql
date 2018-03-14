-- Select a set of Census tracts or a region, and a buffer around it.
-- In this case, it's a 1km buffer around Hyde Park.
WITH 
  w AS (
    SELECT
			ST_Buffer(ST_Union(geom), 0.01) u 
    FROM 
      tracts15
    WHERE
      state = 17 AND county = 31 AND
      tract IN (410500, 410600, 410700, 410800, 410900, 411000, 411100, 411200, 836200)
  )
SELECT the_geom
FROM ways
WHERE ST_Intersects(the_geom, (SELECT u FROM w)); 

-- Select all census tracts from Cook County, as a test set.
SELECT
  tract id,
  ST_X(ST_Transform(centroid, 4326)) x,
  ST_Y(ST_Transform(centroid, 4326)) y,
  2 dir
FROM census_tracts_2015
WHERE
  state = 17 AND county = 31 AND
  tract IN (410500, 410600, 410700, 410800, 410900, 411000, 411100, 411200, 836200);

-- Select all of the blocks in this region, coded to their osm_id.
-- So basically -- shortest paths.
SELECT
  DISTINCT ON (state, county, tract, block) 
  state, county, tract, block, id, osm_id, ST_MakeLine(geom, the_geom)
FROM 
  block15, ways_vertices_pgr
WHERE
  state = 17 AND county = 31 AND
  tract IN (410500, 410600, 410700, 410800, 410900, 411000, 411100, 411200, 836200) AND
  ST_DWithin(geom, the_geom, 0.01)
ORDER BY
  state, county, tract, block,
  geom <-> the_geom
;


SELECT * FROM pgr_dijkstra('SELECT gid id, source, target, cost,
                            CASE WHEN reverse_cost < 0 THEN 1e8 ELSE ST_Length(the_geom) END AS reverse_cost
                            FROM ways', 1, 2, FALSE);

SELECT * FROM pgr_dijkstra('SELECT gid id, source, target, cost FROM ways', 1, ARRAY[2, 3], FALSE);

SELECT * FROM pgr_dijkstraCost('SELECT gid id, source, target, cost FROM ways', 1, 2);

SELECT * FROM pgr_dijkstraCostMatrix(
  'SELECT gid id, source, target, cost FROM ways', 
  (SELECT array_agg(gid) FROM ways WHERE gid < 50)
);

-- For testing.
SELECT                              
  a.seq, the_geom path, 
  a.cost, a.agg_cost, a.node, a.edge, b.name
FROM pgr_dijkstra(
  'SELECT gid id, source, target, ST_Length(the_geom) AS cost,
 CASE WHEN reverse_cost < 0 THEN 1e8 ELSE ST_Length(the_geom) END AS reverse_cost FROM ways',
  42608, 32016, True
) a JOIN ways b ON 
  a.edge = b.gid;


