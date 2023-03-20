#!/usr/bin/env bash

# TODO: @luciorq DEPRECATION NOTE
# + Update to apptainer instructions
# + this is an old version tested on Ubuntu 16.04

# Install apptainer
function __install_apptainer () {
  # install ystem dependencies
  sudo apt update -y \
    && sudo apt install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup;
  #libseccomp-dev pkg-config squashfs-tools cryptsetup
  export VERSION='1.13.1' OS='linux' ARCH='amd64' \
    && wget -O "/tmp/go${VERSION}.${OS}-${ARCH}.tar.gz" \
      "https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz" \
    && sudo tar \
      -C '/usr/local' \
      -xzf "/tmp/go${VERSION}.${OS}-${ARCH}.tar.gz";
  builtin echo 'export GOPATH=${HOME}/go' >> ${HOME}/.bashrc;
  builtin echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ${HOME}/.bashrc;
  builtin source "${HOME}/.bashrc";
  # Install golangci-lint
  curl -sfL \
    https://install.goreleaser.com/github.com/golangci/golangci-lint.sh \
    | sh -s -- -b "$(go env GOPATH)/bin" v1.15.0;
  # install singularity
  # + clone the repo
  mkdir -p ${GOPATH}/src/github.com/sylabs \
    && builtin cd ${GOPATH}/src/github.com/sylabs \
    && git clone https://github.com/sylabs/singularity.git \
    && builtin cd singularity;
  # Build Singyularity
  (
    builtin cd ${GOPATH}/src/github.com/sylabs/singularity \
    && ./mconfig \
    && builtin cd ./builddir \
    && make \
    && sudo make install
  )
  # Check installed version
  singularity version;
  return 0;
}
