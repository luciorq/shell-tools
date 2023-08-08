#!/usr/bin/env bash


# Before starting compile e2fsprogs from GitHub repo
# + git clone https://github.com/tytso/e2fsprogs
# + preferentially compile on a different machine
function __compile_e2fsprogs () {
  # builtin local mkdir_bin;
  mkdir -p "${HOME}/workspaces/temp";
  builtin cd "${HOME}/workspaces/temp" || exit;
  git clone https://github.com/tytso/e2fsprogs;
  builtin cd e2fsprogs || exit;
  mkdir build;
  builtin cd build || exit;
  ../configure;
  make;
  make check;
  builtin return 0;
}

function __remove_chattr_trojan () {
  local sudo_bin;
  # local ls_bin;
  local rm_bin;
  local build_path;
  local lsattr_bin chattr_bin;
  local _search_dir_arr;
  local _still_infected;
  local _pkg_arr;
  local _path_to_search;
  local _i;
  local _j;
  local _count;
  local _file;
  local _pkg;

  sudo_bin='/usr/bin/sudo';

  "${sudo_bin}" builtin echo -ne "Super User\n";

  # ls_bin='/usr/bin/ls';
  rm_bin='/usr/bin/rm';
  build_path="${HOME}/workspaces/temp";
  lsattr_bin="${build_path}/e2fsprogs/build/misc/lsattr";
  chattr_bin="${build_path}/e2fsprogs/build/misc/chattr";

  declare -a _search_dir_arr=(
    /usr/bin/
    /usr/sbin/
    /usr/share/
  );

  declare -a _still_infected;
  builtin echo -ne "Files still infected:\n\n";

  # _still_infected=( $("${sudo_bin}" "${ls_bin}" /usr/share/doc/*so* -A1 2> /dev/null | grep '\.so.*') )
  _still_infected=( );

  for _path_to_search in "${_search_dir_arr[@]}"; do
    _still_infected+=(
      $("${sudo_bin}" "${lsattr_bin}" -a "${_path_to_search}" 2> /dev/null \
        | grep 'i--' \
        | grep -v 'Operation not supported While reading flag' \
        | grep 'i--' \
        | cut -d ' ' -f2)
    );
  done

  for _i in "${_still_infected[@]}"; do
    builtin echo -ne "${_i}\n";
  done

  for _file in "${_still_infected[@]}"; do
    _count=1;
    while [[ -f ${_file} && ${_count} -lt 100 ]]; do
      "${sudo_bin}" "${chattr_bin}" -i "${_file}" 2> /dev/null \
        && "${sudo_bin}" "${rm_bin}" -rf "${_file}" 2> /dev/null;
      builtin echo -ne "can't remove ${_file}\n";
      _count=$(( _count + 1 ));
    done
    builtin echo -ne "Removed: '${_file}'\n";
  done

  # try apt update?
  "${sudo_bin}" DEBIAN_FRONTEND=noninteractive apt update --yes;
  # Fix stuck dpkg
  "${sudo_bin}" DEBIAN_FRONTEND=noninteractive apt --fix-broken --yes install;

  declare -a _pkg_arr=(
    cpio
    gzip
    initramfs-tools
    initramfs-tools-core
    coreutils
    findutils
    procps
    e2fsprogs
    openssh-server
    openssh-sftp-server
  )

  # --allow-change-removed-packages \
  for _pkg in "${_pkg_arr[@]}"; do
    "${sudo_bin}" DEBIAN_FRONTEND=noninteractive apt install \
      --yes \
      --reinstall \
      --purge \
      "${_pkg}";
  done

  builtin echo -ne \
    "\n |> Install additional programs that appear as removed above.\n";

  for _j in "${_still_infected[@]}"; do
    builtin echo -ne "${_j}\n";
  done

  builtin return 0;
}
