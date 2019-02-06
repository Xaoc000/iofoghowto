#!/usr/bin/env bash

# This will take over all raspberry Pis on the network, and setup initial ECN on them

EMAIL=$1
FIRST_NAME=$2
LAST_NAME=$3
PASSWORD=$4
IP="http://$(ifconfig | grep 192 | awk '{print $2}'):54421/api/v3/"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # ...
    sudo apt-get update
    sudo apt-get install -y -q nodejs npm
    sudo apt-get install -y -q nmap sshpass
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    sudo xcode-select --install || true
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || true
    brew install node || true
    brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb || true
fi

sudo npm install -g iofogcontroller --unsafe-perm || true

iofog-controller config dev-mode --on

sudo iofog-controller user add --email $1 --first-name $2 --last-name $3 --password $4 || true

CONTROLLER="$(sudo iofog-controller user list | grep id | awk 'NR==1 {print $2}')"
USER_ID=${CONTROLLER%?}

NODE_IPS=($(sudo nmap -sP 192.168.1.0/24 | awk '/^Nmap/{ip=$NF}/B8:27:EB/{print ip}' | awk '{gsub(/[()]/,""); print;}'))

sudo iofog-controller start

for var in "${!NODE_IPS[@]}"
do
    NODE_ID=$(sudo iofog-controller iofog add --name "RPI${var}" --fog-type 0 -u ${USER_ID} | grep uuid | awk -F  ":" '{print $2}' | awk '{print substr($0, 2, length($0) - 3)}')
    PROV_KEY=$(sudo iofog-controller iofog provisioning-key --node-id "${NODE_ID}" | grep \"key\" | awk '{print $2}' | awk '{print substr($0, 2, length($0) - 3)}')
    sshpass -p raspberry scp ./raspberrypiagent.sh pi@"${NODE_IPS[var]}":~/.
    sshpass -p raspberry ssh -tt pi@"${NODE_IPS[var]}" "~/raspberrypiagent.sh '${IP}' '${PROV_KEY}'; exit"
done

exit 0