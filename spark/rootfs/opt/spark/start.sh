#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail

if [[ -z ${SPARK_MASTER_URL+x} ]]; then
  #Default to the one in docker-compose
  SPARK_MASTER_URL="spark://master:7077"
fi

if [ "$SPARK_MODE" == "master" ]; then
  EXEC=$(command -v start-master.sh)
  ARGS=()
  echo "Starting spark master"
elif [ "$SPARK_MODE" == "thrift" ]; then
  EXEC=$(command -v start-thriftserver.sh)
  ARGS=("--master=$SPARK_MASTER_URL")
  echo "Starting thrift"
else 
  EXEC=$(command -v start-worker.sh)
  ARGS=("$SPARK_MASTER_URL")
  echo "Starting spark worker. Master url $SPARK_MASTER_URL"
fi

exec "$EXEC" "${ARGS[@]-}"