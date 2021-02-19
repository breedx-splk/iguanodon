#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"
OTLP_PORT=55680
SPLUNK_AGENT_URL="https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent-all.jar"
OTEL_AGENT_URL="https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent-all.jar"

function usage {
  echo "$0 --agent [otel|splunk]"
}

while [[ $# -gt 0 ]] ; do
  key="$1"
  case $key in
      -a|--extension)
      AGENT="$2"
      shift # past argument
      shift # past value
  esac
done

if [ "$AGENT" == "otel" ] ; then
  URL="$OTEL_AGENT_URL"
  AGENT_JAR="opentelemetry-javaagent-all.jar"
elif [ "$AGENT" == "splunk" ] ; then
  URL="$SPLUNK_AGENT_URL"
  AGENT_JAR="splunk-otel-javaagent.jar"
else
    usage
    exit 1
fi


curl -C - -L "${URL}" -o "${AGENT_JAR}"

echo Running the petclinic app

# Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
# TODO: Please make me better!
MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
echo $MYIP

# NOTE: JFR is not started at startup -- it is started after the app is healthy

java -javaagent:$AGENT_JAR \
    -Dotel.traces.exporter=otlp \
    -Dotel.imr.export.interval=5000 \
    -Dotel.exporter.otlp.insecure=true \
    -Dotel.exporter.otlp.endpoint=http://${MYIP}:${OTLP_PORT} \
    -Dotel.resource.attributes=service.name=iguanodon-petclinic \
    -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar