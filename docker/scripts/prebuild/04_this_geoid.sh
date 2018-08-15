#!/bin/bash 

psql -U postgres -c "
  CREATE TABLE geoid (geoid INTEGER);
  INSERT INTO geoid VALUES ($GEOID);
"

