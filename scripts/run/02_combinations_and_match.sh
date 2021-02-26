#!/bin/bash 

if test -f ./user_data/combinations.csv ; then

echo loading combinations knn matches.

psql -U postgres -d postgres -p 5432 -h localhost <<EOSQL

DROP TABLE IF EXISTS combinations;
CREATE TABLE combinations (idxA TEXT, idxB TEXT);
\\copy combinations FROM './user_data/combinations.csv' CSV;

ALTER TABLE combinations ADD COLUMN source BIGINT;
ALTER TABLE combinations ADD COLUMN target BIGINT;

UPDATE combinations comb
SET    source = la.osm_nn, target = lb.osm_nn 
FROM   locations la, locations lb
WHERE  comb.idxa = la.id AND comb.idxb = lb.id;

EOSQL

fi


