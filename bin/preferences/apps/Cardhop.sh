#!/bin/bash

# hide in menu bar
defaults write 'com.flexibits.cardhop.mac' HideInMenubar -bool true
# hide in dock
defaults write 'com.flexibits.cardhop.mac' HideInDock -bool true
# Keyboard shortcut: [Record Shortcut]
defaults write 'com.flexibits.cardhop.mac' HotKeyEmpty -int 1
# Skip first run setup
defaults write 'com.flexibits.cardhop.mac' FirstRunSetup -bool true
# Update automatically
defaults write 'com.flexibits.cardhop.mac' SUAutomaticallyUpdate -bool true
defaults write 'com.flexibits.cardhop.mac' SUEnableAutomaticChecks -bool true
defaults write 'com.flexibits.cardhop.mac' SUHasLaunchedBefore -bool true
# Allow dialing local numbers
defaults write 'com.flexibits.cardhop.mac' AllowDialingLocalNumbers -bool true
# hide window after actions
defaults write com.flexibits.cardhop.mac HideWindowAfterAction -bool YES
# center the window
frame=$(defaults read 'com.flexibits.cardhop.mac' 'NSWindow Frame Main Window')
if [[ -z "${frame}" ]]; then
	open -a "Cardhop"
	sleep 2
	open -b "${TERMID}"
	killall "Cardhop"
fi
align_window 'com.flexibits.cardhop.mac' 'NSWindow Frame Main Window'
