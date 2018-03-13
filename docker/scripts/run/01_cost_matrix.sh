#!/bin/bash 

psql -U postgres -t -A -F"," -o /scripts/output/cost_matrix.csv -c "

  SELECT * FROM pgr_dijkstraCost('
    	WITH
    	  w AS (
    	    SELECT
    	      ST_Buffer(ST_Union(geom), 0.025) u
    	    FROM
    	      tracts15
    	    WHERE
            state = 17 AND county = 31 AND 
            centroid && ST_MakeEnvelope(-87.77,41.64,-87.52,42.02)
    	  )
    	SELECT
        gid id, source, target, cost,
        CASE WHEN reverse_cost < 0 THEN 1e8 ELSE cost END AS reverse_cost
      FROM ways
    ', 
    ARRAY[279414,249882,255143,260893,162050,86800,169436,195790,170848,281651,259762,244585,235517,220548,254188,247142,
          57263,94408,82268,49867,78861,29371,38786,1962,20267,21228,62613,46470,69373,76452,74036,32630,32787,7916,20528,
          210712,146056,162420,144299,148183,155159,163938,233653,145376,261969,234775,264814,237280,267199,211939]::BIGINT[],
    (SELECT array_agg(nid)
     FROM block15 
     WHERE 
       state = 17 AND county = 31 AND 
       geom && ST_MakeEnvelope(-87.77,41.64,-87.52,42.02)
    ), FALSE
  );

"

