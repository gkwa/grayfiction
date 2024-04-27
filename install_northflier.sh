#!/usr/bin/env bash

set -e
set -x
set -u

export ORIGCWD=$(pwd)

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes git curl

# install go-task
curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash

gray=$ORIGCWD/grayfiction
ringgem=$gray/ringgem

git clone --depth 1 https://github.com/taylormonacelli/grayfiction $gray
cd $gray
git submodule update --init --recursive
cd $ringgem

for i in {1..5}; do
    sudo task --output=prefixed --dir=$ringgem --verbose northflier
done
