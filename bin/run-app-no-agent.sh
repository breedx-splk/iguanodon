#!/bin/bash

MYDIR=`dirname $0`;
APPDIR="${MYDIR}/../spring-petclinic-rest"

echo Running the petclinic app
java -jar ${APPDIR}/target/spring-petclinic-rest-2.2.5.jar