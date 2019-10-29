#!/bin/bash

# Show scroll bars: (·) Always
defaults write NSGlobalDomain AppleShowScrollBars -string 'Always'
# don't close windows when quitting an app
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
# dark mode: auto
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
