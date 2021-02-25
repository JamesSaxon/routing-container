CREATE TABLE region ();
SELECT AddGeometryColumn('region', 'geometry', 4326, 'MULTIPOLYGON', 2);

-- ogr2ogr/postgres versions are being obnoxious, so....
CREATE TEMP TABLE json_data (data jsonb);
COPY json_data FROM '/scripts/input/region.geojson';

INSERT INTO region 
SELECT ST_GeomFromGeoJSON(row ->> 'geometry') g
FROM (
  SELECT json_array_elements((data ->> 'features')::json) AS row 
  FROM json_data
) as h;

