#!/usr/bin/env bash

# Create folders for apps and projects
function __deploy_infrastructure () {
  local user_path_arr;
  local system_path_arr;
  local sys_path user_path;
  local sudo_bin mkdir_bin;
  local cfg_path;
  cfg_path="$(get_config_path)";

  builtin mapfile -t user_path_arr < <(
    parse_yaml "${cfg_path}vars/projects.yaml" main dirs user
  );

  builtin mapfile -t system_path_arr < <(
    parse_yaml "${cfg_path}vars/projects.yaml" main dirs system
  );

  sudo_bin="$(which_bin 'sudo')";
  mkdir_bin="$(which_bin 'mkdir')";

  for user_path in "${user_path_arr[@]}"; do
    user_path="$(eval echo -ne "${user_path}")";
    if [[ ! -d ${user_path} ]]; then
      "${mkdir_bin}" -p "${user_path}";
    fi
  done
  for sys_path in "${system_path_arr[@]}"; do
    sys_path="$(eval echo -ne "${sys_path}")";
    if [[ ! -d ${sys_path} ]]; then
      "${sudo_bin}" "${mkdir_bin}" -p "${sys_path}";
    fi
  done
  # Prepare gh

  # TODO luciorq Clone shell-lib

  # TODO luciorq Clone dotfiles as bare
  return 0;
}

# Sync git repositories
function __sync_repos () {
  local git_bin;
  local repo_arr org_arr org_repo_arr;
  local _repo _org _org_repo;
  local cfg_path;
  git_bin="$(which_bin 'git')";
  cfg_path="$(get_config_path)";
  builtin mapfile -t repo_arr < <(
    parse_yaml "${cfg_path}/vars/projects.yaml" main repos github
  );
  builtin mapfile -t collab_repo_arr < <(
    parse_yaml "${cfg_path}/vars/projects.yaml" main repos collab
  );
  builtin mapfile -t org_arr < <(
    parse_yaml "${cfg_path}/vars/projects.yaml" main repos
  );
  builtin mapfile -t org_repo_arr < <(
    parse_yaml "${cfg_path}/vars/projects.yaml" main repos
  );
  for _repo in "${repo_arr[@]}"; do
    "${git_bin}" clone "${_repo}";
  done
  return 0;
}
