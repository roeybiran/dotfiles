#!/usr/bin/env bash

# Change the user's profile picture to "Penguin"
# userList=$(dscl . list /Users UniqueID | awk '$2 > 500 {print $1}')
# for user in $userList; do
# 	sudo dscl . delete "/Users/$user" JPEGPhoto
# 	sudo dscl . create "/Users/$user" Picture "/Library/User Pictures/Animals/Penguin.tif"
# done
# [ ] Allow guests to log in to this computer
sudo sysadminctl -guestAccount off &>/dev/null
# Show input menu in login window
sudo defaults write '/Library/Preferences/com.apple.loginwindow' showInputMenu -bool true
# Show fast user switching menu as account name
defaults write "Apple Global Domain" userMenuExtraStyle -int 1

LOGIN_ITEMS=\
"/Applications/LaunchBar.app
/Applications/Hammerspoon.app"

# clears invalid items and duplicates, returns all valid ones
current_login_items=$(
	/usr/bin/osascript - "${HOME}/.Trash" <<-EOF
	on run argv
		set _seen to {}
		set _trashFolder to item 1 of argv
		tell application "System Events"
			set _loginitems to every login item
			repeat with i from 1 to count _loginitems
				set _loginitem to item i of _loginitems
				tell _loginitem
					set _path to path
					if (_path is missing value) or ((_path as text) begins with _trashFolder) or _seen contains _path then
						delete _loginitem
					else
						set hidden to true
						copy _path to end of _seen
					end if
				end tell
			end repeat
			set loginItemsList to path of every login item
			set {saveTID, text item delimiters of AppleScript} to {text item delimiters of AppleScript, {return}}
			return loginItemsList as text
			set text item delimiters of AppleScript to saveTID
		end tell
	end run
	EOF
)

while IFS=$'\n' read -r login_item; do
	if ! grep --silent "${login_item}" <<< "${current_login_items}"
	then
		/usr/bin/osascript &>/dev/null - "${login_item}" <<-EOF
			on run argv
				set _app to item 1 of argv
				tell app "System Events"
					make new login item with properties { hidden: true, path: _app }
				end tell
			end run
		EOF
	fi
done <<< "${LOGIN_ITEMS}"
