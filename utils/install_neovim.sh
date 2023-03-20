#!/usr/bin/env bash

# Install neovim
function __install_neovim () {
  local brew_bin;
  local brew_prefix;

  brew_bin="$(which_bin 'brew')";
  brew_prefix="$("${brew_bin}" --prefix)";
  "${brew_bin}" install neovim --HEAD;

  __install_neovim_configs;
}

# Rum Neovim commands from the CLI
# @examples `neovim_command +PlugInstall`
function neovim_command () {
  local nvim_bin;
  local nvim_cmds;
  nvim_bin="$(require 'nvim')";
  "${nvim_bin}" --headless ${nvim_cmds[@]} +qa
}

# tested on neovim 0.7 alpha
function __install_neovim_configs () {
  local npm_bin gh_bin;
  npm_bin="$(require 'npm');"
  gh_bin="$(require 'gh')";

  "${gh_bin}" repo clone \
    luciorq/neovim-lua \
    "${HOME}/workspaces/temp/neovim-lua";

  # Copy config
  # cp -Rv ${HOME}/temp/neovim-lua/nvim ${HOME}/.config/
  # install packer
  #git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  #  ${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim
  # Install Packages
  # sudo
  "${npm_bin}" install -g \
    bash-language-server \
    @emacs-grammarly/unofficial-grammarly-language-server \
    pyright \
    yaml-language-server

  # TODO luciorq install lua-language-server

  if [[ $(is_linux) ]]; then
    go install github.com/mattn/efm-langserver@latest
  elif [[ $(is_macos) ]]; then
    brew install \
      efm-langserver \
      markdownlint-cli \
      prettier
  fi

  python -m pip install --user \
    pipx \
    neovim
  # Linters
  "${npm_bin}" install -g \
    markdownlint-cli \
    prettier

  pipx install \
    vim-vint \
    yamllint \
    black


  luarocks install \
    --server=https://luarocks.org/dev \
    luaformatter
  "${nvim_bin}" --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  # neovim_command +PackerInstall
  # neovim_command +PackerSync

  # Install Language servers
  local lsp_arr;
  declare -a lsp_arr=(
    ansiblels
    bashls
    cland
    cmake
    cssls
    diagnosticls
    dockerls
    grammarly
    groovyls
    html
    perlnavigator
    pyright
    r_language_server
    sumneko_lua
    yamlls
  )
}


