#!/bin/bash

# setComputerName () {
# 	if [[ ! -e ~/.compname ]]; then
# 		computer_name=$(osascript <<-EOF 2>/dev/null
# 			set _dialog to display dialog "Choose a Name for this Computer" default answer ""
# 			if button returned of _dialog = "OK" then return text returned of _dialog
# 		EOF
# 		)
# 		if [[ "${computer_name}" ]]; then
# 			echo "${computer_name}"
# 			sudo scutil --set ComputerName "${computer_name}"
# 			sudo scutil --set HostName "${computer_name}"
# 			sudo scutil --set LocalHostName "${computer_name}"
# 			sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${computer_name}"
# 			touch ~/.compname
# 			computer_name=$(scutil --get ComputerName)
# 			echo "Chosen computer name is:" "${computer_name}"
# 		fi
# 	fi
# }
# setComputerName &

if AssetCacheManagerUtil status 2>&1 | grep --silent "Activated = 1;"; then
  echo "===> macOS content caching is active. Deactivating..."
  sudo AssetCacheManagerUtil deactivate 1>/dev/null
fi
