#!/usr/bin/env bash

# FIXME: luciorq This script is not working for containers and LTS installs.
# + Currently, `rolling-rhino` project depends on daily ISO being installed.

# This is a really dangerous function
# + don't do it if you are unsure of the outcomes

function update_deps () {
  apt update -y \
    && apt upgrade -y

  apt install -y \
    curl \
    wget \
    vim \
    git \
    lsb-release \
    ubuntu-release-upgrader-core;
  return 0;
}


# from Daily ISO to Current Release
function convert_to_rolling () {
  sed -i \
    's|Prompt=lts|Prompt=normal|g' \
    /etc/update-manager/release-upgrades;

  do-release-upgrade \
    -q \
    --frontend=noninteractive;

  git clone https://github.com/wimpysworld/rolling-rhino.git;
  builtin cd rolling-rhino || exit;
  ./rolling-rhino;
  return 0;
}

