DROP TABLE IF EXISTS locations;

CREATE TABLE locations (id TEXT PRIMARY KEY, x FLOAT8, y FLOAT8, dir SMALLINT);
\copy locations FROM 'scripts/input/locations.csv' CSV;

SELECT AddGeometryColumn('locations', 'point', 4326, 'POINT', 2);
UPDATE locations SET point = ST_SetSRID(ST_MakePoint(x, y), 4326);

ALTER TABLE locations ADD COLUMN osm_nn    BIGINT;
ALTER TABLE locations ADD COLUMN snap_dist FLOAT;

SELECT DoKnnMatch(0.0005, 0.2, 2);

