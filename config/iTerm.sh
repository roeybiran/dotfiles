#!/bin/sh

# General
# Preferences
# load prefs from a custom directory
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string ~/.iterm2
# save changes automatically
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2
