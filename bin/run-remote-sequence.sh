#!/bin/bash

# Runs the test pass without agent, gathers results, then again with agent, and gathers results.

set -e

TS=$(date +%Y%m%d%H%M%S)

/app/bin/run-test-remote.sh --no-agent

echo Fetching results...
scp -o StrictHostKeyChecking=no remote@petclinic:/app/no-agent.jfr no-agent.jfr

/app/bin/run-test-remote.sh --agent otel

echo Fetching results...
scp -o StrictHostKeyChecking=no remote@petclinic:/app/with-agent.jfr with-agent.jfr

ls -ltr

NO_ITER_AVG=$(jq '.metrics | .iteration_duration | .avg' no-agent.json)
NO_ITER_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' no-agent.json)
NO_HTTP_AVG=$(jq '.metrics | .http_req_duration | .avg' no-agent.json)
NO_HTTP_P95=$(jq '.metrics | .http_req_duration | ."p(95)"' no-agent.json)

WITH_ITER_AVG=$(jq '.metrics | .iteration_duration | .avg' with-agent.json)
WITH_ITER_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' with-agent.json)
WITH_HTTP_AVG=$(jq '.metrics | .http_req_duration | .avg' with-agent.json)
WITH_HTTP_P95=$(jq '.metrics | .http_req_duration | ."p(95)"' with-agent.json)

# total GC time:
GC_WITH=$(jfr print --json --events "jdk.G1GarbageCollection" with-agent.jfr | \
  jq '[.recording.events | .[].values.duration | .[2:] | .[:-1] | tonumber] | add')

GC_WITHOUT=$(jfr print --json --events "jdk.G1GarbageCollection" no-agent.jfr | \
  jq '[.recording.events | .[].values.duration | .[2:] | .[:-1] | tonumber] | add')

echo "-------------------------------------------------------"
echo " No agent   : iter duration: avg = ${NO_ITER_AVG} p95 = ${NO_ITER_P95}"
echo " With agent : iter duration: avg = ${WITH_ITER_AVG} p95 = ${WITH_ITER_P95}"
echo "-------------------------------------------------------"
echo " No agent   : total gc: ${GC_WITHOUT}"
echo " With agent : total gc: ${GC_WITH}"
echo "-------------------------------------------------------"

NO_ALLOCS=$(jfr print --json --events jdk.ThreadAllocationStatistics no-agent.jfr | jq '[.recording.events | .[].values.allocated] | add')
NO_HEAP_MIN=$(jfr print --json --events jdk.GCHeapSummary no-agent.jfr | jq '[.recording.events | .[].values.heapUsed ] | min')
NO_HEAP_MAX=$(jfr print --json --events jdk.GCHeapSummary no-agent.jfr | jq '[.recording.events | .[].values.heapUsed ] | max')

WITH_ALLOCS=$(jfr print --json --events jdk.ThreadAllocationStatistics with-agent.jfr | jq '[.recording.events | .[].values.allocated] | add')
WITH_HEAP_MIN=$(jfr print --json --events jdk.GCHeapSummary with-agent.jfr | jq '[.recording.events | .[].values.heapUsed ] | min')
WITH_HEAP_MAX=$(jfr print --json --events jdk.GCHeapSummary with-agent.jfr | jq '[.recording.events | .[].values.heapUsed ] | max')

NO_TS_RATE=$(jfr print --json --events jdk.ThreadContextSwitchRate no-agent.jfr | jq '[.recording.events | .[].values.switchRate ] | max')
WITH_TS_RATE=$(jfr print --json --events jdk.ThreadContextSwitchRate with-agent.jfr | jq '[.recording.events | .[].values.switchRate ] | max')

echo "${TS},${NO_ITER_AVG},${NO_ITER_P95},${NO_HTTP_AVG},${NO_HTTP_P95},${WITH_ITER_AVG},${WITH_ITER_P95},${WITH_HTTP_AVG},${WITH_HTTP_P95}" >> results/throughput.csv
echo "${TS},${NO_ALLOCS},${WITH_ALLOCS}" >> results/allocations.csv
echo "${TS},${GC_WITHOUT},${GC_WITH}" >> results/garbage_collection.csv
echo "${TS},${NO_HEAP_MIN},${NO_HEAP_MAX},${WITH_HEAP_MIN},${WITH_HEAP_MAX}" >> results/heap_used.csv
echo "${TS},${NO_TS_RATE},${WITH_TS_RATE}" >> results/thread_context_switch_rate.csv

jfr print --json \
  --events jdk.ThreadAllocationStatistics,jdk.GCHeapSummary,jdk.ThreadContextSwitchRate,jdk.G1GarbageCollection \
  with-agent.jfr > results/${TS}.with-agent.json

jfr print --json \
  --events jdk.ThreadAllocationStatistics,jdk.GCHeapSummary,jdk.ThreadContextSwitchRate,jdk.G1GarbageCollection \
  no-agent.jfr > results/${TS}.no-agent.json

NO_AGENT_STARTUP=$(cat results/no-agent.startup.seconds)
AGENT_STARTUP=$(cat results/with-agent.startup.seconds)
rm results/no-agent.startup.seconds
rm results/with-agent.startup.seconds

echo "${TS},${NO_AGENT_STARTUP},${AGENT_STARTUP}" >> results/start_time.csv

#ls -ltr results
#ls -ltr /github/workspace/

echo Cleaning up...
rm results/*.no-agent.json results/*.with-agent.json

echo Copying data out of the container to the github workspace
rsync -avv --progress results/ /github/workspace/results/