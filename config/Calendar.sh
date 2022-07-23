#!/bin/sh

# don't show alternate calenda
defaults write com.apple.iCal CALPrefOverlayCalendarIdentifier -string ""
# show calendar list
defaults write com.apple.iCal CalendarSidebarShown -bool true
# shortcuts
defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Go to Date\\U2026' -string '@$g'
defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Hide Calendar List' -string '@^1'
defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Hide Notifications' -string '@^2'
defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Show Calendar List' -string '@^1'
defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Show Notifications' -string '@^2'
