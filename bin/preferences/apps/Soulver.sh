#!/bin/bash

defaults write "app.soulver.mac" SUAutomaticallyUpdate -bool true
defaults write "app.soulver.mac" SUHasLaunchedBefore -bool true
defaults write "app.soulver.mac" SUUpdateRelaunchingMarker -bool false

# [✓] Suppress save warning for unsaved documents
defaults write "com.acqualia.soulver" "SVSuppressSaveAlert" -bool true
# Automatically update
defaults write "com.acqualia.soulver" "SUEnableAutomaticChecks" -bool true
defaults write "com.acqualia.soulver" "SUAutomaticallyUpdate" -bool true
# Surpress the welcome window
defaults write "com.acqualia.soulver" "SVShowWelcomeWindowOnLaunch" -bool false
# Skip tutorial
defaults write "com.acqualia.soulver" "SVTutorialHasRun" -bool true
