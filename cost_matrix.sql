DROP TABLE IF EXISTS times;
CREATE TABLE times AS
SELECT origins.geoid origin, destinations.geoid destination, agg_cost FROM pgr_dijkstraCost('
    WITH w AS (
        SELECT ST_Buffer(ST_Envelope(ST_Union(centroid)), 0.025) u 
        FROM   tracts15
        WHERE  osm_nn IS NOT NULL
      )
    SELECT
      gid id, source, target, 
      CASE WHEN cost         < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / default_maxspeed END AS cost,
      CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / default_maxspeed END AS reverse_cost
    FROM ways
    JOIN osm_way_classes ON 
      ways.class_id = osm_way_classes.class_id
    WHERE ST_Intersects(the_geom, (SELECT u FROM w))
  ', 
  (SELECT array_agg(osm_nn) A 
   FROM tracts15
   WHERE osm_nn IS NOT NULL 
   AND state = 17 AND county = 31),
  (SELECT array_agg(osm_nn) 
   FROM tracts15
   WHERE osm_nn IS NOT NULL 
   AND ST_DWithin(ST_Transform(centroid, 3528),
                  ST_Transform(ST_SetSRID(ST_MakePoint(-87.60, 41.79),4326), 3528),
                  50000)
  ),
  FALSE
) 
JOIN tracts15 origins      ON start_vid = origins.osm_nn
JOIN tracts15 destinations ON end_vid   = destinations.osm_nn
ORDER BY origin, destination
;
