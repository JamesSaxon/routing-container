#!/bin/bash

for geoid in $(psql census -t -A -c "SELECT geoid FROM counties_2010 WHERE state < 57 ORDER BY state, county;"); do

  aws batch submit-job \
      --job-name routing-${geoid}-02b --job-queue routing-queue \
      --job-definition arn:aws:batch:us-east-1:808035620362:job-definition/routing-def:5 \
      --container-overrides '{"command": ["postgres"], "environment" : [{"name" : "GEOID", "value" : "'${geoid}'"}]}'

done


for geoid in 09013 09015 25005 25009 25011 25013 25015 25017 25021 25023 25025 25027 33005 33011 44003 44007 06037; do

  aws batch submit-job \
      --job-name routing-${geoid}-02b --job-queue routing-queue-large \
      --job-definition arn:aws:batch:us-east-1:808035620362:job-definition/routing-def:7 \
      --container-overrides '{"command": ["postgres"], "environment" : [{"name" : "GEOID", "value" : "'${geoid}'"}]}'

done 

