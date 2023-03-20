#!/usr/bin/env bash

# SSH Port Forwarding
function ssh_local_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  local login_port;
  user="${1:-${USER}}";
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -N -L \
    ${local_port}:${local_ip}:${remote_port} \
    -p "${login_port}" \
    ${user}@${remote_ip};
}
function ssh_remote_port_forwarding () {
  local local_port remote_port;
  local local_ip remote_ip;
  local user;
  local login_port;
  user="${1:-${USER}}";
  local_port='';
  local_ip='';
  remote_port='';
  remote_ip='';
  ssh -N -R \
    ${local_port}:${local_ip}:${remote_port} \
    -p "${login_port}" \
    ${user}@${remote_ip};
}


# TODO luciorq Create Rotate keys function, that rotates local and remote keys
# Rotate key and sync with remote
function __ssh_rotate_keys () {
  return 0;
}
