#!/bin/bash

# Runs the test pass without agent, gathers results, then again with agent, and gathers results.

TS=$(date +%Y%m%d%H%M%S)

/app/bin/run-test-remote.sh --no-agent

echo Fetching results...
scp -o StrictHostKeyChecking=no remote@petclinic:/app/no-agent.jfr no-agent.jfr

/app/bin/run-test-remote.sh --agent otel

echo Fetching results...
scp -o StrictHostKeyChecking=no remote@petclinic:/app/with-agent.jfr with-agent.jfr

ls -ltr

NO_AVG=$(jq '.metrics | .iteration_duration | .avg' no-agent.json)
NO_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' no-agent.json)
WITH_AVG=$(jq '.metrics | .iteration_duration | .avg' with-agent.json)
WITH_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' with-agent.json)

echo "-------------------------------------------------------"
echo " No agent   : iter duration: avg = ${NO_AVG} p95 = ${NO_P95}"
echo " With agent : iter duration: avg = ${WITH_AVG} p95 = ${WITH_P95}"
echo "-------------------------------------------------------"
