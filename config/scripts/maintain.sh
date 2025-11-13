#!/bin/bash

# https://github.com/keith/reminders-cli

maintain() {
	# set -euo pipefail

	echo "Updating package managers..."

	# npm
	# echo ">> updating npm"
	# npm install -g npm@latest
	# echo ">> updating global npm packages"
	# npm update -g

	# brew
	# update brew itself and all formulae
	echo ">> brew update"
	brew update
	# update casks and all unpinned formulae
	echo ">> brew upgrade"
	brew upgrade
	echo ">> brew cleanup"
	brew cleanup
	echo ">> brew autoremove"
	brew autoremove
	echo ">> brew doctor"
	brew doctor

	# mas
	echo ">> updating mas apps"
	mas upgrade

	backup_repos_from_github --dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/stuff/projects/_code"
	backup_dotfiles
}
