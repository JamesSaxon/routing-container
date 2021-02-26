\pset format csv

SELECT c.idxa, c.idxb, a.* FROM pgr_dijkstra('

  SELECT
    gid id, source, target, 
    CASE WHEN cost         < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed_urban END AS cost,
    CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed_urban END AS reverse_cost
  FROM ways
  JOIN configuration ON 
    ways.tag_id = configuration.tag_id
  ',
  'SELECT source, target FROM combinations',
  FALSE
) a
JOIN combinations c ON
  start_vid = c.source AND end_vid = c.target 
JOIN ways w ON a.edge = w.gid
ORDER BY idxa, idxb, path_seq
\g './user_data/paths.csv'


