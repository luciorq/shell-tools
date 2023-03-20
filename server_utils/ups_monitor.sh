#!/usr/bin/env bash


# Not to technicial or accurate video tutorial:
# + https://www.youtube.com/watch?v=vyBP7wpN72c
# TODO: Find better tutorial

__install_ups_monitor_deps () {
  local sudo_bin;

  sudo_bin="$(which_bin 'sudo')";


  "${sudo_bin}" apt install \
    nut \
    nut-client \
    nut-server \
    libneon27-dev \


  # Scan for autodetected UPSs
  # + -C for complete search
  # + -U to only search USB devices
  "${sudo_bin}" nut-scanner -C

  # TODO: Edit all the following
  # + /etc/nut/{nut,ups,upsmon}.conf
  # + /etc/nut/upsd.users

}
