#!/bin/bash

# [✓] Look up & data detectors: tap with three fingers
defaults write NSGlobalDomain "com.apple.trackpad.forceClick" -bool false
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerTapGesture" -int 2
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerTapGesture" -int 2
# [✓] Tap to click
defaults write "com.apple.AppleMultitouchTrackpad" "Clicking" -bool true
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" -bool true
# also for login screen
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int 1
# [ ] Scroll direction: Natural
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool false
# Swipe between pages: swipe with three fingers
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
defaults write "com.apple.AppleMultitouchTrackpad" TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write "com.apple.AppleMultitouchTrackpad" TrackpadThreeFingerVertSwipeGesture -int 1
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" TrackpadThreeFingerVertSwipeGesture -int 1
# [ ] Swipe between full-screen apps
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadFourFingerHorizSwipeGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFourFingerHorizSwipeGesture" -int 0
# [ ] Notification Center
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" -int 0
# [ ] Mission Control
# [ ] App Exposé
defaults write "com.apple.dock" "showMissionControlGestureEnabled" -bool false
defaults write "com.apple.dock" "showAppExposeGestureEnabled" -bool false
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadFourFingerVertSwipeGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFourFingerVertSwipeGesture" -int 0
# [ ] Launchpad
# [ ] Show Desktop
defaults write "com.apple.dock" "showLaunchpadGestureEnabled" -bool false
defaults write "com.apple.dock" "showDesktopGestureEnabled" -bool false
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadFourFingerPinchGesture" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadFiveFingerPinchGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFourFingerPinchGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFiveFingerPinchGesture" -int 0
