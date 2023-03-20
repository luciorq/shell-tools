#!/usr/bin/env bash

function install_open_mpi () {
  local omp_version;
  local xy_version;
  omp_version="${1:-4.1.2}";
  xy_version="${omp_version%%.[0-9]}";
  wget \
    "https://download.open-mpi.org/release/open-mpi/v${xy_version}/openmpi-${omp_version}.tar.gz";
  gunzip -c "openmpi-${omp_version}.tar.gz" | tar xf -
  (
    builtin cd "openmpi-${omp_version}" \
      && . ./configure --prefix=/usr/local \
      && sudo make all install
  )
  return 0;
}
