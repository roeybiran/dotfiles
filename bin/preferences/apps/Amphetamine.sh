#!/bin/bash

# [ ] Show this window at launch
defaults write "com.if.Amphetamine" "Show Welcome Window" -int 0

# hide in the dock
defaults write "com.if.Amphetamine" "Hide Dock Icon" -int 0

# reduce motion
defaults write "com.if.Amphetamine" "Reduce Motion" -int 1

# Left-click to show menu, right click to start/end session
defaults write "com.if.Amphetamine" "Status Item Click" -int 0

# [✓] Start a new session when Amphetamine launches
defaults write "com.if.Amphetamine" "Start Session At Launch" -int 1

# Remind about an active session every 60 mins
defaults write "com.if.Amphetamine" "Enable Session Notifications" -int 1

# disable notifications' sounds
defaults write "com.if.Amphetamine" "Enable Notification Sound" -int 0

# Icon Style: [Owl]
defaults write "com.if.Amphetamine" "Icon Style" -int 9

# [✓] Show session time remaining in system menu/status bar
defaults write "com.if.Amphetamine" "Show Session Time In Status Bar" -int 1

# [✓] Use 24-hour clock
defaults write "com.if.Amphetamine" "Use 24 Hour Clock" -int 1

# end sessions when fast user switching
defaults write "com.if.Amphetamine" "End Sessions when FUS" -int 1

defaults write "com.if.Amphetamine" "Enable Session Auto End Notifications" -int 0
defaults write "com.if.Amphetamine" "Enable Session Auto Start Notifications" -int 0
defaults write "com.if.Amphetamine" "Enable Session Notifications" -int 0
