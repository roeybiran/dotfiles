#!/usr/bin/env bash

set -euo pipefail

_keepalive() {
	sudo -v && while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
}

file="$(zsh -c 'echo ${0:A}' "$0")"
dir="$(dirname "$(zsh -c 'echo ${0:A}' "$0")")"
linkscript="$dir/link.sh"
linkdir="$dir/links"
settingsscript="$dir/settings.sh"
settingsdir="$dir/settings"
secretsdir="$dir/secrets"
installscript="$dir/install.sh"
installdir="$dir/install"

# symlink this file to $PATH
mkdir -p /usr/local/bin/ 2>/dev/null
cd /usr/local/bin || exit
test -e dotfiles && rm dotfiles
ln -sf "$file" dotfiles
if ! test -e dotfiles; then
	echo "Failed to symlink $0 to /usr/local/bin. Aborting"
	exit
fi

cd - &>/dev/null || exit

case "$1" in
link)
	"$linkscript" "$linkdir"
	exit
	;;
settings)
	_keepalive
	"$settingsscript" "$settingsdir" "$secretsdir" "$2"
	exit
	;;
install)
	_keepalive
	"$installscript" "$installdir"
	exit
	;;
esac

echo "USAGE: dotfiles <command> [option]"
echo "Available commands:"
echo "  link                    set up symlinks"
echo "  install                 install packages"
echo "  settings [file]         set up defaults"
echo "    [file]    execute a specific settings file."
