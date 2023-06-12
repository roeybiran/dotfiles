#!/bin/bash

# https://github.com/keith/reminders-cli

function maintain() {
	now="$(date +%s)"

	if [ "$1" = --check ]; then
		last_update_date="$(defaults read "$dotfiles_prefs" maintainanceLastRunDate 2>/dev/null)"
		if [ -z "$last_update_date" ]; then
			# first run
			last_update_date="$now"
		fi
		time_elapsed_since_last_update=$(((now - last_update_date) / 86400))
		if [ "$time_elapsed_since_last_update" -gt 7 ]; then
			echo "Please perform maintenance (last performed $time_elapsed_since_last_update days ago)."
		fi
		return
	fi

	if [ "$1" = --run ]; then
		dependencies=(
			trash
		)

		dotfiles_prefs=~/Library/Preferences/com.roeybiran.dotfiles.plist

		weekly_maintenance_dirs=(
			~/Dropbox
		)

		for f in "${dependencies[@]}"; do
			if ! command -v "$f" &>/dev/null; then
				echo "Missing depedency: $f. Exiting"
				exit
			fi
		done

		sudo -v
		while true; do
			sudo -n true
			sleep 60
			kill -0 "$$" || exit
		done 2>/dev/null &

		echo "Updating package managers..."

		# mas
		echo ">> mas upgrade"
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

		defaults write "$dotfiles_prefs" maintainanceLastRunDate -int "$now"

		# if [ -f "$flag" ]; then
		# 	trash "$flag"
		# fi

		# if softwareupdate --all --install --force 2>&1 | tee /dev/tty | grep -q "No updates are available"; then
		# 	sudo rm -rf /Library/Developer/CommandLineTools
		# 	sudo xcode-select --install
		# fi
	fi

	echo "USAGE: maintain [--run|--check]"

}
