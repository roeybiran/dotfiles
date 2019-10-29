#!/bin/bash

# Prefer tabs when opening documents: [Always]
defaults write "NSGlobalDomain" "AppleWindowTabbingMode" -string "always"
# [✓] Automatically hide and show the Dock
defaults write "com.apple.dock" "autohide" -bool true
# Show only open applications in the Dock
defaults write "com.apple.dock" "static-only" -bool true
# Remove the auto-hiding Dock delay
defaults write "com.apple.dock" "autohide-delay" -float 3600
# minimize windows using scale effect
defaults write "com.apple.dock" "mineffect" -string "scale"
