#!/usr/bin/env bash

set -e
set -x
set -u

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes git curl

# install go-task
curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash

for i in {1..5}; do
    sudo task --output=prefixed --dir=$(pwd)/ringgem --verbose northflier
done
