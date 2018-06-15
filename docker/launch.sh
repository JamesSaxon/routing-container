#!/bin/bash

geoid=17031
aws batch submit-job --job-name routing-01 --job-queue routing-optimal-express \
                     --job-definition arn:aws:batch:us-east-1:808035620362:job-definition/routing-def \
                     --container-overrides '{"command": ["postgres"], "environment" : [{"name" : "GEOID", "value" : "'${geoid}'"}]}'


