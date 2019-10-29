#!/bin/bash

# don't show the pop up page
defaults write "de.appsolute.MAMP" checkForMampPro -bool false
# start servers on launch
defaults write "de.appsolute.MAMP" startServers -bool true
# don't open WebStart page
defaults write "de.appsolute.MAMP" openPage -bool false
