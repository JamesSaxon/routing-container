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
      'id',         park, -- the GeoJson spec includes an 'id' field, but it is optional, replace {id} with your id field
      'geometry',   ST_AsGeoJSON(path)::json,
      'properties', json_build_object(
          -- list of fields
          'tract',  tract,
          'length', ST_Length(path)
      )
    )
  )
)
FROM (
  SELECT
    o.id tract, SUBSTR(d.id, 0, 5)::INT park, ST_LineMerge(ST_Union(w.the_geom)) path
    -- a.seq, a.cost, a.agg_cost, a.node, a.edge
  FROM pgr_dijkstra(
    'SELECT gid id, source, target, length_m AS cost
     FROM ways
     JOIN configuration ON configuration.tag_id = ways.tag_id
     WHERE configuration.tag_value NOT IN (''motorway'', ''motorway_junction'', ''motorway_link'', ''trunk'', ''trunk_link'')',
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 1 AND osm_nn IS NOT NULL),
    (SELECT array_agg(osm_nn) FROM locations WHERE dir != 0 AND osm_nn IS NOT NULL),
    FALSE
  ) a
  JOIN ways w ON a.edge = w.gid
  JOIN locations o ON start_vid = o.osm_nn
  JOIN locations d ON end_vid   = d.osm_nn
  GROUP BY tract, park
) q
\g '/scripts/output/paths.geojson'


