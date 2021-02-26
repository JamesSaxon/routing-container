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
		             -- ST_Distance(point::geography, vtx.the_geom::geography) vtx_dist
                 point <-> vtx.the_geom AS vtx_dist
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

