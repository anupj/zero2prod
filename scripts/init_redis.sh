#!/usr/bin/env bash

# Enable debugging
# i.e. print all executed commands to 
# the terminal
set -x

# exit immediately upon error
# and return code will be used 
# as the return code of the whole pipeline
set -eo pipefail

# if a redis container is running, print 
# instructions to kill it and exit
RUNNING_CONTAINER=$(docker ps --filter 'name=redis' --format '{{.ID}}')
if [[ -n $RUNNING_CONTAINER ]]; then
  echo >&2 "there is a redis container already running, kill it with"
  echo >&2 "docker kill ${RUNNING_CONTAINER}"
  exit 1
fi

# Launch Redis using Docker
docker run \
  -p "6379:6379" \
  -d \
  --name "redis_$(date '+%s')" \
  redis:6

>&2 echo "Redis is ready to go!"
