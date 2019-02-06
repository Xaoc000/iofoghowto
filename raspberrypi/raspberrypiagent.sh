#!/usr/bin/env bash

# Pass in the IP of the controller, after it's been setup
IP=$1
PROV_KEY=$2

if [[ -z $(ls /usr/local/bin | grep iofog-agent) ]]; then
    sudo apt install curl
    curl -sSf https://iofog.org/linux.sh | sh
fi

sudo service iofog-agent start

sudo iofog-agent deprovision

sudo iofog-agent config -dev on

sudo iofog-agent config -a $IP

sudo iofog-agent provision $PROV_KEY

exit 0
