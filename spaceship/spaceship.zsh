#!/bin/zsh


SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_TRUNC=0
SPACESHIP_CHAR_SYMBOL_SUCCESS="❯ "
SPACESHIP_CHAR_SYMBOL_FAILURE="𝖷 "
SPACESHIP_GIT_PREFIX=""
SPACESHIP_NODE_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_XCODE_SHOW=false
SPACESHIP_SWIFT_SHOW=false

source "$HOME/.zsh/spaceship-vi-mode/spaceship-vi-mode.plugin.zsh"
spaceship remove vi_mode
spaceship add --after char vi_mode
SPACESHIP_VI_MODE_COLOR=blue
eval spaceship_vi_mode_enable