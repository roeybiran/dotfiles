#!/usr/bin/env bash

set -euo pipefail

_keepalive() {
	sudo -v && while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
}

dir="$(dirname "$(zsh -c 'echo ${0:A}' "$0")")"
linkscript="$dir/symlink.sh"
linkdir="$dir/symlink"
settingsscript="$dir/config.sh"
settingsdir="$dir/config"
secretsdir="$dir/secrets"
installscript="$dir/install.sh"
installdir="$dir/install"

case "${1:-help}" in
link)
	"$linkscript" "$linkdir"
	;;
config)
	"$settingsscript" "$settingsdir" "$secretsdir" "${2-""}"
	;;
install)
	"$installscript" "$installdir"
	;;
*)
	echo "USAGE: dotfiles <command> [option]"
	;;
esac
