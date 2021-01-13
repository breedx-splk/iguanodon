#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"
OTLP_PORT=55680

curl -C - -L https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent-all.jar \
    -o splunk-otel-javaagent.jar

echo Running the petclinic app

# Find the local IP, in a way that is super clumsy and probably very custom to OSX and prone to breaking.
# TODO: Please make me better!
MYIP=$(ifconfig | grep inet | grep -v :: | grep -v 127 | awk '{print $2}' | head -1)
echo $MYIP

#    -Dotel.javaagent.debug=true \
java -javaagent:splunk-otel-javaagent.jar \
    -Dotel.exporter=otlp \
    -Dotel.resource.attributes=iguanodon-testing \
    -Dotel.exporter.otlp.endpoint=${MYIP}:${OTLP_PORT} \
    -Dotel.resource.attributes=service.name=iguanodon-petclinic \
    -XX:StartFlightRecording=dumponexit=true,name=with-agent,filename=${MYDIR}/../with-agent.jfr \
    -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar