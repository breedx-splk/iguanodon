#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"

curl -L https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent-all.jar \
    -o splunk-otel-javaagent.jar

echo Running the petclinic app

java -javaagent:splunk-otel-javaagent.jar \
    -Dotel.javaagent.debug=true \
    -Dotel.exporter=logging \
    -Dotel.resource.attributes=iguanodon-testing \
    -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar