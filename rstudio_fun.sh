#!/usr/bin/env bash

function rstudio_server_local_install_from_source() {
  \builtin local install_path
  \builtin local rstudio_src_path
  \builtin local rstudio_deps_url

  rstudio_deps_url="https://rstudio-buildtools.s3.amazonaws.com"
  install_path="${HOME}/.local/opt/apps/rstudio-server"
  rstudio_src_path="${install_path}/src/rstudio-rstudio-e4392fc"

  if [[ ! -d ${install_path} ]]; then
    \mkdir -p "${install_path}"
  fi

  # \builtin cd "${install_path}"
  download https://github.com/rstudio/rstudio/tarball/v2024.04.2+764 "${install_path}"/src
  unpack "${install_path}"/src/v2024.04.2+764 "${install_path}"/src

  #\rm src/v2024.04.2+764

  #\builtin cd "${rstudio_src_path}"

  # DEPENDENCIES
  # R packages
  #   digest
  # purrr
  # rmarkdown
  # testthat
  # xml2
  # yaml

  # dictionaries
  download "${rstudio_deps_url}/dictionaries/core-dictionaries.zip" "${rstudio_src_path}/dependencies/"
  unpack "${rstudio_src_path}/dependencies/core-dictionaries.zip" "${rstudio_src_path}/dependencies/dictionaries/"

  # mathjax
  download "${rstudio_deps_url}/mathjax-27.zip" "${rstudio_src_path}/dependencies/"
  unpack "${rstudio_src_path}/dependencies/mathjax-27.zip" "${rstudio_src_path}/dependencies/mathjax-27/"
  #   \builtin cd "${rstudio_src_path}/dependencies/common"
  #   ./install_

  (
    mkdir -p "${install_path}/tools" &&
      \builtin cd "${rstudio_src_path}/dependencies/common" &&
      RSTUDIO_TOOLS_ROOT="${install_path}/tools" ./install-quarto
  )

  #
  # BUILD
  # \builtin cd "${rstudio_src_path}/build"

  # rstudio_server_build_run cmake

  # \rm -rf ${rstudio_src_path}/build

  (
    \mkdir -p "${rstudio_src_path}/build" &&
      \builtin cd "${rstudio_src_path}/build" &&
      USE_PAM=OFF RSTUDIO_USE_PAM=OFF conda run -n rstudio-build-env cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${HOME}/.local/opt/apps/rstudio-server" -DBoost_INCLUDE_DIR="${HOME}/.local/share/conda/envs/rstudio-build-env/include" -DSOCI_CORE_LIB="${HOME}/.local/share/conda/envs/rstudio-build-env/lib" -DSOCI_SQLITE_LIB="${HOME}/.local/share/conda/envs/rstudio-build-env/lib" -DRSTUDIO_TOOLS_ROOT="${install_path}/tools" -DRSTUDIO_USE_PAM:BOOL=OFF -DUSE_PAM:BOOL=OFF
  )

  (\builtin cd "${rstudio_src_path}/build" && RSTUDIO_TOOLS_ROOT="${install_path}/tools" conda run -n rstudio-build-env make install)

  \builtin return 0
}

function rstudio_server_build_env_create() {
  conda create -n rstudio-build-env -y \
    -c conda-forge -c bioconda \
    cmake ant ninja "libboost-devel=1.83.0" libboost soci-core soci-sqlite python make gcc gxx \
    r-base r-tidyverse openssl pkg-config \
    zlib
  \builtin return 0
}

function rstudio_server_build_run() {
  conda run -n rstudio-build-env "${@}"
  \buitin return 0
}

# ---
function rstudio_server_local_install_precompiled() {
  \builtin local install_path
  install_path="${HOME}/.local/opt/apps/rstudio-server"
  if [[ ! -d ${install_path} ]]; then
    \mkdir -p "${install_path}"
  fi

  download https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb "${install_path}/deb/"

  dpkg-deb -x "${install_path}/deb/rstudio-server-2024.04.2-764-amd64.deb" "${install_path}/"

  if [[ ! -d "${install_path}/config" ]]; then
    \mkdir -p "${install_path}/config"
  fi

  \builtin return 0
}

function rstudio_server_local_start() {
  \builtin local install_path
  \builtin local rserver_bin
  \builtin local db_conf_path

  install_path="${HOME}/.local/opt/apps/rstudio-server"
  rserver_bin="${install_path}/usr/lib/rstudio-server/bin/rserver"
  rsession_bin="${install_path}/usr/lib/rstudio-server/bin/rsession"

  #  RSTUDIO_CONFIG_DIR=$HOME/.config/rstudio-server-local \
  #    RSTUDIO_CONFIG_HOME=$HOME/.config/rstudio-server-local \
  #    RSTUDIO_DATA_HOME=$HOME/.local/share/rstudio-server-local \
  #    "${rserver_bin}" --auth-none=1 --www-frame-origin=same --www-port={port} --www-verify-user-agent=0 --server-data-dir={my-tmp-path} --server-pid-file={my-tmp-path}/rstudio.pid --database-config-file={my-tmp-path}/db.conf}

  #  \mkdir -p "${HOME}/.local/opt/apps/rstudio-server"

  db_conf_path="${HOME}/.config/rstudio-server-local/db.conf"
  \mkdir -p "${HOME}/.config/rstudio-server-local"
  \touch "${db_conf_path}"
  \chmod 0600 "${db_conf_path}"

  rstats_env_bin="$(conda_run r-env which R)"

  rstats_env_ld_path="$(conda_run r-env env | grep CONDA_PREFIX | sed 's|CONDA_PREFIX=||')/lib"

  \builtin echo -ne "provider=sqlite\n\ndirectory=${install_path}/var/lib/rstudio-server\n" >"${db_conf_path}"
  PATH="${install_path}/usr/lib/rstudio-server/bin":${PATH} \
    RSTUDIO_CONFIG_DIR=$HOME/.config/rstudio-server-local \
    RSTUDIO_CONFIG_HOME=$HOME/.config/rstudio-server-local \
    RSTUDIO_DATA_HOME=${install_path} \
    "${rserver_bin}" --server-user="${USER}" --server-daemonize=0 --auth-none=1 --www-port=8383 --www-frame-origin=same --www-verify-user-agent=0 \
    --server-data-dir="${HOME}/.local/share/rstudio-server-local" \
    --server-pid-file="${HOME}/.local/share/rstudio-server-local/rstudio.pid" \
    --server-working-dir="${install_path}" \
    --database-config-file="${db_conf_path}" \
    --rsession-path="${rsession_bin}" \
    --rsession-which-r="${rstats_env_bin}" \
    --rsession-ld-library-path="${rstats_env_ld_path}"

  \builtin return 0

}

# For RHEL8: `download https://s3.amazonaws.com/rstudio-ide-build/server/rhel8/x86_64/rstudio-server-rhel-2024.07.0-daily-251-x86_64.rpm`
# + `rpm2cpio rstudio-server-rhel-2024.07.0-daily-251-x86_64.rpm | cpio -idmv`

# For RHEL7:
# + 2023.12.2-407 was the last version build for rhel7
# + `download https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64/rstudio-server-rhel-2023.12.2-407-x86_64.rpm`
# + `rpm2cpio rstudio-server-rhel-2023.12.2-407-x86_64.rpm | cpio -idmv`
