#!/usr/bin/env bash
# --------------------------------------------------------------------------

# Main system update function
function system_update () {
  local sys_info_arr;
  builtin mapfile -t sys_info_arr < <( __get_system_info );
  sys_os_name="${sys_info_arr[2]}";
  if [[ "${sys_os_name,,}" == ubuntu ]]; then
    __system_update_ubuntu;
  elif [[ "${sys_os_name,,}" == macos ]]; then
    __system_update_macos;
  else
    exit_fun "No supported system detected.";
    return 1;
  fi

  # Update applications configurations
  builtin echo -ne \
    "\n\nUpdating Applications Configurations\n\n";
  __update_configs;
  builtin echo -ne \
    "\n\nSystem update succesfull.\n\n";
}

# Get system description strings
function __get_system_info () {
  local sys_arch;
  local sys_kernel_name;
  local sys_kernel_version;
  local sys_os_name;
  local sys_os_version;
  # local sys_strings_arr;
  sys_arch="$(uname -m)";
  sys_kernel_name="$(uname -s)";
  sys_kernel_version="$(uname -r)";
  if [[ "${sys_kernel_name,,}" == linux ]]; then
    sys_os_name="$(
      grep -i '^name=' /etc/os-release \
        | sed -e 's/\"//g' \
        | sed -e 's/name=//gi'
    )";
    sys_os_version="$(
      grep -i '^version_id=' /etc/os-release \
        | sed -e 's/\"//g' \
        | sed -e 's/version_id=//gi'
      )";
  elif [[ "${sys_kernel_name}" == Darwin ]]; then
    sys_os_name="$(sw_vers -productVersion)";
    sys_os_version="$(sw_vers -productName)";
  fi
  builtin echo -ne "${sys_os_name}\n";
  builtin echo -ne "${sys_arch}\n";
  builtin echo -ne "${sys_os_version}\n";
  builtin echo -ne "${sys_kernel_name}\n";
  builtin echo -ne "${sys_kernel_version}";
  return 0;
}

# MacOS specific updates
function __system_update_macos () {
  local topgrade_bin;
  topgrade_bin="$(which_bin 'topgrade')";
  "${topgrade_bin}" \
    --yes \
    --cleanup \
    --no-retry;
    # --disable antibody;
  return 0;
}

# Ubuntu specific updates
function __system_update_ubuntu () {
  # local snap_app_name;
  # local snap_revision;
  local sudo_bin;

  sudo_bin="$(which_bin 'sudo')";

  if [[ "$(sudo_check)" == false ]]; then
    builtin echo >&2 -ne \
      "Insuficient permissions.\n";
    return 1;
  fi

  builtin echo -ne \
    "\n\nUpdating packages from package manager (APT) ...\n\n";
  __update_apt_pkgs;

  builtin echo -ne \
    "\n\nUpdating applications via Snap (Snapcraft) ...\n\n";
  __update_snap_pkgs;

  builtin echo -ne \
    "\n\nUpdating Firmwares and Drivers (fwupdmgr) ...\n\n";
  "${sudo_bin}" fwupdmgr refresh --force;
  "${sudo_bin}" fwupdmgr get-upgrades;
  # --offline
  "${sudo_bin}" fwupdmgr update -y \
      --ignore-power \
      --no-reboot-check;

  # TODO luciorq Add python, golang, rust, and R packages to auto update
  builtin echo -ne \
    "\n\nUpdating Programming Languages (R, Python, Node.js & Go)\n\n";
  # _update_programming_languages;

  # TODO luciorq Use install_app module to install system applications
  # + using ansible need to integrate installed module to
  # + "configured module paths" or add new module paths to
  # + the "ansible_cfg_path" file.

  builtin echo -ne "\n\nUpdating Custom Applications (install_apps)\n\n";

  local ansible_bin;
  local ansible_cfg_path;
  local ansible_playbook_path;

  ansible_bin="$(require 'ansible-playbook')";
  ansible_cfg_path="${_BCA_CONFIG}";
  ansible_playbook_name=test_install_app.yaml;
  ansible_playbook_path="${_LOCAL_PROJECT}"/villabioinfo/install_apps/playbooks;
  ansible_playbook_path="${ansible_playbook_path}/${ansible_playbook_name}";

  if [[ -n ${ansible_bin} ]]; then
    ANSIBLE_CONFIG="${ansible_cfg_path}" "${ansible_bin}" \
      "${ansible_playbook_path}" \
      --extra-vars "@${_ANS_SEV}";
  else
    builtin echo -ne "\n\nAnsible not set correctly.\n\n";
  fi
  # ANSIBLE_CONFIG=${ansible_cfg_path} ansible \
  #   -v ${host_exec} -m "${module_name}" -a "${cmd_exec}"
  return 0;
}

