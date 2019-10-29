#!/bin/bash

defaults write com.apple.news hasLaunchedBefore -bool true
defaults write com.apple.news "has_passed_new_user_state" -bool true
defaults write com.apple.news "has_user_been_presubscribed" -bool true
defaults write com.apple.news "onboarding_completed" -bool true
defaults write com.apple.news "primary_language" -string en
