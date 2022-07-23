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
linkscript="$dir/link.sh"
linkdir="$dir/links"
settingsscript="$dir/exec/settings.sh"
settingsdir="$dir/settings"
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
	echo "Available commands:"
	echo "  link                    set up symlinks"
	echo "  install                 install packages"
	echo "  settings [file]         set up defaults"
	echo "    [file]    execute a specific settings file."
	;;
esac
