#!/bin/bash

defaults write com.mrrsoftware.NameChanger SUHasLaunchedBefore -bool true
defaults write com.mrrsoftware.NameChanger hasEULABeenAccepted -bool true
defaults write com.mrrsoftware.NameChanger SUSendProfileInfo -bool false
defaults write com.mrrsoftware.NameChanger SUEnableAutomaticChecks -bool true
defaults write com.mrrsoftware.NameChanger SUCheckAtStartup -bool true
defaults write com.mrrsoftware.NameChanger hideExtensionsByDefault -bool true
defaults write com.mrrsoftware.NameChanger keepHistory -bool false

frame=$(defaults read 'com.mrrsoftware.NameChanger' "NSWindow Frame MainWindow")
if [[ -z "${frame}" ]]; then
	open -a "NameChanger"
	sleep 2
	open -b "${TERMID}"
	killall "NameChanger"
fi

align_window 'com.mrrsoftware.NameChanger' "NSWindow Frame MainWindow"
