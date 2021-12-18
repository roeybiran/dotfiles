#!/usr/bin/env bash

dir="${1:?ERR! no config_files_dir argument supplied}"

command -v brew 1>/dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle install --no-upgrade --no-lock
for f in "$dir"/install/*.sh; do
	echo ">>> $(basename "$f" | sed -E 's/[[:digit:]]+_//')"
	"$f"
done
