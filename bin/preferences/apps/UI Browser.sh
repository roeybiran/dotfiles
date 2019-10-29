#!/bin/bash

# Accessibility names: (·) Technical
defaults write "com.pfiddlesoft.uibrowser" "Terminology style" -int 1

# [✓] Copy script to clipboard (·) Always
defaults write "com.pfiddlesoft.uibrowser" "Copy new script to clipboard" -bool true

# [✓] Send script to script editor (·) Always
defaults write "com.pfiddlesoft.uibrowser" "Send new script to script editor" -bool true

# [✓] Include application process
defaults write "com.pfiddlesoft.uibrowser" "New script includes process reference" -bool true

# [ ] Hot keys active
defaults write "com.pfiddlesoft.uibrowser" "Hotkeys active" -bool false

# defaults write com.pfiddlesoft.uibrowser Application hotkey Control down" -bool false
# defaults write com.pfiddlesoft.uibrowser Application hotkey modifier flags" -int 1048576
# defaults write com.pfiddlesoft.uibrowser Systemwide hotkey Control down" -bool false
# defaults write com.pfiddlesoft.uibrowser Systemwide hotkey modifier flags" -int 1048576

# Don‘t show
defaults write "com.pfiddlesoft.uibrowser" "noOptionalAlertsSuppressed" -bool false

# Don‘t show
defaults write "com.pfiddlesoft.uibrowser" "targetApplicationTerminatedAlertSuppressed" -bool true

# Don‘t show the ‘UI Element Destroyed‘ pop-up
defaults write "com.pfiddlesoft.uibrowser" "selectedElementDestroyedAlertSuppressed" -bool true

# Don‘t show
defaults write "com.pfiddlesoft.uibrowser" "applescriptWindowOpenAlertSuppressed" -bool true

# skip welcome
defaults write "com.pfiddlesoft.uibrowser" "First run" -bool false

# Send scripts to Script Debugger
defaults write "com.pfiddlesoft.uibrowser" "Use AppleScript URL Protocol" -bool false
defaults write "com.pfiddlesoft.uibrowser" "Use AppleScript default script editor" -bool false
defaults write "com.pfiddlesoft.uibrowser" "Default script editor" -bool true
defaults write "com.pfiddlesoft.uibrowser" "Ignore AppleScript default script editor" -bool true
