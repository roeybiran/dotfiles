#!/bin/bash

sudo /usr/sbin/DevToolsSecurity --enable &>/dev/null
defaults write com.apple.dt.Xcode IBShowingBoundsRectangles -bool true
defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarning -bool true
defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarningTarget -string "IDESuppressStopExecutionWarningTargetValue_Stop"
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
