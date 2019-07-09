DROP TABLE IF EXISTS park_routing;
CREATE TABLE park_routing (tract BIGINT, park INT, eucl_m INT, routing_m INT, total_m INT);

DO $$DECLARE r record;
BEGIN
 FOR r IN 
   SELECT DISTINCT id tract, point
   FROM locations
	 WHERE dir = 0 
   ORDER BY tract
   -- LIMIT 3
 LOOP
  BEGIN
    RAISE NOTICE 'tract = %', r.tract;

    INSERT INTO park_routing(tract, park, eucl_m, routing_m, total_m)
		SELECT 
                  origins.id::BIGINT tract, 
                  SUBSTR(destinations.id, 0, 5)::INT park, 
                  MIN(ST_Distance(origins.point::geography, destinations.point::geography))::INT eucl_m,
                  MIN(agg_cost)::INT routing_m, 
                  MIN(agg_cost + origins.snap_dist + destinations.snap_dist)::INT total_m
		FROM pgr_dijkstraCost(
      'SELECT gid id, source, target, length_m AS cost
       FROM ways
       JOIN configuration ON configuration.tag_id = ways.tag_id
       WHERE configuration.tag_value NOT IN (''motorway'', ''motorway_junction'', ''motorway_link'', ''trunk'', ''trunk_link'')', 
      (SELECT array_agg(osm_nn) FROM locations 
       WHERE id = r.tract AND dir != 1 AND osm_nn IS NOT NULL),
      (SELECT array_agg(osm_nn) FROM locations
       WHERE ST_DWithin(point::geography, r.point::geography, 5e3, TRUE) AND 
             dir != 0 AND osm_nn IS NOT NULL),
      FALSE
		) 
		LEFT JOIN locations origins      ON start_vid = origins.osm_nn
		LEFT JOIN locations destinations ON end_vid   = destinations.osm_nn
		WHERE origins.id = r.tract AND destinations.dir != 0
		GROUP BY tract, park
		HAVING MIN(agg_cost + origins.snap_dist + destinations.snap_dist) < 5e3
		ORDER BY tract, total_m ASC
		;

  EXCEPTION
    WHEN OTHERS THEN
     RAISE WARNING 'Loading of % failed: %', r.tract, SQLERRM;
  END;
 END LOOP;
END$$;

\copy park_routing TO '/scripts/output/cost_matrix.csv' DELIMITER ',' CSV HEADER;

