#!/usr/bin/env bash

# Check RACADM version
function racadm_exec () {
  local _remote_ip;
  local _remote_port;
  local _remote_user;
  local _remote_pw;
  local _cmd_to_exec;
  _remote_ip="${1}";
  _remote_port="${2}";
  _remote_user="${3}";
  _remote_pw="${4}";
  _cmd_to_exec="${5}";
  if [[ -z ${_cmd_to_exec} ]]; then
    _cmd_to_exec='version';
  fi
  docker run --rm \
    justinclayton/racadm \
    -r "${_remote_ip}:${_remote_port}" \
    -u "${_remote_user}" \
    -p "${_remote_pw}" \
    ${@:5};
  return 0;
}

# Set default configuration to all disks and to the card
function server_raid_set_default_config () {
  builtin echo -ne 'Setting the time on the RAID card.\n';
  docker run --rm \
    --privileged \
    kamermans/docker-megacli \
      /megacli/lsi.sh settime;
  builtin echo -ne \
    'Setting configurations to default values, for disks and card.\n';
  docker run --rm \
    --privileged \
    kamermans/docker-megacli \
      /megacli/lsi.sh setdefaults;
  return 0;
}
