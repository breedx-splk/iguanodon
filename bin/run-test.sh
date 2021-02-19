#!/bin/bash

# Runs a full test sequence with no agent.

MYDIR=`dirname $0`;
LOGS="${MYDIR}/../logs"
K6="${MYDIR}/../k6"
RESULTS="${MYDIR}/.."
PORT=9966
VUSERS=5
ITERATIONS=500
TS=$(date +%Y%m%d%H%M%S)

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
  SCRIPT="${MYDIR}/run-app-${TEST_TYPE}.sh"
elif [ "$TEST_TYPE" == "with-agent" ]; then
  SCRIPT="${MYDIR}/run-app-${TEST_TYPE}.sh -a ${AGENT}"
else
  usage
  exit 1
fi


# Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
# TODO: Please make me better!
MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
echo $MYIP

if [ ! -d "${LOGS}" ] ; then
  mkdir "${LOGS}"
fi

echo $SCRIPT
${SCRIPT} > ${LOGS}/app.log 2>&1 &

echo 'Waiting for app to be ready...'

while [ "1" == "1" ] ; do
  curl -qs -I http://${MYIP}:${PORT}/petclinic/swagger-ui.html > /dev/null
  if [ "$?" == "0" ] ; then
    break
  fi
  sleep 1
done

PID=$(jps | grep petclinic | awk '{print $1}')
echo "App is ready, pid = ${PID}"

echo 'Sleeping a bit...'
sleep 2

echo 'Starting JFR recording...'
jcmd ${PID} JFR.start settings=profile dumponexit=true name=${TEST_TYPE} filename=${MYDIR}/../${TEST_TYPE}.jfr

echo 'Running test'
SUMMARY_FILE=${RESULTS}/${TEST_TYPE}.json
k6 run -u ${VUSERS} -i ${ITERATIONS} --summary-export=${SUMMARY_FILE} ${K6}/basic.js

HPROF="${RESULTS}/${TEST_TYPE}.hprof"
echo "Taking a heap dump: ${HPROF}"
jcmd ${PID} GC.heap_dump "${HPROF}"

echo 'Stopping the petclinic app...'
kill $PID

if [ -f ${RESULTS}/with-agent.json ] && [ -f ${RESULTS}/no-agent.json ] ; then
  NO_AVG=$(jq '.metrics | .iteration_duration | .avg' "${RESULTS}/no-agent.json")
  NO_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' "${RESULTS}/no-agent.json")
  WITH_AVG=$(jq '.metrics | .iteration_duration | .avg' "${RESULTS}/with-agent.json")
  WITH_P95=$(jq '.metrics | .iteration_duration | ."p(95)"' "${RESULTS}/with-agent.json")

  echo "-------------------------------------------------------"
  echo " No agent   : avg = ${NO_AVG} p95 = ${NO_P95}"
  echo " With agent : avg = ${WITH_AVG} p95 = ${WITH_P95}"
  echo "-------------------------------------------------------"
fi
