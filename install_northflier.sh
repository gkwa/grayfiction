#!/usr/bin/env bash

set -e
set -x
set -u


sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes unzip curl

curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash
curl -Lo ringgem-master.zip https://github.com/taylormonacelli/ringgem/archive/refs/heads/master.zip
unzip ringgem-master.zip -d .
ls -la ringgem-master

for i in {1..5}; do
  sudo task --output=prefixed --dir=ringgem-master --verbose northflier
done
