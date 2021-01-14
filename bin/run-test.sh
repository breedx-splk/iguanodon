#!/bin/bash

# Runs a full test sequence with no agent.

MYDIR=`dirname $0`;
LOGS="${MYDIR}/../logs"
K6="${MYDIR}/../k6"
RESULTS="${MYDIR}/.."
PORT=9966
VUSERS=5
ITERATIONS=500

function usage {
  echo "$0 <with-agent | no-agent>"
  exit 1
}

if [ "$1" == "no-agent" ] ; then
  TEST_TYPE="no-agent"
elif [ "$1" == "with-agent" ] ; then
  TEST_TYPE="with-agent"
else
  usage
fi
SCRIPT="${MYDIR}/run-app-${TEST_TYPE}.sh"

# Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
# TODO: Please make me better!
MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
echo $MYIP

if [ ! -d "${LOGS}" ] ; then
  mkdir "${LOGS}"
fi

${SCRIPT} > ${LOGS}/app.log &

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
jcmd ${PID} JFR.start dumponexit=true name=${TEST_TYPE} filename=${MYDIR}/../${TEST_TYPE}.jfr

echo 'Running test'
SUMMARY_FILE=${RESULTS}/${TEST_TYPE}.json
k6 run -u ${VUSERS} -i ${ITERATIONS} --summary-export=${SUMMARY_FILE} ${K6}/basic.js

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
