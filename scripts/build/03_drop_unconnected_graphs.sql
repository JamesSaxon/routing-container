ALTER TABLE ways_vertices_pgr
ADD COLUMN IF NOT EXISTS component bigint DEFAULT NULL;

ALTER TABLE ways
DROP CONSTRAINT ways_source_fkey,
DROP CONSTRAINT ways_target_fkey,
DROP CONSTRAINT ways_source_osm_fkey,
DROP CONSTRAINT ways_target_osm_fkey;

UPDATE ways_vertices_pgr a
SET component = b.component
FROM pgr_connectedComponents(
    'SELECT gid id, source, target, cost, reverse_cost FROM ways') b
WHERE a.id = b.node;

DELETE FROM ways_vertices_pgr 
WHERE component IN (
    SELECT component FROM (
        SELECT DISTINCT ON (component) component, COUNT(*)
        FROM ways_vertices_pgr
        GROUP BY component
        ORDER BY component, COUNT) AS m
    WHERE COUNT <= 10
);

WITH county_hull AS (
    SELECT ST_SetSRID(ST_ConvexHull(ST_Collect(point)), 4326) AS hull
    FROM locations
    WHERE dir = 2
)
DELETE FROM ways_vertices_pgr
WHERE component NOT IN (
    SELECT component FROM (
        SELECT DISTINCT ON (component) component, COUNT(*),
            ST_SetSRID(ST_ConvexHull(ST_Collect(the_geom)), 4326) AS pgr_hull
        FROM ways_vertices_pgr
        GROUP BY component) AS m
    WHERE ST_Intersects(pgr_hull, (SELECT hull FROM county_hull))
    AND COUNT >= 50
);

DELETE FROM ways a
WHERE NOT EXISTS (
    SELECT * FROM ways_vertices_pgr b
    WHERE a.source_osm = b.osm_id);

ALTER TABLE ways
ADD CONSTRAINT ways_source_fkey FOREIGN KEY (source)
REFERENCES ways_vertices_pgr (id);

ALTER TABLE ways
ADD CONSTRAINT ways_target_fkey FOREIGN KEY (target)
REFERENCES ways_vertices_pgr (id);

ALTER TABLE ways
ADD CONSTRAINT ways_source_osm_fkey FOREIGN KEY (source_osm)
REFERENCES ways_vertices_pgr (osm_id);

ALTER TABLE ways
ADD CONSTRAINT ways_target_osm_fkey FOREIGN KEY (target_osm)
REFERENCES ways_vertices_pgr (osm_id);
