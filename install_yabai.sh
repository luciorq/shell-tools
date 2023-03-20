#!/usr/bin/env bash

# Install YABAI development version
# + before starting create a self signing certificate
# + following inscrctions from:
# + https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)#macos-big-sur-and-monterey---automatically-load-scripting-addition-on-startup
function __install_yabai () {
  local brew_bin;
  local _hb_prefix;
  local _xav;
  local yabai_bin;
  local _plugin;
  brew_bin="$(require 'brew')";
  if [[ -z ${brew_bin} ]]; then
    exit_fun "Unable to find 'brew' binary";
    return 1;
  fi

  _hb_prefix="$(brew --prefix)";

  # Install
  brew install koekeishiya/formulae/yabai --HEAD;

  # Key bindings for yabai
  brew install koekeishiya/formulae/skhd --HEAD;

  # TODO: @luciorq Remove karabiner dependency
  # + test all funcitonality using skhd
  # Change keyboard behavior on MacOS
  # brew install --cask karabiner-elements

  # Spacebar - Menu bar
  # brew install cmacrae/formulae/spacebar
  # SketchyBar - Menu bar
  brew install FelixKratz/formulae/sketchybar;
  brew tap homebrew/cask-fonts;
  brew install --cask font-hack-nerd-font;

  # NOTE: @luciorq If full functionality is required, please
  # + disable SIP
  builtin echo >&2 -ne \
    "Disable SIP for full funcionality.\nPress Enter to Continue:\n";
  builtin read -r _xav;
  # TODO: @luciorq Is this still required?
  # + sudo nvram boot-args=-arm64e_preview_abi

  # Create a self signing certificate
  builtin echo >&2 -ne \
    "Create a Self Signing certificate to continue.\nPress Enter to Continue:";
  builtin read -r _xav;


  # TODO: @luciorq Use check_in_file to test
  # + if yabai can be run sudo without password
  local sa_auth_string;
  local sa_auth_present;
  sa_auth_string="${USER} ALL = (root) NOPASSWD: ${_hb_prefix}/bin/yabai";
  sa_auth_present="$(
    check_in_file "${sa_auth_string}" '/private/etc/sudoers.d/yabai'
  )";
  if [[ ! -f /private/etc/sudoers.d/yabai ]]; then
    sudo touch "/private/etc/sudoers.d/yabai";
    sudo chmod 0440 "/private/etc/sudoers.d/yabai";
  fi
  if [[ ${sa_auth_present} == false ]]; then
    builtin echo "${sa_auth_string}" \
      | sudo tee -a "/private/etc/sudoers.d/yabai";
  fi

  # Sign, it will prompt to authenticate
  yabai_bin="$(require 'yabai')";
  if [[ -z ${yabai_bin} ]]; then
    exit_fun "Unable to find 'yabai' binary";
    return 1;
  fi

  codesign -fs 'yabai-cert' $(which_bin 'yabai');
  codesign -fs 'yabai-cert' $(which_bin 'skhd');

  # copy example config files
  # TODO: @luciorq Make it xdg base dirs compliant, i.e. add XDG variables

  # For Yabai
  if [[ ! -d ${HOME}/.config/yabai ]]; then
    \mkdir -p "${HOME}/.config/yabai";
  fi
  if [[ ! -f ${HOME}/.config/yabai/yabairc ]]; then
    \cp "${_hb_prefix}/opt/yabai/share/yabai/examples/yabairc" \
      "${HOME}/.config/yabai/yabairc";
  fi
  \chmod +x "${HOME}/.config/yabai/yabairc";

  # For SKHD
  if [[ ! -d ${HOME}/.config/skhd ]]; then
    \mkdir -p "${HOME}/.config/skhd";
  fi
  if [[ ! -f ${HOME}/.config/skhd/skhdrc ]]; then
    \cp "${_hb_prefix}/opt/yabai/share/yabai/examples/skhdrc" \
      "${HOME}/.config/skhd/skhdrc";
  fi
  \chmod +x "${HOME}/.config/skhd/skhdrc";

  # For SpaceBar
#  if [[ ! -d ${HOME}/.config/spacebar ]]; then
#   \mkdir -p "${HOME}/.config/spacebar";
#  fi
#  if [[ ! -f ${HOME}/.config/skhd/spacebar ]]; then
#    \cp "${_hb_prefix}/opt/spacebar/share/spacebar/examples/spacebarrc" \
#    "${HOME}/.config/spacebar/spacebarrc";
# fi
#  \chmod +x "${HOME}/.config/spacebar/spacebarrc";

  # For SketchyBar
  if [[ ! -d ${HOME}/.config/sketchybar ]]; then
    \mkdir -p "${HOME}/.config/sketchybar";
  fi
 if [[ ! -d ${HOME}/.config/sketchybar/plugins ]]; then
    \mkdir -p "${HOME}/.config/sketchybar/plugins";
  fi
  if [[ ! -f ${HOME}/.config/sketchybar/sketchybarrc ]]; then
    \cp "${_hb_prefix}/opt/sketchybar/share/sketchybar/examples/sketchybarrc" \
      "${HOME}/.config/sketchybar/sketchybarrc";
  fi
  if [[ ! -f ${HOME}/.config/sketchybar/plugins/space.sh ]]; then
    \cp -r \
      "${_hb_prefix}/opt/sketchybar/share/sketchybar/examples/plugins" \
      "${HOME}/.config/sketchybar";
    for _plugin in "${HOME}/.config/sketchybar/plugins/"*; do
      \chmod +x "${_plugin}";
    done
  fi

  # Enable accessibility API permission
  # TODO: @luciorq Add a wait till confirm button and open system preferences
  builtin read -r _xav;
  # start service
  brew services start koekeishiya/formulae/yabai;
  brew services start koekeishiya/formulae/skhd;
  # brew services start cmacrae/formulae/spacebar;
  brew services start felixkratz/formulae/sketchybar;

  # Disable finder animation that interrupts tiling
  defaults write com.apple.finder DisableAllAnimations -bool true;
  # If this setting needs to be reset, execute:
  # + defaults delete com.apple.finder DisableAllAnimations
  return 0;
}

