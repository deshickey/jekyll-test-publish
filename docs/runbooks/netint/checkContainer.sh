#!/bin/bash

# Written by @rufus for checking running container processes.
# This script requires 2 or 3 parameters, in the correct order.
# 1. Containers host machine (e.g. stage-dal09-carrier0-worker-02). 
#    You can also use the host IP address.
# 2. Nova Container ID (e.g. ce6ed2da-1c18-40f0-8eb3-1a528c5cd49b).
#    This is used to obtain the Docker container ID, so that commands
#    can be run in the container
# 3. Command to run. e.g. "ps -e". If you export the CMD variable before
#    running the script, it will use this instead of what is provided on 
#    command line.

# Usage: ./checkContainer.sh <Container host machine> <Nova container ID> 
#                            <Non-interactive command to run>

HOST=$1
CONT_ID=$2
echo "Host : $HOST"
echo "Container ID : $CONT_ID"

# shifts to get rest of args as command with parameters

if [[ -z $CMD ]] ; then
  shift
  shift
  CMD=$*
fi

echo "Command to run : $CMD (must be non-interactive)"

DOCKER_CONTAINER_ID=$(ssh "$HOST" sudo docker ps | grep "$CONT_ID" | cut -f1 -d' ')
if [[ -z $DOCKER_CONTAINER_ID ]] ; then
  echo "Docker container not found."
  exit
fi

echo "Docker Container ID : $DOCKER_CONTAINER_ID"

# shellcheck disable=SC2029
ssh "$HOST" sudo docker exec "$DOCKER_CONTAINER_ID" "$CMD"
