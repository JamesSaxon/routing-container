#!/bin/bash 

psql -U postgres -t -A -F"," -o /scripts/output/cost_matrix.csv -c "

  SELECT origins.id origin, destinations.id destination, agg_cost FROM pgr_dijkstraCost('
    	WITH
        w AS (
    	    SELECT ST_Buffer(ST_Envelope(ST_Union(point)), 0.025) u 
    	    FROM   locations),
        speeds AS (
          SELECT 
            tag_id,
            CASE WHEN rural THEN maxspeed_rural 
                            ELSE maxspeed_urban END maxspeed
          FROM configuration, geoid, rural
          WHERE rural.geoid = geoid.geoid ORDER BY tag_id)
    	SELECT
        gid id, source, target, 
        CASE WHEN cost         < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed END AS cost,
        CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed END AS reverse_cost
      FROM ways
      JOIN speeds ON 
        ways.tag_id = speeds.tag_id
      WHERE ST_Intersects(the_geom, (SELECT u FROM w))
    ', 
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 1),
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 0 AND osm_nn IS NOT NULL),
    FALSE
  ) 
  LEFT JOIN locations origins      ON start_vid = origins.osm_nn
  LEFT JOIN locations destinations ON end_vid   = destinations.osm_nn
  ORDER BY origin, destination
  ;

"

