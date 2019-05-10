DROP TABLE IF EXISTS park_routing;
CREATE TABLE park_routing (geoid BIGINT, park INT, m INT);

DO $$DECLARE r record;
BEGIN
 FOR r IN 
   SELECT DISTINCT SUBSTR(id, 0, 12) tract FROM locations
	 WHERE dir = 0 -- AND SUBSTR(id, 0, 12) IN ('17031410900', '17031410100', '17031400300')
   ORDER BY tract
 LOOP
  BEGIN
    RAISE NOTICE 'chicago tract = %', r.tract;
    INSERT INTO park_routing(geoid, park, m)

			WITH buff AS (
			  SELECT 
			    ST_Transform(ST_Buffer(ST_Union(ST_Transform(point, 3528)), 5e3), 4326) u
			  FROM locations
			  WHERE SUBSTR(ID, 0, 12) = r.tract
			)
			SELECT 
			  origins.id::BIGINT block, 
			  SUBSTR(destinations.id, 0, 5)::INT park, 
			  MIN(agg_cost)::INT m
			FROM pgr_dijkstraCost('
			    SELECT
			      gid id, source, target, 
			      CASE WHEN cost         < 0 THEN 1e8 ELSE length_m END AS cost,
			      CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m END AS reverse_cost
			    FROM ways
			  ', 
			  (SELECT array_agg(osm_nn) FROM locations 
			   WHERE 
			     SUBSTR(ID, 0, 12) = r.tract AND 
			     dir != 1 AND osm_nn IS NOT NULL),
			  (SELECT array_agg(osm_nn) FROM locations, buff
			   WHERE ST_Within(point, buff.u) AND
			         dir != 0 AND osm_nn IS NOT NULL),
			  FALSE
			) 
			LEFT JOIN locations origins      ON start_vid = origins.osm_nn
			LEFT JOIN locations destinations ON end_vid   = destinations.osm_nn
			WHERE
			  SUBSTR(origins.id, 0, 12) = r.tract AND
			  destinations.dir != 0
			GROUP BY block, park
			HAVING MIN(agg_cost)::INT < 5e3
			ORDER BY block, m ASC
			;

  EXCEPTION
    WHEN OTHERS THEN
     RAISE WARNING 'Loading of % failed: %', r.tract, SQLERRM;
  END;
 END LOOP;
END$$;

\copy park_routing TO '/scripts/output/cost_matrix.csv' DELIMITER ',' CSV HEADER;

