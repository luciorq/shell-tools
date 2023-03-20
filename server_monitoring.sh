#!/usr/bin/env bash

# Monitoring functions

# Check temperatures for nvidia
function check_temps () {
  servers_exec 'sensors; nvidia-smi -q -d temperature || echo ""'

  # sensors
}

# TODO add check for dir is ZFS and print real(compressed usage)
# + and quota, if available;
# Print Space used at home dir with time of last modification
function check_home_usage () {
  local home_path_arr;
  local user_home;
  local pw_file_path;
  local dust_bin;
  local du_bin;
  local sudo_bin;
  sudo_bin="$(require 'sudo')";
  dust_bin="$(which_bin 'dust')";
  du_bin="$(which_bin 'du')";
  if [[ -z "${dust_bin}" ]]; then
    builtin echo -ne "'dust' not found, using 'du' instead.\n";
  else
    "${sudo_bin}" "${dust_bin}" \
      -x -H -d 1 -r "${HOME%%/${USER}}";
    return 0;
  fi
  pw_file_path='/etc/passwd';
  if [[ -f ${pw_file_path} ]]; then
    builtin mapfile -t home_path_arr < <(
      grep -v '/nologin' "${pw_file_path}" \
      | grep -v '/false' \
      | grep -v '/sync' \
      | grep -v '^rstudio-server' \
      | grep -v '^slurm' \
      | grep -v '^_' \
      | grep -v '^#' \
      | cut -d':' -f 6
    )
  fi
  for user_home in "${home_path_arr[@]}"; do
    "${sudo_bin}" "${du_bin}" \
      -shL \
      --time \
      "${user_home}";
  done
  return 0;
}

# ======================
# Hardware Inventory functions
function __list_network_devices () {
  local sudo_bin;
  sudo_bin="$(require 'sudo')";
  "${sudo_bin}" lshw \
    -class network -short;
  return 0;
}
function __list_manufacturer () {
  \dmidecode -s system-manufacturer;
  return 0;
}
function __list_storage () {
  \ls /dev/disk/by-id \
    | grep -v ".*-part";
  return 0;
}

# list Filesystem usage
function __fs_usage () {
  local dust_bin;
  local sudo_bin;
  sudo_bin="$(which_bin 'sudo') ";
  dust_bin="$(require 'dust')";
  "${sudo_bin} ${dust_bin}" \
    --limit-filesystem -H --reverse -d 1 "${@}";
  return 0;
}
