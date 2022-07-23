#!/usr/bin/env bash

dir="${1:?ERR! no config_files_dir argument supplied}"

command -v brew 1>/dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle install --global --no-upgrade --no-lock
for f in "$dir"/install/*.sh; do
	echo ">>> $(basename "$f" | sed -E 's/[[:digit:]]+_//')"
	sh "$f"
done

# pdftk
test -d "/opt/pdflabs/pdftk/" && exit

# https://gist.github.com/jvenator/9672772a631c117da151
# https://stackoverflow.com/questions/32505951/pdftk-server-on-os-x-10-11/33248310#33248310
url="https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg"
tmpdir="$(mktemp -d)"
cd "${tmpdir}" || exit
echo "Downloading pdftk..."
downloaded="$(curl --progress-bar --location --remote-name --write-out '%{filename_effective}' "${url}")"
sudo installer -pkg "${downloaded}" -target /

# https://github.com/Lord-Kamina/SwiftDefaultApps
path=~/.local/bin
mkdir -p "$path" 1>/dev/null 2>&1
if ! test -f "$path/swda"; then
	cd "$(mktemp -d)" || exit
	curl -s https://api.github.com/repos/Lord-Kamina/SwiftDefaultApps/releases/latest |
		grep browser_download_url |
		cut -d '"' -f 4 |
		xargs -n 1 curl -LO |
		xargs -n 1 unzip
	open "$PWD"
	# mv swda "$path"
fi
