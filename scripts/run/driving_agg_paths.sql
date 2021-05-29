\t on
\pset format unaligned

SELECT json_build_object(
  'type', 'FeatureCollection',
  'crs',  json_build_object(
    'type',      'name', 
    'properties', json_build_object(
        'name', 'urn:ogc:def:crs:OGC:1.3:CRS84' -- 4326: https://gist.github.com/sgillies/1233327#file-geojson-spec-1-0-L256
    )
  ), 
  'features', json_agg(
    json_build_object(
      'type',       'Feature',
      'id',         osm_id, -- the GeoJson spec includes an 'id' field, but it is optional, replace {id} with your id field
      'geometry',   ST_AsGeoJSON(ST_Transform(path, 4326))::json,
      'properties', json_build_object(
          -- list of fields
          'osm_id',   osm_id,
          'length', ST_Length(ST_Transform(path, 3528)),
          'n', n
      )
    )
  )
) 
FROM (
  SELECT w.osm_id, COUNT(*) n, w.the_geom path
  FROM pgr_dijkstra('
  
    SELECT
      gid id, source, target, 
      CASE WHEN cost         < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed_urban END AS cost,
      CASE WHEN reverse_cost < 0 THEN 1e8 ELSE length_m * 6.2e-4 * 60 / maxspeed_urban END AS reverse_cost
    FROM ways
    JOIN configuration ON 
      ways.tag_id = configuration.tag_id
    ',
    'SELECT source, target FROM combinations WHERE source IS NOT NULL AND target IS NOT NULL',
    FALSE
  ) a
  JOIN combinations c ON
    start_vid = c.source AND end_vid = c.target 
  JOIN ways w ON a.edge = w.gid
  GROUP BY w.the_geom, w.osm_id
) q
\g './user_data/paths.geojson'





