#!/usr/bin/env bash

# Run MacOS GUI VM
function macos_vm_start () {
  docker start macos-vm;
  return 0;
}


# SSH to the MacOS VM
function macos_vm_ssh () {
  ssh -p 50922 "${USER}@localhost";
  return 0;
}

# Opens a shared directory with running MacOS VM
function macos_shared_dir_open () {
  if [[ ! -d ${HOME}/Documents/MacOS ]]; then
    \mkdir -p "${HOME}/Documents/MacOS"
  fi
  sshfs -o port=50922 \
    "${USER}@localhost:/Users/${USER}" \
    "${HOME}/Documents/MacOS";
  # TODO luciorq send SSH command to VM to open Finder on the VM
  ssh -p 50922 "${USER}@localhost" 'open "\${HOME}/Documents/MacOS"';
  return 0;
}
