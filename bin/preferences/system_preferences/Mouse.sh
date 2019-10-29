#!/bin/bash

# [ ] Scroll direction: Natural
defaults write "NSGlobalDomain" "com.apple.swipescrolldirection" -bool false
# [✓] Secondary click: Click on right side
defaults write "com.apple.AppleMultitouchMouse" "MouseButtonMode" -string "TwoButton"
defaults write "com.apple.driver.AppleBluetoothMultitouch.mouse" "MouseButtonMode" -string "TwoButton"
# [✓] Swipe between pages: Swipe left or right with two fingers
defaults write "com.apple.AppleMultitouchMouse" "MouseTwoFingerHorizSwipeGesture" -int 1
defaults write "com.apple.driver.AppleBluetoothMultitouch.mouse" "MouseTwoFingerHorizSwipeGesture" -int 1
# [ ] Mission Control
defaults write "com.apple.AppleMultitouchMouse" "MouseTwoFingerDoubleTapGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.mouse" "MouseTwoFingerDoubleTapGesture" -int 0
