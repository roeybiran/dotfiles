#!/bin/bash

# https://github.com/keith/reminders-cli

function maintain() {
	# set -euo pipefail

	weekly_maintenance_dirs=(
		~/Dropbox
	)

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

	echo "Trashing sync conflicts and broken symlinks..."
	for dir in "${weekly_maintenance_dirs[@]}"; do
		find "$dir" \( -iname '*conflict*-*-*)*' -or -type l ! -exec test -e {} \; \) -exec echo "Found a Dropbox conflicted file: " {} \;
	done

	# launchbar housekeeping
	# remove logging for all actions
	# for f in "$HOME/Library/Application Support/LaunchBar/Actions/"*".lbaction/Contents/Info.plist"; do
	# 	/usr/libexec/PlistBuddy -c "Delete :LBDebugLogEnabled" "$f" 2>/dev/null
	# done

	return

	actions_identifiers=()
	launchbar_dir="$HOME/Library/Application Support/LaunchBar"
	action_support_dir="$launchbar_dir/Action Support"
	lbaction_packages=$(find "$launchbar_dir/Actions" -type d -name "*.lbaction")
	while IFS=$'\n' read -r plist; do
		actions_identifiers+=("$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$plist/Contents/Info.plist" 2>/dev/null)")
	done <<<"$lbaction_packages"
	paths="$(printf "%s\n" "$action_support_dir/"*)"
	while IFS=$'\n' read -r dir; do
		delete=true
		basename="$(basename "$dir")"
		for id in "${actions_identifiers[@]}"; do
			if test "$basename" = "$id"; then
				delete=false
			fi
		done
		if "$delete"; then
			echo "LaunchBar cleanup: $dir"
			trash "$dir"
		fi
	done <<<"$paths"
}
