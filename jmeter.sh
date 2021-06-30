#!/bin/bash

NAME="jmeter"
IMAGE="justb4/jmeter:5.3"

test "$1" || exit
echo Running Jmeter benchmark \"$1\" $(uname -a)

docker run --rm --name ${NAME} --network host -i -v ${PWD}:${PWD} -w ${PWD} ${IMAGE} -JHOST=localhost -JPORT=80 -JNUM_USERS=10000 \
	-n -t bank-test.jmx -l $1.csv -e -o $1
