#!/bin/bash

HOSTNAME=$(hostname)
LEADER=$(curl -s http://localhost:4040 | jq -r .name)
LEADER_CHECK_INTERVAL=${LEADER_CHECK_INTERVAL:-5}

until [[ ${HOSTNAME} == ${LEADER} ]];
do
  echo "Hostname: ${HOSTNAME}, Leader: ${LEADER} "
  echo "Waiting for becoming the leader..."
  sleep ${LEADER_CHECK_INTERVAL}
  LEADER=$(curl -s http://localhost:4040 | jq -r .name)
done

echo "Becoming the leader..."
/bin/bash -c "dagster-daemon run -w /dagster-workspace/workspace.yaml"
