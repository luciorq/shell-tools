#!/usr/bin/env bash

# Tools to be used on the cepad-icb-ufmg sagarana cluster
# + Website: https://bioinfo.icb.ufmg.br
function __get_color () {
  local color;
  color="$1";
  case "${color}" in
    red)
      echo -ne '\e[31m';
      ;;
    green)
      echo -ne '\e[32m';
      ;;
    yellow)
      echo -ne '\e[33m';
      ;;
    blue)
      echo -ne '\e[34m';
      ;;
    magenta)
      echo -ne '\e[35m';
      ;;
    cyan)
      echo -ne '\e[36m';
      ;;
    white)
      echo -ne '\e[37m';
      ;;
    *)
      echo -ne '\e[0m';
      ;;
  esac
  return 0;
}
export red="\033[1;31m";
export green="\033[1;32m"
export yellow="\033[1;33m"
export blue="\033[1;34m"
export purple="\033[1;35m"
export cyan="\033[1;36m"
export grey="\033[0;37m"
export reset="\033[m"

function __sagarana_jobs () {
  qstat;
  return 0;
}


# Terraform server environment
# + Used to make an old server withou administrative rights
# + to offer a modern command line based experience.
#' @param arch
#' @param hostname
function __terraform_cli_server () {
  local kernel_name;
  local kernel_version
  local sys_arch;
  local sys_os_name;
  local sys_os_version;
  local base_path;
  local bin_dir;
  base_path="${HOME}/.local/opt/bca/tools";
  bin_dir="${HOME}/.local/bin";
  kernel_name="$(uname -s)";
  kernel_version="$(uname -r)";
  sys_arch="$(uname -m)";

  # TODO luciorq move to a switch case approach
  if [[ ! ${kernel_name} == Linux ]]; then
    builtin echo >&2 -ne "System is not Linux.\n";
    return 1;
  else
    sys_os_name="$(grep "^NAME=" /etc/os-release | sed 's/NAME=//g' | sed 's/\"//g' | tr '[:upper:]' '[:lower:]')";
    sys_os_version="$(grep "^VERSION_ID=" /etc/os-release | sed 's/VERSION_ID=//g' | sed 's/\"//g' | tr '[:upper:]' '[:lower:]')";
  fi
  if [[ ! ${sys_arch} == x86_64 ]]; then
    builtin echo >&2 -ne "Currently, this tool is only supported on 64 bits x86 machines.\n";
    return 1;
  fi
  mkdir -p "${base_path}";
  # Install necessary dependencies tools
  case ${sys_os_name} in
    ubuntu) echo "Ubuntu <3" ;;
    cento*)
      __install_git_source;
      __install_curl_source;
  ;;
  esac

  # Install Linux Brew
  export PATH="$HOME/.local/bin:$PATH";
  local bash_bin;
  bash_bin="$(which bash)";
  "${bash_bin}" -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";

}


# ========================
# Utils
function __install_curl_source () {
  local base_path;
  local bin_dir;
  local app_name;
  base_path="${HOME}/.local/opt/bca/tools";
  bin_dir="${HOME}/.local/bin";
  app_name='curl';
  app_version='7.82.0';
  mkdir -p "${base_path}/${app_name}";
  wget -L -nv -q --no-check-certificate --output-document="${base_path}/${app_name}/${app_name}.tar.gz" "https://curl.se/download/curl-${app_version}.tar.gz";
  tar -C "${base_path}/${app_name}" -xzf "${base_path}/${app_name}/${app_name}.tar.gz";
  builtin cd "${base_path}/${app_name}/${app_name}-${app_version}";
  # make configure;
  ./configure --prefix="${base_path}/${app_name}" --without-ssl; # --with-openssl;
  make;
  make install;
  ln -sf "${base_path}/${app_name}/bin/${app_name}" "${bin_dir}";
  builtin cd "${HOME}" || return 1;
  # [[ -d ${base_path}/git/git-git-* ]] && rm -rf ${base_path}/git/git-git-*;
  # [[ -f ${base_path}/git/git.tar.gz ]] && rm "${base_path}/git/git.tar.gz";
  return 0;
}

# TODO: @luciorq Check for the implementation in bootstrap_user.sh (shell-lib)
function __install_git_source () {
  __build_git;
  return 0;
}

