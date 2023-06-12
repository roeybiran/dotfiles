#!/bin/bash

command -v brew 1>/dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle install --global --no-upgrade --no-lock

# https://github.com/Lord-Kamina/SwiftDefaultApps
path=~/.local/bin
if [ -f "$path/swda" ]; then
	mkdir -p "$path" 1>/dev/null 2>&1
	cd "$(mktemp -d)" || exit
	curl -s https://api.github.com/repos/Lord-Kamina/SwiftDefaultApps/releases/latest |
		grep browser_download_url |
		cut -d '"' -f 4 |
		xargs -n 1 curl -LO |
		xargs -n 1 unzip
	open "$PWD"
fi
