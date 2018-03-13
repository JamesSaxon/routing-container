ALTER TABLE block15 ADD COLUMN nid BIGINT;
UPDATE block15 SET
  nid = id
FROM (
  SELECT DISTINCT ON (state, county, tract, block)
    state, county, tract, block, id
  FROM
    block15, ways_vertices_pgr
  WHERE
    nid IS NULL AND 
    state = 17 AND county = 31 AND
    ST_DWithin(geom, the_geom, 0.01)
  ORDER BY
    state, county, tract, block, ST_Distance(geom, the_geom)
) AS osm_nn WHERE
  block15.state  = osm_nn.state  AND 
  block15.county = osm_nn.county AND 
  block15.tract  = osm_nn.tract  AND 
  block15.block  = osm_nn.block
;


