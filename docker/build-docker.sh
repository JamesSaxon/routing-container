#!/bin/bash

docker build -t routing .
$(aws ecr get-login --no-include-email --region us-east-1)
docker tag routing:latest 808035620362.dkr.ecr.us-east-1.amazonaws.com/routing:latest
docker push 808035620362.dkr.ecr.us-east-1.amazonaws.com/routing:latest

