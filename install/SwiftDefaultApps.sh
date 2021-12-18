#!/bin/sh

# https://github.com/Lord-Kamina/SwiftDefaultApps
path=/usr/local/bin
if ! test -f "$path/swda"; then
	cd "$(mktemp -d)" || exit
	curl -s https://api.github.com/repos/Lord-Kamina/SwiftDefaultApps/releases/latest |
		grep browser_download_url |
		cut -d '"' -f 4 |
		xargs -n 1 curl -LO |
		xargs -n 1 unzip
	mv swda "$path"
	cd - || exit
fi
