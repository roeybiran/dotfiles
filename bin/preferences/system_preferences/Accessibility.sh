#!/bin/bash

# [✓] Use scroll gesture with modifier keys to zoom: [⌃⌥⌘]
defaults write "com.apple.universalaccess" "closeViewScrollWheelToggle" -bool true
defaults write "com.apple.universalaccess" closeViewScrollWheelModifiersInt -integer 1835008
defaults write "com.apple.AppleMultitouchTrackpad" HIDScrollZoomModifierMask -integer 1835008
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" HIDScrollZoomModifierMask -integer 1835008
# Zoom follows the keyboard focus
defaults write "com.apple.universalaccess" "closeViewZoomFollowsFocus" -bool true

# reduce transparency
defaults write "com.apple.universalaccess" reduceTransparency -bool true

# [✓] Enable dragging [three finger drag]
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" -bool true
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" -bool true

# [✓] Enable Type to Siri
defaults write "com.apple.Siri" "TypeToSiriEnabled" -bool true

# "feature.alternateMouseButtons" -bool false \

# [ ] Zoom
# [ ] VoiceOver
# [ ] Sticky Keys
# [ ] Slow keys
# [ ] Mouse Keys
# [ ] Accessibility Keyboard
# [ ] Invert Display Color
defaults write 'com.apple.universalaccess' 'axShortcutExposedFeatures' -dict \
"feature.displayFilters" -bool false \
"feature.invertDisplayColor" -bool false \
"feature.mouseKeys" -bool false \
"feature.slowKeys" -bool false \
"feature.stickyKeys" -bool false \
"feature.switchControl" -bool false \
"feature.virtualKeyboard" -bool false \
"feature.voiceOver" -bool false \
"feature.zoom" -bool false \
