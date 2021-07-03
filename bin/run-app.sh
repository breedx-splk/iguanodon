#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"
OTLP_PORT=55680
SPLUNK_AGENT_URL="https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent-all.jar"
OTEL_AGENT_URL="https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent-all.jar"

function usage {
  echo
  echo "$0 <options> "
  echo "  --agent [otel|splunk|none] : specify the agent to use"
  echo "  --endpoint [url]           : specify otlp endpoint url"
  echo
}

while [[ $# -gt 0 ]] ; do
  key="$1"
  case $key in
    -a|--agent)
      AGENT="$2"
      shift # past argument
      shift # past value
      ;;
    -e|--endpoint)
      ENDPOINT="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "$AGENT" == "otel" ] ; then
  URL="$OTEL_AGENT_URL"
  AGENT_JAR="opentelemetry-javaagent-all.jar"
  JAVA_AGENT_ARG="-javaagent:${AGENT_JAR}"
elif [ "$AGENT" == "splunk" ] ; then
  URL="$SPLUNK_AGENT_URL"
  AGENT_JAR="splunk-otel-javaagent.jar"
  JAVA_AGENT_ARG="-javaagent:${AGENT_JAR}"
elif [ "$AGENT" == "none" ] ; then
  URL="none"
  JAVA_AGENT_ARG=""
else
  usage
  exit 1
fi

if [ "$URL" != "none" ] ; then
  echo "Downloading the latest ${AGENT} agent jar"
  curl -C - -L "${URL}" -o "${AGENT_JAR}"
fi

echo Running the petclinic app

if [ "${ENDPOINT}" == "" ] ; then
  echo WARNING:::: guessing that OTLP is on localhost, trying to find my IP
  # Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
  # TODO: Please make me better!
  MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
  echo $MYIP
  ENDPOINT="http://${MYIP}:${OTLP_PORT}"
  echo $ENDPOINT
fi

# NOTE: JFR is not started at startup -- it is started after the app is healthy
java $JAVA_AGENT_ARG \
    -Dotel.traces.exporter=otlp \
    -Dotel.imr.export.interval=5000 \
    -Dotel.exporter.otlp.insecure=true \
    -Dotel.exporter.otlp.endpoint=${ENDPOINT} \
    -Dotel.resource.attributes=service.name=iguanodon-petclinic \
    -jar "${APPDIR}/target/spring-petclinic-rest-2.4.2.jar"