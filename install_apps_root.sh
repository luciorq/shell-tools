#!/usr/bin/env bash

# Deploy compiled tools for the system
function __install_apps_system () {
  builtin local mkdir_bin;
  builtin local sudo_bin;
  builtin local cp_bin;

  builtin local user_config_path;
  builtin local root_config_path;
  builtin local lib_path;
  builtin local _i;
  builtin local app_name;
  if [[ "$(sudo_check)" == false ]]; then
    exit_fun 'Run any sudo commnad before running this function.';
    return 1;
  fi
  mkdir_bin="$(require 'mkdir')";
  sudo_bin="$(require 'sudo')";
  cp_bin="$(require 'cp')";

  user_config_path="$(get_config_path)";
  root_config_path='/root/.config';


  "${sudo_bin}" "${mkdir_bin}" -p "${root_config_path}/vars";

  "${sudo_bin}" "${cp_bin}" \
    "${user_config_path}/vars/apps.yaml" \
    "${root_config_path}/vars/apps.yaml";

  for _i in "${HOME}"/projects/shell-lib/lib/*.sh; do
    builtin source "$_i";
  done

  app_name="${1}";
  __install_app --system "${app_name}";

  return 0;
}
