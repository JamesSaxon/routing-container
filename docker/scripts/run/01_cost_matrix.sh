#!/bin/bash 

BUFFER=0.025

psql -U postgres -t -A -F"," -o /scripts/output/cost_matrix.csv -c "

  SELECT origins.id origin, destinations.id destination, agg_cost FROM pgr_dijkstraCost('
    	WITH w AS (
    	    SELECT ST_Buffer(ST_Envelope(ST_Union(point)), 0.025) u 
    	    FROM   locations
    	  )
    	SELECT
        gid id, source, target, 
        CASE WHEN cost         < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed END AS cost,
        CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed END AS reverse_cost
      FROM ways
      JOIN configuration ON 
        ways.tag_id = configuration.tag_id
      WHERE ST_Intersects(the_geom, (SELECT u FROM w))
    ', 
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 1),
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 0),
    FALSE
  ) 
  RIGHT OUTER JOIN locations origins      ON start_vid = origins.osm_nn
  RIGHT OUTER JOIN locations destinations ON end_vid   = destinations.osm_nn
  ORDER BY origin, destination
  ;

"

