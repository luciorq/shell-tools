#!/usr/bin/env bash

function __upgrade_ubuntu_server () {
  local sudo_bin;
  local sudo_bool;
  local apt_bin;

  sudo_bin="$(require 'sudo')";

  sudo_bool="$(sudo_check)";
  if [[ "${sudo_bool}" == false ]]; then
    exit_fun 'Insuficient permissions.';
    return 1;
  fi

  apt_bin="$(require 'apt')";

  "${sudo_bin}" "${apt_bin}" update;
  "${sudo_bin}" "${apt_bin}" upgrade --yes;
  "${sudo_bin}" "${apt_bin}" dist-upgrade --yes;
  "${sudo_bin}" "${apt_bin}" autoremove --yes;
  "${sudo_bin}" "${apt_bin}" --yes install update-manager-core;
  "${sudo_bin}" do-release-upgrade -d;

  return 0;
}
