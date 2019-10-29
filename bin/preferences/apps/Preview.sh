#!/bin/sh

# Don't start on the last viewed page when opening documents
defaults write com.apple.Preview kPVPDFRememberPageOption -bool false
# Opening for the first time: Show as [Single Page]
defaults write com.apple.Preferences kPVPDFDefaultPageViewModeOption -bool false
defaults write com.apple.Preview kPVPDFDefaultPageViewModeOption -bool true
# Surpress the PDF cropping alert
defaults write com.apple.Preview PVSupressPDFCroppingAlert -bool true
