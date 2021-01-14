#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"

echo Running the petclinic app

# NOTE: JFR is not started at startup -- it is started after the app is healthy
java \
  -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar