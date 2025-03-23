#!/usr/bin/env python

from pyinfra.operations import server, host

server.shell(
  name = "Return os-release file content",
  commands = [
    r"cat /etc/os-release",
  ]
)

server.shell(
  name = "install all pixi global tools for user",
  commands = [
    r"~/.local/bin/pixi global sync",
  ]
)