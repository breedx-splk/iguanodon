#!/bin/bash

# Runs a full test sequence with no agent.

MYDIR=`dirname $0`;
LOGS="${MYDIR}/../logs"
K6="${MYDIR}/../k6"
RESULTS="${MYDIR}/.."
PORT=9966

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
k6 run -u 5 -i 500 --out json=${RESULTS}/$1.json ${K6}/basic.js

kill $PID