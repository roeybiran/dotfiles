#!/bin/bash

# https://support.apple.com/en-us/HT201372

FILE="${BASH_SOURCE[0]}"
DIR="$(cd "$(dirname "${FILE}")" >/dev/null 2>&1 && pwd)"

BREW_FILE="${DIR}/installations/brew.conf"
CASK_FILE="${DIR}/installations/cask.conf"

echo "Ignition: Phase 1"
echo "Prerequisites:"
echo '1) a flash drive with at least 12GB of space, "Mac OS Extended"-formatted.'
echo '2) a local Mac (whose not scheduled for a reinstall) with content caching turned on.'
echo "Download the required macOS installation file from the Mac App Store:"

while true; do
	echo "Open the Mac App Store to download macOS Catalina? (y/n)"
	read -r -p "Enter choice: " choice
	if [[ "${choice}" == [Yy] ]]; then
		open "macappstores://itunes.apple.com/app/id1466841314"
		break
  else
    break
  fi
done
echo
read -r -p "Cache brew and brew cask while 'Install macOS' is downloading? (y/n) " choice

if [[ "${choice}" == [Yy] ]]; then
	while IFS= read -r app; do
		if [[ "${app}" != "#"* ]]; then
			brew fetch "${app}"
		fi
	done <"${BREW_FILE}"
	while IFS= read -r app; do
		if [[ "${app}" != "#"* ]]; then
			brew cask fetch "${app}"
		fi
	done <"${CASK_FILE}"
elif [[ "${choice}" == [Nn] ]]; then
	:
else
	exit 0
fi

echo

while true; do
	echo "All packages have been cached. Pausing execution until 'Install macOS' has finished downloading. Meanwhile, insert the aforementioned USB drive."
	echo "Once everything's done, press Y to continue, N to exit. Choice: "
	read -r choice
	if [[ "${choice}" == [Yy] ]]; then
		break
		# allow for time to breath before applescript dialog
		sleep 0.5
	elif [[ "${choice}" == [Nn] ]]; then
		exit 0
	fi

done

_target_drive=$(
	osascript <<-EOF
		on run
			tell application "Terminal"
				set targetDrive to choose folder with prompt ¬
					"Choose a target drive:" default location (alias "Macintosh HD:Volumes:")
				return POSIX path of targetDrive
			end tell
		end run
	EOF
)

# create the bootable drive
while true; do
	echo "Create a bootable drive? (y/n) "
	read -r -n 1 choice
	if [[ "${choice}" == [Yy] ]]; then
		for app in "/Applications/"*; do
			if [[ "${app}" == *"Install macOS "* ]]; then
				sudo "${app}/Contents/Resources/createinstallmedia" --volume "${_target_drive}"
				break
			fi
		done
		break 2
	elif [[ "${choice}" == [Nn] ]]; then
		break 2
	fi
done

for volume in "/Volumes/"*; do
	if [[ "${volume}" == *"Install macOS "* ]]; then
		BREW_IGNITION_DIR="${volume}/IGNITION/BREW"
		mkdir -p "${BREW_IGNITION_DIR}"
		# copy brew cache directories
		cp -R -H -v "${HOME}/Library/Caches/Homebrew" "${BREW_IGNITION_DIR}"
		# copy dotfiles directory
		break 2
	fi
done

# https://support.apple.com/en-il/HT202796
echo "Done! Press and hold the OPTION key immediately after boot and choose the newly created volume as the startup disk."
