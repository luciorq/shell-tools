#!/usr/bin/env bash
# shellcheck shell=bash

# TODO: replace arguments with actual variables
# + this function is not tested in any way
function run_open_ssh_server () {
  local _debug_var="${DEBUG:-false}";
  [[ "${_debug_var}" == true ]] && set -o xtrace;
  local _usage="$0 <ARGS>";
  docker run -d \
    --name=openssh-server \
    --hostname=openssh-server `#optional` \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -e PUBLIC_KEY=yourpublickey `#optional` \
    -e PUBLIC_KEY_FILE=/path/to/file `#optional` \
    -e PUBLIC_KEY_DIR=/path/to/directory/containing/_only_/pubkeys `#optional` \
    -e PUBLIC_KEY_URL=https://github.com/username.keys `#optional` \
    -e SUDO_ACCESS=false `#optional` \
    -e PASSWORD_ACCESS=false `#optional` \
    -e USER_PASSWORD=password `#optional` \
    -e USER_PASSWORD_FILE=/path/to/file `#optional` \
    -e USER_NAME=linuxserver.io `#optional` \
    -p 2222:2222 \
    -v /path/to/appdata/config:/config \
    --restart unless-stopped \
    lscr.io/linuxserver/openssh-server:latest
  return 0;
}