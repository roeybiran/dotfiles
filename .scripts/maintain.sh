#!/bin/bash

# https://github.com/keith/reminders-cli

function maintain() {
	# set -euo pipefail

	echo "Updating package managers..."

	# mas
	echo ">> updating mas apps"
	mas upgrade

	# npm
	echo ">> updating npm"
	npm install -g npm@latest
	echo ">> updating global npm packages"
	npm update -g

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

	# launchbar housekeeping
	# remove logging for all actions
	# for f in "$HOME/Library/Application Support/LaunchBar/Actions/"*".lbaction/Contents/Info.plist"; do
	# 	/usr/libexec/PlistBuddy -c "Delete :LBDebugLogEnabled" "$f" 2>/dev/null
	# done
}
