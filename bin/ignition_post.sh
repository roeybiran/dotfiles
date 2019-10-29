#!/usr/bin/env bash

# copy brew caches
COPY_OK=false

for volume in "/Volumes/"*; do
	if [[ "${volume}" == *"Install macOS "* ]]; then
		BREW_IGNITION_DIR="${volume}/IGNITION/BREW/Homebrew/"
		BREW_TARGET_DIR="${HOME}/Library/Caches/Homebrew/"
		mkdir -p "${BREW_TARGET_DIR}"
		rsync --archive --human-readable --progress "${BREW_IGNITION_DIR}" "${BREW_TARGET_DIR}"
		COPY_OK=true
		break 2
	fi
done

if [[ ! "${COPY_OK}" ]] && [[ ! -d "${BREW_TARGET_DIR}/downloads" ]]; then
  echo "Could not not find the Homebrew cache directory. Aborting"
  exit 0
fi

if ! command -v brew &>/dev/null; then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [[ ! -d "/Applications/1Password 7.app" ]] || [[ ! -d "/Applications/Dropbox.app" ]]; then
	brew cask install 1password dropbox && open -a "1Password 7" && open -a "Dropbox"
fi

while true
do
	printf "%s" 'Type "y" and press return once /dotfiles has been downloaded. '
	read -r REPLY
	if [[ "${REPLY}"  == "y" ]]
	then
		break
	fi
done

/usr/bin/osascript &>/dev/null <<-EOF &
	tell application "System Preferences"
		reveal anchor "Privacy_AllFiles" of pane id "com.apple.preference.security"
		activate
		authorize current pane
	end tell
EOF
echo "IMPORTANT! Make sure Terminal.app has Full Disk Access. Press any key to continue. "
read -r

export IGNITION_MODE=true

~/Dropbox/dotfiles/dotfiles.sh
