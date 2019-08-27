ALTER TABLE locations ADD COLUMN osm_nn    BIGINT;
ALTER TABLE locations ADD COLUMN snap_dist FLOAT;

ALTER TABLE ways_vertices_pgr ADD COLUMN hway BOOLEAN DEFAULT(FALSE);

UPDATE ways_vertices_pgr
SET hway = TRUE
FROM ways 
JOIN configuration ON 
  configuration.tag_id = ways.tag_id
WHERE
  (ways.source_osm = ways_vertices_pgr.osm_id OR
   ways.target_osm = ways_vertices_pgr.osm_id) AND
  configuration.tag_value IN ('motorway', 'motorway_junction', 'motorway_link', 'trunk', 'trunk_link')
;

DROP FUNCTION IF EXISTS DoKnnMatch;
CREATE FUNCTION DoKnnMatch(init_tol float8, max_tol float8, factor_tol float8)
RETURNS float8 AS $$
DECLARE
  tol float8;
  sql varchar;
BEGIN
  tol := init_tol;
  LOOP

    EXECUTE 'UPDATE locations 
             SET osm_nn = vtx_id,
                 snap_dist = vtx_dist
             FROM (
               SELECT DISTINCT ON (loc.id)
                 loc.id, vtx.id vtx_id,
		             ST_Distance(point::geography, vtx.the_geom::geography) vtx_dist
               FROM
                 locations loc, ways_vertices_pgr vtx
	             WHERE 
                 NOT vtx.hway AND osm_nn IS NULL AND 
                 ST_DWithin(point, vtx.the_geom, ' || tol || ')
               ORDER BY
                 id, ST_Distance(point::geography, vtx.the_geom::geography)
             ) knn WHERE locations.id = knn.id;
             ';

    IF tol < max_tol AND EXISTS (SELECT id FROM locations WHERE osm_nn IS NULL) THEN
      tol := tol * factor_tol;
      RAISE NOTICE 'TOLERANCE NOW % and % remain', tol, (SELECT count(*) FROM locations WHERE osm_nn IS NULL);
    ELSE 
      RETURN tol;
    END IF;

  END LOOP;
END
$$ LANGUAGE 'plpgsql' STRICT;

SELECT DoKnnMatch(0.0005, 0.2, 2);

