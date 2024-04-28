#!/usr/bin/env bash

set -e
set -x
set -u

export ORIGCWD=$(pwd)

# Retry loop for apt update
max_retries=5
retry_delay=10

for ((i = 1; i <= max_retries; i++)); do
    sudo apt-get update && break
    if [ $i -eq $max_retries ]; then
        echo "Failed to run apt update after $max_retries attempts. Exiting."
        exit 1
    fi
    echo "apt update failed. Retrying in $retry_delay seconds... (Attempt $i/$max_retries)"
    sleep $retry_delay
done

DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes git curl

# install go-task
curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash

gray=$ORIGCWD/grayfiction
ringgem=$gray/ringgem

git clone --depth 1 https://github.com/taylormonacelli/grayfiction $gray
cd $gray
git submodule update --depth 1 --init --recursive
cd $ringgem

for i in {1..2}; do
    sudo task --output=prefixed --dir=$ringgem --verbose install-many-homebrew-apps
done

# get homebrew env into current context
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

for i in {1..5}; do
    sudo task --output=prefixed --dir=$ringgem --verbose northflier
done
