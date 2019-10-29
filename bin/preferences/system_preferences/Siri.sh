#!/bin/bash

# Enable Ask Siri
defaults write "com.apple.assistant.support" "Assistant Enabled" -bool true
# Ask Siri in U.S. English (Female)
defaults write "com.apple.Siri.SiriTodayExtension" AppleLanguages -array "en-US"
defaults write "com.apple.SiriNCService" AppleLanguages -array "en-US"
defaults write "com.apple.assistant.backedup" "Output Voice" -dict-add "Language" -string "en-US"
defaults write "com.apple.assistant.backedup" "Output Voice" -dict-add "Gender" -int 2
defaults write "com.apple.assistant.backedup" "Output Voice v3" -dict-add "Language" -string "en-US"
defaults write "com.apple.assistant.backedup" "Output Voice v3" -dict-add "Gender" -int 2
defaults write "com.apple.assistant.backedup" "Session Language" -string "en-US"
# Keyboard Shortcut: [Off]
defaults write com.apple.Siri HotKeyTag -int 0
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 "<dict><key>enabled</key><false/></dict>"
