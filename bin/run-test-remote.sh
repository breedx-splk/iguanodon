#!/bin/bash

# Runs a full test sequence against a "remote" instance.
# It ssh's into the system to start the app, start jfr, and take a heap dump, etc.

LOGS="/app"
K6="/app/k6"
RESULTS="/app"
PORT=9966
VUSERS=5
ITERATIONS=500

function usage {
  echo
  echo "$0 <options>"
  echo
  echo "   --no-agent              : run without the agent"
  echo "   --agent <otel|splunk>   : run with one of the agents"
  echo "   --users <vusers>        : use this many vusers (default=5)"
  echo "   --iterations <num>      : run this many iterations (default=500)"
  echo
  exit 1
}

while [[ $# -gt 0 ]] ; do
  key="$1"
  case $key in
    -a|--agent)
      TEST_TYPE="with-agent"
      AGENT=$2
      shift # past argument
      shift # past value
      ;;
    -n|--no-agent)
      TEST_TYPE="no-agent"
      shift # past argument
      ;;
    -u|--users)
      VUSERS=$2
      shift
      shift
      ;;
    -i|--iterations)
      ITERATIONS=$2
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "$TEST_TYPE" == "no-agent" ] ; then
  SCRIPT="/app/bin/run-app-${TEST_TYPE}.sh"
elif [ "$TEST_TYPE" == "with-agent" ]; then
  SCRIPT="/app/bin/run-app-${TEST_TYPE}.sh --agent ${AGENT} --endpoint http://collector:4317"
else
  usage
  exit 1
fi

if [ ! -d "${LOGS}" ] ; then
  mkdir "${LOGS}"
fi

echo Sleeping a bit before running remote...
sleep 2

echo $SCRIPT
ssh -o StrictHostKeyChecking=no remote@petclinic "${SCRIPT} > ${LOGS}/app.log 2>&1 &"
SECONDS=0

echo 'Waiting for app to be ready...'

while [ "1" == "1" ] ; do
  curl -qs -I http://petclinic:${PORT}/petclinic/swagger-ui.html > /dev/null
  if [ "$?" == "0" ] ; then
    break
  fi
  echo 'Waiting for app to be ready...'
  sleep 1
done
echo $SECONDS > "results/${TEST_TYPE}.startup.seconds"

PID=$(ssh -o StrictHostKeyChecking=no remote@petclinic "jps | grep petclinic | awk '{print \$1}'" | tail -1)

echo "App is ready, pid = ${PID}"

echo 'Sleeping a bit...'
sleep 2

echo 'Starting JFR recording...'
ssh -o StrictHostKeyChecking=no remote@petclinic "jcmd ${PID} JFR.start settings=profile dumponexit=true name=${TEST_TYPE} filename=/app/${TEST_TYPE}.jfr"

echo 'Running test'
SUMMARY_FILE=${RESULTS}/${TEST_TYPE}.json
TARGET_HOST=petclinic k6 run -u ${VUSERS} -i ${ITERATIONS} --summary-export=${SUMMARY_FILE} ${K6}/basic.js

# Commenting this out until we can decide _how_ we wanna automatically analyze the heap
#HPROF="${RESULTS}/${TEST_TYPE}.hprof"
#echo "Taking a heap dump: ${HPROF}"
#ssh -o StrictHostKeyChecking=no remote@petclinic "jcmd ${PID} GC.heap_dump ${HPROF}"

echo 'Stopping the petclinic app...'
ssh -o StrictHostKeyChecking=no remote@petclinic "kill -15 $PID"
ssh -o StrictHostKeyChecking=no remote@petclinic "while kill -0 $PID; do sleep 1; done"
sleep 1