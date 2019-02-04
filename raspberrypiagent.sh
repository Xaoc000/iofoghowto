#!/usr/bin/env bash

#Pass in the IP of the controller, after it's been setup
IP=${1:'127.0.0.1:9001'}
PROV=$2

curl -sSf https://iofog.org/linux.sh | sh

sudo service iofog-agent start
sudo iofog-agent config -dev on

iofog-agent config -a "${IP}"

iofog-agent provision "${PROV}"