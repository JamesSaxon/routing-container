\t on
\pset format unaligned

SELECT json_build_object(
  'type', 'FeatureCollection',
  'crs',  json_build_object(
    'type',      'name', 
    'properties', json_build_object(
        'name', 'EPSG:4326'  
    )
  ), 
  'features', json_agg(
    json_build_object(
      'type',       'Feature',
      'id',         idxa, -- the GeoJson spec includes an 'id' field, but it is optional, replace {id} with your id field
      'geometry',   ST_AsGeoJSON(path)::json,
      'properties', json_build_object(
          -- list of fields
          'idxa',   idxa,
          'idxb',   idxb,
          'length', ST_Length(path)
      )
    )
  )
) 
FROM (
  SELECT idxa, idxb, ST_LineMerge(ST_Union(w.the_geom)) path
  FROM pgr_dijkstra('
  
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
  GROUP BY idxa, idxb
  ORDER BY idxa, idxb
    
) q
\g '/scripts/output/paths.geojson'





