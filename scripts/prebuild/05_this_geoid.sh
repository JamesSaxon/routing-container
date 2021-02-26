#!/bin/bash 

if [ ! -v $GEOID ]; then

  psql -U $POSTGRES_USER -c "
    CREATE TABLE geoid (geoid INTEGER);
    INSERT INTO geoid VALUES ($GEOID);
  "

fi

