ALTER TABLE locations ADD COLUMN osm_nn BIGINT;

DROP FUNCTION IF EXISTS DoKnnMatch;
CREATE FUNCTION DoKnnMatch(init_tol float8, max_tol float8, factor_tol float8)
RETURNS float8 AS $$
DECLARE
  tol float8;
  sql varchar;
BEGIN
  tol := init_tol;
  LOOP

    EXECUTE 'UPDATE locations SET osm_nn = vtx_id FROM (
               SELECT DISTINCT ON (loc.id)
                 loc.id, vtx.id vtx_id
               FROM
                 locations loc, ways_vertices_pgr vtx
               WHERE
                 osm_nn IS NULL AND 
                 ST_DWithin(point, the_geom, ' || tol || ')
               ORDER BY
                 id, point <-> the_geom
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

SELECT DoKnnMatch(0.001, 0.2, 2);

