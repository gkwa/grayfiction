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

apt_upgrade_with_retry() {
    max_retries=5
    retry_delay=10s

    for ((i = 1; i <= max_retries; i++)); do
        sudo apt-get -y upgrade && break
        if [ $i -eq $max_retries ]; then
            echo "Failed to run apt upgrade after $max_retries attempts. Exiting."
            exit 1
        fi
        echo "apt upgrade failed. Retrying in $retry_delay seconds... (Attempt $i/$max_retries)"
        sleep $retry_delay
    done
}

apt_update_with_retry

apt_upgrade_with_retry

DEBIAN_FRONTEND=noninteractive sudo apt-get install --assume-yes git curl

# install go-task
curl -fsSL https://raw.githubusercontent.com/taylormonacelli/ringgem/master/install-go-task-on-linux.sh | sudo bash

pwd

if [ -d grayfiction ]; then # testing locally
    cd grayfiction
    cd ringgem
else
    git clone --depth 1 https://github.com/taylormonacelli/grayfiction
    cd grayfiction
    pwd

    git submodule update --init --recursive
    cd ringgem
    pwd
fi

sudo task --output=prefixed --verbose configure-homebrew-on-linux
sudo --login --user linuxbrew bash -l -c 'source /etc/profile.d/homebrew.sh && brew install gkwa/homebrew-tools/howbob'

source /etc/profile.d/homebrew.sh

python3 -c "
import os

for i, p in enumerate(os.environ.get('PATH', '').split(os.pathsep), 1):
   print(f'[{i}] {p}')
   try:
       files = [f for f in os.listdir(p) if os.path.isfile(os.path.join(p, f))]
       print(f'    {len(files)} files: {\" \".join(files)}')
   except:
       print('    (no access)')
"

old_xtrace=${-//[^x]/}
if [[ -n $old_xtrace ]]; then set -x; else set +x; fi

sudo /home/linuxbrew/.linuxbrew/bin/howbob run --taps=/tmp/taps.sh --path=homebrew.k --brewfile=/tmp/Brewfile --checker=/tmp/versions.sh
sudo --login --user linuxbrew bash -l -e /tmp/taps.sh
for i in {1..2}; do
    set +e
    sudo --login --user linuxbrew bash -l -c 'brew bundle --file=/tmp/Brewfile'
    set -e
done
sudo --login --user linuxbrew bash -l -c 'brew bundle --file=/tmp/Brewfile'

sudo --login --user linuxbrew bash -l -e /tmp/versions.sh

for i in {1..3}; do
    sudo --preserve-env task --output=prefixed --verbose northflier
done

sudo rm -f /tmp/versions.sh
