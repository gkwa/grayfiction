#!/usr/bin/env bash

set -e
set -x
set -u

apt_update_with_retry() {
    max_retries=5
    retry_delay=10s

    for ((i = 1; i <= max_retries; i++)); do
        sudo apt-get update && break
        if [ $i -eq $max_retries ]; then
            echo "Failed to run apt update after $max_retries attempts. Exiting."
            exit 1
        fi
        echo "apt update failed. Retrying in $retry_delay seconds... (Attempt $i/$max_retries)"
        sleep $retry_delay
    done
}

apt_update_with_retry

DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes git curl

# install go-task
curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash

pwd

git clone --depth 1 https://github.com/taylormonacelli/grayfiction
cd grayfiction
pwd

git submodule update --init --recursive
cd ringgem
pwd

sudo task --output=prefixed --verbose configure-homebrew-on-linux
/home/linuxbrew/.linuxbrew/bin/brew install gkwa/homebrew-tools/howbob

old_xtrace=${-//[^x]/}
set +x
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if [[ -n $old_xtrace ]]; then set -x; else set +x; fi

howbob run --path=homebrew.k --brewfile=/tmp/Brewfile --checker=/tmp/versions.sh
for i in {1..3}; do
    /home/linuxbrew/.linuxbrew/bin/brew bundle --file=/tmp/Brewfile
done

bash -e /tmp/versions.sh

for i in {1..3}; do
    sudo task --output=prefixed --verbose northflier
done

rm -f /tmp/versions.sh
