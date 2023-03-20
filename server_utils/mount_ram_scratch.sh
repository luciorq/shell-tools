#!/usr/bin/env bash

# Create and mount Ramdisk scratch and give user permissions
function __create_ramdisk_scratch () {
  local sudo_bin;
  local mkdir_bin;
  local mount_bin;
  local chown_bin;

  local mount_path;
  local disk_size_gb;
  local disk_size_mb;

  local user_arr;
  local _user;
  local _user_dir;

  mount_path="${1:-/scratch}";
  disk_size_gb="${2:-30}";

  builtin mapfile -t user_arr < <(
    __get_server_users;
  );

  sudo_bin="$(which_bin 'sudo')";
  mkdir_bin="$(which_bin 'mkdir')";
  mount_bin="$(which_bin 'mount')";
  chown_bin="$(which_bin 'chown')";

  disk_size_mb="$(( disk_size_gb * 1024 ))";
  # echo "${disk_size_gb}";
  # echo "${disk_size_mb}";

  if [[ ! -d ${mount_path} ]]; then
    "${sudo_bin}" "${mkdir_bin}"
  fi
  "${sudo_bin}" "${mount_bin}" \
    -t tmpfs -o "size=${disk_size_mb}M" tmpfs \
    "${mount_path}";

  for _user in "${user_arr[@]}"; do
    _user_dir="${mount_path}/${_user}";
    if [[ ! -d ${_user_dir} ]]; then
      "${sudo_bin}" "${mkdir_bin}" -p "${_user_dir}";
    fi
    "${sudo_bin}" "${chown_bin}" \
      -R "${_user}":"${_user}" "${_user_dir}";
  done
  return 0;
}
