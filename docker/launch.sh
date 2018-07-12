#!/bin/bash

# for geoid in 42101 17031; do
# for geoid in 42101 17031 17093 17089 17043 17111 17097 17197; do
# for geoid in 46113; do 
# for geoid in 06031 06033 06035 06039 06043 06049 06051 06055 06063 06065 06067 06069 06071 06075 06077 06079 06081 06087 06089 06091 06095 06097 06099 06101 06103 06105 06107 06109 06111 06113 06115 36001 36003 36005 36007 36009 36011 36015 36017 36019 36023 36027 36031 36035 36037 36039 36043 36045 36049 36051 36053 36057 36059; do 
for geoid in $(psql census -t -A -c "select geoid from counties_2010 where state IN (54) and state < 57 order by state, county;"); do

  aws batch submit-job \
      --job-name routing-${geoid}-02b --job-queue routing-queue \
      --job-definition arn:aws:batch:us-east-1:808035620362:job-definition/routing-def:5 \
      --container-overrides '{"command": ["postgres"], "environment" : [{"name" : "GEOID", "value" : "'${geoid}'"}]}'

done


# for geoid in 09013 09015 25005 25009 25011 25013 25015 25017 25021 25023 25025 25027 33005 33011 44003 44007 06037; do
# for geoid in 25025; do
# 
#   aws batch submit-job \
#       --job-name routing-${geoid}-02b --job-queue routing-queue-large \
#       --job-definition arn:aws:batch:us-east-1:808035620362:job-definition/routing-def:7 \
#       --container-overrides '{"command": ["postgres"], "environment" : [{"name" : "GEOID", "value" : "'${geoid}'"}]}'
# 
# done 

