#!/bin/sh

if [ $# -eq 1 -a $1 = "down" ];
then
  docker-compose -f build/docker-compose-mk_cert.yml down
else
  docker-compose -f build/docker-compose-mk_cert.yml up
fi
