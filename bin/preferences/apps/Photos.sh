#!/bin/bash

defaults write com.apple.CloudPhotosConfiguration "service-preferences-com.apple.photo.icloud.cloudphoto" -dict "CPSPreferenceOnlyKeepThumbnailsKey" -bool true
defaults write com.apple.CloudPhotosConfiguration "com.apple.photo.icloud.cloudphoto" -bool true
defaults write com.apple.CloudPhotosConfiguration "com.apple.photo.icloud.myphotostream" -bool false
defaults write com.apple.Photos IPXDefaultDidPromoteiCloudPhotosInGettingStarted -bool true
defaults write com.apple.Photos IPXDefaultHasBeenLaunched -bool true
defaults write com.apple.Photos IPXDefaultHasChosenToEnableiCloudPhotosInGettingStarted -bool true
