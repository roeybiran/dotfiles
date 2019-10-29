#!/bin/bash

# skip welcome window
defaults write "io.sipapp.Sip-paddle" "kUserdefaultsShowOnboard" -bool false
# show color dock on bottom left
defaults write "io.sipapp.Sip-paddle" "kUserdefaultsColorDockFrame" -string "{{-36, -22}, {86, 467}}"
defaults write "io.sipapp.Sip-paddle" "kUserdefaultsColorDockOrientation" -string vertical
defaults write "io.sipapp.Sip-paddle" "kUserdefaultsColorDockPosition" -string left

# Update automatically
defaults write "io.sipapp.Sip-paddle" "SUAutomaticallyUpdate" -bool true
defaults write "io.sipapp.Sip-paddle" "SUEnableAutomaticChecks" -bool true
defaults write "io.sipapp.Sip-paddle" "SUHasLaunchedBefore" -bool true
