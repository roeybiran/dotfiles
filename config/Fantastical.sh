#!/bin/sh

defaults write com.flexibits.fantastical2.mac SUEnableAutomaticChecks -bool true
defaults write com.flexibits.fantastical2.mac SUHasLaunchedBefore -bool true
defaults write com.flexibits.fantastical2.mac DidImportFantastical1Defaults -bool true
defaults write com.flexibits.fantastical2.mac FirstRunSetup -bool true

for f in "$HOME/Library/Group Containers/"*".com.flexibits.fantastical2.mac/Library/Preferences/"*".com.flexibits.fantastical2.mac.plist"; do
	defaults write "$f" DarkTheme -int 2
	defaults write "$f" HotKeyEmpty -int 1
	defaults write "$f" RealLightTheme -int 3
	defaults write "$f" StatusItemBadge -string StatusItemStyleDateAndWeekday
done
