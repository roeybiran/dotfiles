#!/bin/bash

command -v brew 1>/dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle install --global

# https://sourceforge.net/projects/aoo-extensions/files/1155/3/dict-he-2010-11-05.oxt
if [ ! -f ~/Library/Spelling/he_IL.dic ] || [ ! -f ~/Library/Spelling/he_IL.aff ]; then
	echo "Installing Hebrew spellchecking dictionary"
	tmpdir="$(mktemp -d)"
	cd "$tmpdir" || exit
	curl --progress-bar --location --remote-name "https://downloads.sourceforge.net/project/aoo-extensions/1155/3/dict-he-2010-11-05.oxt?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Faoo-extensions%2Ffiles%2F1155%2F3%2Fdict-he-2010-11-05.oxt%2Fdownload%3Fuse_mirror%3Djaist&ts=1571244020"
	unzip -o ./* he_IL.{dic,aff} -d ~/Library/Spelling/
	rm -rf "$tmpdir"
	cd || exit
fi
