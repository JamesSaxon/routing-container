#!/bin/bash 

if test -f scripts/input/combinations.csv ; then

echo loading combinations file.

psql -U postgres --dbname="$POSTGRES_DB" <<EOSQL
CREATE TABLE combinations (idxA TEXT, idxB TEXT);
\\copy combinations FROM 'scripts/input/combinations.csv' CSV;
EOSQL

fi

