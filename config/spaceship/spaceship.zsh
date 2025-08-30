#!/bin/zsh

SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_TRUNC=0
SPACESHIP_CHAR_SYMBOL_SUCCESS="❯ "
SPACESHIP_CHAR_SYMBOL_FAILURE="𝖷 "
SPACESHIP_GIT_PREFIX=""

source "$HOME/.zsh/spaceship-vi-mode/spaceship-vi-mode.plugin.zsh"
SPACESHIP_VI_MODE_COLOR=blue
eval spaceship_vi_mode_enable

SPACESHIP_PROMPT_ORDER=(
time
user
dir
host
git
# hg
# package
# node
# bun
# deno
# ruby
# python
# red
# elm
# elixir
# xcode
# xcenv
# swift
# swiftenv
# golang
# perl
# php
# rust
# haskell
# scala
# kotlin
# java
# lua
# dart
# julia
# crystal
# docker
# docker_compose
# aws
# gcloud
# azure
# venv
# conda
# uv
# dotnet
# ocaml
# vlang
# zig
# purescript
# erlang
# gleam
# kubectl
# ansible
# terraform
# pulumi
# ibmcloud
# nix_shell
# gnu_screen
exec_time
async
line_sep
battery
jobs
exit_code
sudo
char
vi_mode
)

# spaceship remove vi_mode
# spaceship add --after char vi_mode