#!/usr/bin/env bash


# Print Disk and filesystem IO usage statistics
function __filesystem_io_stats () {
  local sudo_bin;
  local btrfs_bin;
  local zpool_bin;
  local iostat_bin;
  local _disk;
  local disk_arr;

  declare -a disk_arr=(
    /scratch
    /
    /home
    /data
  );

  btrfs_bin="$(which_bin 'btrfs')";
  zpool_bin="$(which_bin 'zpool')";
  iostat_bin="$(which_bin 'iostat')";
  if [[ -n ${zpool_bin} ]]; then
    "${sudo_bin}" "${zpool_bin}" iostat;
  fi
  if [[ -n ${iostat_bin} ]]; then
    "${sudo_bin}" "${iostat_bin}" -x;
  fi
  if [[ -n ${btrfs_bin} ]]; then
    for _disk in "${disk_arr[@]}"; do
      if [[ -d ${_disk} ]]; then
        "${sudo_bin}" "${btrfs_bin}" filesystem usage "${_disk}";
      fi
    done
  fi
  return 0;
}
