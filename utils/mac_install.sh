#!/usr/bin/env bash

# Functions to bootstrap and configure MacOS machines from the command line

# Install Devtools
function __install_macos_devtools () {
  local xcs_bin;
  local res_var;
  local sudo_bin;
  local mkdir_bin;
  local _i;
  local _j
  # local ln_bin;
  xcs_bin="$(which_bin 'xcode-select')";
  sudo_bin="$(which_bin 'sudo')";
  mkdir_bin="$(which_bin 'mkdir')";
  # ln_bin="$(which_bin 'ln')";
  res_var="$("${sudo_bin}" "${xcs_bin}" -p 2> /dev/null)";
  if [[ -z "${res_var}" ]]; then
    "${sudo_bin}" "${xcs_bin}" --install 2> /dev/null;
    sleep 2;
    osascript \
      -e "tell application \"System Events\"" \
        -e "tell process \"Install Command Line Developer Tools\"" \
          -e "keystroke return" \
          -e "click button \"Agree\" of window \"License Agreement\"" \
        -e "end tell" \
      -e "end tell";
    sleep 2;
    "${sudo_bin}" "${xcs_bin}" -p 2> /dev/null;
    while [[ "${?}" -ne 0 ]]; do
      "${sudo_bin}" "${xcs_bin}" -p 2> /dev/null;
    done
    builtin echo -ne "Devtools installed.\n";
  fi
  if [[ ! -d /usr/local/include ]]; then
    "${sudo_bin}" "${mkdir_bin}" -p /usr/local/include;
  fi

  # NOTE: @luciorq Don't Link if objective is to use Hombrew as build tool
  # Link developer tools headers
  # for _i in "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"/*; do
  #  _j="${_i##*/}";
  #  "${sudo_bin}" "${ln_bin}" -sf \
  #    "${_i}" "/usr/local/include/${_j}" 2> /dev/null
  # done

  # NOTE: Undo the above
  for _i in /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/*; do
    _j="${_i##*/}";
    if [[ -L /usr/local/include/${_j} ]]; then
      sudo unlink "/usr/local/include/${_j}";
    fi
  done
  return 0;
}

# Install Rosetta2 on ARM
function __install_rosetta () {
  local swu_bin;
  local sudo_bin;
  local pgrep_bin;
  local lsbom_bin;
  local file_res;
  local proc_res;
  local has_rosetta;
  local updater_path;
  local bom_path;
  local sys_arch;

  swu_bin="$(which_bin 'softwareupdate')";
  sudo_bin="$(which_bin 'sudo')";
  pgrep_bin="$(which_bin 'pgrep')";
  # lsbom_bin="$(which_bin 'lsbom')";
  sys_arch="$(uname -m)";

  if [[ ! ${sys_arch} == arm64 ]]; then
  builtin echo -ne \
    "System is not ARM, so not installing Rosetta2.\n";
  return 0;
  fi

  has_rosetta='no';

  if [[ -f /Library/Apple/usr/libexec/oah/libRosettaRuntime \
      && -f /usr/libexec/rosetta/oahd \
    ]]; then
    has_rosetta='yes';
    builtin echo -ne "Rosetta2 files found...\n";
  fi

  proc_res=$("${pgrep_bin}" oahd >/dev/null 2>&1; echo $?)
  if [[ ${proc_res} -eq 0 ]]; then
    has_rosetta='yes';
    builtin echo -ne "Rosetta2 process running...\n";
  fi

  updater_path='/System/Library/CoreServices/Rosetta 2 Updater.app';
  if [[ -d ${updater_path} ]]; then
    open "${updater_path}";
    # TODO: @luciorq Add Apple Script to click confirm
  fi

  if [[ -f /Library/Apple/System/Library/Receipts/com.apple.pkg.RosettaUpdateAuto.bom ]]; then
    builtin echo -ne "Rosetta2 Updater available...\n";
  fi

  if [[ ${has_rosetta} == no ]]; then
    "${sudo_bin}" "${swu_bin}" --install-rosetta --agree-to-license;
    builtin echo -ne "Rosetta2 installed.\n";
  fi
  return 0;
}

# Install  Homebrew
function __install_homebrew () {
  local brew_bin;
  local curl_bin;
  local bash_bin;
  curl_bin="$(which_bin 'curl')";
  bash_bin="$(which_bin 'bash')";
  # TODO luciorq Check for non-interactive install instructions
  "${bash_bin}" -c \
    "$(${curl_bin} -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  builtin echo -ne "Homebrew installed.\n";
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" doctor;
  "${brew_bin}" analytics off;
  "${brew_bin}" update;
  "${brew_bin}" cleanup;
  "${brew_bin}" analytics off;
  "${brew_bin}" update;
  "${brew_bin}" upgrade;
  "${brew_bin}" install cask;

  # Support for casks upgrade
  "${brew_bin}" tap buo/cask-upgrade;

  # Support for installing fonts
  "${brew_bin}" tap homebrew/cask-fonts;

  "${brew_bin}" reinstall gcc;

  return 0;
}

# Install Homebrew packages
function __install_homebrew_pkgs () {
  local pkg_arr;
  local cask_arr;
  local to_remove_arr;
  local tap_repo_arr;
  local brew_pkg;
  local cask_pkg;
  local remove_pkg;
  local tap_repo;
  local brew_bin;
  local cfg_path;
  cfg_path="$(get_config_path)";
  brew_bin="$(which_bin 'brew')";
  builtin mapfile -t tap_repo_arr < <(
    parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew taps
  );
  for tap_repo in "${tap_repo_arr[@]}"; do
    "${brew_bin}" tap "${tap_repo}";
  done
  # Remove conflicting packages
  builtin mapfile -t to_remove_arr < <(
    parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew to_remove
  );
  for remove_pkg in "${to_remove_arr[@]}"; do
    "${brew_bin}" uninstall --force --ignore-dependencies "${remove_pkg}";
  done
  builtin mapfile -t pkg_arr < <(
    parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew pkgs
  );
  for brew_pkg in "${pkg_arr[@]}"; do
    "${brew_bin}" install "${brew_pkg}";
  done
  builtin mapfile -t cask_arr < <(
    parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew casks
  );
  for cask_pkg in "${cask_arr[@]}"; do
    "${brew_bin}" install --cask "${cask_pkg}";
  done
  # Install fonts
  __install_fonts;
  # Double check on conflicting packages not being installed
  for remove_pkg in "${to_remove_arr[@]}"; do
    "${brew_bin}" uninstall --force --ignore-dependencies "${remove_pkg}";
  done
  "${brew_bin}" completions link;
  return 0;
}

# Set Upgraded BASH as default shell
function __update_bash_shell () {
  local is_bash_allowed;
  local bash_bin;
  local cat_bin;
  bash_bin="$(brew --prefix)/bin/bash";
  is_bash_allowed="$(
    "${cat_bin}" /private/etc/shells \
      | grep "${bash_bin}" || builtin echo -ne ''
  )";
  if [[ -z ${is_bash_allowed} ]]; then
    builtin echo "${bash_bin}" | sudo tee -a /private/etc/shells;
  fi
  sudo chpass -s "${bash_bin}" "${USER}";
  # TODO luciorq Change the default shell in Terminal App
  builtin read -r _temp_var;
  unset _temp_var;
  return 0;
}

# Install fonts for macOS
function __install_fonts () {
  local brew_bin;
  local fonts_arr font_pkg;
  local cfg_path;
  cfg_path="$(get_config_path)";
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" tap homebrew/cask-fonts;
  builtin mapfile -t fonts_arr < <(
    parse_yaml "${cfg_path}"/vars/homebrew.yaml default homebrew fonts
  );
  for font_pkg in "${fonts_arr[@]}"; do
    "${brew_bin}" install --cask "${font_pkg}";
  done
  return 0;
}

# Install Kitty terminal
function __install_kitty () {
  local brew_bin;
  local fonts_arr font_pkg;
  brew_bin="$(which_bin 'brew')";
  "${brew_bin}" install --cask kitty;
  # TODO: @luciorq Make Kitty default terminal
  return 0;
}

# Allow sudo commands to authenticate through TouchID
function __allow_touch_id_sudo () {
  local str_present;
  local pam_sudo_path;
  local wait_var;
  local sudo_bin;
  local replace_str;
  sudo_bin="$(require 'sudo')";
  pam_sudo_path='/private/etc/pam.d/sudo';
  # TODO: @luciorq Add automatic replace
  replace_str='auth       sufficient     pam_tid.so';
  str_present="$(check_in_file "auth.*sufficient.*pam_tid.so" "${pam_sudo_path}")";
  if [[ ${str_present} == false ]]; then
    # NOTE: Edit /private/etc/pam.d/sudo
    # + Add: 'auth       sufficient     pam_tid.so' to the first line
    # + IMPORTANT It needs to be above the other options!
    # sudo replace_in_file "auth.*sufficient.*pam_tid.so" "${replace_str}" "${pam_sudo_path}";
    builtin echo -ne "Insert the following:\n";
    builtin echo -ne "--> 'auth       sufficient     pam_tid.so'\n";
    builtin echo -ne "To the first line of ${pam_sudo_path}\n";
    builtin echo -ne "Press enter to continue:"
    # NOTE: @luciorq this line is used to wait for user input ...
    builtin read -r wait_var;
    builtin echo -ne "${wait_var}" > /dev/null;
    "${sudo_bin}" visudo "${pam_sudo_path}";
    builtin echo -ne "TouchID sudo enabled.\n";
  else
    builtin echo -ne "TouchID sudo already enabled.\n";
  fi
  return 0;
}

# Open MacOS options menu
function __open_macos_menu () {
  #  Example of opening System Preferencer -> Spotlight -> Search Results
  # + x-help-action://openPrefPane?bundleId=com.apple.preference.spotlight&anchorId=searchResults
  return 0;
}

# Update configuration from applications
function __update_configs () {
  # TODO: @luciorq Check Config update from bootstrap user
  local tldr_bin;
  tldr_bin=$(which_bin 'tldr');
  "${tldr_bin}" --update;
  # TODO: @luciorq Rebuild configuration files that need template
  # __rebuild_templates;
  return 0;
}

# Install R
function __install_rstats () {
  # FIXME: @luciorq Moved to RIG install method
  # + rstats lib:
  rstats::install_rig;
  rstats::install_rstats_version;
  rstats::boostrap_quarto_install;
  rstats::install_all_pkgs;

  builtin echo -ne "Install R...\n";
  return 0;
}
# Install Python
function __install_python () {
  # FIXME: @luciorq Homebrew method is working properly
  builtin echo -ne "Install Python...\n";
  return 0;
}

