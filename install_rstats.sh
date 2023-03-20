#!/usr/bin/env bash

# Install R (r-devel) from source
# + Linking to openMP and FL
function __install_rstats_source_hb () {

  # Deps: as of https://cran.r-project.org/doc/manuals/r-devel/R-admin.html#Essential-and-useful-other-programs-under-a-Unix_002dalike
  # + gcc,
  # + gfortran
  # + readline - headers at:
  # + libiconv
  # + zlib
  # + libbz2 - 'brew install bzip2'
  # + liblzma, actually included in 'brew install xz'
  # + pcre2
  # + libcurl
  # Execute to expose the libcurl variables:
  # + texinfo
  # + texi2html
  # + gettext
  # + cairo
  # + pango
  # + libjpeg: brew install jpeg
  # + libpnb
  # + libtiff

  # === Non essential support ===
  # + tcltk - brew install tcl-tk
  # + java - openjdk
  # For linux, additionally, apt names:
  # + xorg-dev

  local brew_bin;
  local brew_pkgs brew_pkg;
  brew_bin="$(which_bin 'brew')"
  declare -a brew_pkgs=(
    bzip2
    xz
    curl
    grep
    gnu-sed
    gnu-tar
    gettext
    texinfo
    texi2html
    libomp
    libiconv
    cairo
    pango
    jpeg
    libpng
    libtiff
    tcl-tk
    lapack
    make
    bash
    webp
    openjpeg
    openjdk
    llvm
    open-mpi
    binutils
    pcre2
    readline
    coreutils
    gfortran
    gcc
  )
  for brew_pkg in "${brew_pkgs[@]}"; do
    "${brew_bin}" install "${brew_pkg}";
  done

  # Casks
  brew install --cask mactex
  brew install --cask xquartz

  # ========================================================================
  # using custom tap from https://github.com/sethrfore/homebrew-r-srf
  # + Formula: sethrfore/r-srf/r
  local formula_path
  if [[ -f r.rb ]]; then
    formula_path="./r.rb";
  else
    formula_path="sethrfore/r-srf/r";
  fi
  # brew tap sethrfore/homebrew-r-srf
  brew install --build-from-source \
    "${formula_path}" \
    --with-cairo-x11 \
    --with-tcl-tk-x11 \
    --with-libtiff \
    --with-openjdk \
    --with-texinfo \
    --with-openblas \
    --with-icu4c

  # After install
  \sudo ln -sfn \
    /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
    /Library/Java/JavaVirtualMachines/openjdk.jdk
  \sudo R CMD javareconf
}

# Install R from CRAN source
function __install_rstats_source_cran () {
# ========================================================================
  # Using devel source from cran
  # For R-devel
  downlaod https://stat.ethz.ch/R/daily/R-devel.tar.gz r-tmp/
  unpack r-tmp/R-devel.tar.gz r-tmp/
  builtin cd r-tmp/R-devel

  local pkg path_str ld_str pkgconfig_str;
  local lib_str include_str;
  local brew_prefix;
  brew_prefix="$(brew --prefix)";
  _bp="${brew_prefix}/opt";

  bca_prefix="${HOME}/.local/opt/bca"

  path_str="${PATH}";
  ld_str="/opt/homebrew/lib";
  lib_str="-L/opt/X11/lib -L/opt/homebrew/lib";
  include_str="-I/opt/X11/include -I/opt/homebrew/include";
  pkgconfig_str="/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig";

  for pkg in "${brew_pkgs[@]}"; do
    path_str="${_bp}/${pkg}/bin:${path_str}";
    lib_str="-L${_bp}/${pkg}/lib ${lib_str}";
    ld_str="${_bp}/${pkg}/lib:${ld_str}";
    include_str="-I${_bp}/${pkg}/include ${include_str}";
    pkgconfig_str="${_bp}/${pkg}/lib/pkgconfig:${pkgconfig_str}";
  done

  # https://colinfay.me/r-installation-administration/appendix-b-configuration-on-a-unix-alike.html

  # TODO luciorq define ld_flags and cpp_flags based on the lib_str and include_str, respectively
  # Custom try with homebrew
  # + --enable-jit is broken on arm64
  dash_ver='-11'

  export PATH="${path_str}"
  export LD_LIBRARY_PATH="${ld_str}"
  export JAVA_HOME="${brew_prefix}/opt/openjdk"
  export R_JAVA_HOME="${brew_prefix}/opt/openjdk"
  export R_BATCHSAVE='--no-save'
  export R_PAPERSIZE='a4'
  export R_BROWSER='/usr/bin/open'
  export R_SHELL="${brew_prefix}/bin/bash"
  export CC=clang
  export FC=gfortran
  export CXX=clang++
  export LIBS="${lib_str}"
  export MAKE=cmake
  export TAR=gtar
  export SED=gsed
  # export LDFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${lib_str}"
  export LDFLAGS="${lib_str}"
  # export CFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export CFLAGS="${include_str}"
  # export FFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export FFLAGS="${include_str}"
  # export CXXFLAGS="-mtune=native -g -O2 -Wall -pedantic -Wconversion ${include_str}"
  export CPPFLAGS="${include_str}"
  export CXXFLAGS="${include_str}"
  export PKG_CONFIG="${brew_prefix}/bin/pkg-config"
  export PKG_CONFIG_PATH="${pkgconfig_str}"
  ./configure \
    --config-cache \
    --prefix="${bca_prefix}/R/devel" \
    --enable-memory-profiling \
    --with-blas \
    --with-lapack \
    --with-x=no \
    --x-includes="/opt/X11/include" \
    --x-libraries="/opt/X11/lib" \
    --with-readline=yes \
    --with-pcre2 \
    --with-tcltk \
    --without-aqua \
    --with-libpng \
    --with-jpeglib \
    --with-libtiff \
    --with-cairo \
    --with-recommended-packages

  # To remove macos specific variations
  # + use: --without-aqua
  #   --enable-R-shlib \
  # + not working: --enable-utf8 and --enable-jit
  n_threads="$(get_nthreads 24)";
  make_threads="$((n_threads+1))";
  gmake -j "${make_threads}" -O;
  gmake install;
  # After Install ===============================================
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  sudo R CMD javareconf

  return 0;
}

# ========================
# Install Homebrew R
# + and tries to fix broken package installations on arm64 MacOS
# TODO luciorq Add checks for package already installed and working correctly
function __install_rstats_hb () {
  local config_sub_path;
  brew install \
    gh \
    openssl \
    automake \
    gmake;

  # FS broken
  fs_path="${HOME}/temp/clones/fs";
  gh repo clone r-lib/fs "${fs_path}";
  config_sub_path='${HOME}/temp/clones/fs/src/libuv*/config.sub';
  config_sub_path=$(realpath $(eval echo "$config_sub_path"));
  builtin echo 'echo arm-apple-darwin' > "${config_sub_path}";
  r_bin="$(which_bin R)";
  dep_r_pkg='remotes';
  "${r_bin}" -q -s -e "if(isFALSE(base::requireNamespace('${dep_r_pkg}',quietly=TRUE))){install.packages('${dep_r_pkg}')}";
  "${r_bin}" -q -s -e "remotes::install_local(path='${fs_path}')";
  rm -rf "${fs_path}";

  # HTTPUV broken
  pkg_repo='rstudio/httpuv';
  pkg_name="$(basename ${pkg_repo})";
  clone_path="${HOME}/temp/clones/${pkg_name}";
  gh repo clone ${pkg_repo} "${clone_path}";
  fd_bin="$(require 'fd')";
  config_sub_path=$("${fd_bin}" --no-ignore --hidden --follow "config.sub" "${clone_path}/src")
  builtin echo 'echo arm-apple-darwin' > "${config_sub_path}";
  "${r_bin}" -q -s -e "remotes::install_local(path='${clone_path}')";
  rm -rf "${clone_path}";

  # stringi broken
  brew reinstall icu4c
  "${r_bin}" -q -s -e \
    "withr::with_makevars(c(CC='gcc-11',CXX='g++-11',CXXFLAGS='-fopenmp -L/opt/homebrew/opt/icu4c/lib'),install.packages('stringi',type='source'))"

  # gaborcsardi/prompt broken
  # pkg_repo='gaborcsardi/prompt'
  # pkg_name="$(basename ${pkg_repo})";
  # clone_path="${HOME}/temp/clones/${pkg_name}";
  # gh repo clone ${pkg_repo} "${clone_path}";
}

# Install R packages
function __install_rstats_packages () {
  local config_path;
  config_path="${_LOCAL_CONFIG}/vars/rstats_packages.yaml";

  builtin mapfile -t cran_packages < <(
    parse_yaml "${config_path}" default cran_packages
  );
  builtin mapfile -t bioc_packages < <(
    parse_yaml "${config_path}" default bioc_packages
  );
  builtin mapfile -t gh_packages < <(
    parse_yaml "${config_path}" default gh_packages
  );

  declare -a brew_deps=(
    curl
    openssl
    libgit2 # gert
    llvm
    automake
    nlopt
    boost
    proj
    openjdk
  )

  local sudo_bin r_bin ln_bin;
  ln_bin="$(which_bin 'ln')";
  sudo_bin="$(which_bin 'sudo')";
  r_bin="$(require 'R')";

  if [[ $(uname -s) == Darwin ]]; then
    # brew dependencies
    brew install "${brew_deps[@]}";
    "${sudo_bin}" "${ln_bin}" -sfn \
      /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
      /Library/Java/JavaVirtualMachines/openjdk.jdk;
  fi
  "${sudo_bin}" "${r_bin}" CMD javareconf;

  # Install Package CRAN
  for cran_pkg in "${cran_packages[@]}"; do
    install_rstats_pkg "${cran_pkg}";
  done

  install_rstats_pkg 'remotes';
  #  from GitHub
  for gh_pkg in "${gh_packages[@]}"; do
    # gh_pkg_name="$(basename ${gh_pkg})";
    install_rstats_pkg "${gh_pkg}" 'gh';
  done
  # from BioConductor
  install_rstats_pkg 'BiocManager';
  # For devel Bioconductor
  R -q -s -e \
    "if(requireNamespace('BiocManager',quietly=TRUE)){BiocManager::install(version='devel')}";
  R -q -s -e \
    "if(requireNamespace('BiocManager',quietly=TRUE)){BiocManager::install()}";
  for bioc_pkg in "${bioc_packages[@]}"; do
    install_rstats_pkg "${bioc_pkg}" 'bioc';
  done
}


# TODO replace pkg_name variables and cran_pkg, they are wrong

function install_rstats_pkg () {
  local pkg_name;
  local pkg_type
  local r_bin;
  local num_threads;
  cran_pkg="$1";
  pkg_type="${2:-cran}";
  r_bin="$(require 'R')";
  case ${pkg_type} in
    cran)      install_str='install.packages'           ;;
    gh)        install_str='remotes::install_github'    ;;
    local)     install_str='remotes::install_local'     ;;
    bioc*)     install_str='BiocManager::install'       ;;
    *)
      builtin echo >&2 -ne "'${pkg_type}' not available as a Source.\n";
      return 1;
    ;;
  esac
  num_threads="$(get_nthreads 24)";

  "${r_bin}" -q -s -e \
    "if(isFALSE(base::requireNamespace('${cran_pkg}',quietly=TRUE))){${install_str}('${cran_pkg}',Ncpus=${num_threads})}";
}


function __install_rstats_precompiled_ubuntu () {

  local r_version;
  # local rstudio_version;
  local sudo_bin rm_bin ln_bin;
  local ubuntu_version;
  local apt_bin;
  local temp_dir;
  sudo_bin="$(which_bin 'sudo')";
  rm_bin="$(which_bin 'rm')";
  ln_bin="$(which_bin 'ln')";
  # apt_bin="$(which_bin 'nala')";
  #if [[ -z ${apt_bin} ]]; then
  apt_bin="$(which_bin 'apt')";
  #fi
  r_version="${1:-4.2.1}";
  # rstudio_version=2022.06.0-daily-136
  ubuntu_version="$(. '/etc/os-release' && echo "${ID}-${VERSION_ID/\./}")";
  "${sudo_bin}" "${apt_bin}" update --yes
  "${sudo_bin}" "${apt_bin}" upgrade --yes
  "${sudo_bin}" "${apt_bin}" install --yes gdebi-core
  temp_dir="$(create_temp 'inst-rstats')";
  \curl -fsSL \
    -o "${temp_dir}/r-${r_version}_1_amd64.deb" \
    "https://cdn.rstudio.com/r/${ubuntu_version}/pkgs/r-${r_version}_1_amd64.deb"
  \sudo gdebi -n "${temp_dir}/r-${r_version}_1_amd64.deb"

  if [[ -e /usr/local/bin/R ]]; then \sudo rm /usr/local/bin/R; fi
  if [[ -e /usr/local/bin/Rscript ]]; then \sudo rm /usr/local/bin/Rscript; fi
  "${sudo_bin}" "${ln_bin}" -sf \
    "/opt/R/${r_version}/bin/R" "/usr/local/bin/R"
  "${sudo_bin}" "${ln_bin}" -sf \
    "/opt/R/${r_version}/bin/Rscript" "/usr/local/bin/Rscript"

  # curl -O https://s3.amazonaws.com/rstudio-ide-build/desktop/bionic/amd64/rstudio-${rstudio_version}-amd64.deb
  # sudo gdebi -n rstudio-${rstudio_version}-amd64.deb

  "${rm_bin}" "${temp_dir}"/r-*
  #rm "${temp_dir}"~/temp/rstudio-*
  "${rm_bin}" -rf "${temp_dir}";
  return 0;
}

# sysreqs file generated by:
# + cat utils/install_rstats_ubuntu_sysreqs.sh | grep "^apt\-get" | grep -v '^#' | cut -d' ' -f 4 | sort | uniq > utils/rstats_ubuntu_sysreqs.txt
# + using RSPM data
function __install_rstats_sysreqs_ubuntu () {
  local lib_path;
  local sysreqs_arr;
  local apt_bin;
  local cat_bin;
  lib_path="$(get_lib_path 'shell-lib')";
  apt_bin="$(which_bin 'nala')";
  if [[ -z ${apt_bin} ]]; then
    apt_bin="$(which_bin 'apt')";
  fi
  cat_bin="$(which_bin 'cat')";
  builtin mapfile -t sysreqs_arr < <(
    "${cat_bin}" "${lib_path}/utils/rstats_ubuntu_sysreqs.txt"
  );
  sudo "${apt_bin}" install "${sysreqs_arr[@]}";
  return 0;
}

# =============================================================================
# Install RStudio related functions
# =============================================================================

# Install RStudio Desktop MacOS, using Homebrew
# + Currently not working with ARM source compiled R versions
# + Electron version will have native ARM support for MacOS
# + <https://github.com/rstudio/rstudio/issues/8652#issuecomment-1082077752>
# + and <https://s3.amazonaws.com/rstudio-ide-build/electron/macos>
function __install_rstudio_desktop () {
  local _usage="Usage: ${0} [daily-electron|daily|preview|current]";
  unset _usage;
  local release_type;
  local brew_bin;
  local os_type;
  release_type="${1:-current}";
  os_type="${os_type}";

  if [[ ${os_type} == "Darwin" ]]; then
    brew_bin="$(require 'brew')";
    "${brew_bin}" tap luciorq/homebrew-rs-daily;
    case ${release_type} in
      daily-electron)
        "${brew_bin}" install --cask luciorq/rs-daily/rstudio-daily-electron;
      ;;
      daily)
        "${brew_bin}" install --cask homebrew/cask-versions/rstudio-daily;
      ;;
      preview)
        "{brew_bin}" install --cask homebrew/cask-versions/rstudio-preview;
      ;;
      current)
        "${brew_bin}" install --cask rstudio;
      ;;
      *) builtin echo >&2 -ne "'${release_type}' not available.\n";;
    esac
  fi
  return 0;
}

function __get_latest_rstudio_electron () {
  local jq_bin;
  local sed_bin;
  local curl_bin;
  local json_var;
  local rs_daily_url;
  local rs_daily_hash;
  jq_bin="$(require 'jq')";
  curl_bin="$(require 'curl')";
  sed_bin="$(builtin command which 'sed')";
  json_var="$(
    "${curl_bin}" \
      -L -s -S -f \
      'https://dailies.rstudio.com/rstudio/latest/index.json'
  )";
  rs_daily_url="$(
    builtin echo ${json_var} \
      | "${sed_bin}" 's|, }| }|g' \
      | "${jq_bin}" '.products.electron.platforms.macos.link | values' \
      | "${sed_bin}" 's|\"||g'
  )";
  rs_daily_hash="$(
    builtin echo ${json_var} \
      | "${sed_bin}" 's|, }| }|g' \
      | "${jq_bin}" '.products.electron.platforms.macos.sha256 | values' \
      | "${sed_bin}" 's|\"||g'
  )";
  builtin echo "${rs_daily_url}";
  return 0;
}

# =============================================================================
# RIG - R Installation Manager
# =============================================================================

# Dev version @ https://github.com/r-lib/rig
function __install_rstats_rig () {
  local brew_bin;
  local rig_bin;
  brew_bin="$(require 'brew')";
  "${brew_bin}" tap r-lib/rig;
  "${brew_bin}" install --cask rig;
  rig_bin="$(which_bin 'rig')";
  "${rig_bin}" add devel;
  return 0;
}
