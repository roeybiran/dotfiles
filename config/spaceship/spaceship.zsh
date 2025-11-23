#!/bin/zsh

SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_TRUNC=0
SPACESHIP_CHAR_SYMBOL_SUCCESS="❯ "
SPACESHIP_CHAR_SYMBOL_FAILURE="𝖷 "
SPACESHIP_GIT_PREFIX=""

# vi mode
source "$HOME/.zsh/spaceship-vi-mode/spaceship-vi-mode.plugin.zsh"
eval spaceship_vi_mode_enable
SPACESHIP_VI_MODE_COLOR=red

SPACESHIP_PROMPT_ORDER=(
	time
	user
	dir
	host
	git
	exec_time
	async
	line_sep
	jobs
	exit_code
	sudo
	char
	vi_mode
)
