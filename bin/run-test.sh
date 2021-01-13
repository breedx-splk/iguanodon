#!/bin/bash

# Runs a full test sequence with no agent.

MYDIR=`dirname $0`;
LOGS="${MYDIR}/../logs"
K6="${MYDIR}/../k6"
PORT=9966

function usage {
  echo "$0 <with-agent | no-agent>"
  exit 1
}


if [ "$1" == "no-agent" ] ; then
  SCRIPT="${MYDIR}/run-app-no-agent.sh"
elif [ "$1" == "with-agent" ] ; then
  SCRIPT="${MYDIR}/run-app-with-agent.sh"
else
  usage
fi

# Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
# TODO: Please make me better!
MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
echo $MYIP

${SCRIPT} > ${LOGS}/app.log &

echo 'Waiting for app to be ready...'

while [ "1" == "1" ] ; do
  curl -qs -I http://${MYIP}:${PORT}/petclinic/swagger-ui.html > /dev/null
  if [ "$?" == "0" ] ; then
    break
  fi
  sleep 1
done

sleep 2
echo 'Running test'
k6 run -u 5 -i 500 ${K6}/basic.js

PID=$(jps | grep petclinic | awk '{print $1}')
kill $PID