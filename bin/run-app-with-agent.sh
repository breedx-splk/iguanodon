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

# NOTE: JFR is not started at startup -- it is started after the app is healthy

#    -Dotel.javaagent.debug=true \
#    -Dotel.instrumentation.default-enabled=false \
#    -Dotel.instrumentation.hibernate.enabled=false \
#    -Dotel.instrumentation.jdbc.query.normalizer.enabled=false \
#    -Dotel.instrumentation.jdbc.enabled=false \
#java -javaagent:splunk-otel-javaagent.jar \
java -javaagent:splunk-otel-javaagent-0.6.0-SNAPSHOT-all.jar \
    -Dotel.instrumentation.jdbc.enabled=false \
    -Dotel.exporter=otlp \
    -Dotel.exporter.otlp.endpoint=${MYIP}:${OTLP_PORT} \
    -Dotel.resource.attributes=service.name=iguanodon-petclinic \
    -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar